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
stimsize=2*sqrt((P.x_size/2).^2+(P.y_size/2).^2); %deg

%add extra so that we can slide the window to generate motion 
stimsize=stimsize+P.speed*P.stim_time; %deg

%use ceil to make sure that we definitely have enough pixels
stimsizeN=deg2pix(stimsize,'ceil'); %pixel

%now divide into squares with same width as bar
nText = ceil(stimsizeN/xNbar);

%operate at block level - set certain blocks to texture
nBlock=length(nText^2);
idxText=randperm(nBlock,round(nBlock*P.frac_text));

textOut=ones(nBlock)*P.background;
textOut(idxText)=P.text_lum;

textOut=repelem(textOut,xNbar,xNbar);
Gtxtr(2) = Screen('MakeTexture',screenPTR,textOut, [],[],2);








