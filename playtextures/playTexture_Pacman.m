function playTexture_Pacman
%play bar stimulus
%assumes normalized color

global Mstate screenPTR screenNum daq loopTrial 

global Masktxtr Stxtr DotCoord %Created in makeSyncTexture


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


%%%%%Play stimuli%%%%%%%%%%
for i = 1:Nstimframes
    
    %coloring
    pacColor = [P.redgun P.greengun P.bluegun];
    pacColor2 = [P.redgun P.greengun P.bluegun 1];
        
    if (P.stim_type == 3), %line stimulus
        penWidth = P.lineWidth;
        Screen('FramePoly',screenPTR, pacColor2, [DotCoord(1,:); DotCoord(2,:)]', penWidth);
        
        % Make a base Rect of size of circle to block outline
        baseRect = [0 0 2.1*deg2pix(P.r_size,'round') 2.1*deg2pix(P.r_size,'round')];
        penWidth_circ= 5*penWidth;
        
        % Center the rectangle on the centre of the screen
        centeredRect = CenterRectOnPointd(baseRect, P.x_pos, P.y_pos);
        
        % Set the color of the circle
        circColor = P.background;
        
        % Draw the rect to the screen
        Screen('FrameOval', screenPTR, circColor, centeredRect,penWidth_circ);
    else
        % Cue to tell PTB that the polygon is convex (concave polygons require much
        % more processing)
        if P.sharp == 0,
            isConvex = 0;
        else
            isConvex = 1;
        end
       % Draw the rect to the screen
        Screen('FillPoly', screenPTR, pacColor, [DotCoord(1,:); DotCoord(2,:)]', isConvex);
    end
    
    %add mask
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawTexture', screenPTR, Masktxtr(1)); 

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



