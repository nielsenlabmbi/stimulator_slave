%connect to zaber stages

function zaberConnect

global zaber

import zaber.motion.Library;
import zaber.motion.ascii.Connection;
%import zaber.motion.Units;
%import zaber.motion.ascii.AxisSettings;
import zaber.motion.ascii.AllAxes;
import zaber.motion.ascii.Axis;

Library.enableDeviceDbStore();

%establish connection
zaber.connection = Connection.openSerialPort('/dev/ttyUSB0');

try
    %find devices
    deviceList = zaber.connection.detectDevices();
    fprintf('Found %d Zaber devices.\n', deviceList.length);
    
    %save devices
    for i=1:length(deviceList)
        zaber.device(i)=deviceList(i);
        zaber.axis(i) = zaber.device(i).getAxis(1);
    end
    
    %move home
    zaber.device(1).getAllAxes().home();
    
catch exception
    zaber.connection.close();
    fprintf('Error connecting to Zaber stages!\n');
    rethrow(exception);
end