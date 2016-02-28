function makeTexture_RCNGratings

%Reverse correlation with drifting grating; this function only generates
%one line of the grating per spatial frequency, as well as the distribution
%of conditions; the rest is handled in playTexture_DG
%this assumes a normalized color scale from 0 to 1

global Mstate screenPTR screenNum loopTrial

global Gtxtr  Masktxtr  Gseq %'play' will use these

%clean up
if ~isempty(Gtxtr)
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


%convert stimulus size to pixel
xN=deg2pix(P.x_size,'round');
yN=deg2pix(P.y_size,'round');


%create the mask
mN=deg2pix(P.mask_radius,'round');
mask=makeMask(screenRes,P.x_pos,P.y_pos,xN,yN,mN,P.mask_type);
Masktxtr = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers


%make orientation domains
oridom = linspace(P.min_ori,P.min_ori+P.orirange,P.n_ori+1);
oridom = oridom(1:end-1);
    

%make phase domain
phasedom = linspace(0,360,P.n_phase+1);
phasedom = phasedom(1:end-1); 

%number of images to present per trial
N_Im = round(P.stim_time*screenRes.hz/P.h_per); 

%create random stream for trial
s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*str2double(Mstate.unit)+str2double(Mstate.expt)+P.rseed);

for i=1:P.n_grating
    oriseq{i} = randi(s,[1 length(oridom)],1,N_Im);
    phaseseq{i} = randi(s,[1 length(phasedom)],1,N_Im);
end

%add blanks
blankflag = zeros(1,N_Im);
if P.blankProb > 0
    nblanks = round(P.blankProb*N_Im);
    dumseq = randperm(s,N_Im);
    bidx=find(dumseq<=nblanks);
    
    %blank condition is identified with the following indices
    oriseq(bidx) = length(oridom)+1;
    phaseseq(bidx) = 1;
    blankflag(bidx) = 1;
end


%save these in global structure for use by playTexture
Gseq.oridom=oridom;
Gseq.phasedom=phasedom;
Gseq.oriseq=oriseq;
Gseq.phaseseq=phaseseq;
Gseq.blankflag=blankflag;

%now generate textures - we need one per spatial frequency

%stimuli will need to be larger to deal with rotation
%all stimuli will be generated as a square with a side length equal to
%twice length of the diagonal of the chosen stimulus rectangle
%width is computed in degree because spatial frequency is in degree
stimsize=2*sqrt((P.x_size/2).^2+(P.y_size/2).^2);


%we also need to add extra so that we can slide the window to generate
%motion - need one extra cycle; to keep all stimuli the same size, we'll go
%with the lowest spatial frequency here
stimsize=stimsize+1/min(sfdom);

stimsizeN=deg2pix(stimsize,'ceil');

x_ecc=linspace(-stimsize/2,stimsize/2,stimsizeN);

sdom = x_ecc*P.s_freq*2*pi; %radians
grating = cos(sdom);

if strcmp(P.s_profile,'square')
    thresh = cos(P.s_duty*pi);
    grating=sign(grating-thresh);
end
        
Gtxtr = Screen('MakeTexture',screenPTR, grating,[],[],2);



%save sequence data
if Mstate.running
    saveLog(Gseq,P.rseed,loopTrial)  %append log file with the latest sequence
end





