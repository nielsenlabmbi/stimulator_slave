% connect to functionGenerator on the Arduino (Adafruit Feather M4 Express, SAMD51)

function funcGenConnect

global funcGen


% setup serial port 
BaudRate = 1000000;

if ~isfield(funcGen,'port')
    % get a list of serial ports 
    allPorts = serialportlist;
    numPorts = size(allPorts, 2);

    for n = 1 : numPorts
        pname = allPorts(n);
        ndx = regexp(pname, 'ACM');      % on ubuntu, the M4 is /dev/ttyACMx

        if ~isempty(ndx)
            break;
        end     
    end

    %fprintf('\npname = %s\n', pname);
    funcGen.port = serialport(pname, BaudRate);
end

% the serial command processor is looking for both
configureTerminator(funcGen.port,"CR/LF");   % CRUCIAL !!

% processing messages from the arduino?
% maybe not needed ... it's only debug type stuff now
configureCallback(funcGen.port, "terminator", @processIncoming);

%add a couple of general parameters for the function generator
funcGen.MinAmp = 0.1;
funcGen.MaxAmp = 10.0;
funcGen.DacRes = 1; % (3.3 / 4096);    % DAC resolution: range = 3.3 V, over 12-bits
funcGen.cmdFormatStr = '!Set %d %s %0.2f %0.2f %0.2f %0.2f';  % length limited, no extra whitespace 
funcGen.startStr = '!Start';
funcGen.stopStr = '!Stop';

disp('Function generator connected');
