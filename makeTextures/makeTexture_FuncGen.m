function makeTexture_FuncGen

%set up stimulation waveform for whisker stimulation

global FuncGenPort

%need to initialize port first if necessary
if isempty(FuncGenPort)
    BaudRate = 1000000;%  ...  1000000;
    
    %find all available ports
    plist=serialportlist('available');
    
    for i=1:length(plist)
        idx=strfind(plist{i},'ACM'); %func gen shows up as ACM
        if ~isempty(idx)
            FuncGenPort = serialport(plist{i}, BaudRate);
            break;
        end
    end
    
    % the serial command processor is looking for both
    configureTerminator(FuncGenPort,"CR/LF");   % CRUCIAL !!
    
    % processing messages from the arduino?
    % maybe not needed ... it's only debug type stuff now
    configureCallback(FuncGenPort, "terminator", @processIncoming);
end

%now make command string - that's all that needs to happen here
cmdFormatStr = '!Set %s %.0f %.0f %0.2f %0.2f';  % length limited!! 

%get parameters
P = getParamStruct;

switch P.waveform
    case 'sin'
        
        cmdStr = sprintf(cmdFormatStr, P.waveform, P.amp,P.freq,P.phase,P.dutyCycle);
        
    case 'tri'
        
        cmdStr = sprintf(cmdFormatStr, P.waveform, P.amp, P.freq, P.phase, P.dutyCycle);
        
    case 'sqr'
        
        cmdStr = sprintf(cmdFormatStr, P.waveform, P.amp, P.freq, P.phase, P.dutyCycle);
        
    case 'saw'
        cmdStr = sprintf(cmdFormatStr, P.waveform, P.amp, P.freq, P.rampDur1, P.rampDur2);
        
    case 'ramp'
        
        cmdStr = sprintf(cmdFormatStr, P.waveform, P.amp, P.rampDur1, P.holdDur, P.rampDur2);
        
end

 writeline(FuncGenPort, cmdStr);


