%disconnect zaber stages

function zaberDisconnect
import zaber.motion.Library;
import zaber.motion.ascii.Connection;

global zaber

if ~isempty(fieldnames(zaber))
    zaber.connection.close();
    fprintf('Closed connection to zaber stages\n');
    
    zaber=struct;
end