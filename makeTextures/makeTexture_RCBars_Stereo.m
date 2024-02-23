function makeTexture_RCBars_Stereo

%reverse correlation with bars to map receptive fields; black/white bars
%only at this time

global Mstate screenPTR screenNum loopTrial

global Gseq Gtxtr barTxtr Gseq2 Gtxtr2 barTxtr2


if ~isempty(barTxtr)
    Screen('Close',barTxtr);  %First clean up: Get rid of all textures/offscreen windows
end
barTxtr = [];
Gtxtr = [];  
Gseq=[];
barTxtr2 = [];
Gtxtr2 = [];  
Gseq2=[];



screenRes = Screen('Resolution',screenNum);
fps=screenRes.hz;      % frames per second

P = getParamStruct;


%generate basic bars, either black and white or one color only
barW=deg2pix(P.barWidth,'round');
barL=deg2pix(P.barLength,'round');

barW2=deg2pix(P.barWidth2,'round');
barL2=deg2pix(P.barLength2,'round');
        
Screen('SelectStereoDrawBuffer', screenPTR, 0);

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

Screen('SelectStereoDrawBuffer', screenPTR, 1);
if P.bw_bit2==0 %black bar only
    Im2 = zeros(barL2,barW2);
    barTxtr = Screen(screenPTR, 'MakeTexture',Im2,[],[],2);
elseif P.bw_bit==1 %white bar only
    Im2 = ones(barL2,barW2);
    barTxtr2 = Screen(screenPTR, 'MakeTexture',Im2,[],[],2);
else %black and white
    Im2 = zeros(barL2,barW2);
    barTxtr2(1) = Screen(screenPTR, 'MakeTexture',Im2,[],[],2);
    Im2 = ones(barL2,barW2);
    barTxtr2(2) = Screen(screenPTR, 'MakeTexture',Im2,[],[],2);
end

%convert stimulus size to pixel
stimW=deg2pix(P.x_size,'round');
stimH=deg2pix(P.y_size,'round');

stimW2=deg2pix(P.x_size2,'round');
stimH2=deg2pix(P.y_size2,'round');

%define the perimeters of the "location grid"
xbound = [P.x_pos-ceil(stimW/2)+1  P.x_pos+floor(stimW/2)];
ybound = [P.y_pos-ceil(stimH/2)+1  P.y_pos+floor(stimH/2)];

xbound2 = [P.x_pos2-ceil(stimW2/2)+1  P.x_pos2+floor(stimW2/2)];
ybound2 = [P.y_pos2-ceil(stimH2/2)+1  P.y_pos2+floor(stimH2/2)];

%make position domain
xdom = linspace(xbound(1),xbound(2),P.N_x); %Make x domain  (these are the center locations of the bar)
ydom = linspace(ybound(1),ybound(2),P.N_y); %Make y domain

xdom2 = linspace(xbound2(1),xbound2(2),P.N_x2); %Make x domain  (these are the center locations of the bar)
ydom2 = linspace(ybound2(1),ybound2(2),P.N_y2); %Make y domain

%Make orientation domain
oridom = linspace(P.min_ori,P.min_ori+P.orirange,P.n_ori+1);
oridom = oridom(1:end-1);

%Make bw domain
if P.bw_bit == 0 || P.bw_bit == 1
    bwdom = 1;
else
    bwdom = [1 2];
end

if P.bw_bit2 == 0 || P.bw_bit2 == 1
    bwdom2 = 1;
else
    bwdom2 = [1 2];
end

%number of images (aka bar configurations) to present per trial
N_Im = round(P.stim_time*screenRes.hz/P.h_per); 

%Create independent sequence for each parameter - need N_bar x N_im for
%each
s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*str2double(Mstate.unit)+str2double(Mstate.expt)+P.rseed);

if P.EyeVary==0
xseq = randi(s,[1 length(xdom)],P.N_bar,N_Im); 
yseq = randi(s,[1 length(ydom)],P.N_bar,N_Im); 
oriseq = randi(s,[1 length(oridom)],P.N_bar,N_Im); 
bwseq = randi(s,[1 length(bwdom)],P.N_bar,N_Im); 

xseq2 = randi(s,[1 length(xdom2)],P.N_bar2,N_Im); 
yseq2 = randi(s,[1 length(ydom2)],P.N_bar2,N_Im); 
oriseq2 = randi(s,[1 length(oridom)],P.N_bar2,N_Im); 
bwseq2 = randi(s,[1 length(bwdom2)],P.N_bar2,N_Im); 

