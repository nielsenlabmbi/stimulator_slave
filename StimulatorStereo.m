function StimulatorStereo

global stereoFlag

%prepares the setup
getSetup;


Priority(5);  %Make sure priority is set to "real-time"  

% priorityLevel=MaxPriority(w);
% Priority(priorityLevel);

stereoFlag=1; %need this for calls to configurePstate
mList=moduleListStereo;
configurePstate(mList{1}{1}) %Use grater as the default when opening
configureMstate;

configCom_tcp; %configures communication to master

configSync; %configures TTL device

screenconfigStereo; %configures psychtoolbox

