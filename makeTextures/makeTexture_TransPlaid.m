function makeTexture_TransPlaid

%this makes transparent plaids similar to the paper by stoner & albright
%both gratings are forced to be square wave and share the same parameters
%intersections between the dark bars are manipulated
%also makes square wave gratings as a comparison

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


%create the general mask 
mN=deg2pix(P.mask_radius,'round');
mask=makeMask(screenRes,P.x_pos,P.y_pos,xN,yN,mN,P.mask_type,0.5);

Masktxtr(1) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers


%generate texture

%stimuli will need to be larger to deal with rotation
stimsize=2*sqrt((P.x_size/2).^2+(P.y_size/2).^2); %deg

%add extra so that we can slide the window to generate motion 
stimsize=stimsize+1/P.s_freq; %deg

%use ceil to make sure that we definitely have enough pixels
stimsizeN=deg2pix(stimsize,'ceil'); %pixel


%generate grating
x_ecc=linspace(-stimsize/2,stimsize/2,stimsizeN); %deg
sdom = x_ecc*P.s_freq*2*pi; %radians
grating = cos(sdom);
thresh = cos(P.s_duty*pi);
grating=sign(grating-thresh);

Gtxtr(1) = Screen('MakeTexture',screenPTR, grating,[],[],2);

%generate grating mask - this sets the alpha channel for the dark bars to 1
%and has a constant value of 1 for the image channel
gtmp=grating<0;
gratingmask = ones([size(gtmp),2]);
gratingmask(:,:,2) = gtmp;
Masktxtr(2) = Screen(screenPTR, 'MakeTexture', gratingmask,[],[],2);

%also need to generate intersection stimulus - single value is sufficient,
%rest happens in playtexture
Gtxtr(2) = Screen(screenPTR, 'MakeTexture', P.lumInter,[],[],2);  %need to specify correct mode to allow for floating point numbers









