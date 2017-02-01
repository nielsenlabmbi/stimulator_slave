function bufLUT = GammaCal2(RGB)

% function bufLUT = GammaCal(RGB)
%
% This function does a gamma calibration.
% 
% bufLUT is the gamma correction table and is named so because that is the
% variable name used by our current 2 photon stimulus display code.
%
% RGB column 1 indicates the power of the color channels, RGB column 2
% gives lumiance of the red channel in cd/m2, column 3 is green, column 4
% is blue.
%
% change the imax values if you need to cut off a saturating part of the
% data
%
% Once data is collected, save the output into 'luminance.mat' in a
% directory indicating the monitor used and the datem, e.g. 'VPIXX 050213'
% This directory can be transfered to the machine to display 2 photon
% stimuli. The gamma correction table, bufLUT may also be useful for other
% code for display of stimuli.
%
% This code generates plots of each step to see the monitor measurements
% and its gamma correction.
%
% Created by: Sam Nummela       Date: 050213
% Modified by: Kristina Nielsen  Date: 240315

%plot the data first
figure
plot(RGB(:,1),RGB(:,2),'r-')
hold on
plot(RGB(:,1),RGB(:,3),'g-')
plot(RGB(:,1),RGB(:,4),'b-')



% INVERT THE RGB DATA
cRGB = nan(256,3);

y = interp1(RGB(:,1),RGB(:,2),0:255,'pchip');
%iMax = find(max(y)==y,1,'first');
iMax = 240;
iMin = find(min(y)==y,1,'last');
mR = (y - y(iMin))/y(iMax);
dR = 0:(1/255):1;
for i = 1:256
    cRGB(i,1) = find(min(abs(mR-dR(i)))==abs(mR-dR(i)),1)/256;
end

y = interp1(RGB(:,1),RGB(:,3),0:255,'pchip');
%iMax = find(max(y)==y,1,'first');
iMax = 212;
iMin = find(min(y)==y,1,'last');
mG = (y - y(iMin))/y(iMax);
dG = (0:(1/255):1)';
for i = 1:256
    cRGB(i,2) = find(min(abs(mG-dG(i)))==abs(mG-dG(i)),1)/256;
end

y = interp1(RGB(:,1),RGB(:,4),0:255,'pchip');
%iMax = find(max(y)==y,1,'first');
iMax = 212;
iMin = find(min(y)==y,1,'last');
mB = (y - y(iMin))/y(iMax);
dB = (0:(1/255):1)';
for i = 1:256
    cRGB(i,3) = find(min(abs(mB-dB(i)))==abs(mB-dB(i)),1)/256;
end

figure(2); 
plot(0:(1/255):1,cRGB(:,1),'r');
hold on
plot(0:(1/255):1,cRGB(:,2),'g');
plot(0:(1/255):1,cRGB(:,3),'b');
xlabel('Desired fraction luminance'); ylabel('Fraction channel power needed');
title('Gamma correction for each channel (R, G, & B)');

bufLUT = cRGB;

