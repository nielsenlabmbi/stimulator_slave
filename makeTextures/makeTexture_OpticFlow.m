function makeTexture_OpticFlow

%stimuli: basic set described in Duffy & Wurtz 91 - translation, circular
%and radial motion; also added random condition
%same idea: speed sets speed for translational, radial and random stimuli and random; for the circular
%motion, it sets the average speed
%all stimuli are programmed as circles -> large enough circles make
%fullfield stimuli
%reason: wrap around for the radial and circular condition are difficult to get right otherwise
%four types of translation: up, down, left, right
%two types of rotation: cw, ccw
%two types of radial: expansion, contraction
%this uses the classic way of generating noise dots, in which they are
%simply moved to some other location on the screen. i.e. noise dots have
%different speeds and directions, unlike the brownian type motion used for
%noise dots in the RDK stimulus

global  Mstate DotFrame screenNum loopTrial;


%get parameters
P = getParamStruct;

%get screen settings
screenRes = Screen('Resolution',screenNum);
fps=screenRes.hz;      % frames per second


%stimulus radius in pixels
stimRadiusPx=deg2pix(P.stimRadius,'round');

%dot displacement
if P.stimType~=3
    deltaFrame = deg2pix(P.speedDots,'none')/fps;
else %different speed for rotating stimulus
    %average speed for a circular motion: v=dtheta/dt *r
    deltaFrame=P.speedDots/(P.stimRadius/sqrt(2))*(1/fps);
end


%figure out how many dots 
stimArea=P.stimRadius^2*4;  %we initialize all stimuli on a square, so use that to compute area
nrDots=round(P.dotDensity*stimArea/fps); %this is the number of dots in each frame


%initialize random number generate to time of date
s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*str2double(Mstate.unit)+str2double(Mstate.expt)+loopTrial);


%initialize dot positions
%initialization using polar coordinates leads to 'clumping' in the center, so 
%need to initialize on a square no matter which condition
randpos=rand(s,2,nrDots); %this gives numbers between 0 and 1

xypos=[];
if P.stimType<3 %for the translation stimulus, we keep all of these dots
    xypos(1,:)=(randpos(1,:)-0.5)*stimRadiusPx*2; %now we have between -stimsize and +stimsize
    xypos(2,:)=(randpos(2,:)-0.5)*stimRadiusPx*2;
else %for the other stimuli, remove the dots that are outside the center and correct nr of dots accordingly
    tmpx=(randpos(1,:)-0.5)*stimRadiusPx*2;
    tmpy=(randpos(2,:)-0.5)*stimRadiusPx*2;
    idx=find(sqrt(tmpx.^2+tmpy.^2)<stimRadiusPx);
  
    nrDots=length(idx);
    xypos(1,:)=tmpx(idx);
    xypos(2,:)=tmpy(idx);
end

%initialize signal/noise vector; 1 indicates signal, 0 indicates noise
nrSignal=round(nrDots*P.dotCoherence/100);
noisevec=zeros(nrDots,1);
noisevec(1:nrSignal)=1;

%initialize lifetime vector - between 1 and dotLifetimte
if P.dotLifetime>0
    randlife=randi(s,P.dotLifetime,nrDots,1);
    lifetime=randlife;
end

%figure out how many frames - we use the first and the last frame to be
%shown in the pre and postdelay, so only stimulus duration matters here
nrFrames=ceil(P.stim_time*fps);

DotFrame={};
tmpFrame={};

