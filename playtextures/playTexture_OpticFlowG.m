function playTexture_OpticFlowG

global Mstate screenPTR screenNum loopTrial

global daq  %Created in makeAngleTexture

global Stxtr %Created in makeSyncTexture

global DotFrame %created in makeRandomDots


P = getParamStruct;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);

syncSrc = [0 0 syncWX-1 syncWY-1]';
syncDst = [0 0 syncWX-1 syncWY-1]';


sizeDotsPx=deg2pix(P.sizeDots,'round');

r=P.redgun;
g=P.greengun;
b=P.bluegun;


Npreframes = ceil(P.predelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);



Screen(screenPTR, 'FillRect', P.background)



%Wake up the daq to improve timing later
if ~isempty(daq)
    DaqDOut(daq, 0, 0);
end

%%%Play predelay - static %%%%
for i=1:Npreframes
    if ~isempty(DotFrame{1})
        Screen('DrawDots', screenPTR, DotFrame{1}, sizeDotsPx, [r g b],...
            [P.x_pos P.y_pos],P.dotType);
    end
    if i==1
        Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
        Screen(screenPTR, 'Flip');
        if loopTrial ~= -1 && ~isempty(daq)
            digWord = 1;  %Make 1st,2nd,3rd bits high
            DaqDOut(daq, 0, digWord);
        end
    else
        Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
        Screen(screenPTR, 'Flip');
    end
end

%%%%%Play whats in the buffer (the stimulus)%%%%%%%%%%
for i=1:Nstimframes
    if ~isempty(DotFrame{i})
        Screen('DrawDots', screenPTR, DotFrame{i}, sizeDotsPx, [r g b],...
            [P.x_pos P.y_pos],P.dotType);
    end
    Screen('DrawTextures', screenPTR, Stxtr(1),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1 && ~isempty(daq)
        digWord = 3;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
    end
end


%%%Play postdelay %%%%
for i = 1:Npostframes-1
    if ~isempty(DotFrame{Nstimframes})
        Screen('DrawDots', screenPTR, DotFrame{Nstimframes}, sizeDotsPx, [r g b],...
            [P.x_pos P.y_pos],P.dotType);
    end
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1 && ~isempty(daq)
        digWord = 1;  %toggle 2nd bit to signal stim off
        DaqDOut(daq, 0, digWord);
    end
end
if ~isempty(DotFrame{Nstimframes})
    Screen('DrawDots', screenPTR, DotFrame{Nstimframes}, sizeDotsPx, [r g b],...
        [P.x_pos P.y_pos],P.dotType);
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');

if loopTrial ~= -1 && ~isempty(daq)
    DaqDOut(daq, 0, 0);  %Make sure 1st bit finishes low
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');

