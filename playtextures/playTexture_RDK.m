function playTexture_RDK

%play random dot stimuli

global Mstate screenPTR screenNum loopTrial

global daq  

global Stxtr %Created in makeSyncTexture

global DotFrame %created in makeTexture_RDK


%Wake up the daq:
DaqDOut(daq, 0, 0); %I do this at the beginning because it improves timing on the call to daq below


P = getParamStruct;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

%get sync size and position
syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);
syncSrc = [0 0 syncWX-1 syncWY-1]';
syncDst = [0 0 syncWX-1 syncWY-1]';



%size of dots
sizeDotsPx=deg2pix(P.sizeDots,'round');



%dot color 
r=P.redgun;
g=P.greengun;
b=P.bluegun;

Npreframes = ceil(P.predelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);


%set background
Screen(screenPTR, 'FillRect', P.background)

%set sync to black 
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');

%Wake up the daq to improve timing later
DaqDOut(daq, 0, 0); 


%%%Play predelay %%%%
if ~isempty(DotFrame{1})
    Screen('DrawDots', screenPTR, DotFrame{1}, sizeDotsPx, [r g b],...
        [P.x_pos P.y_pos],P.dotType);
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
end
for i = 2:Npreframes
    if ~isempty(DotFrame{1})
        Screen('DrawDots', screenPTR, DotFrame{1}, sizeDotsPx, [r g b],...
            [P.x_pos P.y_pos],P.dotType);
    end
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end


%%%%%Play stimulus
if ~isempty(DotFrame{1})
    Screen('DrawDots', screenPTR, DotFrame{1}, sizeDotsPx, [r g b],...
        [P.x_pos P.y_pos],P.dotType);
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    digWord = 7;  %toggle 2nd and 3 bit to signal stim on
    DaqDOut(daq, 0, digWord);
end

for i = 2:Nstimframes
    if ~isempty(DotFrame{i})
        Screen('DrawDots', screenPTR, DotFrame{i}, sizeDotsPx, [r g b],...
            [P.x_pos P.y_pos],P.dotType);
    end
        
    if mod(i,10) == 0
        Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    else
        Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    end
    Screen(screenPTR, 'Flip');
    
    if mod(i,10) ==0 && loopTrial ~= -1
        if digWord==7
            digWord=3;
        else
            digWord=7;
        end
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
    if i==i && loopTrial ~= -1
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

if loopTrial ~= -1
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
Screen(screenPTR, 'Flip');

