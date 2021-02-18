function makeTexture_PerGratingFG

%make periodic grating
%types of stimuli: one grating (plaid_bit=0, surround_bit=0), two overlapping gratings,
%both visible entirely (plaid_bit=1, surround_bit=0), two gratings, one in
%center, one in surround (plaid_bit=0, surround_bit=1); ; plaid_bit==1 and
%surround_bit==1 defaults to plaid
%gratings have to have the same center
%this just generates the basic grating and mask, movement and visibility is
%handled in playtexture
%this assumes a normalized color scale from 0 to 1, and only generates b/w
%gratings
%adds the capability to output a waveform through the function generator in
%synchrony with the grating

global  screenPTR screenNum 

global Gtxtr  Masktxtr   %'play' will use these

global funcGen

%clean up
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

if ~isempty(Masktxtr)
    Screen('Close',Masktxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];  
Masktxtr=[];


%get parameters
P = getParamStruct;
screenRes = Screen('Resolution',screenNum);


%convert stimulus size to pixel
xN=deg2pix(P.x_size,'round');
yN=deg2pix(P.y_size,'round');

if P.plaid_bit==1 || P.surround_bit==1
    xN2=deg2pix(P.x_size2,'round');
    yN2=deg2pix(P.y_size2,'round');
end


%create the masks 
mN=deg2pix(P.mask_radius,'round');
mask=makeMask(screenRes,P.x_pos,P.y_pos,xN,yN,mN,P.mask_type,P.background);

%we need to invert the mask if this is a surround stimulus
if P.surround_bit==1 && P.plaid_bit==0
    mask=1-mask;
end

Masktxtr(1) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers

if P.plaid_bit==1 || P.surround_bit==1
    mN=deg2pix(P.mask_radius2,'round');
    mask=makeMask(screenRes,P.x_pos,P.y_pos,xN2,yN2,mN,P.mask_type2,P.background);
    Masktxtr(2) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers
end



%generate texture

%stimuli will need to be larger to deal with rotation
stimsize=2*sqrt((P.x_size/2).^2+(P.y_size/2).^2); %deg

%add extra so that we can slide the window to generate motion 
stimsize=stimsize+1/P.s_freq; %deg

%use ceil to make sure that we definitely have enough pixels
stimsizeN=deg2pix(stimsize,'ceil'); %pixel

if P.plaid_bit==1 || P.surround_bit==1
    stimsize2=2*sqrt((P.x_size2/2).^2+(P.y_size2/2).^2);
    stimsize2=stimsize2+1/P.s_freq2;
    stimsizeN2=deg2pix(stimsize2,'ceil');
end



%generate first grating
x_ecc=linspace(-stimsize/2,stimsize/2,stimsizeN); %deg
sdom = x_ecc*P.s_freq*2*pi; %radians
grating = cos(sdom);


if strcmp(P.s_profile,'square')
    thresh = cos(P.s_duty*pi);
    grating=sign(grating-thresh);
end

%need to change contrast here if this a center/surround situation (can't
%use the alpha channel like usually)
if P.surround_bit==1 && P.plaid_bit==0
    gAmp=min(P.background,1-P.background);
    grating=P.contrast/100*gAmp*grating+P.background;
end

Gtxtr(1) = Screen('MakeTexture',screenPTR, grating,[],[],2);

%generate second grating (overlapping or surround)
if P.plaid_bit==1 || P.surround_bit==1
    x_ecc=linspace(-stimsize2/2,stimsize2/2,stimsizeN2);
    sdom = x_ecc*P.s_freq2*2*pi; %radians
    grating = cos(sdom);

    if strcmp(P.s_profile2,'square')
        thresh = cos(P.s_duty2*pi);
        grating=sign(grating-thresh);
    end
    Gtxtr(2) = Screen('MakeTexture',screenPTR, grating,[],[],2);
end

%%function generator part
cmdStr1 = funcGen.cmdFormatStr;
cmdStr2 = funcGen.cmdFormatStr;


% convert amplitude to dac bins
amp_C1=max(P.amp_C1,funcGen.MinAmp);
amp_C1=min(amp_C1,funcGen.MaxAmp);
amp_C1 = amp_C1 * funcGen.DacRes;

if P.useCh2==1
    amp_C2=max(P.amp_C2,funcGen.MinAmp);
    amp_C2=min(amp_C2,funcGen.MaxAmp);
    amp_C2 = amp_C2 * funcGen.DacRes;
else
    amp_C2=funcGen.MinAmp; %need to output something to avoid crosstalk
    P.wave_C2='sin';
end

%generate command strings for channel 1
switch P.wave_C1
    case 'sin'
        %sinewave
        cmdStr1 = sprintf(cmdStr1, 1, P.wave_C1, amp_C1, P.freq_C1, P.phase_C1, P.dutyCycle_C1);
    case 'saw'
        %sawtooth
        pC1=P.rampDur1_C1+P.rampDur2_C1;
        cmdStr1 = sprintf(cmdStr1, 1, P.wave_C1, amp_C1, 1/pC1, P.rampDur1_C1, P.rampDur2_C1);
    case 'ramp'
        %ramp and hold
        cmdStr1 = sprintf(cmdStr1, 1, P.wave_C1, amp_C1, P.rampDur1_C1, P.holdDur_C1, P.rampDur2_C1);
    case 'tri'
        %triangle                 
        cmdStr1 = sprintf(cmdStr1, 1, P.wave_C1, amp_C1, P.freq_C1, P.phase_C1, P.dutyCycle_C1);
    case 'sqr'
        %square wave     
        cmdStr1 = sprintf(cmdStr1, 1, P.wave_C1, amp_C1, P.freq_C1, P.phase_C1, P.dutyCycle_C1);
    otherwise
        disp('Unknown waveform for function generator!')
end

%set up ch2 if needed
switch P.wave_C2
    case 'sin'
        %sinewave
        cmdStr2 = sprintf(cmdStr2, 2, P.wave_C2, amp_C2, P.freq_C2, P.phase_C2, P.dutyCycle_C2);
    case 'saw'
        %sawtooth
        pC2=P.rampDur1_C2+P.rampDur2_C2;
        cmdStr2 = sprintf(cmdStr2, 2, P.wave_C2, amp_C2, 1/pC2, P.rampDur1_C2, P.rampDur2_C2);
    case 'ramp'
        %ramp and hold
        cmdStr2 = sprintf(cmdStr2, 2, P.wave_C2, amp_C2, P.rampDur1_C2, P.holdDur_C2, P.rampDur2_C2);
    case 'tri'
        %triangle                 
        cmdStr2 = sprintf(cmdStr2, 2, P.wave_C2, amp_C2, P.freq_C2, P.phase_C2, P.dutyCycle_C2);
    case 'sqr'
        %square wave     
        cmdStr2 = sprintf(cmdStr2, 2, P.wave_C2, amp_C2, P.freq_C2, P.phase_C2, P.dutyCycle_C2);
    otherwise
        disp('Unknown waveform for function generator!')
end

        
% write the command
writeline(funcGen.port, cmdStr1);
pause(0.05);
writeline(funcGen.port, cmdStr2);






