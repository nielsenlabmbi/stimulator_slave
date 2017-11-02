function optoStim(pulseState)

%turn light on or off

%requires daqPort1state so as to not interfere with the shutters

global daq daqPort1state optoInfo

daqPort1state=bitset(daqPort1state,optoInfo.Ch,pulseState);
disp(daqPort1state)
DaqDOut(daq, 1, daqPort1state);
    
  

