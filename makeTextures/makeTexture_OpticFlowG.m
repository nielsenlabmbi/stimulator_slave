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
speedPlane = [1 1/2 3/2]*avgDeltaFrame; %this is for radius independent speed planes

deltaFrame=zeros(1,nrDots);
dotDir=zeros(1,nrDots);

%initialize lifetime vector: set everything to 0 here so every dot gets an
%initial direction and speed; set to random start value for frame 1 later 
lifetime=zeros(1, nrDots);

%figure out how many noise dots there are
nrNoise=round(nrDots*(1-P.dotCoherence/100)); 

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
        dotDir(idx)=th+P.ori/180*pi; %this is in radians
        if P.speedGradient==1
            deltaFrame(idx)=speedScale*rad;
        else
            %split dots into 3 groups to assign to speed planes
            sidx=randi(s,3,size(idx));
            deltaFrame(idx)=speedPlane(sidx);
        end
        
        %for the contracting stimulus, we need to flag dots that would
        %cross to the opposite side of the center and move in the wrong
        %direction there
        %turns out this is not noticeable
        %if P.ori==0 
        %    flagOut=find(deltaFrame>rad);
        %end
    else
        %for translation, set all of these dots to signal direction
        dotDir(idx)=P.ori/180*pi;
        if P.speedGradient==1
            deltaFrame(idx)=avgDeltaFrame;
        else
            sidx=randi(s,3,size(idx));
            deltaFrame(idx)=speedPlane(sidx);
        end
    end
    
    %noise: either randomly reposition or randomly assign direction to
    %preserve speed gradient
    if P.noiseType==0 %reposition, assign new speed and direction accordingly
        idxNoise=randperm(s,nrDots,nrNoise);
        rvec=rand(s,[2 length(idxNoise)]); 
        xypos(1,idxNoise)=(rvec(1,:)-0.5)*2*stimRadius;
        xypos(2,idxNoise)=(rvec(2,:)-0.5)*2*stimRadius;
        
        if P.spiralBit==1 %spiral           
            [th,rad]=cart2pol(xypos(1,idxNoise),xypos(2,idxNoise));
            dotDir(idxNoise)=th+P.ori/180*pi; %this is in radians
            if P.speedGradient==1
                deltaFrame(idxNoise)=speedScale*rad;
            else
                %split dots into 3 groups to assign to speed planes
                sidx=randi(s,3,size(idxNoise));
                deltaFrame(idxNoise)=speedPlane(sidx);
            end
        else
            dotDir(idxNoise)=P.ori/180*pi;
            if P.speedGradient==1
                deltaFrame(idxNoise)=avgDeltaFrame;
            else
                sidx=randi(s,3,size(idxNoise));
                deltaFrame(idxNoise)=speedPlane(sidx);
            end
        end
        %reset the lifetime to full (at the end of the loop) 
        lifetime(idxNoise)=0; 
    else %change direction only
        %we randomly pick a fraction of the lifetime 0 dots for this method
        %dots will keep their assignment for their lifetime
        signalid=rand(s,1,length(idx))<P.dotCoherence/100; %id=1: signal
        randdir=round(360*rand(s,1,length(idx)-sum(signalid)));
        dotDir(idx(signalid==0))=randdir;
    end
    
    %now move everyone
    xypos(1,:)=xypos(1,:)-deltaFrame.*cos(dotDir);
    xypos(2,:)=xypos(2,:)-deltaFrame.*sin(dotDir);
    
    %deal with the ones that end up outside of the stimulus: reshuffle and
    %assign new speed based on position (speed and direction only matter on
    %next frame)
    idxOut=find(abs(xypos(1,:))>stimRadius | abs(xypos(2,:))>stimRadius);
    rvec=rand(s,[2 length(idxOut)]); 
    xypos(1,idxOut)=(rvec(1,:)-0.5)*2*stimRadius;
    xypos(2,idxOut)=(rvec(2,:)-0.5)*2*stimRadius;
    if P.spiralBit==1 %spiral
        [th,rad]=cart2pol(xypos(1,idxOut),xypos(2,idxOut));
        dotDir(idxOut)=th+P.ori/180*pi; %this is in radians
        if P.speedGradient==1
            deltaFrame(idxOut)=speedScale*rad;
        else
            %split dots into 3 groups to assign to speed planes
            sidx=randi(s,3,size(idxOut));
            deltaFrame(idxOut)=speedPlane(sidx);
        end
    else
        dotDir(idxOut)=P.ori/180*pi;
        if P.speedGradient==1
            deltaFrame(idxOut)=avgDeltaFrame;
        else
            sidx=randi(s,3,size(idxOut));
            deltaFrame(idxOut)=speedPlane(sidx);
        end
    end
    %reset the lifetime to full (at the end of the loop)
    lifetime(idxOut)=0;
        
    %update lifetime
    if f==1
        randlife=randi(s,P.dotLifetime,nrDots,1);
        lifetime=randlife;
    else
        lifetime(lifetime==0)=P.dotLifetime; 
        lifetime=lifetime-1;
    end
    
   
        
    %for the contracting stimulus only (Sdir==pi), eliminate dots that
    %cross the origin
    %if isempty(flagOut)
    %    rvec=rand(s,[2 length(flagOut)]); 
    %    xypos(1,flagOut)=(rvec(1,:)-0.5)*2*stimRadius;
    %    xypos(2,flagOut)=(rvec(2,:)-0.5)*2*stimRadius;
    %    lifetime(flagOut)=0;
    %end  
   
    %now save, keeping only dots that are inside the radius
    [~,rad]=cart2pol(xypos(1,:),xypos(2,:));
    DotFrame{f}=xypos(:,rad<stimRadius);
    
end %for frames


