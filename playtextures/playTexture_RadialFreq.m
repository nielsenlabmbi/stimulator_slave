function playTexture_RadialFreq
%play radial frequency stimulus


global Mstate screenPTR screenNum daq loopTrial

global Gtxtr    %Created in makeTexture

global Stxtr %Created in makeSyncTexture

global vSyncState %ventilator sync

%get basic parameters
P = getParamStruct;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

%get sync size and position
syncWX = round(pixpercmX*Mstate.syncSize); %syncsize is in cm to be independent of screen distance
syncWY = round(pixpercmY*Mstate.syncSize);
syncSrc = [0 0 syncWX-1 syncWY-1]';
syncDst = [0 0 syncWX-1 syncWY-1]';

%stimulus position for each of the gratings
xsize=deg2pix(P.x_size);
ysize=deg2pix(P.y_size);
xgrid=linspace(0,xsize,P.xN+2);  %need to add 2 because linspace will always use the end points of the interval
ygrid=linspace(0,ysize,P.yN+2);
xgrid=round(xgrid(2:end-1)); %get rid of the end points
ygrid=round(ygrid(2:end-1)); %get rid of the end points
[xgrid,ygrid]=meshgrid(xgrid,ygrid);
xgrid=xgrid(:)+P.x_pos;
ygrid=ygrid(:)+P.y_pos;

xstimsize=deg2pix(P.x_stimsize,'round');
ystimsize=deg2pix(P.y_stimsize,'round');

%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);


%set background
Screen(screenPTR, 'FillRect', 0.5)

%set sync to black 
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');

%Wake up the daq to improve timing later
DaqDOut(daq, 0, 0); 


%%%Play predelay %%%%
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
    %stop ventilator
    if vSyncState==1
        setVentilator(0);
    end
end
for i = 2:Npreframes
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if P.avg_bit==1 && loopTrial ~=-1
        if i==Npreframes/4
            digWord = 3; %digital 11 - 1st and 2nd high
            DaqDOut(daq, 0, digWord);
        elseif i==3*Npreframes/4
            digWord=1; %go back to only first high
            DaqDOut(daq, 0, digWord);
        end
    end


end


%%%%%Play stimuli%%%%%%%%%%
for i = 1:Nstimframes
    
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
    
    %add gratings
    for s=1:length(xgrid)
        stimDst=CenterRectOnPoint(
        Screen('DrawTexture', screenPTR, Gtxtr, [], stimDst2,P.ori2,[],ctr2);
    
    %get parameters for grating 1
    
    xoffset = mod((i-1)*shiftperframe+P.phase/360*pixpercycle,pixpercycle);
    stimSrc=[xoffset 0 xoffset + stimsizeN-1 stimsizeN-1];
    

  
    %we plot grating2 first, b/c it is the larger of the 2 in the surround
    %case;set blend function so that the global alpha can scale the contrast
    if P.plaid_bit==1 || P.surround_bit==1
        Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
        Screen('DrawTexture', screenPTR, Gtxtr(2), stimSrc2, stimDst2,P.ori2,[],ctr2);
    
       
        Screen('DrawTexture', screenPTR, Gtxtr(1), stimSrc, stimDst,P.ori,[],ctr);
    end
    
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    
    %flip
    Screen(screenPTR, 'Flip');
        
    %generate event
    if i==1 && loopTrial ~= -1
        digWord=3;
        DaqDOut(daq, 0, digWord);
    end        
end
    

%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1
        digWord = 1;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
        %start ventilator
        if vSyncState==1
            setVentilator(1);
        end
    end
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');


if loopTrial ~= -1
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end


%set sync to black for next stimulus
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');