for i=1:nrFrames
    
    %check lifetime (unless inf)
    if P.dotLifetime>0
        idx=find(lifetime==0);
        %reposition the dots that are too old - different procedures based
        %on stimulus type (see reasoning below)   
        if P.stimType<3 
            temppos=rand(s,2,length(idx));
            xypos(1,idx)=(temppos(1,:)-0.5)*stimRadiusPx*2; 
            xypos(2,idx)=(temppos(2,:)-0.5)*stimRadiusPx*2;
        else
            [~,rad]=cart2pol(xypos(1,idx),xypos(2,idx));
            thrand=rand(s,1,length(idx))*2*pi;
            [xypos(1,idx),xypos(2,idx)]=pol2cart(thrand,rad);
        end
        lifetime=lifetime-1;
        lifetime(idx)=P.dotLifetime;
    end
    
    
    %generate new positions - this is different for noise and signal pixels
    %the algorithm we use here is the one described in Britten et al, 1993
    %first determine which pixels are signal or noise
    noiseid=noisevec(randperm(s,nrDots));
    

    %noise dots are randomly placed somewhere; again, because of the
    %clumping when randomizing the radius, we only randomize the phase for the radial stimuli, not the
    %radius
    idx=find(noiseid==0);
    if P.stimType<3
        temppos=rand(s,2,length(idx));
        xypos(1,idx)=(temppos(1,:)-0.5)*stimRadiusPx*2; 
        xypos(2,idx)=(temppos(2,:)-0.5)*stimRadiusPx*2;
    else
        [~,rad]=cart2pol(xypos(1,idx),xypos(2,idx));
        thrand=rand(s,1,length(idx))*2*pi;
        [xypos(1,idx),xypos(2,idx)]=pol2cart(thrand,rad);
    end
        
    
    %signal dots go with preset motion direction
    idx=find(noiseid==1);
    switch P.stimType
        case 0 %random motion
            
            %random orientation vector
            ori=rand(s,size(idx))*2*pi;
            
            %move dots
            xypos(1,idx)=xypos(1,idx)+P.stimDir*deltaFrame.*cos(ori)';
            xypos(2,idx)=xypos(2,idx)-P.stimDir*deltaFrame.*sin(ori)';
            
            %randomly reposition the dots that are outside the window now
            idx2=find(abs(xypos(1,:))>stimRadiusPx | abs(xypos(2,:))>stimRadiusPx);
            rvec=rand(s,2,length(idx2));
            xypos(1,idx2)=(rvec(1,:)-0.5)*stimRadiusPx*2;
            xypos(2,idx2)=(rvec(2,:)-0.5)*stimRadiusPx*2;
        
        
        case 1 %translation along x
            
            xypos(1,idx)=xypos(1,idx)+P.stimDir*deltaFrame;
            
            %check which ones are outside and place back on the other side
            idx2=find(abs(xypos(1,:))>stimRadiusPx);
            rvec=rand(s,size(idx2));
            xypos(1,idx2)=-1*P.stimDir*stimRadiusPx;
            xypos(2,idx2)=(rvec-0.5)*2*stimRadiusPx;
            
        case 2 %translation along y
           
            xypos(2,idx)=xypos(2,idx)-P.stimDir*deltaFrame;
            
            %check which ones are outside and place back on the other side
            idx2=find(abs(xypos(2,:))>stimRadiusPx);
            rvec=rand(s,size(idx2));
            xypos(1,idx2)=(rvec-0.5)*stimRadiusPx*2;
            xypos(2,idx2)=P.stimDir*stimRadiusPx;
            
        case 3 %rotation - in this case speed is angular speed
            %no wrap around procedure necessary here
            
            %half the number of dots are contained within a circle of
            %radius 1/sqrt(2)*stimRadius
                    
            %now compute movement stuff - first get radius and angle
            [th,rad]=cart2pol(xypos(1,idx),xypos(2,idx));
            
            %result of cart2pol has theta in radians, with 0 to pi = 0 to
            %180, and -pi to 0 = 180 to 360; transform to 0 to 2pi         
            idx2=find(th<0);
            th(idx2)=2*pi+th(idx2);
            
            %translate
            th=th+P.stimDir*deltaFrame;
                             
            %go back to cartesian
            [xtemp,ytemp]=pol2cart(th,rad);
            xypos(1,idx)=xtemp;
            xypos(2,idx)=ytemp;
            
            
        case 4 %radial pattern
            %radial pattern needs to be solved differently than the other
            %patterns because of wrap around; problem: in the expanding
            %stimulus, every deltaFrame ring loses dots (because the
            %smaller rings have less dots in them); this can be fixed by
            %redistributing the dots that come out of the largest ring in
            %every frame; if the stimulus contracts, every ring has more
            %dots in the subsequent frame than before -> would need to
            %redistribute them somehow.... easier to just run an expanding
            %stimulus backwards
            
            [th,rad]=cart2pol(xypos(1,idx),xypos(2,idx));
                                   
            rad=rad+deltaFrame;
            
            %wrap around          
            %logic behind this computation: a ring of width deltaFrame,
            %from r to r+deltaFrame, contains (ignoring the density)
            %nrdots = pi(r+deltaFrame)^2-pi r^2= 2pi r deltaFrame+piDeltaFrame^2
            %based on this, every frame each of the deltaFrame rings
            %loses 2 pi deltaFrame^2 dots; the only exception is the
            %central ring, which only loses pi deltaFrame^2 dots
            %so to correctly fill in dots, we need to adjust the
            %probability of assigning the radius for the central ring
            %and all other rings; likelihood for a dot needing to be
            %placed at the center is 1/(2*(nrbins-1)+1, which ends up
            %being 1/(2*stimRadiusPx/deltaFrame -1)
                
                
            %find out of bounds dots
            idx2=find(rad>stimRadiusPx);
            
            %determine how many dots should fall into the center based
            %on probability distribution described above
            probinner=1/(2*stimRadiusPx/deltaFrame-1);
            rinout=rand(s,1,length(idx2));
            nrinner=length(find(rinout<probinner));
            
            %now get new locations (random radius within limit, random
            %theta)
            tmprad=[];
            tmprad(1:nrinner)=rand(s,1,nrinner)*deltaFrame;
            tmprad(nrinner+1:length(idx2))=rand(s,1,length(idx2)-nrinner)*...
                (stimRadiusPx-deltaFrame)+deltaFrame;
      
            tmpth=rand(s,1,length(idx2))*2*pi;
            
            %put back into original matrix
            rad(idx2)=tmprad;
            th(idx2)=tmpth;
            
            %done with wrap around and moving, generate xypos for next
            %frame
            [xtemp,ytemp]=pol2cart(th,rad);
            xypos(1,idx)=xtemp;
            xypos(2,idx)=ytemp;
            
        
            
        otherwise
            disp('undefined stimulus type')
    end
    
   
    
    %make sure to only keep dots inside the stimulus radius
    [~,rad]=cart2pol(xypos(1,:),xypos(2,:));
    idx=find(rad<stimRadiusPx);
    
    if P.stimDir==-1 && P.stimType==4 %we still need to reverse the order for the contracting stimuli
        tmpFrame{i}=xypos(:,idx);
    else
        DotFrame{i}=xypos(:,idx);
    end
   
end

if P.stimDir==-1 && P.stimType==4
    for i=1:nrFrames
        DotFrame{i}=tmpFrame{nrFrames-i+1};
    end
end
