function configCom(setup)

%configures UDP communication with master
%accepts:
%  setup: string identifier of setup
%returns:
%  sets global variable comState

global comState

%remote host IP address
setup=getMacIP;
if strcmp(setup,'172.30.11.130') %2p
    rip = '172.30.11.131';  
elseif strcmp(setup,'172.30.11.142') %ephys
    rip = '172.30.11.141'; 
end

% close all open serial port objects on the same port and remove
% the relevant object from the workspace
port=instrfindall('RemoteHost',rip); 
if length(port) > 0; 
    fclose(port); 
    delete(port);
    clear port;
end

% make udp object named 'stim'
comState.serialPortHandle = udp(rip,'RemotePort',9000,'LocalPort',8000);

%For unknown reasons, the output buffer needs to be set to the amount that the input
%buffer needs to be.  For example, we never exptect to send a packet higher
%than 512 bytes, but the receiving seems to want the output buffer to be
%high as well.  Funny things happen if I don't do this.  (For UDP)
set(comState.serialPortHandle, 'InputBufferSize', 1024)
set(comState.serialPortHandle, 'OutputBufferSize', 1024)  %This is necessary for UDP!!!

set(comState.serialPortHandle, 'Datagramterminatemode', 'off')  %things are screwed w/o this


%Establish serial port event callback criterion
comState.serialPortHandle.BytesAvailableFcnMode = 'Terminator';
comState.serialPortHandle.Terminator = '~'; %Magic number to identify request from Stimulus ('c' as a string)

% open and check status 
fopen(comState.serialPortHandle);
stat=get(comState.serialPortHandle, 'Status');
if ~strcmp(stat, 'open')
    disp([' StimConfig: trouble opening port; cannot proceed']);
    comState.serialPortHandle=[];
    out=1;
    return;
end

comState.serialPortHandle.bytesavailablefcn = @Mastercb;  

