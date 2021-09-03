function playTexture_ZaberRot
%move 1 zaber stage in a ramp and hold pattern

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
Nstimframes = ceil(P.stimDur*screenRes.hz);

moveAngle=P.stimDur*P.rotSpeed; %relative angle by which to move the stage

%Wake up the daq to improve timing later
if ~isempty(daq)
    DaqDOut(daq, 0, 0);
end

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


%%%%%ramp 1%%%%%%%%%%
for i = 1:Nstimframes
    Screen(screenPTR, 'Flip');
    
    if i==1
        %start moving; will not wait for execution here       
        zaber.axis(3).moveRelative(moveAngle,Units.ANGLE_DEGREES,0);

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
    
    if i==1 && loopTrial ~= -1 && ~isempty(daq)
        digWord = 1;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
    end

end
Screen(screenPTR, 'Flip');


if loopTrial ~= -1 && ~isempty(daq)
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end






