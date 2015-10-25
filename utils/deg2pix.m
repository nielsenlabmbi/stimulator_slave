function xN=deg2pix(xdeg,mstring)
%transform degrees into pixel
%mstring specifies whether pixels should be computed using round, ceil, or
%no rounding

%The following assumes the screen is curved.  It will give 
%a slightly wrong stimulus size when they are large.
%we assume here that pixels are square

global screenNum Mstate

screenRes = Screen('Resolution',screenNum);

pixpercmX = screenRes.width/Mstate.screenXcm;

xcm = 2*pi*Mstate.screenDist*xdeg/360;  %stimulus width in cm

%stimulus width in pixels
if strcmp(mstring,'round')
    xN = round(xcm*pixpercmX);  
elseif strcmp(mstring,'ceil')
    xN = ceil(xcm*pixpercmX);
else
    xN = xcm*pixpercmX;
end

