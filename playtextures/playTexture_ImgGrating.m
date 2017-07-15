function playTexture_ImgGrating

%play drifting grating made of 3d bars


global Mstate screenPTR screenNum loopTrial IDim

global Gtxtr daq Masktxtr  %Created in makeGratingTexture

global Stxtr %Created in makeSyncTexture

P = getParamStruct;

%get stimulus size
screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);

syncSrc = [0 0 syncWX-1 syncWY-1]';
syncDst = [0 0 syncWX-1 syncWY-1]';

%size change necessary to deal with rotation
stimsizeN=IDim(1)*IDim(2); %IDim(1): width of 1 cycle in pixels, IDim(2) nr cycles
stimDst=[P.x_pos-floor(stimsizeN/2)+1 P.y_pos-floor(stimsizeN/2)+1 ...
    P.x_pos+ceil(stimsizeN/2) P.y_pos+ceil(stimsizeN/2)]';


%speed (IDim(1) has width of 1 cycle)
shiftperframe=IDim(1)/P.t_period;

Npreframes = ceil(P.predelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);


Screen(screenPTR, 'FillRect', P.background)

DaqDOut(daq, 0, 0); 


%%%Play predelay %%%%
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
end
for i = 2:Npreframes
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end


%%%%%Play whats in the buffer (the stimulus)%%%%%%%%%%
for i=1:Nstimframes
    xoffset = mod((i-1)*shiftperframe,IDim(1));
    stimSrc=[xoffset 0 xoffset + stimsizeN-1 stimsizeN-1];

    
    Screen('DrawTexture', screenPTR, Gtxtr, stimSrc, stimDst,P.ori);
    %add mask
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawTexture', screenPTR, Masktxtr);
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    
    
    if ~isempty(daq)
        if i==1 && loopTrial ~= -1
            digWord=3;
            DaqDOut(daq, 0, digWord);
        end
    end
    
end


%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1
        digWord = 1;  %toggle 2nd bit to signal stim off
        DaqDOut(daq, 0, digWord);
    end
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');

