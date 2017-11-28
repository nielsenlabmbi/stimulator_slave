function configCom_tcp

%configures communication with the stimulus master

global comState setupDefault


% % close all open udp port objects on the same port and remove
% % the relevant object form the workspace
% port = instrfindall('RemoteHost',setupDefault.slaveIP);
% if ~isempty(port); 
%     fclose(port); 
%     delete(port);
%     clear port;
% end

% this is the port that receives messages from the master
comState.serialPortHandle = tcpip(setupDefault.masterIP, 30000, 'NetworkRole', 'client');
comState.serialPortHandle.BytesAvailableFcnMode = 'Terminator';
comState.serialPortHandle.Terminator = '~';
comState.serialPortHandle.InputBufferSize = 5120;
comState.serialPortHandle.Timeout = 5;
comState.serialPortHandle.BytesAvailableFcn = @Mastercb;  

% this is the port that sends messages to the master
comState.serialPortHandleSender = tcpip(setupDefault.masterIP, 30001, 'NetworkRole', 'server');
comState.serialPortHandleSender.BytesAvailableFcnMode = 'Terminator';
comState.serialPortHandleSender.Terminator = '~';
comState.serialPortHandleSender.OutputBufferSize = 5120;


% open and check status 
fopen(comState.serialPortHandle);
stat=get(comState.serialPortHandle, 'Status');
if ~strcmp(stat, 'open')
    disp('Communication Error: Trouble opening port for slave client.');
    comState.serialPortHandle=[];
    return;
end

pause(2);

% open and check status 
fopen(comState.serialPortHandleSender);
stat=get(comState.serialPortHandleSender, 'Status');
if ~strcmp(stat, 'open')
    disp('Communication Error: Trouble opening port for slave server.');
    comState.serialPortHandleSender=[];
    return;
end



