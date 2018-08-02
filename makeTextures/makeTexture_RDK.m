function makeTexture_RDK
%this function generates random dots using a brownian motion approach
%dots have a limited lifetime, at the end of their lifetime, they get
%assigned either the preset direction, or a random direction
%thus, all dots move at the same speed
%the program generates either one field of dots (motionopp_bit=0 and
%surround_bit=0), two fields of dots in the same region (motionopp_bit=1
%and surround_bit=0), or a central field of dots surrounded by a second
%field of dots (motionopp_bit=0 and surround_bit=1). motionopp_bit=1 and
%surround_bit=1 behaves like motionopp_bit=1 and surround_bit=0
%for wrap around calculations, we treat the stimuli like rectangles, so
%area is also calculated based on a rectangle, not a circle

%10/7/16: added option to remove net noise movement; this will not be
%perfect for limited lifetimes; at the beginning, directions are balanced, 
%but small imbalances may arise over time when dots are reassigned new
%directions after the lifetime ends

global Mstate DotFrame screenNum loopTrial 

%clean up
DotFrame={};


%get parameters
P = getParamStruct;

%get screen settings
screenRes = Screen('Resolution',screenNum);
fps=screenRes.hz;      % frames per second


%parameters for the main RDK
stimSize=[P.x_size P.y_size];
stimSizePx(1)=deg2pix(P.x_size,'round');
stimSizePx(2)=deg2pix(P.y_size,'round');
maskradiusPx=deg2pix(P.mask_radius,'round');
stimArea=stimSize(1)*stimSize(2);

nrDots=round(P.dotDensity*stimArea); %density is specified in dots/(deg^2)

deltaFrame = deg2pix(P.speedDots,'none')/fps;  % displacement per frame, based on dot speed (pixels/frame)

%size parameters for the second grating if necessary
if P.motionopp_bit==1
    stimSizePx2=stimSizePx;
    maskradiusPx2=maskradiusPx;
    stimArea2=stimArea;
    
    nrDots2=round(P.dotDensity2*stimArea2);
    
    deltaFrame2 = deg2pix(P.speedDots2,'none')/fps;                 
end

if P.surround_bit==1 && P.motionopp_bit==0 
    stimSize2=[P.x_size2 P.y_size2];
    stimSizePx2(1)=deg2pix(P.x_size2,'round');
    stimSizePx2(2)=deg2pix(P.y_size2,'round');
    maskradiusPx2=deg2pix(P.mask_radius2,'round');
    
    stimArea2=stimSize2(1)*stimSize2(2);
    
    nrDots2=round(P.dotDensity2*stimArea2);
    
    deltaFrame2 = deg2pix(P.speedDots2,'none')/fps;                  
end


%figure out how many frames - we use the first and the last frame to be
%shown in the pre and postdelay, so only stimulus duration matters here
nrFrames=ceil(P.stim_time*fps);


%initialize random number generate to time of date
s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*str2double(Mstate.unit)+str2double(Mstate.expt)+loopTrial);


%initialize dot positions, lifetime etc for main grating
xypos=rand(s,2,nrDots); %this gives numbers between 0 and 1
xypos(1,:)=(xypos(1,:)-0.5)*stimSizePx(1); %now we have between -stimsize/2 and +stimsize/2
xypos(2,:)=(xypos(2,:)-0.5)*stimSizePx(2);

if P.dotLifetime>0
    lifetime=randi(s,P.dotLifetime,1,nrDots); %between 1 and dotLifetime
end

nrSignal=round(nrDots*P.dotCoherence/100); %nr of signal dots (dots moving with preset orientation)

if P.noNetNoise==0
    dotdir=round(360*rand(s,1,nrDots));
    dotdir(1:nrSignal)=P.ori; %we can pick the first N dots here because dot position is randomized
else %try to eliminate net noise motion
    %first make sure that there is an even number of noise dots, keeping
    %the overall nr of dots the same
    nrNoise=nrDots-nrSignal;
    nrNoise=nrNoise-rem(nrNoise,2);
    
    dotdir=ones(1,nrDots)*P.ori;
    tmp=round(360*rand(s,1,nrNoise/2));
    dotdir(1:nrNoise/2)=tmp;
    dotdir(nrNoise/2+1:nrNoise)=mod(tmp+180,360);
end


