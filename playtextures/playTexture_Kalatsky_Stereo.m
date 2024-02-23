function playTexture_Kalatsky_Stereo
%play bar stimulus
%assumes normalized color

global Mstate screenPTR screenNum daq loopTrial

global Gtxtr Gtxtr2   %Created in makeTexture

global Stxtr %Created in makeSyncTexture


%get basic parameters
P = getParamStruct;

screenRes = Screen('Resolution',screenNum);
fps=screenRes.hz;      % frames per second
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

%get sync size and position
syncWX = round(pixpercmX*Mstate.syncSize); %syncsize is in cm to be independent of screen distance
syncWY = round(pixpercmY*Mstate.syncSize);
syncSrc = [0 0 syncWX-1 syncWY-1]';
syncDst = [0 0 syncWX-1 syncWY-1]';

%stimulus source window (destination happens below to incorporate movement)
if P.axis1==0
    yN=screenRes.width;
    xN=deg2pix(P.width1,'round');
else
    xN=screenRes.width;
    yN=deg2pix(P.width1,'round');
end
stimSrc=[0 0 xN yN];

if P.axis2==0
    yN2=screenRes.width;
    xN2=deg2pix(P.width2,'round');
else
    xN2=screenRes.width;
    yN2=deg2pix(P.width2,'round');
end
stimSrc2=[0 0 xN2 yN2];

%diplacement per frame in pixels
deltaFrame = P.speed1/fps;   
deltaFrame2 = P.speed2/fps;   

%set orientation based on axis and direction
ori=P.axis1*90 + P.dir1*180;
ori2=P.axis2*90 + P.dir2*180;

%set starting position
if P.axis1==0 %vertical grating, dir=0: moving right to left
    if P.dir1==0
        xpos=screenRes.width-xN/2;
    else
        xpos=xN/2;
    end
    ypos=screenRes.height/2;
else %horizontal grating, dir=0: moving up
    xpos=screenRes.width/2;
    if P.dir1==0
        ypos=screenRes.height-yN/2;
    else
        ypos=yN/2;
    end
end

 if P.axis2==0 %vertical grating, dir=0: moving right to left
    if P.dir2==0
        xpos2=screenRes.width-xN2/2;
    else
        xpos2=xN2/2;
    end
    ypos2=screenRes.height/2;
else %horizontal grating, dir=0: moving up
    xpos2=screenRes.width/2;
    if P.dir2==0
        ypos2=screenRes.height-yN2/2;
    else
        ypos2=yN2/2;
    end
end   

%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);


%set background
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen(screenPTR, 'FillRect', P.background)
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen(screenPTR, 'FillRect', P.background)
%set sync to black 
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');

%Wake up the daq to improve timing later
DaqDOut(daq, 0, 0); 


%%%Play predelay %%%%
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
end
for i = 2:Npreframes
    Screen('SelectStereoDrawBuffer', screenPTR, 0);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen('SelectStereoDrawBuffer', screenPTR, 1);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end


%%%%%Play stimuli%%%%%%%%%%
for i = 1:Nstimframes
    
    %get stimulus location - bar drifts from one edge of the screen to the next, 
    %then relocates to the starting position
    if i>1
        xpos=xpos-deltaFrame*cos(ori*pi/180);
        ypos=ypos-deltaFrame*sin(ori*pi/180);
        
        if xpos<0
            xpos=screenRes.width;
        end
        if xpos>screenRes.width
            xpos=0;
        end
        if ypos<0
            ypos=screenRes.height;
        end
        if ypos>screenRes.height
            ypos=0;
        end
            
        
    end  
    stimDst=CenterRectOnPoint(stimSrc,xpos,ypos);
   if i>1
        xpos2=xpos2-deltaFrame2*cos(ori2*pi/180);
        ypos2=ypos2-deltaFrame2*sin(ori2*pi/180);
        
        if xpos2<0
            xpos2=screenRes.width;
        end
        if xpos2>screenRes.width
            xpos2=0;
        end
        if ypos2<0
            ypos2=screenRes.height;
        end
        if ypos2>screenRes.height
            ypos2=0;
        end
            
        
    end  
    stimDst2=CenterRectOnPoint(stimSrc2,xpos2,ypos2);
    
    if P.StereoDisp==0 | P.StereoDisp==1
    %draw bar
    Screen('SelectStereoDrawBuffer', screenPTR, 0);
    Screen('DrawTextures', screenPTR,Gtxtr,stimSrc,stimDst);
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    end
    if P.StereoDisp==0 | P.StereoDisp==2
    %draw bar
    Screen('SelectStereoDrawBuffer', screenPTR, 1);
    Screen('DrawTextures', screenPTR,Gtxtr2,stimSrc2,stimDst2);
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    %flip
    end
    Screen(screenPTR, 'Flip');
        
    %generate event
    if loopTrial ~=-1
        if (xpos<100 || ypos<100)
            digWord = 3;  %toggle 2nd and 3rd bit high to signal stim on
            DaqDOut(daq, 0, digWord);
        else
            digWord=1;
            DaqDOut(daq, 0, digWord);
        end
    end
end
    

%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen('SelectStereoDrawBuffer', screenPTR, 0);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen('SelectStereoDrawBuffer', screenPTR, 1);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1
        digWord = 1;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
    end
end
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');


if loopTrial ~= -1
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end


%set sync to black for next stimulus
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
Screen(screenPTR, 'Flip');



