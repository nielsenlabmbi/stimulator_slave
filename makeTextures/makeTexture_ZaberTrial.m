function makeTexture_ZaberTrial

import zaber.motion.Library;
import zaber.motion.ascii.Connection;
import zaber.motion.Units;
import zaber.motion.ascii.AxisSettings;
import zaber.motion.ascii.AllAxes;
import zaber.motion.ascii.Axis;
import zaber.motion.ascii.Stream;
import zaber.motion.Measurement;

Library.enableDeviceDbStore();

%use the zaber stages to move objects
%in every trial, stages move from start_1 (x), start_2 (y), start_3 (alpha)
%to stop_1 (x), stop_2 (y), stop_3(alpha)
%axes move independently; 2 axes moves in ITI, the last one during the
%trial using a ramp and hold

%assumption: 3rd stage is rotatary stage

global zaber

%get parameters
P = getParamStruct;



%first set all axes to their default speed
zaber.axis(1).getSettings().set('maxspeed', P.defLinSpeed, Units.VELOCITY_MILLIMETRES_PER_SECOND);
zaber.axis(2).getSettings().set('maxspeed', P.defLinSpeed, Units.VELOCITY_MILLIMETRES_PER_SECOND);
zaber.axis(3).getSettings().set('maxspeed', P.defRotSpeed, Units.ANGULAR_VELOCITY_DEGREES_PER_SECOND);

%then figure out ramp speed and set
if P.trialAxis==1
    deltaPos=abs(P.stopPos1-P.startPos1);
    rampSpeed=deltaPos/P.rampDur; %this is in mm/s
    zaber.axis(1).getSettings().set('maxspeed', rampSpeed, Units.VELOCITY_MILLIMETRES_PER_SECOND);
elseif P.trialAxis==2
    deltaPos=abs(P.stopPos2-P.startPos2);
    rampSpeed=deltaPos/P.rampDur; %this is in mm/s
    zaber.axis(2).getSettings().set('maxspeed', rampSpeed, Units.VELOCITY_MILLIMETRES_PER_SECOND);
else %rotation
    deltaA=abs(P.stopA-P.startA);
    rampSpeed=deltaA/P.rampDur; %this is in deg/s
    zaber.axis(3).getSettings().set('maxspeed', rampSpeed, Units.ANGULAR_VELOCITY_DEGREES_PER_SECOND);
end

%move all stages into start position (this also holds for the one that will
%be moved in the trial)
zaber.axis(1).moveAbsolute(P.startPos1,Units.LENGTH_MILLIMETRES);
zaber.axis(2).moveAbsolute(P.startPos2,Units.LENGTH_MILLIMETRES);
zaber.axis(3).moveAbsolute(P.startA,Units.ANGLE_DEGREES);