function playTexture_ZaberRot
%note: if this function crashes, it's because the zaber stages can't
%execute the relative movement because it's past their range

import zaber.motion.Library;
import zaber.motion.ascii.Connection;
import zaber.motion.Units;
import zaber.motion.ascii.AxisSettings;
import zaber.motion.ascii.AllAxes;
import zaber.motion.ascii.Axis;
import zaber.motion.ascii.Stream;
import zaber.motion.Measurement;

Library.enableDeviceDbStore();

global  screenPTR screenNum daq loopTrial

global zaber

%get basic parameters
P = getParamStruct;

%get timing information
screenRes = Screen('Resolution',screenNum);
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nrotframes = ceil(P.rotDur*screenRes.hz);

moveAngle=P.rotDir*P.rotDur*P.rotSpeed; %relative angle by which to move the stage

%Wake up the daq to improve timing later
if ~isempty(daq)
    DaqDOut(daq, 0, 0);
end

%move the x and y stages to their locations
zaber.axis(1).moveRelative(P.pos1,Units.LENGTH_MILLIMETRES);
zaber.axis(2).moveRelative(P.pos2,Units.LENGTH_MILLIMETRES);

%%%Play predelay %%%%
Screen(screenPTR, 'FillRect', 0)
Screen(screenPTR, 'Flip');
if loopTrial ~= -1 && ~isempty(daq)
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);    
end
for i = 2:Npreframes
    Screen(screenPTR, 'Flip');
end


%%%%%rot%%%%%%%%%%
for i = 1:Nrotframes
    Screen(screenPTR, 'Flip');
    
    if i==1
        %start moving; will not wait for execution here       
        %zaber.axis(3).moveRelative(moveAngle,Units.ANGLE_DEGREES,0);
        zaber.axis(3).moveVelocity(P.rotDir*P.rotSpeed,Units.ANGULAR_VELOCITY_DEGREES_PER_SECOND);

        %generate event
        if ~isempty(daq) && loopTrial ~= -1
            digWord=3;
            DaqDOut(daq, 0, digWord);
        end        
    end
end




%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen(screenPTR, 'Flip');
    
    if i==1 
        zaber.axis(3).stop();
        if loopTrial ~= -1 && ~isempty(daq)
            digWord = 1;  %toggle 2nd bit to signal stim on
            DaqDOut(daq, 0, digWord);
        end
    end

end
Screen(screenPTR, 'Flip');


%move the x and y stages back to their initial locations
zaber.axis(1).moveRelative(-P.pos1,Units.LENGTH_MILLIMETRES);
zaber.axis(2).moveRelative(-P.pos2,Units.LENGTH_MILLIMETRES);

if loopTrial ~= -1 && ~isempty(daq)
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end






