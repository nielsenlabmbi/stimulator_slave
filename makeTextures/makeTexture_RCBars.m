function makeTexture_RCBars

%reverse correlation with bars to map receptive fields; black/white bars
%only at this time

global Mstate screenPTR screenNum loopTrial

global Gseq Gtxtr barTxtr


if ~isempty(barTxtr)
    Screen('Close',barTxtr);  %First clean up: Get rid of all textures/offscreen windows
end
barTxtr = [];
Gtxtr = [];  
Gseq=[];


screenRes = Screen('Resolution',screenNum);
fps=screenRes.hz;      % frames per second

P = getParamStruct;


%generate basic bars, either black and white or one color only
barW=deg2pix(P.barWidth,'round');
barL=deg2pix(P.barLength,'round');

if P.bw_bit==0 %black bar only
    Im = zeros(barL,barW);
    barTxtr = Screen(screenPTR, 'MakeTexture',Im,[],[],2);
elseif P.bw_bit==1 %white bar only
    Im = ones(barL,barW);
    barTxtr = Screen(screenPTR, 'MakeTexture',Im,[],[],2);
else %black and white
    Im = zeros(barL,barW);
    barTxtr(1) = Screen(screenPTR, 'MakeTexture',Im,[],[],2);
    Im = ones(barL,barW);
    barTxtr(2) = Screen(screenPTR, 'MakeTexture',Im,[],[],2);
end


%convert stimulus size to pixel
stimW=deg2pix(P.x_size,'round');
stimH=deg2pix(P.y_size,'round');

%define the perimeters of the "location grid"
xbound = [P.x_pos-ceil(stimW/2)+1  P.x_pos+floor(stimW/2)];
ybound = [P.y_pos-ceil(stimH/2)+1  P.y_pos+floor(stimH/2)];

%make position domain
xdom = linspace(xbound(1),xbound(2),P.N_x); %Make x domain  (these are the center locations of the bar)
ydom = linspace(ybound(1),ybound(2),P.N_y); %Make y domain

%Make orientation domain
oridom = linspace(P.min_ori,P.min_ori+P.orirange,P.n_ori+1);
oridom = oridom(1:end-1);

%Make bw domain
if P.bw_bit == 0 || P.bw_bit == 1
    bwdom = 1;
else
    bwdom = [1 2];
end

%number of images (aka bar configurations) to present per trial
N_Im = round(P.stim_time*screenRes.hz/P.h_per); 

%Create independent sequence for each parameter - need N_bar x N_im for
%each
s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*str2double(Mstate.unit)+str2double(Mstate.expt)+P.rseed);

xseq = randi(s,[1 length(xdom)],P.N_bar,N_Im); 
yseq = randi(s,[1 length(ydom)],P.N_bar,N_Im); 
oriseq = randi(s,[1 length(oridom)],P.N_bar,N_Im); 
bwseq = randi(s,[1 length(bwdom)],P.N_bar,N_Im); 
    

%save all sequences and domains in Gseq
Gseq.xdom=xdom;
Gseq.ydom=ydom;
Gseq.bwdom=bwdom;
Gseq.oridom=oridom;
Gseq.xseq=xseq;
Gseq.yseq=yseq;
Gseq.oriseq=oriseq;
Gseq.bwseq=bwseq;


%we determine the stimulus locations here to save time during the play loop
deltaFrame = deg2pix(P.speed,'none')/fps;
for n=1:P.N_bar
    %get the position sequence for each image
    xloc=xdom(xseq(n,:)); %xloc: positions for 1 bar, all images
    yloc=ydom(yseq(n,:));
    
    %get the orientation sequence
    ori=oridom(oriseq(n,:));
    
    %tie orientation to position for Radon transform
    if strcmp(P.gridType,'polar')
        xlocRot = (xloc-P.x_pos).*cos(-ori*pi/180) - (yloc-P.y_pos).*sin(-ori*pi/180);
        ylocRot = (xloc-P.x_pos).*sin(-ori*pi/180) + (yloc-P.y_pos).*cos(-ori*pi/180);

        xloc = xlocRot+P.x_pos;
        yloc = ylocRot+P.y_pos;
    end
    disp(size(xloc))
    
    %now loop through images and determine locations and colors
    for i=1:N_Im
        xinc = deltaFrame*cos(ori(i)*pi/180);
        yinc = -deltaFrame*sin(ori(i)*pi/180);  %negative because origin is at top
 
        for j = 1:P.h_per
            dx = (j-1)*xinc;
            dy = (j-1)*yinc;
            
            stimDst{i,j}(:,n)=CenterRectOnPoint([0 0 barW barL],xloc(i)+dx,yloc(i)+dy); 
        end

        Gtxtr{i}(n) = barTxtr(bwseq(n,i));
    end
end

Gseq.stimDst=stimDst;

if Mstate.running %if its in the looper    
    saveLog(Gseq,P.rseed,loopTrial)  %append log file with the latest sequence
end




