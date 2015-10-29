function configSync

%configures the DAQ device used to generate TTL pulses

global daq daqPort1state

daq = DaqDeviceIndex;

if ~isempty(daq)
    
    %port 0 is used for stimulus related TTL pulses
    DaqDConfigPort(daq,0,0);    
    
    DaqDOut(daq, 0, 0); 
    
    %port 1 is used to move the shutter and control the ventilator
    %channel assignment: ch 0 - eye 1; ch 1 - eye 2; ch 3 - eye 3;
    %for port 1, we want to remember settings across trials (only move shutter if necessary)
    daqPort1state = 0; 
    DaqDConfigPort(daq,1,0);    

    DaqDOut(daq, 1, 0);

else
    
    errordlg('Daq device does not appear to be connected');
    
end