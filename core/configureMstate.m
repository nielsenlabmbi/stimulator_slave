function configureMstate

%configures settings in the main window; this initializes the variables and
%will be overwritten by the master
%accepts:
%  setup: string identifier of setup

global Mstate setupDefault

Mstate.anim = 'xxxx0';
Mstate.unit = '000';
Mstate.expt = '000';

Mstate.hemi = 'left';
Mstate.screenDist = 60;

%remote host IP address
Mstate.monitor=setupDefault.defaultMonitor;

    
%'updateMonitor.m' happens in 'screenconfig.m' at startup

Mstate.running = 0;

Mstate.syncSize = 4;  %cm
