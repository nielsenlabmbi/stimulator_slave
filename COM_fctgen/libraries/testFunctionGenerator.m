% JK 1 July 2020
%   Test drive the functionGenerator on the Arduino (Adafruit Feather M4 Express, SAMD51)
%
%


% Commands:
%   !Set wavename amp freq param3 param4
%   !Start
%   !Stop
%  
%  E.G.  cmdStr = '!Set sin 400 4 0.00 0.00'
% 
% Beware!! The format is inflexible : case matters, 1 space separation and no
% trailing stuff.  
%
% so, premake command strings, including a base format string to be
% used later with sprintf to build the final cmdStr
%     '!Set sin 404 1 0.00 0.00'
startStr = '!Start';
stopStr = '!Stop';
cmdFormatStr = '!Set %s %.0f %.0f %0.2f %0.2f';  % length limited!! 
cmdStr = cmdFormatStr;

% 'const'
BaudRate = 1000000;%  ...  1000000;
MinAmp = 100;
MaxAmp = 1000;

% prot params
blocks = 1;
numTrials = 50;
trialDur = 4; 
iti = 4;
phase = 0;
dutyCycle = 0;
numWaves = 5;   % sin, saw, ramp, tri, sqr

% "parameters"
amps = randi([MinAmp, MaxAmp], numTrials, blocks)';
freqs = randi([1,6], numTrials, 2)';
rampDurs = linspace(0.5, 0.9, numTrials); 
rampDurs = rampDurs(randperm(numTrials));

    
% setup serial port 

if ~exist('port', 'var')
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

    fprintf('\npname = %s\n', pname);
    port = serialport(pname, BaudRate);
end
%  flush(port);


% the serial command processor is looking for both
configureTerminator(port,"CR/LF");   % CRUCIAL !!

% processing messages from the arduino?
% maybe not needed ... it's only debug type stuff now
configureCallback(port, "terminator", @processIncoming);




%%


% the trials
for blockNum = 1 : blocks
     
    for trialNum = 1 : numTrials 
        
        waveSelector = mod(trialNum, numWaves);
        
         if waveSelector == 0
            waveName = 'sin';     
            % use the format string to make the final cmdStr
            cmdStr = sprintf(cmdFormatStr, waveName, amps(blockNum, trialNum), ...
                freqs(blockNum, trialNum), phase, dutyCycle);
           
         elseif waveSelector == 1
            waveName = 'saw';
            sawFreq = freqs(blockNum, trialNum); 
            period = 1 / sawFreq;
            rampDur1 = rampDurs(trialNum);
            rampDur2 = period - rampDur1;
            
            if(rampDur1 >= period)
                rampDur1 = period * .8;
                rampDur2 = period - rampDur1;
                fprintf(2, '\nadjusting sawtooth rampDur1 from %0.2f to %0.2f\n', rampDurs(trialNum), rampDur1);
fprintf(2, 'paused ...');
pause;
            end
            cmdStr = sprintf(cmdFormatStr, waveName, amps(blockNum, trialNum), ...
                sawFreq, rampDur1, rampDur2);
         
         elseif waveSelector == 2
            waveName = 'ramp';            
            holdDur = 0.4;
            
             cmdStr = sprintf(cmdFormatStr, waveName, amps(blockNum, trialNum), ...
                    rampDurs(trialNum), holdDur, rampDurs(trialNum));
                
            
         elseif waveSelector == 3
             waveName = 'tri';
             
             cmdStr = sprintf(cmdFormatStr, waveName, amps(blockNum, trialNum), ...
                    freqs(blockNum, trialNum), phase, dutyCycle);
                
            
         elseif waveSelector == 4
             waveName = 'sqr';
             dutyCycle =  randi([20, 80]);        
             cmdStr = sprintf(cmdFormatStr, waveName, amps(blockNum, trialNum), ...
                    freqs(blockNum, trialNum), phase, dutyCycle);
                
         end        
        
        % finally write the command
        writeline(port, cmdStr);
        fprintf('\nbegin trial %d:\n\tcommand string =  %s \n', trialNum, cmdStr);
        pause(0.2); 
        writeline(port, startStr);
        pause(trialDur);
        writeline(port, stopStr);       
        fprintf('\ntrial %d finished\n', trialNum);
        pause(iti);

    end  % trials
end   % blocks

fprintf('\nProtocol finished\n\n');