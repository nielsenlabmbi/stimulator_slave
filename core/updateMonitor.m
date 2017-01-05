function updateMonitor


global Mstate screenPTR


switch Mstate.monitor
    
    case 'LCD' %60Hz
        
        Mstate.screenXcm = 54.5; %1920 pixel
        Mstate.screenYcm = 30; %1080 pixel
        
        %need this as long as the setups are different
        if ismac
            load('/Stimulator_slave/calibration/Acer151109/luminance.mat','bufLUT')
        else
            load('/home/nielsenlab/stimulator_slave/calibration/Acer160617/luminance.mat','bufLUT')
        end
        
        
    case 'LIN'   %load a linear table
        
        Mstate.screenXcm = 32.5;
        Mstate.screenYcm = 24;
        
        bufLUT = (0:255)/255;
        bufLUT = bufLUT'*[1 1 1];
        
        
    case 'VSN' % 120Hz
        Mstate.screenXcm = 54.5; %1920 pixel
        Mstate.screenYcm = 30; %1080 pixel
        
        %        load('/Stimulator_slave/calibration/ACER 2-4-13/luminance.mat','bufLUT')
        %         load('/Stimulator_slave/calibration/LCD 5-3-10 PR650/luminance.mat','bufLUT')
        
        if ismac
            load('/Stimulator_slave/calibration/ViewSonic151109/luminance.mat')
        else
            load('/home/nielsenlab/stimulator_slave/calibration/ViewSonic151109/luminance.mat')
        end
        
        
    case 'VPX' %120Hz
        
        Mstate.screenXcm = 52; %1920 pixel
        Mstate.screenYcm = 29.5; %1080 pixel
        
        bufLUT = (0:255)/255;
        bufLUT = bufLUT'*[1 1 1];
        bufLUT=bufLUT.^(1/2.2);
        
    case 'LG43'
        
        Mstate.screenXcm = 94.3; %1920 pixel
        Mstate.screenYcm = 53.4; %1080 pixel
        
        if ismac
            load('/Stimulator_slave/calibration/LG43_161013/luminance.mat')
        else
            load('/home/nielsenlab/stimulator_slave/calibration/LG43_161013/luminance.mat')
        end
        
end


Screen('LoadNormalizedGammaTable', screenPTR, bufLUT);  %gamma LUT

