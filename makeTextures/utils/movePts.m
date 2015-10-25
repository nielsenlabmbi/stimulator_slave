function movedPts = movePts(pts,x,y,s,o)
% movePts() performs affine transformation of the specified points
% in cartesian space. It also rotates the cartesian space.
% Maintained by Ramanujan Srinath
% Accepts:
%   pts - points - column 1 = x; column 2 = y;
%   x 	- new origin x
%	y 	- new origin y
%	s 	- new size
%	o 	- rotation specified in degrees
% Returns:
%   movedPts - transformed points in the same format

    [th,r] = cart2pol(pts(:,1),pts(:,2));
    th = th+deg2rad(o);
    [x1,y1] = pol2cart(th,r);
    
    movedPts = [x1 y1];
        
    movedPts = movedPts * s;
    
    movedPts(:,1) = movedPts(:,1) + x;
    movedPts(:,2) = movedPts(:,2) + y;
end
