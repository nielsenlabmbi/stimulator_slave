function makeTexture_NoiseBar

%generate checkerboard texture

global  screenPTR screenNum 

global Gtxtr  Masktxtr   %'play' will use these

%clean up
if ~isempty(Gtxtr)
    disp(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

if ~isempty(Masktxtr)
    Screen('Close',Masktxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];  
Masktxtr=[];


%get parameters
P = getParamStruct;
screenRes = Screen('Resolution',screenNum);


%convert bar size to pixel
xNbar=deg2pix(P.bar_width,'round');
yNbar=deg2pix(P.bar_length,'round');

%make bar
Im = ones(yNbar,xNbar)*P.bar_lum;
Gtxtr(1) = Screen(screenPTR, 'MakeTexture',Im,[],[],2);

%generate noise texture - treat like grating (add on in one direction, rest
%solved with rotation/translation in playTexture
%stimuli will need to be larger to deal with rotation
stimsize=2*sqrt(2*(P.text_size/2).^2); %deg

%add extra so that we can slide the window to generate motion 
stimsize=stimsize+P.speed*P.stim_time; %deg

%use ceil to make sure that we definitely have enough pixels
stimsizeN=deg2pix(stimsize,'ceil'); %pixel

%now divide into squares with same width as bar
nText = ceil(stimsizeN/xNbar);

%generate output texture
textOut=ones(nText)*P.background; %we're operating at the block level here

idxText=randperm(nText^2,round(P.frac_text*nText^2));

textOut(idxText)=P.text_lum;

%expand out into pixel level
textOut=repelem(textOut,xNbar,xNbar);
Gtxtr(2) = Screen('MakeTexture',screenPTR,textOut, [],[],2);

%need a mask to deal with the rotation
maskN=deg2pix(P.text_size,'round');
mask=makeMask(screenRes,P.x_pos,P.y_pos,maskN,maskN,0,'none',P.background);
Masktxtr(1) = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers









