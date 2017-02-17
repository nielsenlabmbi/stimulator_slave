function playTexture_WarpedGrating
%play checkerboard with inverting polarity
%assumes normalized color

global Mstate screenPTR screenNum daq loopTrial

global Gtxtr Masktxtr   %Created in makeTexture

global Stxtr %Created in makeSyncTexture

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

%stimulus size and position
xN=deg2pix(P.x_size,'round',2);
yN=deg2pix(P.y_size,'round',2);
stimSrc=[0 0 xN-1 yN-1];
stimDst=CenterRectOnPoint(stimSrc,P.x_pos,P.y_pos);

%contrast
ctr=P.contrast/100*0.5;  %full contrast = .5 (grating goes from -0.5 to 0.5, and is added to background of 0.5)


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
if ~isempty(daq)
    DaqDOut(daq, 0, 0);
end

%%%Play predelay %%%%
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1 && ~isempty(daq)
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
end
for i = 2:Npreframes
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end


%%%%%Play stimuli%%%%%%%%%%
Screen(screenPTR, 'FillRect', 0.5) %mask takes care of the rest
count=1;
for i = 1:Nstimframes
    
    %set cycle (need to account for static - tperiod = 1)
    if length(Gtxtr)>1 && mod(i,length(Gtxtr))==1
        count=1;
    end
    
    %plot grating
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
    Screen('DrawTexture', screenPTR, Gtxtr(count), stimSrc, stimDst,[],[],ctr);
    if length(Gtxtr)>1
        count=count+1;
    end
    
    %add mask
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawTexture', screenPTR, Masktxtr);
    
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    
    %flip
    Screen(screenPTR, 'Flip');
    
    %generate event
    if ~isempty(daq)
        if P.use_ch3==1   %indicate cycles using the 3rd channel
            if mod(i-1,P.t_period)==0 && loopTrial ~= -1
                digWord = 7;  %toggle 2nd and 3rd bit high to signal stim on
                DaqDOut(daq, 0, digWord);
            elseif mod(i-1,P.t_period)==10 && loopTrial ~=-1
                digWord=3;
                DaqDOut(daq, 0, digWord);
            end
        else %just signal stimulus on/off
            if i==1 && loopTrial ~= -1
                digWord=3;
                DaqDOut(daq, 0, digWord);
            end
        end
    end
    
end


%%%Play postdelay %%%%
Screen(screenPTR, 'FillRect', P.background) %hack
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1 && ~isempty(daq)
        digWord = 1;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
    end
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');


if loopTrial ~= -1 && ~isempty(daq)
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end


%set sync to black for next stimulus
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
Screen(screenPTR, 'Flip');



