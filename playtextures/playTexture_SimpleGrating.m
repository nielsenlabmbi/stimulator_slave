function playTexture_SimpleGrating
%just a single b/w grating

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

%stimulus size and position - this has to be larger than set by the user to
%deal with the rotation
stimsize=2*sqrt((P.x_size/2).^2+(P.y_size/2).^2);
stimsizeN=deg2pix(stimsize,'round');
stimDst=[P.x_pos-floor(stimsizeN/2)+1 P.y_pos-floor(stimsizeN/2)+1 ...
    P.x_pos+ceil(stimsizeN/2) P.y_pos+ceil(stimsizeN/2)]';


%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);


%grating parameters
pixpercycle=deg2pix(1/P.s_freq,'none');
shiftperframe=pixpercycle/P.t_period;

%contrast - 3 settings
switch P.contrast_mode
    case 'contrast'
        %grating is scaled between -1 and 1; we add 0.5 and scale contrast to get to 0 to 1
        ctrBase=P.contrast/100*0.5;
        ctrFrame=repmat(ctrBase,1,Nstimframes);
        offsetLum=0.5;
    case 'lum'
        %offset should be halfway between min and max
        offsetLum=(P.max_lum-P.min_lum)/2+P.min_lum;
        ctrBase=(P.max_lum-P.min_lum)/2;
        ctrFrame=repmat(ctrBase,1,Nstimframes);
    case 'tmod'
        ctr=cos([0:Nstimframes-1]*2*pi/P.tmod_tperiod);
        if strcmp(P.tmod_tprofile,'square')
            ctr=sign(ctr);
        end
        %ctr goes between -1 and 1; scale to go between min and max
        %contrast
        ctrMin=P.tmod_min/100*0.5;
        ctrMax=P.tmod_max/100*0.5;
        ctrFrame=ctrMin+(ctrMax-ctrMin)/2*(1+ctr);
        offsetLum=P.tmod_mean;
    
end

    
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
    digWord =  17;%1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
    %stop ventilator
    if vSyncState==1
        setVentilator(0);
    end
end
for i = 2:Npreframes
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end


%%%%%Play stimuli%%%%%%%%%%
Screen(screenPTR, 'FillRect', offsetLum) %sets the level that the gratings will be added to

for i = 1:Nstimframes
    %Screen(screenPTR, 'FillRect', 0.5)
    %get parameters for grating 1   
    xoffset = mod((i-1)*shiftperframe+P.phase/360*pixpercycle,pixpercycle);
    stimSrc=[xoffset 0 xoffset + stimsizeN-1 stimsizeN-1];
     

    %plot grating; need to simply remove background to allow separate
    %scaling
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
    Screen('DrawTexture', screenPTR, Gtxtr(1), stimSrc, stimDst,P.ori,[],ctrFrame(i));

    %add mask
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawTexture', screenPTR, Masktxtr(1));

    
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    
    %flip
    Screen(screenPTR, 'Flip');
        
    %generate event
    if ~isempty(daq)
        if P.use_ch3==1   %indicate cycles using the 3rd channel
            if mod(i-1,P.t_period)==0 && loopTrial ~= -1
                digWord = 23;%7;  %toggle 2nd and 3rd bit high to signal stim on
                DaqDOut(daq, 0, digWord);
            elseif mod(i-1,P.t_period)==10 && loopTrial ~=-1
                digWord=19; %3;
                DaqDOut(daq, 0, digWord);
            end
        else %just signal stimulus on/off
            if i==1 && loopTrial ~= -1
                digWord=19;%3;
                DaqDOut(daq, 0, digWord);
            end
        end
    end
    
end
    

%%%Play postdelay %%%%
Screen(screenPTR, 'FillRect', P.background) 
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1 && ~isempty(daq)
        digWord = 17;%1;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
        %start ventilator
        if vSyncState==1
            setVentilator(1);
        end
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




