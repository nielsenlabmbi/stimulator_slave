function makeTexture_WarpedChecker

%generate a checkerboard that takes into account changes in distance from eye
%for a large screen
%one band of the checkerboard pattern will be shown

global Mstate screenPTR  screenNum

global Gtxtr Masktxtr   %'playgrating' will use these


%clean up
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

if ~isempty(Masktxtr)
    Screen('Close',Masktxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];  


%get parameters
P = getParamStruct;
screenRes = Screen('Resolution',screenNum);


%depending on whether or not the screen is rotated, need to change x and y
if P.rotated==0
    xPx=screenRes.width;
    xCm=Mstate.screenXcm; 
    yPx=screenRes.height;
    yCm=Mstate.screenYcm;
else
    yPx=screenRes.width;
    yCm=Mstate.screenXcm; 
    xPx=screenRes.height;
    xCm=Mstate.screenYcm;
end
    

%Determine stimulus size in pixel, assuming (in contrast to usual) a projection of spherical 
%coordinates onto the flat screen
xN=round(xPx/P.x_zoom); %allow downsampling to speed things up
yN=round(yPx/P.y_zoom); %allow downsampling to speed things up


%get screen size in deg (we need this for spatial frequency computations)
xDeg=2*atan(xCm/(2*Mstate.screenDist))*180/pi;
yDeg=2*atan(yCm/(2*Mstate.screenDist))*180/pi;

    
%generate grid for screen location (this is in cm)
x_ecc = linspace(-xCm/2,xCm/2,xN); 
y_ecc = linspace(-yCm/2,yCm/2,yN);
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

%Transform grid into spherical coordinates
switch P.altazimuth
    case 'altitude'      
           
        %orientation is represented by rotating a grating around the z-axis
        %(connecting monitor to screen)
        x_eccO = x_eccR*cos(P.ori*pi/180) - y_eccT*sin(P.ori*pi/180); 
        y_eccO = x_eccR*sin(P.ori*pi/180) + y_eccT*cos(P.ori*pi/180); 
        
        %computation altitude angle
        sdom = asin(y_eccO./sqrt(x_eccO.^2 + y_eccO.^2 + z_eccR.^2))*180/pi; %deg

        %determine spatial frequency
        %the spatial frequency is set such that 1 cycle of the grating fits
        %on the screen; width is then regulated using the duty cycle
        s_freq=1/(yDeg);
        s_duty=P.width/yDeg;
        
        %determine t_period for grating
        %it will take the ydeg*speed seconds for 1 period
        t_period=yDeg/P.speed*screenRes.hz;
        
    case 'azimuth'      
        
        %change orientation (we don't need the transformed y for the rest)
        x_eccO = x_eccR*cos(P.ori*pi/180) - y_eccT*sin(P.ori*pi/180); 
        
        %computation of azimuth angle
        sdom = atan(x_eccO./z_eccR)*180/pi; %deg
        
        %determine spatial frequency
        s_freq=1/(xDeg);
        s_duty=P.width/xDeg;
        
        %determine t_period for grating
        %it will take the xdeg*speed seconds for 1 period
        t_period=xDeg/P.speed*screenRes.hz;
end

sdom = sdom*s_freq*2*pi; %radians


%compute shift of grating per frame
tdom = linspace(0,2*pi,round(t_period)+1);
tdom = tdom(1:end-1);

        
%generate noise pattern
sdomAlt = atan(y_ecc.*cos(atan(x_ecc/Mstate.screenDist))/Mstate.screenDist)*180/pi; %deg
sdomAz = atan(x_ecc/Mstate.screenDist)*180/pi; %deg

sdomAlt = round(sdomAlt/P.noise_width);
sdomAz = round(sdomAz/P.noise_width);

noiseIm = xor(rem(sdomAz,2),rem(sdomAlt,2));  %xor produces the checker pattern

%now loop through frames
for i = 1:length(tdom)
        
    grating = cos(sdom - tdom(i)-P.phase*pi/180);
    %grating = cos(sdom);
    thresh = cos(s_duty*pi);
    grating=sign(grating-thresh);
    
    %alternate checkerboard polarity
    if rem(i,P.noise_lifetime) == 1
        noiseIm = 1-noiseIm;
    end
        
    %add checkerboard pattern   
    grating = grating - 2*noiseIm;
    grating(grating<-1) = -1;
    
    %if screen is rotated, need to turn these back for display purposes
    if P.rotated==1
        grating=rot90(grating);
    end
    
    Gtxtr(i) = Screen('MakeTexture',screenPTR, grating,[],[],2);
    
end



