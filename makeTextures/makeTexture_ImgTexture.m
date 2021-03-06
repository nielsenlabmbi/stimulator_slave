function makeTexture_ImgTexture

%display texture made out of an image

global screenPTR Gtxtr Masktxtr IDim screenNum Mstate
global Gseq loopTrial

if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end
if ~isempty(Masktxtr)
    Screen('Close',Masktxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];
Masktxtr=[];
Gseq = [];
IDim=[];

%get parameters
P = getParamStruct;
screenRes = Screen('Resolution',screenNum);

%create the mask 
xN=deg2pix(P.x_size,'round');
yN=deg2pix(P.y_size,'round');
mN=deg2pix(P.mask_radius,'round');

mask=makeMask(screenRes,P.x_pos,P.y_pos,xN,yN,mN,P.mask_type,P.background);
Masktxtr = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers


%load images 
load([P.stimfile '.mat']);

%get bar profile and bar width
didx=find(d==P.distance);
if isempty(didx)
    didx=1; %60cm
end

lidx=find(l==P.length);
if isempty(lidx)
    lidx=1; %smallest length
end

midx=find(m==P.material);
if isempty(midx)
    midx=1; %material 1
end

sidx=find(s==P.barWidth);
if isempty(sidx)
    sidx=5; %0.5
end

cSingle=st{sidx,midx,didx,lidx};
cSingle=double(cSingle)./255;

cSize=size(cSingle);

%compute block width (each texture element will sit inside a block at a
%random offset)
blockWidthX=cSize(2)*(P.deltaX+1);
blockWidthY=cSize(1)*(P.deltaY+1);

%replicate line that is large enough to span the stimulus size, plus an
%extra cycle
%stimuli will need to be larger to deal with rotation
stimsize=2*sqrt((P.x_size/2).^2+(P.y_size/2).^2); %deg
stimsizeN=deg2pix(stimsize,'ceil'); %pixel

%turn this into nr of cycles
nCyclesX=ceil(stimsizeN/blockWidthX);
nCyclesY=ceil(stimsizeN/blockWidthY);

%now build image (need an extra cycle for x for movement)
textMat=ones(nCyclesY*blockWidthY,nCyclesX*blockWidthX)*P.background;

%save size and cycle for playTexture
IDim=size(textMat);
IDim(3)=blockWidthX;

%generate offset vector for y (needs to take into account that objects
%should not overlap)
offsetY=(blockWidthY-cSize(1))/P.NposY;
for i=1:nCyclesX
    offY(i)=mod(i-1,P.NposY);
end


%generate random offsets for each block - x fully random, y permutation of
%offsets
sr = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*str2double(Mstate.unit)+str2double(Mstate.expt)+loopTrial);

randoffX=rand(sr,[1,nCyclesX*nCyclesY]);

for i=1:nCyclesY
    rp=randperm(sr,length(offY));
    randoffY(i,:)=offY(rp);
end

Gseq.randoffX=randoffX;
Gseq.randoffY=randoffY;



%generate all but the last cycle (will need to be copied from start)
for i=1:nCyclesX
    for j=1:nCyclesY
        %top left position
        startX = (i-1)*blockWidthX+1; %regular grid
        startX = startX+round(P.noiseX*randoffX((i-1)*nCyclesY+j)*P.deltaX*cSize(2)); %add noise, max shift to the right is blockWidth-imgWidth
        
        %top right position
        startY = (j-1)*blockWidthY+1;
        if P.addNoiseY
            startY = startY+round(randoffY(j,i)*offsetY); %add shifts
        else
            startY = startY+round(offY(i)*offsetY); %add shifts
        end
        %add into matrix at respective position
        textMat(startY:startY+cSize(1)-1,startX:startX+cSize(2)-1)=cSingle;
        
    end
end

%copy the the pattern for movement
textMat=[textMat textMat];

    
%generate texture
Gtxtr = Screen(screenPTR, 'MakeTexture', textMat,[],[],2);


%save sequence data
if Mstate.running
    saveLog(Gseq,loopTrial,loopTrial)  %append log file with the latest sequence
end