%initialize dot positions, lifetime etc for second grating, if necessary
if P.motionopp_bit==1 || P.surround_bit==1
    xypos2=rand(s,2,nrDots2);
    xypos2(1,:)=(xypos2(1,:)-0.5)*stimSizePx2(1);
    xypos2(2,:)=(xypos2(2,:)-0.5)*stimSizePx2(2);
    
    if P.dotLifetime2>0 
        lifetime2=randi(s,P.dotLifetime2,1,nrDots2);
    end

    nrSignal2=round(nrDots2*P.dotCoherence2/100);
      
    if P.noNetNoise==0
        dotdir2=round(360*rand(s,1,nrDots2));
        dotdir2(1:nrSignal2)=P.ori2; 
    else %try to eliminate net noise motion
        nrNoise2=nrDots2-nrSignal2;
        nrNoise2=nrNoise2-rem(nrNoise2,2);
    
        dotdir2=ones(1,nrDots2)*P.ori2;
        tmp=round(360*rand(s,1,nrNoise2/2));
        dotdir2(1:nrNoise2/2)=tmp;
        dotdir2(nrNoise2/2+1:nrNoise2)=mod(tmp+180,360);
    end
end



%now loop through frames and generate stimuli
for i=1:nrFrames
   
    %%%main RDK code
    
    %check lifetime - at the end of the lifetime, assign either preset
    %direction or random direction according to coherence setting
    %we assume things even out over time, so we don't exactly replace the same number of 
    %noise/signal dots, but rather pick a proportion of noise/signal dots according to the coherence setting 
    if P.dotLifetime>0         
        idx=find(lifetime==0);
        
        signalid=rand(s,1,length(idx))<P.dotCoherence/100; %id=1: signal
        
        if P.noNetNoise==0
            randdir=round(360*rand(s,1,length(idx)));
        
            dotdir(idx(signalid==1))=P.ori;
            dotdir(idx(signalid==0))=randdir(signalid==0);
        else
            nrNoise=length(find(signalid==0));
            if rem(nrNoise,2)==1
                nrNoise=nrNoise-1;
                tmp=find(signalid==0);
                signalid(tmp(1))=1;
            end
            dotdir(idx(signalid==1))=P.ori;
            
            randdir=round(360*rand(s,1,nrNoise/2));
            randdir=[randdir mod(randdir+180,360)];
            dotdir(idx(signalid==0))=randdir;
        end
  
        lifetime=lifetime-1;
        lifetime(idx)=P.dotLifetime;
     end
     
    
    %generate new positions - everybody moves according to their direction
    xypos(1,:)=xypos(1,:)-deltaFrame*cos(dotdir*pi/180);
    xypos(2,:)=xypos(2,:)-deltaFrame*sin(dotdir*pi/180);
    
   
    
    %check which ones are outside of the boundaries, and wrap around
    %logic behind this algorithm: the angle of movement determines the
    %probability with which a stimulus edge will be chosen; for this, compute the
    %projection of the movement vector onto the axes first (x=cos(ori),
    %y=sin(ori), then compute the ratio between them as
    %abs(x)/(abs(x)+abs(y)). the ratio will be 0 if the stimulus moves
    %along the y axis, 1 if it moves along the x axis, 0.5 for 45 deg,
    %and so forth; we'll randomly draw a number between 0 and 1 and compare it with the
    %ratio to determine which stimulus edge to place the dot on; the
    %dot will then randomly placed somewhere along this edge
    %we use the same square bounding box independent of the mask, so for
    %a circle dots may be placed outside the boundary and only appear a
    %little later
    
        
    %find out how many dots are out of the stimulus window
    idx=find(abs(xypos(1,:))>stimSizePx(1)/2 | abs(xypos(2,:))>stimSizePx(2)/2);
   
    %reset to the other side of the stimulus
    rvec=rand(s,size(idx));
    for j=1:length(idx)
        %get projection of movement vector onto axes 
        xproj=-cos(dotdir(idx(j))*pi/180);
        yproj=-sin(dotdir(idx(j))*pi/180);
        if rvec(j)<= abs(xproj)/(abs(xproj)+abs(yproj))
            %y axis chosen, so place stimulus at the other x axis and a
            %random y location
            xypos(1,idx(j))=-1*sign(xproj)*stimSizePx(1)/2;
            xypos(2,idx(j))=(rand(s,1)-0.5)*stimSizePx(2);
        else
            %x axis chosen
            xypos(1,idx(j))=(rand(s,1)-0.5)*stimSizePx(1);
            xypos(2,idx(j))=-1*sign(yproj)*stimSizePx(2)/2;
        end
    end
    
    %find the dots that are inside the mask radius if there is a mask
    if strcmp(P.mask_type,'disc')
        [~,rad]=cart2pol(xypos(1,:),xypos(2,:));
        idx=find(rad<maskradiusPx);
        dotout=xypos(:,idx);
    else
        dotout=xypos;
    end
    
    
    %%% all of the same computations for the second grating if necessary
    if P.motionopp_bit==1 || P.surround_bit==1
        if P.dotLifetime2>0         
            idx=find(lifetime2==0);
        
            signalid=rand(s,1,length(idx))<P.dotCoherence2/100;
            
            if P.noNetNoise==0
                randdir=round(360*rand(s,1,length(idx)));
        
                dotdir2(idx(signalid==1))=P.ori2;
                dotdir2(idx(signalid==0))=randdir(signalid==0);
            else
                nrNoise=length(find(signalid==0));
                if rem(nrNoise,2)==1
                    nrNoise=nrNoise-1;
                    tmp=find(signalid==0);
                    signalid(tmp(1))=1;
                end
            
                dotdir2(idx(signalid==1))=P.ori2;
            
                randdir=round(360*rand(s,1,nrNoise/2));
                randdir=[randdir mod(randdir+180,360)];
                dotdir2(idx(signalid==0))=randdir;
            end
  
            lifetime2=lifetime2-1;
            lifetime2(idx)=P.dotLifetime2;
        end
     
    
        %generate new positions - everybody moves according to their direction
        xypos2(1,:)=xypos2(1,:)-deltaFrame2*cos(dotdir2*pi/180);
        xypos2(2,:)=xypos2(2,:)-deltaFrame2*sin(dotdir2*pi/180);

        
        %find out how many dots are out of the stimulus window
        idx=find(abs(xypos2(1,:))>stimSizePx2(1)/2 | abs(xypos2(2,:))>stimSizePx2(2)/2);
   
        %reset to the other side of the stimulus
        rvec=rand(s,size(idx));
        for j=1:length(idx)
            %get projection of movement vector onto axes not assuming 100% coherence
            xproj=-cos(dotdir2(idx(j))*pi/180);
            yproj=-sin(dotdir2(idx(j))*pi/180);
            if rvec(j)<= abs(xproj)/(abs(xproj)+abs(yproj))
                %y axis chosen, so place stimulus at the other x axis and a
                %random y location
                xypos2(1,idx(j))=-1*sign(xproj)*stimSizePx2(1)/2;
                xypos2(2,idx(j))=(rand(s,1)-0.5)*stimSizePx2(2);
            else
                %x axis chosen
                xypos2(1,idx(j))=(rand(s,1)-0.5)*stimSizePx2(1);
                xypos2(2,idx(j))=-1*sign(yproj)*stimSizePx2(2)/2;
            end
        end
        
        %remove dots when necessary
        if P.motionopp_bit==1
            if strcmp(P.mask_type2,'disc')
                [~,rad]=cart2pol(xypos2(1,:),xypos2(2,:));
                idx=find(rad<maskradiusPx2);    
                dotout=[dotout xypos2(:,idx)];
            else
                dotout=[dotout xypos2];
            end
        else
            [~,rad]=cart2pol(xypos2(1,:),xypos2(2,:));
            if strcmp(P.mask_type,'disc')
                idx1=find(rad>maskradiusPx);
            else
                idx1=find(abs(xypos2(1,:))>stimSizePx(1)/2 | abs(xypos2(2,:))>stimSizePx(2)/2);
            end
            if strcmp(P.mask_type2,'disc')
                idx2=find(rad<maskradiusPx2);
                idx=intersect(idx1,idx2);
            else
                idx=idx1;
            end
            dotout=[dotout xypos2(:,idx)];
        end
         
    end %code for grating 2
    
 
    DotFrame{i}=dotout;

end

%Save it if 'running' experiment
if Mstate.running
    saveLog_Dots(DotFrame,loopTrial);
end

