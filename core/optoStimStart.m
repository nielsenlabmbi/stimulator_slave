function optoStimStart(oInfo,pulseType)

%generate a single light pulse or a pulse train in response to a button
%press in the GUI
%accepts:
%   oInfo: pulse parameters
%   type: 1 - single, 2 - train

%requires daqPort1state so as to not interfere with the shutters

global daq daqPort1state

if pulseType==1
    %turn port high
    daqPort1state=bitset(daqPort1state,oInfo.Ch,1);
    DaqDOut(daq, 1, daqPort1state);
    
    wakeup=WaitSecs(oInfo.pulseDur/1000);
    %turn port low
    daqPort1state=bitset(daqPort1state,oInfo.Ch,0);
    DaqDOut(daq, 1, daqPort1state);
end

