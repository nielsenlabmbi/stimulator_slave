function playTexture_RDK_Stereo

%play random dot stimuli

global Mstate screenPTR screenNum loopTrial

global daq  

global Stxtr %Created in makeSyncTexture

global DotFrame DotFrame2 %created in makeTexture_RDK


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


syncWX2 = round(pixpercmX*Mstate.syncSize);
syncWY2 = round(pixpercmY*Mstate.syncSize);
syncSrc2 = [0 0 syncWX2-1 syncWY2-1]';
syncDst2 = [0 0 syncWX2-1 syncWY2-1]';

%size of dots
sizeDotsPx=deg2pix(P.sizeDots1,'round');

sizeDotsPx2=deg2pix(P.sizeDots2,'round');

dx1=deg2pix(P.dx1, 'round');
dx2=deg2pix(P.dx2, 'round');
dy1=deg2pix(P.dy1, 'round');
dy2=deg2pix(P.dy2, 'round');

xpos1=P.x_pos1+dx1;
xpos2=P.x_pos2+dx2; 
ypos1=P.y_pos1+dy1;
ypos2=P.y_pos2+dy2;

%dot color 
r=P.redgun1;
g=P.greengun1;
b=P.bluegun1;

r2=P.redgun2;
g2=P.greengun2;
b2=P.bluegun2;

Npreframes = ceil(P.predelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);


%set background

Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen(screenPTR, 'FillRect', P.background1)

%set sync to black 
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  

Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen(screenPTR, 'FillRect', P.background2)

%set sync to black 
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc2,syncDst2); 

Screen(screenPTR, 'Flip');

%Wake up the daq to improve timing later
DaqDOut(daq, 0, 0); 


%%%Play predelay %%%%
Screen('SelectStereoDrawBuffer', screenPTR, 0);

if ~isempty(DotFrame{1})
    Screen('DrawDots', screenPTR, DotFrame{1}, sizeDotsPx, [r g b],...
        [xpos1 ypos1],P.dotType1);
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);

Screen('SelectStereoDrawBuffer', screenPTR, 1);
if ~isempty(DotFrame{1})
    Screen('DrawDots', screenPTR, DotFrame{1}, sizeDotsPx2, [r2 g2 b2],...
        [xpos2 ypos2],P.dotType2);
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc2,syncDst2);
Screen(screenPTR, 'Flip');

if loopTrial ~= -1
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
end

for i = 2:Npreframes

    if ~isempty(DotFrame{1})
        if P.StereoDisp==0 | P.StereoDisp==1
    
        Screen('SelectStereoDrawBuffer', screenPTR, 0);

        Screen('DrawDots', screenPTR, DotFrame{1}, sizeDotsPx, [r g b],...
            [xpos1 ypos1],P.dotType1);
        end
    
    
     if P.StereoDisp==0 | P.StereoDisp==2
   Screen('SelectStereoDrawBuffer', screenPTR, 1);
        Screen('DrawDots', screenPTR, DotFrame{1}, sizeDotsPx2, [r2 g2 b2],...
            [xpos2 ypos2],P.dotType2);
     end
    end
    Screen('SelectStereoDrawBuffer', screenPTR, 0);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen('SelectStereoDrawBuffer', screenPTR, 1);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc2,syncDst2);
    Screen(screenPTR, 'Flip');

end

%%%%%Play stimulus

Screen('SelectStereoDrawBuffer', screenPTR, 0);
if P.StereoDisp==0 | P.StereoDisp==1

if ~isempty(DotFrame{1})
    Screen('DrawDots', screenPTR, DotFrame{1}, sizeDotsPx, [r g b],...
        [xpos1 ypos1],P.dotType1);
end
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);

Screen('SelectStereoDrawBuffer', screenPTR, 1);
if P.StereoDisp==0 | P.StereoDisp==2

if ~isempty(DotFrame{1})
    Screen('DrawDots', screenPTR, DotFrame{1}, sizeDotsPx2, [r2 g2 b2],...
        [xpos2 ypos2],P.dotType2);
end
end

Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');

if loopTrial ~= -1
    digWord = 7;  %toggle 2nd and 3 bit to signal stim on
    DaqDOut(daq, 0, digWord);
end

for i = 2:Nstimframes
    
    Screen('SelectStereoDrawBuffer', screenPTR, 0);
if P.StereoDisp==0 | P.StereoDisp==1

    if ~isempty(DotFrame{i})
        Screen('DrawDots', screenPTR, DotFrame{i}, sizeDotsPx, [r g b],...
            [xpos1 ypos1],P.dotType1);
    end
end
        
    if mod(i,10) == 0
        Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    else
        Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    end
    
    Screen('SelectStereoDrawBuffer', screenPTR, 1);
if P.StereoDisp==0 | P.StereoDisp==2

    if ~isempty(DotFrame{i})
        Screen('DrawDots', screenPTR, DotFrame{i}, sizeDotsPx2, [r2 g2 b2],...
            [xpos2 ypos2],P.dotType2);
    end
end
    if mod(i,10) == 0
        Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc2,syncDst2);
    else
        Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc2,syncDst2);
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
        if P.StereoDisp==0 | P.StereoDisp==1
        Screen('SelectStereoDrawBuffer', screenPTR, 0);
        Screen('DrawDots', screenPTR, DotFrame{Nstimframes}, sizeDotsPx, [r g b],...
            [xpos1 ypos1],P.dotType1);
        end
        if P.StereoDisp==0 | P.StereoDisp==2
        Screen('SelectStereoDrawBuffer', screenPTR, 1);
        Screen('DrawDots', screenPTR, DotFrame{Nstimframes}, sizeDotsPx2, [r2 g2 b2],...
            [xpos2 ypos2],P.dotType2);
        end
    end
    Screen('SelectStereoDrawBuffer', screenPTR, 0);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen('SelectStereoDrawBuffer', screenPTR, 1);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==i && loopTrial ~= -1
        digWord = 1;  %toggle 2nd bit to signal stim off
        DaqDOut(daq, 0, digWord);
    end
end

Screen('SelectStereoDrawBuffer', screenPTR, 0);
if P.StereoDisp==0 | P.StereoDisp==1

if ~isempty(DotFrame{Nstimframes})
    Screen('DrawDots', screenPTR, DotFrame{Nstimframes}, sizeDotsPx, [r g b],...
        [xpos1 ypos1],P.dotType1);
end
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);

Screen('SelectStereoDrawBuffer', screenPTR, 1);
if P.StereoDisp==0 | P.StereoDisp==2

if ~isempty(DotFrame{Nstimframes})
    Screen('DrawDots', screenPTR, DotFrame{Nstimframes}, sizeDotsPx2, [r2 g2 b2],...
        [xpos2 ypos2],P.dotType2);
end
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc2,syncDst2);

Screen(screenPTR, 'Flip');

if loopTrial ~= -1
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc2,syncDst2);
Screen(screenPTR, 'Flip');

