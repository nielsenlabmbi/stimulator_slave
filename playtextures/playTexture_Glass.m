function playTexture_Glass

%play Glass dot stimuli
%edited 9/29/16 by Cynthia Steinhardt

global Mstate screenPTR screenNum loopTrial

global daq  

global Stxtr %Created in makeSyncTexture

global DotPos %created in makeTexture_Glass


%Wake up the daq:
DaqDOut(daq, 0, 0); %I do this at the beginning because it improves timing on the call to daq below


P = getParamStruct;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;
fps=screenRes.hz;      % frames per second
%get sync size and position
syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);
syncSrc = [0 0 syncWX-1 syncWY-1]';
syncDst = [0 0 syncWX-1 syncWY-1]';

%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);

%set background
Screen(screenPTR, 'FillRect',  P.background)

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
end
for i = 2:Npreframes
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end

%size of dots
sizeDotsPx=deg2pix(P.dotSizes,'round');

%dot color 
r=P.redgun;
g=P.greengun;
b=P.bluegun;

%%%%%Play stimulus
for i = 1:Nstimframes
    if P.dotType == 0,
Screen('DrawDots', screenPTR, DotPos, sizeDotsPx, [r g b],...
        [P.x_pos P.y_pos],4);
    else
    Screen('DrawDots', screenPTR, DotPos, sizeDotsPx, [r g b],...
        [P.x_pos P.y_pos],1);
    end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');

if loopTrial ~= -1
    digWord = 3;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
end

end

%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==i && loopTrial ~= -1
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

