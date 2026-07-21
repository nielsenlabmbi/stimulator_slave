function Stimulator2

global stereoFlag


%prepares the setup
getSetup;


Priority(5);  %Make sure priority is set to "real-time"  

% priorityLevel=MaxPriority(w);
% Priority(priorityLevel);
stereoFlag=0;
mList=moduleListSlave;
configurePstate(mList{1}{1}) %Use grater as the default when opening
configureMstate;

configCom_tcpNew; %configures communication to master

configSync; %configures TTL device

screenconfig; %configures psychtoolbox

