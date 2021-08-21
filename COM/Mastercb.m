function Mastercb(obj,event)
%Callback function 'Stimulator' PC

global comState screenPTR loopTrial vSyncState blankFlag optoInfo Mstate


try
    n = get(comState.serialPortHandle,'BytesAvailable');
     
    if n > 0
        inString = fread(comState.serialPortHandle,n);
        inString = char(inString');
    else
        return
    end
    %inString
    %ind = strfind(inString,'8000');
    
    %for ii=1:length(ind)
    %    ind = strfind(inString,'8000');
    %    inString(ind(1):ind(1)+3) = '';
    %end
    
    inString = inString(1:end-1);  %Get rid of the terminator
    disp(['Message received from master: ' inString]);
        
    %parse string
    delims = find(inString == ';');
    
    %msgID contains the type of signal transmitted and is content before
    %first delim
    msgID = inString(1:delims(1)-1); 
    
    %parse parameters accordingly
    if ismember(msgID,{'M','C','S','OP','L','F','FG','ZS'})
        paramstring = inString(delims(1):end); %parameters start immediately after message string
    elseif strcmp(msgID,'B')        
        modID = inString(delims(1)+1:delims(2)-1); %stimulus module follows message string, then trial ID, then param
        loopTrial = str2num(inString(delims(2)+1:delims(3)-1));
        paramstring = inString(delims(3):end); 
    else
        modID = inString(delims(1)+1:delims(2)-1); %second message string followed by parameters
        paramstring = inString(delims(2):end); 
    end
    
    %parse parameters
    delims = find(paramstring == ';');
    
    %react to message
    switch msgID
        
        case 'M'  %Update sent info from "main" window
            
            for i = 1:length(delims)-1
                
                dumstr = paramstring(delims(i)+1:delims(i+1)-1);
                id = find(dumstr == '=');
                psymbol = dumstr(1:id-1);
                pval = dumstr(id+1:end);
                updateMstate(psymbol,pval)
                
            end
            
        case 'P'  %Update sent info from "param" window.
            
            configurePstate(modID)
            for i = 1:length(delims)-1
                dumstr = paramstring(delims(i)+1:delims(i+1)-1);
                id = find(dumstr == '=');
                psymbol = dumstr(1:id-1);
                pval = dumstr(id+1:end);
                updatePstate(psymbol,pval)
            end
            
        case 'B'  %Build stimulus; update looper info and buffer to video card.
            
            for i = 1:length(delims)-1
                dumstr = paramstring(delims(i)+1:delims(i+1)-1);
                id = find(dumstr == '=');
                psymbol = dumstr(1:id-1);
                pval = dumstr(id+1:end);
                updatePstate(psymbol,pval)
                
            end
            
            blankFlag=0;
            makeTexture(modID)
            makeSyncTexture
                        
            
        case 'G'  %Go Stimulus
            
            playstimulus(modID)
            %Use the callback terminator here...
            %disp('test')
            if loopTrial ~= -1
                fwrite(comState.serialPortHandleSender,'nextT~') %running actual experiment
                disp('Message sent to master: nextT');
            else
                fwrite(comState.serialPortHandleSender,'nextS~') %playing sample
                disp('Message sent to master: nextS');
            end
            
        case 'F'  %get refresh rate
                     
            fwrite(comState.serialPortHandleSender,['r' num2str(Mstate.refresh_rate) '~']) %return refresh rate
            disp('Message sent to master: rate');
                      
        case 'MM'  %Go for manual mapper - necessary because the blankflag otherwise remains unset
            
            blankFlag=0;
            playstimulus(modID)
            fwrite(comState.serialPortHandleSender,'nextS~') %playing sample
            
            
        case 'MON'  %Monitor info
            
            %global Mstate
            
            Mstate.monitor = modID;
            updateMonitor
            
        case 'C'  %Close Display
      
            Screen('Close')
            Screen('CloseAll');
            %clear all
            %close all
            Priority(0);         
            
        case 'Q'  %Used by calibration.m at the Master (not part of 'Stimulator')
            
            paramstring = paramstring(2:end);            
            RGB = [str2num(paramstring(1:3)) str2num(paramstring(4:6)) str2num(paramstring(7:9))];
            Screen(screenPTR, 'FillRect', RGB)
            Screen(screenPTR, 'Flip');
            
        case 'S'  %Move shutter
            %disp(paramstring)
            eye = str2num(paramstring(delims(1)+1:delims(2)-1)); %setting of LE shutter
            %disp(eye)
            pos = str2num(paramstring(delims(2)+1:delims(3)-1)); %setting of RE shutter
            moveShutter(eye,pos);
        
        case 'V' %flag to indicate sync ventilator and stim
            vSyncState=str2num(modID);
            
        case 'L' %blanks
            loopTrial=str2num(paramstring(delims(1)+1:delims(2)-1));
            makeSyncTexture
            blankFlag=1;
        
        case 'FG' %connect/disconnect function generator
            status=str2num(paramstring(delims(1)+1:delims(2)-1));
            if status==1
                funcGenConnect;
            else
                funcGenDisconnect;
            end
            
        case 'ZS' %connect/disconnect zaber stages
            status=str2num(paramstring(delims(1)+1:delims(2)-1));
            if status==1
                zaberConnect;
            else
                zaberDisconnect;
            end
            
        case 'OP' %optoInfo parameters
            for i = 1:length(delims)-1
                dumstr = paramstring(delims(i)+1:delims(i+1)-1);
                id = find(dumstr == '=');
                psymbol = dumstr(1:id-1);
                pval = dumstr(id+1:end);
                optoInfo.(psymbol)=str2num(pval);
            end
        
        case 'O' %start pulse or pulse train
            optoStimM(optoInfo,str2num(modID));
            
        case 'TTL' % send a ttl pulse on the daq
            DaqDOut(daq, 0, 1); pause(0.5); DaqDOut(daq, 0, 0);
            
    end
    
    if ~strcmp(msgID,'G')
        fwrite(comState.serialPortHandleSender,'a')  %dummy so that Master knows it finished
        disp('Message sent to master: Acknowledge');
    end
    
    
catch
    
    Screen('CloseAll');
    ShowCursor;
    
    msg = lasterror;
    msg.message
    msg.stack.file
    msg.stack.line
    
    fwrite(comState.serialPortHandleSender,'a')  %dummy so that Master knows it finished
    
end
