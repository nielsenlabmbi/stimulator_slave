function playTexture_CheckerBoard
%play checkerboard with inverting polarity
%assumes normalized color

global Mstate screenPTR screenNum daq loopTrial

global Gtxtr Masktxtr   %Created in makeTexture

global Stxtr %Created in makeSyncTexture

global vSyncState %ventilator sync

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

%stimulus size and position - size is rounded up to multiples of block size
bN = deg2pix(P.block_size,'round');
xN=ceil(deg2pix(P.x_size,'round')/bN)*bN;
yN=ceil(deg2pix(P.y_size,'round')/bN)*bN;

stimSrc=[0 0 xN-1 yN-1];
stimDst=CenterRectOnPoint(stimSrc,P.x_pos,P.y_pos);


%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);

%randomize starting polarity (is this useful/necessary?)
light_dark = mod(light_dark + (rand < 0.5),2);

%set blend function
Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

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
    %stop ventilator
    if vSyncState==1
        setVentilator(0);
    end
end
for i = 2:Npreframes
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if P.avg_bit==1 && loopTrial ~=-1
        if i==Npreframes/4
            digWord = 3; %digital 11 - 1st and 2nd high
            DaqDOut(daq, 0, digWord);
        elseif i==3*Npreframes/4
            digWord=1; %go back to only first high
            DaqDOut(daq, 0, digWord);
        end
    end
end


%%%%%Play stimuli%%%%%%%%%%
%initialize polarity
polarity=1;
for i = 1:Nstimframes
    
    %set polarity
    if mod(i,P.t_period)==0
        polarity=3-polarity;
    end
    
    %draw checkerboard
    Screen('DrawTexture', screenPTR, Gtxtr(polarity), stimSrc, stimDst);
    
    %add mask
    Screen('DrawTexture', screenPTR, Masktxtr(1));
    
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    
    %flip
    Screen(screenPTR, 'Flip');
    
    %generate event
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


%%%Play postdelay %%%%
Screen(screenPTR, 'FillRect', P.background) %hack
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1
        digWord = 1;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
        %start ventilator
        if vSyncState==1
            setVentilator(1);
        end
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



