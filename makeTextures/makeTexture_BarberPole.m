function makeTexture_BarberPole

%based on periodic grater, but restricted to only one square/rectangular
%grating, with or without a frame around it

global  screenPTR screenNum 

global Gtxtr  Masktxtr   %'play' will use these

%clean up
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

if ~isempty(Masktxtr)
    Screen('Close',Masktxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];  
Masktxtr=[];


%get parameters
P = getParamStruct;
screenRes = Screen('Resolution',screenNum);


%convert stimulus size to pixel
xN=deg2pix(P.x_size,'round');
yN=deg2pix(P.y_size,'round');
fN=deg2pix(P.frame_width,'round');


%create the mask 
mask = 0.5*ones(screenRes.height,screenRes.width,2);

%do we need to add frame?
if P.useFrame
  xran(1) = max(P.x_pos-floor(xN/2)-fN+1,1);
  xran(2) = min(P.x_pos+ceil(xN/2)+fN,screenRes.width);
  yran(1) = max(P.y_pos-floor(yN/2)-fN+1,1);
  yran(2) = min(P.y_pos+ceil(yN/2)+fN,screenRes.height);
  mask(yran(1):yran(2),xran(1):xran(2),1)=1;    
end

%hole in mask for stimulus:
xran(1) = max(P.x_pos-floor(xN/2)+1,1);
xran(2) = min(P.x_pos+ceil(xN/2),screenRes.width);
yran(1) = max(P.y_pos-floor(yN/2)+1,1);
yran(2) = min(P.y_pos+ceil(yN/2),screenRes.height);
maskT=ones(screenRes.height,screenRes.width);
maskT(yran(1):yran(2),xran(1):xran(2))=0;

mask(:,:,2) = maskT;

Masktxtr(1) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers


%generate the grating

stimsize=2*sqrt((P.x_size/2).^2+(P.y_size/2).^2); 
stimsize=stimsize+1/P.s_freq;
stimsizeN=deg2pix(stimsize,'ceil');

x_ecc=linspace(-stimsize/2,stimsize/2,stimsizeN);
sdom = x_ecc*P.s_freq*2*pi; %radians
grating = cos(sdom);


if strcmp(P.s_profile,'square')
    thresh = cos(P.s_duty*pi);
    grating=sign(grating-thresh);
end


Gtxtr(1) = Screen('MakeTexture',screenPTR, grating,[],[],2);

%generate occluders if selected
if P.useOccluder1
    %convert stimulus size to pixel
    xoN=deg2pix(P.o1x_size,'round');
    yoN=deg2pix(P.o1y_size,'round');

    %generate texture
    Im = ones(yoN,xoN,3);
    Gtxtr(2) = Screen(screenPTR, 'MakeTexture',Im,[],[],2);
end

if P.useOccluder2
    %convert stimulus size to pixel
    xoN=deg2pix(P.o2x_size,'round');
    yoN=deg2pix(P.o2y_size,'round');

    %generate texture
    Im = ones(yoN,xoN,3);
    Gtxtr(3) = Screen(screenPTR, 'MakeTexture',Im,[],[],2);
end











