function makeTexture_OpticFlowG

%stimuli: this is the set described in Graziano et al 1994
% logic: 
% - each dot has a limited lifetime (doesn't work otherwise)
% - during the lifetime, each dot moves in a constant direction at a
% constant speed (this way accelaration and path curvature cannot be used
% to distinguish between patterns)
% - speed is set to K*r (where r is the distance from the center) for all
% but the translational patterns; the translational patterns move at the
% average speed of the other patterns
% - dots are randomly replotted when the fall outside the perimeter (which
% will happen even for the rotation since the path is not curved)
% - spiral pattern consists of combination of expansion plus rotation
% (equal weight)

% Sdir notation for spiral space: 0 expansion, pi contraction



global  Mstate DotFrame screenNum loopTrial;


%get parameters
P = getParamStruct;

%get screen settings
screenRes = Screen('Resolution',screenNum);
fps=screenRes.hz;      % frames per second


%size parameters - this stimulus will be forced to be round (large enough
%will fill screen)
%we're computing the nr of dots based on a square, since it is easier to
%initialize/shuffle them on a square to get a homogeneous density
stimRadius=deg2pix(P.stimRadius,'round');
nrDots=round(P.dotDensity*P.stimRadius.^2);%density is specified in dots/(deg^2) 


%initialize random number generate to time of date
s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*str2double(Mstate.unit)+str2double(Mstate.expt)+loopTrial);

%initialize dot positions, delta position and orientation
xypos=zeros(2,nrDots); 

%displacements: set so that the scaling factor makes the average speed
%appear at half the stimulus radius
avgDeltaFrame = deg2pix(P.avgSpeedDots,'none')/fps; %this is the displacement based on the average speed in pixels per frame
speedScale = 2*avgDeltaFrame/stimRadius; 

if P.spiralBit==1 %spiral; everything gets set during first frame
    deltaFrame=zeros(nrDots,1);
    dotDir=zeros(nrDots,1);
else
    deltaFrame=avgDeltaFrame;
    dotDir=P.Tdir/180*pi; %needs to be in radians
end

%initialize lifetime vector: set everything to 0 here so every dot gets an
%initial direction and speed; set to random start value for frame 1 later 
lifetime=zeros(nrDots,1);


%figure out how many frames - we use the first and the last frame to be
%shown in the pre and postdelay, so only stimulus duration matters here
nrFrames=ceil(P.stim_time*fps);

%now generate dot coordinates for all frames
DotFrame={};

for f=1:nrFrames 
    %find dots with lifetime 0 (only then does the direction/speed change)
    idx=find(lifetime==0);
    
    %first move these dots to a new position
    rvec=rand(s,[2 length(idx)]); %gives numbers between 0 and 1
    xypos(1,idx)=(rvec(1,:)-0.5)*2*stimRadius;
    xypos(2,idx)=(rvec(2,:)-0.5)*2*stimRadius;
    
    %now update direction and speed
    if P.spiralBit==1 %spiral
        %get polar coordinates of dots to figure out speed and direction
        [th,rad]=cart2pol(xypos(1,idx),xypos(2,idx));
        dotDir(idx)=th+P.Sdir/180*pi; %this is in radians
        deltaFrame(idx)=speedScale*rad;
        
        %for the contracting stimulus, we need to flag dots that would
        %cross to the opposite side of the center and move in the wrong
        %direction there
        flagOut=[];
        if P.Sdir==180 
            flagOut=find(deltaFrame>rad);
        end
        
    end
    
    %now move everyone
    xypos(1,:)=xypos(1,:)-deltaFrame.*cos(dotDir);
    xypos(2,:)=xypos(2,:)-deltaFrame.*sin(dotDir);
    
    %update lifetime
    if f==1
        randlife=randi(s,P.dotLifetime,nrDots,1);
        lifetime=randlife;
    else
        lifetime=lifetime-1;
        lifetime(idx)=P.dotLifetime;
    end
    
    %randomly reshuffle the ones that end up outside the stimulus (these
    %will need to have their speeds etc recomputed, so set their lifetime to 0 at this point)
    %because density is computed on square, use that to figure out of
    %bounds
    idxOut=find(abs(xypos(1,:))>stimRadius | abs(xypos(2,:))>stimRadius);
    rvec=rand(s,[2 length(idxOut)]); 
    xypos(1,idxOut)=(rvec(1,:)-0.5)*2*stimRadius;
    xypos(2,idxOut)=(rvec(2,:)-0.5)*2*stimRadius;
    lifetime(idxOut)=0;
        
    %for the contracting stimulus only (Sdir==pi), eliminate dots that
    %cross the origin
    if isempty(flagOut)
        rvec=rand(s,[2 length(flagOut)]); 
        xypos(1,flagOut)=(rvec(1,:)-0.5)*2*stimRadius;
        xypos(2,flagOut)=(rvec(2,:)-0.5)*2*stimRadius;
        lifetime(flagOut)=0;
    end  
   
    %now save, keeping only dots that are inside the radius
    [~,rad]=cart2pol(xypos(1,:),xypos(2,:));
    DotFrame{f}=xypos(rad>stimRadius,:);
    
end %for frames


