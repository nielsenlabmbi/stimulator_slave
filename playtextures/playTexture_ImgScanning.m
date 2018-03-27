function playTexture_ImgScanning
    global Mstate screenPTR screenNum IDim params

    global Gtxtr daq loopTrial

    global Stxtr

    P = getParamStruct;
    [pos,finalPos] = getDispDrift(params);

    screenRes = Screen('Resolution',screenNum);
    pixpercmX = screenRes.width/Mstate.screenXcm;
    pixpercmY = screenRes.height/Mstate.screenYcm;

    syncWX = round(pixpercmX*Mstate.syncSize);
    syncWY = round(pixpercmY*Mstate.syncSize);

    syncSrc = [0 0 syncWX-1 syncWY-1]';
    syncDst = [0 0 syncWX-1 syncWY-1]';

    % full imags as is
    stimSrc=[0 0 IDim(2)-1 IDim(1)-1];
    stimDstT = [0 0 IDim(2)-1 IDim(1)-1];

    % displacement as per image number
    xDisp = round(pixpercmX * pos(1,P.shiftID)/10);
    yDisp = round(pixpercmY * pos(2,P.shiftID)/10);

    % number of frames in each epoch
    Npreframes = ceil(P.predelay*screenRes.hz);
    Nstimframes = ceil(P.stim_time*screenRes.hz);
    Npostframes = ceil(P.postdelay*screenRes.hz);
    
    % find actual final position after correct displacement
    rectCenter = [P.x_pos + xDisp, P.y_pos - yDisp];
    xShifts = rectCenter(1) + round(linspace(-finalPos(1)/20,finalPos(1)/20,Nstimframes) .* pixpercmX);
    yShifts = rectCenter(2) - round(linspace(-finalPos(2)/20,finalPos(2)/20,Nstimframes) .* pixpercmY);

    % translate rect to rf center and add displacement
    stimDst = CenterRectOnPoint(stimDstT,xShifts(1),yShifts(2));

    % background
    Screen(screenPTR, 'FillRect', P.background)

    DaqDOut(daq, 0, 0); 

    %%%%% Play predelay %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

    %%%%% Play whats in the buffer (the stimulus) %%%%%%%%%%
    
    Screen('DrawTexture', screenPTR, Gtxtr, stimSrc, stimDst,-P.ori_inplane);
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if loopTrial ~= -1
        digWord = 3;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
    end
    for i=2:Nstimframes
        stimDst = CenterRectOnPoint(stimDstT,xShifts(i),yShifts(i));
        Screen('DrawTexture', screenPTR, Gtxtr, stimSrc,stimDst,-P.ori_inplane);
        Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
        Screen(screenPTR, 'Flip');
    end


    %%%%% Play postdelay %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:Npostframes-1
        Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
        Screen(screenPTR, 'Flip');
        if i==1 && loopTrial ~= -1
            digWord = 1;  %toggle 2nd bit to signal stim off
            DaqDOut(daq, 0, digWord);
        end
    end
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if loopTrial ~= -1
        DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
    Screen(screenPTR, 'Flip');
end

function vert = rotateImageRect(vert,angle)
    Rz = [  cos(angle)  -sin(angle) 0;...
            sin(angle)   cos(angle) 0;...
            0            0          1];
        
    vert = vert*Rz; 
end
