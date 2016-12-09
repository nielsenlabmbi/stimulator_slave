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
s=getSetup;
Mstate.monitor=s.defaultMonitor;

    
%'updateMonitor.m' happens in 'screenconfig.m' at startup

Mstate.running = 0;

Mstate.syncSize = 4;  %cm
