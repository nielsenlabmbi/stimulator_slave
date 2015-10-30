function updateMonitor


global Mstate screenPTR 


switch Mstate.monitor
    
    case 'LCD' %60Hz
        
        Mstate.screenXcm = 54.5; %1920 pixel
        Mstate.screenYcm = 30; %1080 pixel
        
%        load('/Stimulator_slave/calibration/ACER 2-4-13/luminance.mat','bufLUT')
%         load('/Stimulator_slave/calibration/LCD 5-3-10 PR650/luminance.mat','bufLUT')
        
        bufLUT = (0:255)/255;
         bufLUT = bufLUT'*[1 1 1];
        
        
    case 'CRT'
        
        %Actual screen width
        %Mstate.screenXcm = 32.5;
        %Mstate.screenYcm = 24;
        
        %Display size
        %Mstate.screenXcm = 30.5;
        Mstate.screenXcm = 29.3;  %to make the pixels square
        Mstate.screenYcm = 22;  
        
        %load('/Matlab_code/calibration_stuff/measurements/CRT 5-18-10 PR650/LUT.mat','bufLUT')
        %load('/Matlab_code/calibration_stuff/measurements/CRT 6-9-10 UDT/LUT.mat','bufLUT')
        
        %This one is only slightly different than the UDT measurement, but
        %occured after I changed the monitor cable, which eliminated the
        %aliasing.
        load('/Matlab_code/calibration_stuff/measurements/CRT 9-12-10 PR701/LUT.mat','bufLUT')
        
    case 'LIN'   %load a linear table
        
        Mstate.screenXcm = 32.5;
        Mstate.screenYcm = 24;        
        
        bufLUT = (0:255)/255;
        bufLUT = bufLUT'*[1 1 1];
        
   case 'TEL'   %load a linear table
        
        Mstate.screenXcm = 121;
        Mstate.screenYcm = 68.3;        
        
        load('/Matlab_code/calibration_stuff/measurements/TELEV 9-29-10/LUT.mat','bufLUT')
   
    case 'VSN' % 120Hz
        Mstate.screenXcm = 54.5; %1920 pixel
        Mstate.screenYcm = 30; %1080 pixel
        
%        load('/Stimulator_slave/calibration/ACER 2-4-13/luminance.mat','bufLUT')
%         load('/Stimulator_slave/calibration/LCD 5-3-10 PR650/luminance.mat','bufLUT')
        load('/Stimulator_slave/calibration/ViewSonic150605/ViewSonic150605.mat')
        
%         bufLUT = (0:255)/255;
%         bufLUT = bufLUT'*[1 1 1];
        
end


Screen('LoadNormalizedGammaTable', screenPTR, bufLUT);  %gamma LUT

