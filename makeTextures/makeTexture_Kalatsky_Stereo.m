function makeTexture_Kalatsky_Stereo

%make bar stimulus


global  screenPTR  screenNum

global Gtxtr Gtxtr2     %'play' will use these

%clean up
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end
% if ~isempty(Gtxtr2)
%     Screen('Close',Gtxtr2);  %First clean up: Get rid of all textures/offscreen windows
% end

Gtxtr = [];  
Gtxtr2=[];
%get parameters
P = getParamStruct;

%set size - simply make it large enough to cover the horizontal extent of
%the screen; width set by user
%we only do one orientation here, rest is handled in play
screenRes = Screen('Resolution',screenNum);
if P.axis1==0
    yN=screenRes.width;
    xN=deg2pix(P.width1,'round');
else
    xN=screenRes.width;
    yN=deg2pix(P.width1,'round');
end

if P.axis2==0
    yN2=screenRes.width;
    xN2=deg2pix(P.width2,'round');
else
    xN2=screenRes.width;
    yN2=deg2pix(P.width2,'round');
end
%generate texture
Im = ones(yN,xN,3);
Im2 = ones(yN2,xN2,3);
colorvec=[P.redgun P.greengun P.bluegun];
colorvec2=[P.redgun2 P.greengun2 P.bluegun2];

for i=1:3
    Im(:,:,i) = colorvec(i);
end
for i=1:3
    Im2(:,:,i) = colorvec2(i);
end
%Screen('SelectStereoDrawBuffer', screenPTR, 0);
Gtxtr = Screen(screenPTR, 'MakeTexture',Im,[],[],2);
%Screen('SelectStereoDrawBuffer', screenPTR, 1);
Gtxtr2 = Screen(screenPTR, 'MakeTexture',Im2,[],[],2);


