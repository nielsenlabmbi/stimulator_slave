function makeTexture_Bar

%make bar stimulus


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
xN=deg2pix(P.x_size,'round');
yN=deg2pix(P.y_size,'round');


%generate texture
Im = ones(yN,xN,3);
colorvec=[P.redgun P.greengun P.bluegun];
for i=1:3
    Im(:,:,i) = colorvec(i);
end
Gtxtr = Screen(screenPTR, 'MakeTexture',Im,[],[],2);


