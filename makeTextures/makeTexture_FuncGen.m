function makeTexture_FuncGen


%this function sends commands to the
%function generator; commands need to adhere to the following structure

% Commands:
%   !Set chan# wavename amp freq param3 param4
%   !Start
%   !Stop
%  
%  E.G.  cmdStr = '!Set 1 sin 400 4 0.00 0.00'
% 
% Beware!! The format is inflexible : case matters, 1 space separation and no
% trailing stuff.  
%
% so, premake command strings, including a base format string to be
% used later with sprintf to build the final cmdStr
%     '!Set 2 sin 404 1 0.00 0.00'

global funcGen

%get parameters
P = getParamStruct;

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


