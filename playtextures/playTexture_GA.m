function playTexture_GA

%play closed contour stimuli for V4 GA

global Mstate screenPTR screenPTROff screenNum loopTrial

global  daq  %Created in makeGratingTexture

global Stxtr %Created in makeSyncTexture

global vSyncState %ventilator sync

Pstruct = getParamStruct;

%get stimulus size
screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);

syncSrc = [0 0 syncWX-1 syncWY-1]';
syncDst = [0 0 syncWX-1 syncWY-1]';


Npreframes = ceil(Pstruct.predelay*screenRes.hz);
Nstimframes = ceil(Pstruct.stim_time*screenRes.hz);
Npostframes = ceil(Pstruct.postdelay*screenRes.hz);



%reset screen
Screen(screenPTR, 'FillRect', Pstruct.background)

%Wake up the daq:
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
end

%%%%%Play whats in the buffer (the stimulus)%%%%%%%%%%
Screen('CopyWindow',screenPTROff,screenPTR);
Screen('DrawTextures', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    digWord = 3;  %toggle 2nd bit to signal stim on
    DaqDOut(daq, 0, digWord);
end
for i=2:Nstimframes
    Screen('CopyWindow',screenPTROff,screenPTR);
    Screen('DrawTextures', screenPTR, Stxtr(1),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end


%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1
        digWord = 1;  %toggle 2nd bit to signal stim off
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');

