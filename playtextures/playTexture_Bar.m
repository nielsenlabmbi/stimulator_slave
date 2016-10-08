function playTexture_Bar
%play bar stimulus
%assumes normalized color

global Mstate screenPTR screenNum daq loopTrial

global Gtxtr    %Created in makeTexture

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
xN=deg2pix(P.x_size,'round');
yN=deg2pix(P.y_size,'round');
stimSrc=[0 0 xN yN];

%diplacement per frame in pixels
deltaFrame = deg2pix(P.speed,'none')/fps;   
max_delta = deg2pix(P.max_posdelta,'round');

%initial offset
offsetX=deg2pix(P.offset,'round')*cos(P.ori*pi/180);
offsetY=deg2pix(P.offset,'round')*sin(P.ori*pi/180);

%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);


%set background
Screen(screenPTR, 'FillRect', P.background)

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


%%%%%Play stimuli%%%%%%%%%%
for i = 1:Nstimframes
    
    %get stimulus location - bar drifts from start position (x_pos, y_pos)
    %to a maximum of max_delta, then relocates to the starting position
    if i==1
        deltaX=0;
        deltaY=0;
    else
        deltaX=deltaX+deltaFrame*cos(P.ori*pi/180);
        deltaY=deltaY+deltaFrame*sin(P.ori*pi/180);
        if sqrt(deltaX.^2+deltaY.^2)>max_delta
            deltaX=0;
            deltaY=0;
        end
    end  
    stimDst=CenterRectOnPoint(stimSrc,P.x_pos+offsetX-deltaX,P.y_pos+offsetY-deltaY);
   
    %draw bar
    Screen('DrawTextures', screenPTR,Gtxtr,stimSrc,stimDst,P.ori);
    
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    
    %flip
    Screen(screenPTR, 'Flip');
        
    %generate event
    if loopTrial ~=-1
        if (deltaX==0 && deltaY==0)
            digWord = 7;  %toggle 2nd and 3rd bit high to signal stim on
            DaqDOut(daq, 0, digWord);
        else
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
Screen(screenPTR, 'Flip');


if loopTrial ~= -1
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end


%set sync to black for next stimulus
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');



