function makeSimpleGammaLut

bufLUT = (0:255)/255;
bufLUT = bufLUT'*[1 1 1];
bufLUT=bufLUT.^(1/2.2);
        
save('/home/nielsenlab/stimulator_slave/calibration/general/simpleGammaLut.mat','bufLUT');