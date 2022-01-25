function makeTexture_ZaberRot

%nothing to be done here

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

%disp(zaber.axis(1).getPosition());
%zaber.axis(1).moveAbsolute(5,Units.LENGTH_MILLIMETRES);
%disp(zaber.axis(1).getPosition());

%get parameters
%P = getParamStruct;

%move x and y axes
%zaber.axis(1).moveRelative(double(P.pos1),Units.LENGTH_MILLIMETRES);
%zaber.axis(2).moveRelative(P.pos2,Units.LENGTH_MILLIMETRES);


%set axis to its default speed
%zaber.axis(3).getSettings().set('maxspeed', P.rotSpeed, Units.ANGULAR_VELOCITY_DEGREES_PER_SECOND);

