function makeTexture_RCGrating_Stereo

%Reverse correlation with drifting grating; this function only generates
%one line of the grating per spatial frequency, as well as the distribution
%of conditions; the rest is handled in playTexture_DG
%this assumes a normalized color scale from 0 to 1

global Mstate screenPTR screenNum loopTrial

global Gtxtr Gtxtr2  Masktxtr Masktxtr2 Gseq Gseq2 %'play' will use these

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


Gtxtr2 = [];  
Masktxtr2=[];
Gseq2 = [];

%get parameters
P = getParamStruct;
screenRes = Screen('Resolution',screenNum);
screenRes2=screenRes;
screenRes2.width=screenRes2.width/2; 

disp(screenNum)
%convert stimulus size to pixel
xN=deg2pix(P.x_size,'round');
yN=deg2pix(P.y_size,'round');

xN2=deg2pix(P.x_size2,'round');
yN2=deg2pix(P.y_size2,'round');

%create the mask
mN=deg2pix(P.mask_radius,'round');
mN2=deg2pix(P.mask_radius2,'round');


Screen('SelectStereoDrawBuffer', screenPTR, 0);
mask=makeMask(screenRes2,P.x_pos,P.y_pos,xN,yN,mN,P.mask_type);
Masktxtr = Screen(screenPTR, 'MakeTexture', mask,[],[],2);  %need to specify correct mode to allow for floating point numbers

Screen('SelectStereoDrawBuffer', screenPTR, 1);
mask2=makeMask(screenRes2,P.x_pos2,P.y_pos2,xN2,yN2,mN2,P.mask_type2);
Masktxtr2 = Screen(screenPTR, 'MakeTexture', mask2,[],[],2);  %need to specify correct mode to allow for floating point numbers


%make orientation domains
oridom1 = linspace(P.min_ori1,P.min_ori1+P.orirange1,P.n_ori1+1);
oridom1 = oridom1(1:end-1);
if P.KeepSame_ori==0
    oridom2 = linspace(P.min_ori2,P.min_ori2+P.orirange2,P.n_ori2+1);
    oridom2 = oridom2(1:end-1);
elseif P.KeepSame_ori==1
    oridom2=oridom1;
end
    

%make spatial frequency domain
if strcmp(P.sf_domain1,'log')
    sfdom1 = logspace(log10(P.min_sf1),log10(P.max_sf1),P.n_sfreq1);
elseif strcmp(P.sf_domain1,'lin')
    sfdom1 = linspace(P.min_sf1,P.max_sf1,P.n_sfreq1);
end
sfdom1 = unique(sfdom1);
if P.KeepSame_sf==0
if strcmp(P.sf_domain2,'log')
    sfdom2 = logspace(log10(P.min_sf2),log10(P.max_sf2),P.n_sfreq2);
elseif strcmp(P.sf_domain2,'lin')
    sfdom2 = linspace(P.min_sf2,P.max_sf2,P.n_sfreq2);
end
sfdom2 = unique(sfdom2);
elseif P.KeepSame_sf==1
    sfdom2=sfdom1;
end

%make temporal frequency domain
if strcmp(P.tp_domain1,'log')
    tpdom1 = logspace(log10(P.min_tp1),log10(P.max_tp1),P.n_tp1);
elseif strcmp(P.tp_domain1,'lin')
    tpdom1=linspace(P.min_tp1,P.max_tp1,P.n_tp1);
end
tpdom1 = unique(tpdom1);

if P.KeepSame_tp==0
    if strcmp(P.tp_domain2,'log')
        tpdom2 = logspace(log10(P.min_tp2),log10(P.max_tp2),P.n_tp2);
    elseif strcmp(P.tp_domain2,'lin')
        tpdom2=linspace(P.min_tp2,P.max_tp2,P.n_tp2);
    end
    tpdom2 = unique(tpdom2);
elseif P.KeepSame_tp=-1
    tpdom2=tpdom1;
end

%make phase domain
phasedom1 = linspace(0,360,P.n_phase1+1);
phasedom1 = phasedom1(1:end-1); 

if P.KeepSame_phase==0
    phasedom2 = linspace(0,360,P.n_phase2+1);
    phasedom2 = phasedom2(1:end-1);
elseif P.KeepSame_phase==1
    phasedom2=phasedom1;
end

%number of images to present per trial
N_Im = round(P.stim_time*screenRes.hz/P.h_per); 

%create random stream for trial
s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*str2double(Mstate.unit)+str2double(Mstate.expt)+P.rseed);

% if P.EyeVary==0
oriseq = randi(s,[1 length(oridom1)],1,N_Im); 
sfseq = randi(s,[1 length(sfdom1)],1,N_Im); 
tpseq = randi(s,[1 length(tpdom1)],1,N_Im); 
phaseseq = randi(s,[1 length(phasedom1)],1,N_Im); 

oriseq2 = randi(s,[1 length(oridom2)],1,N_Im); 
sfseq2 = randi(s,[1 length(sfdom2)],1,N_Im); 
tpseq2 = randi(s,[1 length(tpdom2)],1,N_Im); 
phaseseq2 = randi(s,[1 length(phasedom2)],1,N_Im); 

