function makeTexture_RCAdaptGrating

%Reverse correlation with drifting grating; this function only generates
%one line of the grating per spatial frequency, as well as the distribution
%of conditions; the rest is handled in playTexture
%the adapatation grating will be inserted every N frames
%this assumes a normalized color scale from 0 to 1

global Mstate screenPTR screenNum loopTrial

global Gtxtr  Masktxtr  Gseq N_Im1 %'play' will use these

%clean up
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end
if ~isempty(Masktxtr)
    Screen('Close',Masktxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];  
Masktxtr=[];
Gseq = [];

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
    
%make spatial frequency domain
if strcmp(P.sf_domain,'log')
    sfdom = logspace(log10(P.min_sf),log10(P.max_sf),P.n_sfreq);
elseif strcmp(P.sf_domain,'lin')
    sfdom = linspace(P.min_sf,P.max_sf,P.n_sfreq);
end
sfdom = unique(sfdom);
    
%make phase domain
phasedom = linspace(0,360,P.n_phase+1);
phasedom = phasedom(1:end-1); 

%number of images to present per trial
N_Im = round(P.stim_time*screenRes.hz/P.h_per); 

% %create random stream for trial
% s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*str2double(Mstate.unit)+str2double(Mstate.expt)+P.rseed);
% 
% %randi: randi(stream,[imin imax},N) generates N integers between imin and
% %imax
% oriseq = randi(s,[1 length(oridom)],1,N_Im); 
% sfseq = randi(s,[1 length(sfdom)],1,N_Im); 
% phaseseq = randi(s,[1 length(phasedom)],1,N_Im); 

%%
% determine number of stimuli possible such that ori,sf,and phase are
% presented an equal number of times in each trial.
adapt_ratio = P.adapt_interv;
ori = 1:length(oridom);
sf = 1:length(sfdom);
ph = 1:length(phasedom);

mult=lcm(lcm(length(oridom), length(sfdom)), length(phasedom)); %least common multiple 
mult = mult + round((mult - (1-P.blankProb)*mult)/(1-P.blankProb));

ntrials = round((1-P.blankProb)*floor((N_Im - N_Im/adapt_ratio)/mult)*mult);

N_Im = ceil((ntrials)/(1-P.blankProb)*(adapt_ratio)/(adapt_ratio - 1));

trials.oriseq = NaN(N_Im,1);
trials.phaseseq = NaN(N_Im,1);
trials.sfseq = NaN(N_Im,1);

% fill matrix with adapted and blanks

%insert adapatation stimulus; we will keep the original phase
adaptflag=zeros(1,N_Im);

adaptidx=[1:P.adapt_interv:N_Im];
adaptflag(adaptidx)=1;
trials.oriseq(adaptidx)=1;
trials.sfseq(adaptidx)=length(sfdom)+2;
trials.phaseseq(adaptidx) = randi(length(phasedom),length(adaptidx),1);

%add blanks
blankflag = zeros(1,N_Im);
blankflag(adaptidx)=0;

if P.blankProb > 0
    nblanks = N_Im - ntrials - length(adaptidx);
    free = find(isnan(trials.oriseq));
    dumseq = randperm(length(trials.oriseq(free)));
    bidx=find(dumseq<=nblanks);
    
    %blank condition is identified with the following indices
    trials.oriseq(free(bidx)) = 1;
    trials.sfseq(free(bidx)) = length(sfdom) + 1;
    trials.phaseseq(free(bidx)) = 1;
    blankflag(free(bidx)) = 1;
end


% given the total number of stimuli, determine how many cycles through the
% differend domains
ori_mult = ntrials/length(oridom);
sf_mult = ntrials/length(sfdom);
ph_mult = ntrials/length(phasedom);

% get the oriseq, phaseseq, and sfseq by choosing a random sample of
% permutations
ori_perms = perms(ori);    
stim = randsample(length(ori_perms),min(ori_mult,length(ori_perms)));
oriseq = ori_perms(stim,:);

% this if loop deals with the case when the number of possible permutations
% is less than the number of cycles needed by iteratively resampling from
% the permutation space.
if length(ori_perms)>1 && length(ori_perms)<ori_mult
  for i = 1:ceil(ori_mult/length(ori_perms))-1  
stim = randsample(length(ori_perms),min(length(ori_perms),ori_mult - i*length(ori_perms)));
oriseq =[oriseq; ori_perms(stim,:)];
  end
end
if length(ori_perms)==1
oriseq = ori*ones(1,ori_mult);
end
oriseq = oriseq(:);


sf_perms = perms(sf);    
stim = randsample(length(sf_perms),min(sf_mult,length(sf_perms)));
sfseq = sf_perms(stim,:);
if length(sf_perms)>1 && length(sf_perms)<sf_mult
  for i = 1:ceil(sf_mult/length(sf_perms))-1  
stim = randsample(length(sf_perms),min(length(sf_perms),sf_mult - i*length(sf_perms)));
sfseq =[sfseq; sf_perms(stim,:)];
  end
end
if length(sf_perms)==1
sfseq = sf*ones(1,sf_mult);
end
sfseq = sfseq(:);

ph_perms = perms(ph);    
stim = randsample(length(ph_perms),min(ph_mult,length(ph_perms)));
phseq = ph_perms(stim,:);
if length(ph_perms)>1 && length(ph_perms)<ph_mult
  for i = 1:ceil(ph_mult/length(ph_perms))-1  
stim = randsample(length(ph_perms),min(length(ph_perms),ph_mult - i*length(ph_perms)));
phseq =[phseq; ph_perms(stim,:)];
  end
end
if length(ph_perms)==1
phseq = ph*ones(1,ph_mult);
end
phseq = phseq(:);

trials.oriseq(isnan(trials.oriseq)) = oriseq;
trials.phaseseq(isnan(trials.phaseseq)) = phseq;
trials.sfseq(isnan(trials.sfseq)) = sfseq;
%%

%save these in global structure for use by playTexture
Gseq.oridom=oridom;
Gseq.sfdom=sfdom;
Gseq.phasedom=phasedom;
Gseq.oriseq=trials.oriseq;
Gseq.sfseq=trials.sfseq;
Gseq.phaseseq=trials.phaseseq;
Gseq.blankflag=blankflag;
Gseq.adaptflag=adaptflag;
N_Im1 = N_Im;

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

for i=1:length(sfdom)
    sdom = x_ecc*sfdom(i)*2*pi; %radians
    grating = cos(sdom);

    if strcmp(P.s_profile,'square')
        thresh = cos(P.s_duty*pi);
        grating=sign(grating-thresh);
    end
        
    Gtxtr(i) = Screen('MakeTexture',screenPTR, grating,[],[],2);
end

%add the adaptation grating just to keep things simple
sdom = x_ecc*P.adapt_sf*2*pi; %radians
grating = cos(sdom);
if strcmp(P.s_profile,'square')
    thresh = cos(P.s_duty*pi);
    grating=sign(grating-thresh);
end
Gtxtr(length(sfdom)+2) = Screen('MakeTexture',screenPTR, grating,[],[],2);

%save sequence data
if Mstate.running
    saveLog(Gseq,P.rseed,loopTrial)  %append log file with the latest sequence
end





