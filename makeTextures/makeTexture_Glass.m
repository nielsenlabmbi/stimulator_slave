function makeTexture_Glass
%this function generates random dots with a second dot of the same size
%oriented at some degree off that dot. coherence determines how many of the
%dots share the same orientation off the original or not.
%edited 9/29/16 by Cynthia Steinhardt

global Mstate DotFrame screenNum loopTrial 

%clean up
DotFrame=[];

%get parameters
P = getParamStruct;


%parameters for the stimulus window
stimSizePx(1)=deg2pix(P.x_size,'round');
stimSizePx(2)=deg2pix(P.y_size,'round');

deltaDot=deg2pix(P.deltaDot,'round');

%initialize random number generate to time of date
s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*str2double(Mstate.unit)+str2double(Mstate.expt)+loopTrial);

%initialize dot positions
randpos=rand(s,2,P.nrDots); %this gives numbers between 0 and 1
randpos(1,:)=(randpos(1,:)-0.5)*stimSizePx(1); %now we have between -stimsize/2 and +stimsize/2
randpos(2,:)=(randpos(2,:)-0.5)*stimSizePx(2);

%copy dot positions to generate pairs 
xproj=cos(P.ori*pi/180);
yproj=-sin(P.ori*pi/180);

randpos2(1,:)=randpos(1,:)+deltaDot*xproj;
randpos2(2,:)=randpos(2,:)+deltaDot*yproj;

%pick noise pairs
nrSignal=round(P.nrDots*P.dotCoherence/100); %nrDots refers to dot pairs in this program
nrNoise=P.nrDots-nrSignal;


%generate random locations for the noise dots - we change the orientation
%of the pair
if nrNoise>0
    noiseori=rand(1,nrNoise)*360;
    xproj=cos(noiseori*pi/180);
    yproj=-sin(noiseori*pi/180);
       
    randpos2(1,1:nrNoise)=randpos(1,1:nrNoise)+P.deltaDot*xproj; 
    randpos2(2,1:nrNoise)=randpos(2,1:nrNoise)+P.deltaDot*yproj;
end

randpos=[randpos randpos2];

DotFrame = randpos;

%Save it if 'running' experiment
if Mstate.running
    saveLog_Dots(DotFrame,loopTrial);
end
