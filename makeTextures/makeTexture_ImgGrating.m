function makeTexture_ImgGrating

%display gratings made of 3d bars

global screenPTR Gtxtr Masktxtr IDim screenNum
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end
if ~isempty(Masktxtr)
    Screen('Close',Masktxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];
Masktxtr=[];
IDim=[];

%get parameters
P = getParamStruct;
screenRes = Screen('Resolution',screenNum);


%load one cycle 
load([P.stimfile '.mat']);

%get bar profile and bar width
didx=find(d==P.distance);
if isempty(didx)
    didx=1; %60cm
end

lidx=find(l==P.lightdir);
if isempty(lidx)
    lidx=3; %dir 0
end

midx=find(m==P.material);
if isempty(midx)
    midx=1; %material 1
end

sidx=find(s==P.barWidth);
if isempty(sidx)
    sidx=5; %0.5
end

barSingle=st{sidx,midx,didx,lidx};
barSingle=double(barSingle)./255;

%add spacing between bars
background=ones(1,length(barSingle)*P.barSpacing)*P.background;
barSingle=[barSingle background];
cycleWidth=length(barSingle);
IDim(1)=cycleWidth;

%replicate line that is large enough to span the stimulus size, plus an
%extra cycle
%stimuli will need to be larger to deal with rotation
stimsize=2*sqrt((P.x_size/2).^2+(P.y_size/2).^2); %deg
stimsizeN=deg2pix(stimsize,'ceil'); %pixel

%turn this into nr of cycles
nCycles=ceil(stimsizeN/cycleWidth);
IDim(2)=nCycles;

%add one cycle for movement
nCycles=nCycles+1;

%replicate bar to generate pattern
barPattern=repmat(barSingle,1,nCycles);


%generate texture
Gtxtr = Screen(screenPTR, 'MakeTexture', barPattern,[],[],2);

%create the mask 
xN=deg2pix(P.x_size,'round');
yN=deg2pix(P.y_size,'round');
mN=deg2pix(P.mask_radius,'round');


mask=makeMask(screenRes,P.x_pos,P.y_pos,xN,yN,mN,P.mask_type,P.background);
Masktxtr = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers





