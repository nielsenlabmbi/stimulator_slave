function makeTexture_ZaberRot

import zaber.motion.Library;
import zaber.motion.ascii.Connection;
import zaber.motion.Units;
import zaber.motion.ascii.AxisSettings;
import zaber.motion.ascii.AllAxes;
import zaber.motion.ascii.Axis;
import zaber.motion.ascii.Stream;
import zaber.motion.Measurement;

Library.enableDeviceDbStore();

%use the zaber stages to rotate objects
%in every trial, rotation stage turns at a specified speed for some time
%stage 3 is rotation stage

global zaber

%get parameters
P = getParamStruct;



%set axis to its default speed
zaber.axis(3).getSettings().set('maxspeed', P.rotSpeed, Units.ANGULAR_VELOCITY_DEGREES_PER_SECOND);

