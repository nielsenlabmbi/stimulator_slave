function setVentilator(state)

%set the channel corresponding to the selected eye to high or low
%accepts:
%   state: start = 1, stop = 0
%returns:
%   changes in global variable daqPort1state

global daq daqPort1state

daqPort1state=bitset(daqPort1state,3,1-state); %TTL high turns the ventilator off


DaqDOut(daq, 1, daqPort1state);