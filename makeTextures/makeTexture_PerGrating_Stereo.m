function makeTexture_PerGrating_Stereo

%make periodic grating for stereo (r/l eye) 
%Options for surround/plaid currently commented out and not usable as
%written, may delete later
%this just generates the basic grating and mask, movement and visibility is
%handled in playtexture
%this assumes a normalized color scale from 0 to 1, and only generates b/w
%gratings

global  screenPTR screenNum  

global Gtxtr  Masktxtr Gtxtr2 Masktxtr2  %'play' will use these
load('/home/nielsenlab/Documents/crashLog.mat', 'crashLog')
Gtxtr = [];  
Masktxtr=[];
Gtxtr2= [];
Masktxtr2=[];


%clean up
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

if ~isempty(Masktxtr)
    Screen('Close',Masktxtr);  %First clean up: Get rid of all textures/offscreen windows
end

if ~isempty(Gtxtr2)
    Screen('Close',Gtxtr2);  %First clean up: Get rid of all textures/offscreen windows
end

if ~isempty(Masktxtr2)
    Screen('Close',Masktxtr2);  %First clean up: Get rid of all textures/offscreen windows
end

%get parameters
P = getParamStruct;
screenRes = Screen('Resolution',screenNum);
screenRes2=screenRes;
screenRes2.width=screenRes2.width/2; 

%convert stimulus size to pixel
xN=deg2pix(P.x_size1,'round');
yN=deg2pix(P.y_size1,'round');
% 
% if P.plaid_bit==1 || P.surround_bit==1
%     xN2=deg2pix(P.x_size2,'round');
%     yN2=deg2pix(P.y_size2,'round');
% end

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

    
%create the masks 
Screen('SelectStereoDrawBuffer', screenPTR, 0);

mN=deg2pix(P.mask_radius1,'round');
mask=makeMask(screenRes2,x_pos1,P.y_pos1,xN,yN,mN,P.mask_type1,P.background);
% %we need to invert the mask if this is a surround stimulus
% if P.surround_bit==1 && P.plaid_bit==0
    mask=1-mask;
% end
% 
mask=ones([1920 1080 2]);
Masktxtr(1) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers
crashLog(end+1, 1)={'mask1'};
save('/home/nielsenlab/Documents/crashLog.mat', 'crashLog')

save('/home/nielsenlab/Documents/crashmask.mat', 'mask')

% if P.plaid_bit==1 || P.surround_bit==1
%     mN=deg2pix(P.mask_radius2,'round');
%     mask=makeMask(screenRes,P.x_pos,P.y_pos,xN2,yN2,mN,P.mask_type2,P.background);
%     Masktxtr(2) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers
% end



%generate texture

%stimuli will need to be larger to deal with rotation
stimsize=2*sqrt((P.x_size1/2).^2+(P.y_size1/2).^2); %deg

%add extra so that we can slide the window to generate motion 
stimsize=stimsize+1/P.s_freq1; %deg

%use ceil to make sure that we definitely have enough pixels
stimsizeN=deg2pix(stimsize,'ceil'); %pixel

% if P.plaid_bit==1 || P.surround_bit==1
%     stimsize2=2*sqrt((P.x_size2/2).^2+(P.y_size2/2).^2);
%     stimsize2=stimsize2+1/P.s_freq2;
%     stimsizeN2=deg2pix(stimsize2,'ceil');
% end
% 


%generate first grating
x_ecc=linspace(-stimsize/2,stimsize/2,stimsizeN); %deg
sdom = x_ecc*P.s_freq1*2*pi; %radians
grating = cos(sdom);


if strcmp(P.s_profile1,'square')
    thresh = cos(P.s_duty1*pi);
    grating=sign(grating-thresh);
end
%need to change contrast here if this a center/surround situation (can't
%use the alpha channel like usually)
% if P.surround_bit==1 && P.plaid_bit==0
%     gAmp=min(P.background,1-P.background);
%     grating=P.contrast/100*gAmp*grating+P.background;
% end

Gtxtr(1) = Screen('MakeTexture',screenPTR, grating,[],[],2);
crashLog(end, 2)={'grating1'};
save('/home/nielsenlab/Documents/crashLog.mat', 'crashLog')

%generate second grating (overlapping or surround)
% if P.plaid_bit==1 || P.surround_bit==1
%     x_ecc=linspace(-stimsize2/2,stimsize2/2,stimsizeN2);
%     sdom = x_ecc*P.s_freq2*2*pi; %radians
%     grating = cos(sdom);
% 
%     if strcmp(P.s_profile2,'square')
%         thresh = cos(P.s_duty2*pi);
%         grating=sign(grating-thresh);
%     end
%     Gtxtr(2) = Screen('MakeTexture',screenPTR, grating,[],[],2);
%     
%     
% end
    
    
%Do it again for other side? 
   %get parameters
