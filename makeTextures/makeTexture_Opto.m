function makeTexture_Opto

%make small square (used for blank optogenetics stimulation)


global  screenPTR  

global Gtxtr     %'play' will use these

%clean up
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];  

%get parameters
P = getParamStruct;

%convert stimulus size to pixel
xN=50;
yN=50;


%generate texture
Im = ones(yN,xN,3);
colorvec=[0 0 1];
for i=1:3
    Im(:,:,i) = colorvec(i);
end
Gtxtr = Screen(screenPTR, 'MakeTexture',Im,[],[],2);


