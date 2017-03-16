function updateMonitor


global Mstate screenPTR setupDefault


%set basic monitor parameters for deg to pixel conversion
monitorPar=feval(setupDefault.monitorList,Mstate.monitor);


Mstate.screenXcm=monitorPar.screenXcm;
Mstate.screenYcm = monitorPar.screenYcm;

%load calibration
load(monitorPar.LUT,'bufLUT');

Screen('LoadNormalizedGammaTable', screenPTR, bufLUT);  %gamma LUT

