function playTexture_NoiseBar
%play bar stimulus
%assumes normalized color

global Mstate screenPTR screenNum daq loopTrial

global Gtxtr    %Created in makeTexture

global Masktxtr

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

%stimulus source window for bar
xNbar=deg2pix(P.bar_width,'round');
yNbar=deg2pix(P.bar_length,'round');
barSrc=[0 0 xNbar yNbar];

%stimulus source window for texture - needs to be larger because of
%rotation
stimsize=2*sqrt(2*(P.text_size/2).^2);
xNtext=deg2pix(stimsize,'round');
textDst=[0 0 xNtext xNtext];
textDst=CenterRectOnPoint(textDst,P.x_pos,P.y_pos);


%diplacement per frame in pixels
deltaFrame = deg2pix(P.speed,'none')/fps;   


%get timing information
Npreframes1 = ceil(P.predelay1*screenRes.hz);
Npreframes2 = ceil(P.predelay2*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);


%set background
Screen(screenPTR, 'FillRect', P.background)

%set sync to black 
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');

%Wake up the daq to improve timing later
DaqDOut(daq, 0, 0); 


%%%Play predelay (gray screen) %%%%
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
end
for i = 2:Npreframes1
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end

%%%Play predelay (stationary stimulus) %%%%
%draw texture, centered on screen
textSrc=[0 0 xNtext xNtext];
Screen('DrawTextures', screenPTR,Gtxtr(2),textSrc,textDst,P.ori);
Screen('DrawTexture', screenPTR, Masktxtr(1)); 

%draw bar at offset relative to center (movement will be symmetric around
%center
if P.stim_type>0
    offset=P.speed*P.stim_time/2; %in deg
    disp(offset)
    
    offsetX=deltaFrame*Nstimframes/2*cos(P.ori*pi/180);
    offsetY=deltaFrame*Nstimframes/2*sin(P.ori*pi/180);
    disp(offsetX)

    barDst=CenterRectOnPoint(barSrc,P.x_pos+offsetX,P.y_pos+offsetY);
    Screen('DrawTextures', screenPTR,Gtxtr(1),barSrc,barDst,P.ori);
end

%draw sync
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);

Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
end
for i = 2:Npreframes2
    Screen('DrawTextures', screenPTR,Gtxtr(2),textSrc,textDst,P.ori);
    Screen('DrawTexture', screenPTR, Masktxtr(1)); 
    if P.stim_type>0
        Screen('DrawTextures', screenPTR,Gtxtr(1),barSrc,barDst,P.ori);
    end
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end


%%%%%Play stimuli%%%%%%%%%%
deltaX=0;
deltaY=0;
for i = 1:Nstimframes
    %move texture
    if P.stim_type==1 %only bar moves
        textSrc=[0 0 xNtext xNtext];
    else
        textOffset = (i-1)*deltaFrame;
        textSrc=[textOffset 0 textOffset+xNtext-1 xNtext-1];
    end

    %draw texture
    Screen('DrawTextures', screenPTR,Gtxtr(2),textSrc,textDst,P.ori);
    Screen('DrawTexture', screenPTR, Masktxtr(1));


    %move bar
    if P.stim_type>0
        deltaX=deltaX+deltaFrame*cos(P.ori*pi/180);
        deltaY=deltaY+deltaFrame*sin(P.ori*pi/180);
        barDst=CenterRectOnPoint(barSrc,P.x_pos+offsetX-deltaX,P.y_pos+offsetY-deltaY);
        Screen('DrawTextures', screenPTR,Gtxtr(1),barSrc,barDst,P.ori);
    end
    
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    
    %flip
    Screen(screenPTR, 'Flip');
        
    %generate event
    if loopTrial ~=-1
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



