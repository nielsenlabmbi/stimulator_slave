function makeTexture_WarpedGrating

%generate a grating that takes into account changes in distance from eye
%for a large screen

global Mstate screenPTR screenNum 

global Gtxtr Masktxtr   %'playgrating' will use these


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


%Determine stimulus size in pixel, assuming (in contrast to usual) a projection of spherical 
%coordinates onto the flat screen
xN=deg2pix(P.x_size,'round',2); %pixel
yN=deg2pix(P.y_size,'round',2); %pixel

    
%create the mask
mN=deg2pix(P.mask_radius,'round',2);
mask=makeMask(screenRes,P.x_pos,P.y_pos,xN,yN,mN,P.mask_type);
Masktxtr(1) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers


%generate grid for screen locatoin
x_ecc = tan(P.x_size/2*pi/180)*Mstate.screenDist;  %cm
y_ecc = tan(P.y_size/2*pi/180)*Mstate.screenDist;  %cm
x_ecc = linspace(-x_ecc,x_ecc,xN); 
y_ecc = linspace(-y_ecc,y_ecc,yN);
[x_ecc,y_ecc] = meshgrid(x_ecc,y_ecc);
       
%Change location of perpendicular bisector relative to stimulus center
x_ecc = x_ecc-P.dx_perpbis; 
y_ecc = y_ecc-P.dy_perpbis; 

%first apply correction for monitor tilt
%Apply tilt to y/z dimensions: rotation around x axis (top vs bottom of screen) 
z_ecc = Mstate.screenDist*ones(size(x_ecc));  %dimension perpendicular to screen, cm
y_eccT = y_ecc*cos(P.tilt_alt*pi/180) - z_ecc*sin(P.tilt_alt*pi/180);
z_eccT = y_ecc*sin(P.tilt_alt*pi/180) + z_ecc*cos(P.tilt_alt*pi/180);

%Apply tilt to x/z direction: rotation around y axis (left vs right side of screen)  
x_eccR = x_ecc*cos(P.tilt_az*pi/180) - z_eccT*sin(P.tilt_az*pi/180);
z_eccR = x_ecc*sin(P.tilt_az*pi/180) + z_eccT*cos(P.tilt_az*pi/180);

%Compute grating in spherical coordinates
switch P.altazimuth
    case 'altitude'      
           
        %orientation is represented by rotating a grating around the z-axis
        %(connecting monitor to screen)
        x_eccO = x_eccR*cos(P.ori*pi/180) - y_eccT*sin(P.ori*pi/180); 
        y_eccO = x_eccR*sin(P.ori*pi/180) + y_eccT*cos(P.ori*pi/180); 
        
        %computation altitude angle
        sdom = asin(y_eccO./sqrt(x_eccO.^2 + y_eccO.^2 + z_eccR.^2))*180/pi; %deg

    case 'azimuth'      
        
        %change orientation (we don't need the transformed y for the rest)
        x_eccO = x_eccR*cos(P.ori*pi/180) - y_eccT*sin(P.ori*pi/180); 
        
        %computation of azimuth angle
        sdom = atan(x_eccO./z_eccR)*180/pi; %deg
end

sdom = sdom*P.s_freq*2*pi; %radians

%compute shift of grating per frame
tdom = linspace(0,2*pi,P.t_period+1);
tdom = tdom(1:end-1);

%now loop through frames
for i = 1:length(tdom)
        
    grating = cos(sdom - tdom(i)-P.phase*pi/180);
  
    if strcmp(P.s_profile,'square')
        thresh = cos(P.s_duty*pi);
        grating=sign(grating-thresh);
    end
    
    Gtxtr(i) = Screen(screenPTR,'MakeTexture', grating,[],[],2);
    
end


