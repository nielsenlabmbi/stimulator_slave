function makeTexture_Pacman

global  screenPTR screenNum 

global Mstate DotCoord loopTrial 
global Masktxtr 
%clean up
if ~isempty(Masktxtr)
    Screen('Close',Masktxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Masktxtr = [];  

%
DotCoord=[];


%get parameters
P = getParamStruct;

%get screen settings
screenRes = Screen('Resolution',screenNum);


%parameters for the scaling
stimRadPx=deg2pix(P.r_size,'round');
mN=deg2pix(P.maskRadius,'round');
mask=makeMask(screenRes,P.x_pos,P.y_pos,stimRadPx*2,stimRadPx*2,mN,P.maskType,P.background);
Masktxtr(1) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers

%%%generate coordinates here and save in DotCoord

    % Angles at which our polygon vertices endpoints will be. We start at zero
    % and then equally space vertex endpoints around the edge of a circle. The
    % polygon is then defined by sequentially joining these end points.
  
    if (P.stim_type == 2),
         anglesDeg= [(360-P.acute):360]; 
    else
         anglesDeg= [(P.acute):360]; 
   end
    
    anglesRad = anglesDeg * (pi / 180);
    radius = 1;
    
     yPosVector = sin(anglesRad) .* radius;
     xPosVector = cos(anglesRad) .* radius;

    
 if P.sharp == 0,
%% make contour:
%set to go through control pts spaces sqrt(2) away and going through center.
    canon_contpx =[2*sqrt(2) sqrt(2) 0 (cos(anglesRad(1))*sqrt(2)) (cos(anglesRad(1))*2*sqrt(2))]; 
    canon_contpy= [ 0 0 0  (sin(anglesRad(1))*sqrt(2)) (sin(anglesRad(1))*2*sqrt(2))];
    canon_contpts = [canon_contpx; canon_contpy];
k = 4;%cubic
% knot sequence

t_best2= [ 0    0    0    0.4714  0.5  0.5286    1    1    1];
% repeats to make go through specific points.

 M_0 = bspline_deboor(k,t_best2,canon_contpts);

     xPosVector2 = [radius radius-(.3*radius) radius-(.5*radius) (M_0(1,:)) xPosVector];
     yPosVector2 = [0 0 0 (M_0(2,:)) yPosVector];

  if (P.stim_type == 2),
        rot_ang = pi*( P.ori+(P.acute/2))/180;
  else
      rot_ang = pi*(P.ori-(P.acute/2))/180;
 end    
        rot_mat = [cos(rot_ang) -sin(rot_ang); sin(rot_ang) cos(rot_ang)];
        PosVectorsr = rot_mat*[xPosVector2; yPosVector2];%rotating
        scale_mat = [stimRadPx 0; 0 stimRadPx]; %scaling
        PosVectors_rs = scale_mat*PosVectorsr;
        DotCoord(1,:) =P.x_pos+PosVectors_rs(1,:); %shifting x
        DotCoord(2,:) =P.y_pos+PosVectors_rs(2,:); %shifting y
 
 else
        
        %% plot for triangle
    % X and Y coordinates of the points defining out polygon, centred on the
    % centre of the screen
    xPosVector(1) = 0;
    yPosVector(1) = 0;    
 if (P.stim_type == 2),
        rot_ang = pi*( P.ori+(P.acute/2))/180;
  else
      rot_ang = pi*(P.ori-(P.acute/2))/180;
 end 
        rot_mat = [cos(rot_ang) -sin(rot_ang); sin(rot_ang) cos(rot_ang)];
        PosVectorsr = rot_mat*[xPosVector; yPosVector];
         scale_mat = [ stimRadPx 0; 0  stimRadPx];
         PosVectors_rs = scale_mat*PosVectorsr;
        DotCoord(1,:) =P.x_pos+PosVectors_rs(1,:);
        DotCoord(2,:) =P.y_pos+PosVectors_rs(2,:);

     
 end
end
 



