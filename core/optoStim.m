function optoStim(pulseCh,pulseState)

%turn light on or off

%requires daqPort1state so as to not interfere with the shutters

global daq daqPort1state

daqPort1state=bitset(daqPort1state,pulseCh,pulseState);
disp(daqPort1state)
DaqDOut(daq, 1, daqPort1state);
    
  

