function makeLinearLut

bufLUT = (0:255)/255;
bufLUT = bufLUT'*[1 1 1];

save('/home/nielsenlab/stimulator_slave/calibration/general/linearLut.mat','bufLUT');