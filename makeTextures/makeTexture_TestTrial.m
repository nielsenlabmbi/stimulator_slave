function makeTexture_TestTrial

%make TestTrial stimulus


global  screenPTR  

global Gtxtr     %'play' will use these

%clean up
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];  

%get parameters
P = getParamStruct;



%generate texture
ColorScreen = ones(100) .* P.Intensity;



Gtxtr = Screen(screenPTR, 'MakeTestTrial',ColorScreen,[],[],2);
