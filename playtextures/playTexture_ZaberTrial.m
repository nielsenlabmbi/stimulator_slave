function playTexture_ZaberTrial
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
Nrampframes = ceil(P.rampDur*screenRes.hz);
Nholdframes = ceil(P.holdDur*screenRes.hz);


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
for i = 1:Nrampframes
    Screen(screenPTR, 'Flip');
    
    if i==1
        %start moving; will not wait for execution here
        if P.trialAxis==1
            zaber.axis(1).moveAbsolute(P.stopPos1, Units.LENGTH_MILLIMETRES,0);
        elseif P.trialAxis==2
            zaber.axis(2).moveAbsolute(P.stopPos2, Units.LENGTH_MILLIMETRES,0);
        else
            zaber.axis(3).moveAbsolute(P.stopA,Units.ANGLE_DEGREES,0);
        end
        
        %generate event
        if ~isempty(daq) && loopTrial ~= -1
            digWord=3;
            DaqDOut(daq, 0, digWord);
        end        
    end
end

%%%Play hold %%%%
for i = 1:Nholdframes
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1 && ~isempty(daq)
        digWord = 5;  %Make 1st bit high
        DaqDOut(daq, 0, digWord);
    end
end

%%%%%ramp 2%%%%%%%%%%
for i = 1:Nrampframes
    Screen(screenPTR, 'Flip');
    
    if i==1
        %start moving; will not wait for execution here
        if P.trialAxis==1
            zaber.axis(1).moveAbsolute(P.startPos1, Units.LENGTH_MILLIMETRES,0);
        elseif P.trialAxis==2
            zaber.axis(2).moveAbsolute(P.startPos2, Units.LENGTH_MILLIMETRES,0);
        else
            zaber.axis(3).moveAbsolute(P.startA,Units.ANGLE_DEGREES,0);
        end
        
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