elseif P.EyeVary==1
xseq = randi(s,[1 length(xdom)],P.N_bar,N_Im); 
yseq = randi(s,[1 length(ydom)],P.N_bar,N_Im); 
oriseq = randi(s,[1 length(oridom)],P.N_bar,N_Im); 
bwseq = randi(s,[1 length(bwdom)],P.N_bar,N_Im);   

xseq2 = ones(P.N_bar2, N_Im); 
yseq2 = ones(P.N_bar2, N_Im); 
oriseq2 = ones(P.N_bar2, N_Im); 
bwseq2 = ones(P.N_bar2, N_Im);

elseif P.EyeVary==2
xseq= ones(P.N_bar2, N_Im); 
yseq = ones(P.N_bar2, N_Im); 
oriseq = ones(P.N_bar2, N_Im); 
bwseq = ones(P.N_bar2, N_Im);
    

xseq2 = randi(s,[1 length(xdom)],P.N_bar2,N_Im); 
yseq2 = randi(s,[1 length(ydom)],P.N_bar2,N_Im); 
oriseq2 = randi(s,[1 length(oridom)],P.N_bar2,N_Im); 
bwseq2 = randi(s,[1 length(bwdom)],P.N_bar2,N_Im);  
end

%save all sequences and domains in Gseq
Gseq.xdom=xdom;
Gseq.ydom=ydom;
Gseq.bwdom=bwdom;
Gseq.oridom=oridom;
Gseq.xseq=xseq;
Gseq.yseq=yseq;
Gseq.oriseq=oriseq;
Gseq.bwseq=bwseq;

Gseq2.xdom=xdom2;
Gseq2.ydom=ydom2;
Gseq2.bwdom=bwdom2;
Gseq2.oridom=oridom;
Gseq2.xseq=xseq2;
Gseq2.yseq=yseq2;
Gseq2.oriseq=oriseq2;
Gseq2.bwseq=bwseq2;

%we determine the stimulus locations here to save time during the play loop
deltaFrame = deg2pix(P.speed,'none')/fps;

deltaFrame2 = deg2pix(P.speed2,'none')/fps;

for n=1:P.N_bar
    %get the position sequence for each image
    xloc=xdom(xseq(n,:)); %xloc: positions for 1 bar, all images
    yloc=ydom(yseq(n,:));
    xloc2=xdom2(xseq2(n,:)); %xloc: positions for 1 bar, all images
    yloc2=ydom2(yseq2(n,:));
    %get the orientation sequence
    ori=oridom(oriseq(n,:));
    ori2=oridom(oriseq2(n,:));

    %tie orientation to position for Radon transform
    if strcmp(P.gridType,'polar')
        xlocRot = (xloc-P.x_pos).*cos(-ori*pi/180) - (yloc-P.y_pos).*sin(-ori*pi/180);
        ylocRot = (xloc-P.x_pos).*sin(-ori*pi/180) + (yloc-P.y_pos).*cos(-ori*pi/180);
        
        xlocRot2 = (xloc2-P.x_pos2).*cos(-ori2*pi/180) - (yloc2-P.y_pos2).*sin(-ori2*pi/180);
        ylocRot2 = (xloc2-P.x_pos2).*sin(-ori2*pi/180) + (yloc2-P.y_pos2).*cos(-ori2*pi/180);

        xloc = xlocRot+P.x_pos;
        yloc = ylocRot+P.y_pos;
        
        xloc2 = xlocRot2+P.x_pos2;
        yloc2 = ylocRot2+P.y_pos2;
    end
    disp(size(xloc))
    disp(size(xloc2))

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
        
        xinc2 = deltaFrame2*cos(ori2(i)*pi/180);
        yinc2 = -deltaFrame2*sin(ori2(i)*pi/180);  %negative because origin is at top
 
        for j = 1:P.h_per
            dx2 = (j-1)*xinc2;
            dy2 = (j-1)*yinc2;
            
            stimDst2{i,j}(:,n)=CenterRectOnPoint([0 0 barW2 barL2],xloc2(i)+dx2,yloc2(i)+dy2); 
        end

        Gtxtr2{i}(n) = barTxtr2(bwseq2(n,i));
    end
end

Gseq.stimDst=stimDst;
Gseq2.stimDst=stimDst2;

if Mstate.running %if its in the looper    
    saveLog(Gseq,P.rseed,loopTrial)  %append log file with the latest sequence
    saveLog(Gseq2,P.rseed,loopTrial)  %append log file with the latest sequence

end




