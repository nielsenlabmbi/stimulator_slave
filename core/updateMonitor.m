function updateMonitor


global Mstate screenPTR setupDefault


%set basic monitor parameters for deg to pixel conversion
monitorPar=feval(setupDefault.monitorList,Mstate.monitor);


Mstate.screenXcm=monitorPar.screenXcm;
Mstate.screenYcm = monitorPar.screenYcm;

%load calibration
load(monitorPar.LUT,'bufLUT');
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('LoadNormalizedGammaTable', screenPTR, bufLUT);  %gamma LUT
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('LoadNormalizedGammaTable', screenPTR, bufLUT);  %gamma LUT



