function makeTexture_Adapt

%make gratings for adaptation paradigm. first grating will oscillate back
%and forth along one axis of movement for adaptation, the other grating is used to measure
%tuning curves
%this just generates the basic grating and mask, movement is handled in playtexture
%this assumes a normalized color scale from 0 to 1, and only generates b/w
%gratings

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

xN2=deg2pix(P.x_size2,'round');
yN2=deg2pix(P.y_size2,'round');


%create the masks 
mN=deg2pix(P.mask_radius,'round');
mask=makeMask(screenRes,P.x_pos,P.y_pos,xN,yN,mN,P.mask_type);
Masktxtr(1) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers

mN=deg2pix(P.mask_radius2,'round');
mask=makeMask(screenRes,P.x_pos,P.y_pos,xN2,yN2,mN,P.mask_type2);
Masktxtr(2) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers


%generate texture

%stimulus size (see makeTexture_PerGrating for comments on these
%parameters)
stimsize=2*sqrt((P.x_size/2).^2+(P.y_size/2).^2);
stimsize=stimsize+1/P.s_freq;
stimsizeN=deg2pix(stimsize,'ceil');

stimsize2=2*sqrt((P.x_size2/2).^2+(P.y_size2/2).^2);
stimsize2=stimsize2+1/P.s_freq2;
stimsizeN2=deg2pix(stimsize2,'ceil');


%generate first grating
x_ecc=linspace(-stimsize/2,stimsize/2,stimsizeN);
sdom = x_ecc*P.s_freq*2*pi; %radians
grating = cos(sdom);

if strcmp(P.s_profile,'square')
    thresh = cos(P.s_duty*pi);
    grating=sign(grating-thresh);
end

Gtxtr(1) = Screen('MakeTexture',screenPTR, grating,[],[],2);

x_ecc=linspace(-stimsize2/2,stimsize2/2,stimsizeN2);
sdom = x_ecc*P.s_freq2*2*pi; %radians
grating = cos(sdom);

if strcmp(P.s_profile2,'square')
    thresh = cos(P.s_duty2*pi);
    grating=sign(grating-thresh);
end
Gtxtr(2) = Screen('MakeTexture',screenPTR, grating,[],[],2);