%screenRes = Screen('Resolution',screenNum);

Screen('SelectStereoDrawBuffer', screenPTR, 1);
crashLog(end, 3)={'switchScreen'};
save('/home/nielsenlab/Documents/crashLog.mat', 'crashLog')

%convert stimulus size to pixel
xN2=deg2pix(P.x_size2,'round');
yN2=deg2pix(P.y_size2,'round');
crashLog(end, 4)={'deg2pix2'};
save('/home/nielsenlab/Documents/crashLog.mat', 'crashLog')

% if P.plaid_bit==1 || P.surround_bit==1
%     xN2=deg2pix(P2.x_size2,'round');
%     yN2=deg2pix(P2.y_size2,'round');
% end


%create the masks 
mN2=deg2pix(P.mask_radius2,'round');
crashLog(end, 5)={'mdeg2pix2'};
save('/home/nielsenlab/Documents/crashLog.mat', 'crashLog')

mask2=makeMask(screenRes2,x_pos2,P.y_pos2,xN2,yN2,mN2,P.mask_type2,P.background);
crashLog(end, 6)={'makemask2'};
save('/home/nielsenlab/Documents/crashLog.mat', 'crashLog')

%we need to invert the mask if this is a surround stimulus
% if P.surround_bit2==1 && P.plaid_bit2==0
   mask2=1-mask2;
% end
% 
save('/home/nielsenlab/Documents/crashmask2.mat', 'mask2')

% Masktxtr2(1) = Screen(screenPTR, 'MakeTexture', mask2,[],[],2);  %need to specify correct mode to allow for floating point numbers
crashLog(end, 7)={'mask2'};
save('/home/nielsenlab/Documents/crashLog.mat', 'crashLog')

% if P2.plaid_bit==1 || P2.surround_bit==1
%     mN=deg2pix(P2.mask_radius2,'round');
%     mask=makeMask(screenRes,P2.x_pos,P.y_pos,xN2,yN2,mN,P2.mask_type2,P2.background);
%     Masktxtr(4) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers
% end



%generate texture

%stimuli will need to be larger to deal with rotation
stimsize_2=2*sqrt((P.x_size2/2).^2+(P.y_size2/2).^2); %deg

%add extra so that we can slide the window to generate motion 
stimsize_2=stimsize_2+1/P.s_freq2; %deg

%use ceil to make sure that we definitely have enough pixels
stimsizeN_2=deg2pix(stimsize_2,'ceil'); %pixel

% if P2.plaid_bit==1 || P2.surround_bit==1
%     stimsize2_2=2*sqrt((P2.x_size2/2).^2+(P2.y_size2/2).^2);
%     stimsize2_2=stimsize2_2+1/P.s_freq2;
%     stimsizeN2_2=deg2pix(stimsize2_2,'ceil');
% end



%generate first grating
x_ecc2=linspace(-stimsize_2/2,stimsize_2/2,stimsizeN_2); %deg
sdom2 = x_ecc2*P.s_freq2*2*pi; %radians
grating2 = cos(sdom2);


if strcmp(P.s_profile2,'square')
    thresh2 = cos(P.s_duty2*pi);
    grating2=sign(grating2-thresh2);
end

%need to change contrast here if this a center/surround situation (can't
% %use the alpha channel like usually)
% if P2.surround_bit==1 && P2.plaid_bit==0
%     gAmp2=min(P2.background,1-P2.background);
%     grating2=P2.contrast/100*gAmp*grating+P2.background;
% end

Gtxtr2(1) = Screen('MakeTexture',screenPTR, grating2,[],[],2);
crashLog(end, 8)={'grating2'};
save('/home/nielsenlab/Documents/crashLog.mat', 'crashLog')

%generate second grating (overlapping or surround)
% if P2.plaid_bit==1 || P2.surround_bit==1
%     x_ecc2=linspace(-stimsize2_2/2,stimsize2_2/2,stimsizeN2_2);
%     sdom2 = x_ecc2*P2.s_freq2*2*pi; %radians
%     grating2 = cos(sdom);
% 
%     if strcmp(P2.s_profile2,'square')
%         thresh2 = cos(P2.s_duty2*pi);
%         grating2=sign(grating2-thresh2);
%     end
%     Gtxtr(4) = Screen('MakeTexture',screenPTR, grating2,[],[],2);
% end








