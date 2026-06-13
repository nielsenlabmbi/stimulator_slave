function playTexture_Kalatsky
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
heightN=round(sqrt(2*screenRes.width.^2)); %need this to deal with the diagonals
widthN=deg2pix(P.width,'round');
stimSrc=[0 0 widthN heightN];

%diplacement per frame in pixels
deltaFrame = P.speed/fps;   

%set orientation based on axis and direction
switch P.axis
    case 0
        oriB=0;
    case 1
        oriB=90;
    case 2
        oriB=45;
    case 3
        oriB=135;
end

ori=oriB + P.dir*180;


%set starting position
switch P.axis
    case 0 %0
        if P.dir==0
            xpos=screenRes.width-widthN/2;
        else
            xpos=widthN/2;
        end
        ypos=screenRes.height/2;
    case 1 %90
        xpos=screenRes.width/2;
        if P.dir==0
            ypos=screenRes.height-widthN/2;
        else
            ypos=widthN/2;
        end
    case 2 %45
        if P.dir==0
            xpos=screenRes.width-widthN/2;
            ypos=screenRes.height-widthN/2;
        else
            xpos=widthN/2;
            ypos=widthN/2;
        end
    case 3 %135
        if P.dir==0
            xpos=screenRes.width-widthN/2;
            ypos=widthN/2;
        else
            xpos=widthN/2;
            ypos=screenRes.height-widthN/2;
        end

end
    

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
    
    %get stimulus location - bar drifts from one edge of the screen to the next, 
    %then relocates to the starting position
    if i>1
        xpos=xpos-deltaFrame*cos(ori*pi/180);
        ypos=ypos-deltaFrame*sin(ori*pi/180);
        
        %note on wrapping: screen is longer than high, so we won't hit the
        %x limits, just the y limits
        if xpos<0
            xpos=screenRes.width;
        end
        if xpos>screenRes.width
            xpos=0;
        end
        if ypos<0
            ypos=screenRes.height;
            if P.axis==2
                xpos=screenRes.width;
            elseif P.axis==3
                xpos=0;
            end
        end
        if ypos>screenRes.height
            ypos=0;
            if P.axis==2
                xpos=0;
            elseif P.axis==3
                xpos=screenRes.width;
            end
        end
    end  
    stimDst=CenterRectOnPoint(stimSrc,xpos,ypos);
   
    %draw bar
    Screen('DrawTextures', screenPTR,Gtxtr,stimSrc,stimDst,ori);
    
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    
    %flip
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



