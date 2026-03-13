function makeTexture_PerGrating_Stereo

%make periodic grating for stereo (r/l eye) 
%Options for surround/plaid currently commented out and not usable as
%written, may delete later
%this just generates the basic grating and mask, movement and visibility is
%handled in playtexture
%this assumes a normalized color scale from 0 to 1, and only generates b/w
%gratings

global  screenPTR screenNum  

global Gtxtr   Gtxtr2   %'play' will use these
Gtxtr = [];  
Gtxtr2= [];


%clean up
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

if ~isempty(Gtxtr2)
    Screen('Close',Gtxtr2);  %First clean up: Get rid of all textures/offscreen windows
end


%get parameters
P = getParamStruct;
screenRes = Screen('Resolution',screenNum);
screenRes2=screenRes;
screenRes2.width=screenRes2.width/2; 

%convert stimulus size to pixel
xN=deg2pix(P.x_size1,'round');
yN=deg2pix(P.y_size1,'round');

if P.mirrorXCoord==0
    x_pos1=P.x_pos1;
    x_pos2=P.x_pos2; 
    
elseif P.mirrorXCoord==1
    x_pos1=P.x_pos1;
    x_pos2=1920-P.x_pos1;
   
elseif P.mirrorXCoord==2
    x_pos1=1920-P.x_pos2;
    x_pos2=P.x_pos2; 
end


Screen('SelectStereoDrawBuffer', screenPTR, 0);

%stimuli will need to be larger to deal with rotation
stimsize=2*sqrt((P.x_size1/2).^2+(P.y_size1/2).^2); %deg

%add extra so that we can slide the window to generate motion 
stimsize=stimsize+1/P.s_freq1; %deg

%use ceil to make sure that we definitely have enough pixels
stimsizeN=deg2pix(stimsize,'ceil'); %pixel

%generate first grating
x_ecc=linspace(-stimsize/2,stimsize/2,stimsizeN); %deg
sdom = x_ecc*P.s_freq1*2*pi; %radians
grating = cos(sdom);

if strcmp(P.s_profile1,'square')
    thresh = cos(P.s_duty1*pi);
    grating=sign(grating-thresh);
end

Gtxtr(1) = Screen('MakeTexture',screenPTR, grating,[],[],2);

% second grating
Screen('SelectStereoDrawBuffer', screenPTR, 1);

xN2=deg2pix(P.x_size2,'round');
yN2=deg2pix(P.y_size2,'round');


%generate texture
stimsize_2=2*sqrt((P.x_size2/2).^2+(P.y_size2/2).^2); %deg
stimsize_2=stimsize_2+1/P.s_freq2; %deg
stimsizeN_2=deg2pix(stimsize_2,'ceil'); %pixel

x_ecc2=linspace(-stimsize_2/2,stimsize_2/2,stimsizeN_2); %deg
sdom2 = x_ecc2*P.s_freq2*2*pi; %radians
grating2 = cos(sdom2);

if strcmp(P.s_profile2,'square')
    thresh2 = cos(P.s_duty2*pi);
    grating2=sign(grating2-thresh2);
end


Gtxtr2(1) = Screen('MakeTexture',screenPTR, grating2,[],[],2);








