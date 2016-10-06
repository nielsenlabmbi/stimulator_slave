function makeTexture_Kalatsky

%make bar stimulus


global  screenPTR  screenNum

global Gtxtr     %'play' will use these

%clean up
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];  

%get parameters
P = getParamStruct;

%set size - simply make it large enough to cover the horizontal extent of
%the screen; width set by user
%we only do one orientation here, rest is handled in play
screenRes = Screen('Resolution',screenNum);
if P.axis==0
    yN=screenRes.width;
    xN=deg2pix(P.width,'round');
else
    xN=screenRes.width;
    yN=deg2pix(P.width,'round');
end

%generate texture
Im = ones(yN,xN,3);
colorvec=[P.redgun P.greengun P.bluegun];
for i=1:3
    Im(:,:,i) = colorvec(i);
end
Gtxtr = Screen(screenPTR, 'MakeTexture',Im,[],[],2);


