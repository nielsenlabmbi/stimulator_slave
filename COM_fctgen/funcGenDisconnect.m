%disconnect function generator
function funcGenDisconnect

global funcGen

funcGen=rmfield(funcGen,'port');
