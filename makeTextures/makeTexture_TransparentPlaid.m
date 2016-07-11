function makeTexture_TransparentPlaid

%this generates transparent plaid stimuli. since we want to be able to
%control the color of the intersection, we can't use the approaches used in
%perGrating, but need to code the full plaid pattern. Assumption: both
%gratings have the same size, position and temporal period, spatial profile is square, 
%and there is only one mask

global screenPTR screenNum    

global Gtxtr Masktxtr    %'playgrating' will use these

Screen('Close')  %First clean up: Get rid of all textures/offscreen windows

%clean up
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end
if ~isempty(Masktxtr)
    Screen('Close',Masktxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];  
Masktxtr=[];


P = getParamStruct;
screenRes = Screen('Resolution',screenNum);

%convert stimulus size to pixel
xN=deg2pix(P.x_size,'round');
yN=deg2pix(P.y_size,'round');


%create the masks 
mN=deg2pix(P.mask_radius,'round');
mask=makeMask(screenRes,P.x_pos,P.y_pos,xN,yN,mN,P.mask_type);
Masktxtr(1) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers


%make grating base - shared
x_ecc = P.x_size/2;
y_ecc = P.y_size/2;
x_ecc = single(linspace(-x_ecc,x_ecc,xN));  %deg
y_ecc = single(linspace(-y_ecc,y_ecc,yN));
[x_ecc, y_ecc] = meshgrid(x_ecc,y_ecc);  %deg

tdom = single(linspace(0,2*pi,P.t_period+1));
tdom = tdom(1:end-1);

%grating base 1
sdom1 = x_ecc*cos(P.ori*pi/180) - y_ecc*sin(P.ori*pi/180);    %deg
sdom1 = sdom1*P.s_freq*2*pi + pi; %radians


%grating base 2
sdom2 = x_ecc*cos(P.ori2*pi/180) - y_ecc*sin(P.ori2*pi/180);    %deg
sdom2 = sdom2*P.s_freq2*2*pi + pi; %radians


%generate individual frames
for i = 1:length(tdom)
    %grating 1
    Im1 = cos(sdom1 - tdom(i));
    thresh = cos(P.s_duty*pi);
    Im1 = sign(Im1-thresh);
    Im1 = Im1*P.contrast/100;
    
    %grating 2
    Im2 = cos(sdom2 - tdom(i));
    thresh = cos(P.s_duty2*pi);
    Im2 = sign(Im2-thresh);
    Im2 = Im2*P.contrast2/100;
    
    %basic plaid
    Im = Im1+Im2; %-2 to 2
    Im = (Im-min(Im(:)))./(max(Im(:))-min(Im(:))); %0 to 1
    
    %now find the minima and change their color
    Im(Im==0)=P.lum_intersect;
   
    %generate texture
    Gtxtr(i) = Screen('MakeTexture',screenPTR, Im,[],[],2);
                
end


