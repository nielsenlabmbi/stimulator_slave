function makeTexture_SimpleGrating

%only makes simple grating so that it's easier to manipulate grating
%contrast and background luminance independently


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


%create the masks 
mN=deg2pix(P.mask_radius,'round');
mask=makeMask(screenRes,P.x_pos,P.y_pos,xN,yN,mN,P.mask_type,P.background);

Masktxtr(1) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers


%generate texture

%stimuli will need to be larger to deal with rotation
stimsize=2*sqrt((P.x_size/2).^2+(P.y_size/2).^2); %deg

%add extra so that we can slide the window to generate motion 
stimsize=stimsize+1/P.s_freq; %deg

%use ceil to make sure that we definitely have enough pixels
stimsizeN=deg2pix(stimsize,'ceil'); %pixel


%generate first grating
x_ecc=linspace(-stimsize/2,stimsize/2,stimsizeN); %deg
sdom = x_ecc*P.s_freq*2*pi; %radians
grating = cos(sdom);

if strcmp(P.s_profile,'square')
    thresh = cos(P.s_duty*pi);
    grating=sign(grating-thresh);
end


Gtxtr(1) = Screen('MakeTexture',screenPTR, grating,[],[],2);








