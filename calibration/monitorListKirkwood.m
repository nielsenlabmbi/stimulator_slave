function monitorPar = monitorListKirkwood(monitorID)

%the long name is used on the master, the short ID on the slave

switch monitorID
        
    case {'Linear','LIN'} %just standard linear lookup table
        
        monitorPar.ID='LIN';
        monitorPar.Name='Linear';
        monitorPar.screenXcm = 54.5;
        monitorPar.screenYcm = 30;
        monitorPar.xpixels = 1920;
        monitorPar.ypixels = 1080;
        monitorPar.LUT='/home/lab/stimulator_slave/calibration/general/linearLut.mat';
        
end
