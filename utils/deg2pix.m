function xN=deg2pix(xdeg,mstring,varargin)
%transform degrees into pixel
%mstring specifies whether pixels should be computed using round, ceil, or
%no rounding
%varargin switches to flat screens, otherwise we assume that the screen is
%curved.

%we assume here that pixels are square

global screenNum Mstate

screenRes = Screen('Resolution',screenNum);

pixpercmX = screenRes.width/Mstate.screenXcm;

if nargin==2
    screenProfile=1; %curved
else
    screenProfile=2; %flat
end

%stimulus width in cm
if screenProfile==1
    xcm = 2*pi*Mstate.screenDist*xdeg/360;  
else
    xcm = 2*Mstate.screenDist*tan(xdeg/2*pi/180);  
end

%stimulus width in pixels
if strcmp(mstring,'round')
    xN = round(xcm*pixpercmX);  
elseif strcmp(mstring,'ceil')
    xN = ceil(xcm*pixpercmX);
else
    xN = xcm*pixpercmX;
end

