function playTexture_ImgManual

global  screenPTR  

global Gtxtr IDim  



%call configure file to preset Pstate - we're doing it this way so that we
%don't overwrite Pstate on the master and confuse stimulus modules and
%manual mappers
configPstate_Img;




%define the list of parameters that can be accessed with the mouse and
%their settings
symbList = {'imgbase','imgnr','x_size'};
valdom{1} = 1:6;
valdom{2} = 1:20;
valdom{3} = logspace(log10(2),log10(100),20);


imgbase={'2dRandom','lsRandom','lsNatural','maRandom','obj','faceRhesus'};

%set starting value and symbol 
state.valId = [1 1 3];  %Current index for each value domain
state.symId = 1;  %Current symbol index

%update the parameters - we only need imgbase and imgnr to make the image
updatePstate('imgbase',imgbase{valdom{1}(state.valId(1))});
updatePstate('imgnr',num2str(valdom{2}(state.valId(2))));


%set correct filetype and oath
updatePstate('filetype','png');
updatePstate('imgpath',['manualImg/' imgbase{state.valId(1)}]);


%initialize texture
makeTexture_Img %this populates Gtxtr and IDim

%initialize text
symbol = symbList{state.symId};
val = valdom{state.symId}(state.valId(state.symId));
newtext = [symbol ' ' num2str(val)];


%initialize screen
Screen(screenPTR, 'FillRect', 0)
Screen(screenPTR,'DrawText',newtext,40,30,1);
Screen('Flip', screenPTR);


%start the actual loop
bLast = [0 0 0];
keyIsDown = 0;
while ~keyIsDown
    
    [mx,my,b] = GetMouse(screenPTR);
    b=b(1:3);
    
    db = bLast - b; %'1' is a button release
           
    %%%Case 1: Left Button:  decrease value%%%
    if ~sum(abs([1 0 0]-db))  
        
        symbol = symbList{state.symId};
        
        
        if state.valId(state.symId) > 1
            state.valId(state.symId) = state.valId(state.symId) - 1;
        end       
        
        val = valdom{state.symId}(state.valId(state.symId));
        
        %in these cases we need to regenerate the stimulus
        if ~strcmp(symbol,'x_size')
            if strcmp(symbol,'imgbase')
                valT = imgbase{val};
                updatePstate(symbol,valT);
                updatePstate('imgpath',['manualImg/' valT]);
            else
                updatePstate(symbol,num2str(val)); 
            end
            makeTexture_Img;
        end
            
        
        newtext = [symbol ' ' num2str(val)];
               
        Screen(screenPTR,'DrawText',newtext,40,30,1);
        Screen('Flip', screenPTR);
    end
    
    %%%Case 2: Middle Button:  change parameter%%%
    if ~sum(abs([0 0 1]-db))  % [0 0 1] is the scroll bar in the middle
        
        state.symId = state.symId+1; %update the symbol
        if state.symId > length(symbList)
            state.symId = 1; %unwrap
        end
        symbol = symbList{state.symId};
        val = valdom{state.symId}(state.valId(state.symId));
        
        
        newtext = [symbol ' ' num2str(val)];
        
        
        Screen(screenPTR,'DrawText',newtext,40,30,1);
        Screen('Flip', screenPTR);
    end
    
    %%%Case 3: Right Button: increase value%%%
    if ~sum(abs([0 1 0]-db))  %  [0 1 0]  is right click
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) < length(valdom{state.symId})
            state.valId(state.symId) = state.valId(state.symId) + 1;
        end
      
        val = valdom{state.symId}(state.valId(state.symId));        
        
        %in these cases we need to regenerate the stimulus
        if ~strcmp(symbol,'x_size')
            if strcmp(symbol,'imgbase')
                valT = imgbase{val};
                updatePstate(symbol,valT);
                updatePstate('imgpath',['manualImg/' valT]);
            else
                updatePstate(symbol,num2str(val)); 
            end
            makeTexture_Img;
        end
        
        newtext = [symbol ' ' num2str(val)];
       
        
        Screen(screenPTR,'DrawText',newtext,40,30,1);
        Screen('Flip', screenPTR);
    end
    
    
    x_size=valdom{3}(state.valId(3));    
    xN=deg2pix(x_size,'round');
    yN = round((xN*IDim(1))/IDim(2));
    stimSrc = [0 0 xN-1 yN-1];
    stimDst=CenterRectOnPoint(stimSrc,mx,my);
    
    Screen('DrawTexture', screenPTR, Gtxtr, [], stimDst);
    
    
    %add text
    Screen(screenPTR,'DrawText',newtext,40,30,1);
    xypos = ['x ' num2str(mx) '; y ' num2str(my)];
    Screen(screenPTR,'DrawText',xypos,40,55,1);
    Screen('Flip', screenPTR);
    
    bLast = b;
    
    keyIsDown = KbCheck(-1);
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen(screenPTR, 'FillRect', 0.5)
Screen(screenPTR, 'Flip');


