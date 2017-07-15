function makeTexture_RCImg

%loads images, and scrambles if selected

global screenPTR Gseq Mstate  loopTrial IDim

global Gtxtr

if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];
Gseq = [];
IDim = [];

%get parameters
P = getParamStruct;

%read matrix with images
load([P.stimfile '.mat']);

%generates matrix img
nrImg=size(img,3);
IDim=size(img);

%make image domain
imgdom=[1:nrImg];

%generate random sequence
s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*str2double(Mstate.unit)+str2double(Mstate.expt)+P.rseed);

%base sequence
imgseq=repmat(imgdom,1,P.nReps);
%add blanks
imgseq=[imgseq ones(1,P.nBlanks)*(nrImg+1)];
%reorder
ridx=randperm(s,length(imgseq));
imgseq=imgseq(ridx);


idx=find(imgseq==nrImg+1);
blankflag = zeros(1,length(imgseq));
blankflag(idx)=1;

%save in Gseq
Gseq.blankflag=blankflag;
Gseq.imgseq=imgseq;


%generate images
for i=1:nrImg
    Gtxtr(i)=Screen(screenPTR, 'MakeTexture', squeeze(img(:,:,i)),[],[],2);
end


%save sequence data
if Mstate.running
    saveLog(Gseq,P.rseed,loopTrial)  %append log file with the latest sequence
end


