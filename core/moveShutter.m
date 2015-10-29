function moveShutter(eye,pos)

%set the channel corresponding to the selected eye to high or low
%accepts:
%   eye: shutter number
%   pos: high or low (open or closed)
%returns:
%   changes in global variable daqPort1state

global daq daqPort1state

daqPort1state=bitset(daqPort1state,eye,1-pos);


DaqDOut(daq, 1, daqPort1state);