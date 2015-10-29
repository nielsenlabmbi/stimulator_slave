function configureMstate

%configures settings in the main window; this initializes the variables and
%will be overwritten by the master
%accepts:
%  setup: string identifier of setup

global Mstate

Mstate.anim = 'xxxx0';
Mstate.unit = '000';
Mstate.expt = '000';

Mstate.hemi = 'left';
Mstate.screenDist = 60;

%remote host IP address
setup=getMacIP;
if strcmp(setup,'172.30.11.130') %2p
    Mstate.monitor = 'LCD';   
elseif strcmp(setup,'172.30.11.142') %ephys
    Mstate.monitor = 'VSN';
end

    
%'updateMonitor.m' happens in 'screenconfig.m' at startup

Mstate.running = 0;

Mstate.syncSize = 4;  %cm