% elseif P.EyeVary==1
% oriseq = randi(s,[1 length(oridom)],1,N_Im); 
% sfseq = randi(s,[1 length(sfdom)],1,N_Im); 
% tpseq = randi(s,[1 length(tpdom)],1,N_Im); 
% phaseseq = randi(s,[1 length(phasedom)],1,N_Im);   
% 
% oriseq2 = ones(1, N_Im); 
% sfseq2 = ones(1, N_Im); 
% tpseq2 = ones(1, N_Im); 
% phaseseq2 = ones(1, N_Im); 
% 
% elseif P.EyeVary==2
% oriseq = ones(1, N_Im);  
% sfseq = ones(1, N_Im); 
% tpseq = ones(1, N_Im); 
% phaseseq = ones(1, N_Im); 
% 
% oriseq2 = randi(s,[1 length(oridom)],1,N_Im); 
% sfseq2 = randi(s,[1 length(sfdom)],1,N_Im); 
% tpseq2 = randi(s,[1 length(tpdom)],1,N_Im); 
% phaseseq2 = randi(s,[1 length(phasedom)],1,N_Im);    
% end
%add blanks
blankflag = zeros(1,N_Im);
if P.blankProb > 0
    nblanks = round(P.blankProb*N_Im);
    dumseq = randperm(s,N_Im);
    bidx=find(dumseq<=nblanks);
    
    %blank condition is identified with the following indices
    oriseq(bidx) = 1;
    sfseq(bidx) = length(sfdom1) + 1;
    tpseq(bidx) = length(tpdom1) + 1;
    phaseseq(bidx) = 1;
    blankflag(bidx) = 1;
    
    oriseq2(bidx) = 1;
    sfseq2(bidx) = length(sfdom2) + 1;
    tpseq2(bidx) = length(tpdom2) + 1;
    phaseseq2(bidx) = 1;
    blankflag2(bidx) = 1;
end


%save these in global structure for use by playTexture
Gseq.oridom=oridom1;
Gseq.sfdom=sfdom1;
Gseq.tpdom=tpdom1;
Gseq.phasedom=phasedom1;
Gseq.oriseq=oriseq;
Gseq.sfseq=sfseq;
Gseq.tpseq=tpseq;
Gseq.phaseseq=phaseseq;
Gseq.blankflag=blankflag;

Gseq2.oridom=oridom2;
Gseq2.sfdom=sfdom2;
Gseq2.tpdom=tpdom2;
Gseq2.phasedom=phasedom2:
Gseq2.oriseq=oriseq2;
Gseq2.sfseq=sfseq2;
Gseq2.tpseq=tpseq2;
Gseq2.phaseseq=phaseseq2;
Gseq2.blankflag=blankflag2;

%now generate textures - we need one per spatial frequency

%stimuli will need to be larger to deal with rotation
%all stimuli will be generated as a square with a side length equal to
%twice length of the diagonal of the chosen stimulus rectangle
%width is computed in degree because spatial frequency is in degree
stimsize=2*sqrt((P.x_size/2).^2+(P.y_size/2).^2);

stimsize2=2*sqrt((P.x_size2/2).^2+(P.y_size2/2).^2);

%we also need to add extra so that we can slide the window to generate
%motion - need one extra cycle; to keep all stimuli the same size, we'll go
%with the lowest spatial frequency here
stimsize=stimsize+1/min(sfdom1);
stimsize2=stimsize2+1/min(sfdom2);

stimsizeN=deg2pix(stimsize,'ceil');
stimsizeN2=deg2pix(stimsize2,'ceil');

x_ecc=linspace(-stimsize/2,stimsize/2,stimsizeN);
x_ecc2=linspace(-stimsize2/2,stimsize2/2,stimsizeN2);

for i=1:length(sfdom1)
    sdom = x_ecc*sfdom1(i)*2*pi; %radians
    grating = cos(sdom);

    if strcmp(P.s_profile,'square')
        thresh = cos(P.s_duty*pi);
        grating=sign(grating-thresh);
    end
    
    %Screen('SelectStereoDrawBuffer', screenPTR, 0);
    Gtxtr(i) = Screen('MakeTexture',screenPTR, grating,[],[],2);
end

for i=1:length(sfdom2)
    sdom2 = x_ecc2*sfdom2(i)*2*pi; %radians
    grating2 = cos(sdom2);

    if strcmp(P.s_profile,'square')
        thresh = cos(P.s_duty*pi);
        grating2=sign(grating2-thresh);
    end
    %Screen('SelectStereoDrawBuffer', screenPTR, 1);
    Gtxtr2(i) = Screen('MakeTexture',screenPTR, grating2,[],[],2);
end

%save sequence data
if Mstate.running
    saveLog(Gseq,P.rseed,loopTrial)  %append log file with the latest sequence
   saveLog(Gseq2,P.rseed,loopTrial) 
end





