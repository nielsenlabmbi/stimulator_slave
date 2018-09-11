function playTexture_TestTrial
%play testtrial stimulus
%assumes normalized color

global Mstate screenPTR screenNum daq loopTrial

global Gtxtr    %Created in makeTexture

global Stxtr %Created in makeSyncTexture


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

%stimulus source window (destination happens below to incorporate movement)
xN=deg2pix(P.x_size,'round');
yN=deg2pix(P.y_size,'round');
stimSrc=[0 0 xN yN];

%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);

%Wake up the daq to improve timing later
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


%%%%%Play stimuli%%%%%%%%%%
for i = 1:Nstimframes
      
    stimDst=CenterRectOnPoint(stimSrc,P.x_pos,P.y_pos);
    %draw 
    Screen('DrawTexture', screenPTR, Gtxtr, stimSrc, stimDst);
    
    %add mask
    if ~strcmp(P.mask_type,'none')
        Screen('DrawTexture', screenPTR, Masktxtr(1));
    end
    
   
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    
    %flip
    Screen(screenPTR, 'Flip');
    
    %generate event
    if P.use_ch3==1   %indicate cycles using the 3rd channel
        if mod(i-1,P.t_period)==0 && loopTrial ~= -1
            digWord = 7;  %toggle 2nd and 3rd bit high to signal stim on
            DaqDOut(daq, 0, digWord);
        elseif mod(i-1,P.t_period)==10 && loopTrial ~=-1
            digWord=3;
            DaqDOut(daq, 0, digWord);
        end
    else %just signal stimulus on/off
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
        digWord = 1;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
    end
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
%add sync
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');


if loopTrial ~= -1
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end

    %draw TestTrial
    Screen('DrawTextures', screenPTR,Gtxtr,stimSrc,stimDst);