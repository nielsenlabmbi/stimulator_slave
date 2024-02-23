function makeTexture_RDK_Stereo
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

global Mstate DotFrame DotFrame2 screenNum loopTrial 

%clean up
DotFrame={};
DotFrame2={};



%get parameters
P = getParamStruct;

%get screen settings
screenRes = Screen('Resolution',screenNum);
fps=screenRes.hz;      % frames per second


%parameters for the main RDK
stimSize=[P.x_size1 P.y_size1];
stimSizePx(1)=deg2pix(P.x_size1,'round');
stimSizePx(2)=deg2pix(P.y_size1,'round');
maskradiusPx=deg2pix(P.mask_radius1,'round');
stimArea=stimSize(1)*stimSize(2);
nrDots=round(P.dotDensity1*stimArea); %density is specified in dots/(deg^2)
deltaFrame = deg2pix(P.speedDots1,'none')/fps;  % displacement per frame, based on dot speed (pixels/frame)

stimSize2=[P.x_size2 P.y_size2];
stimSizePx_2(1)=deg2pix(P.x_size2,'round');
stimSizePx_2(2)=deg2pix(P.y_size2,'round');
maskradiusPx_2=deg2pix(P.mask_radius2,'round');
stimArea_2=stimSize2(1)*stimSize2(2);
nrDots_2=round(P.dotDensity2*stimArea_2); %density is specified in dots/(deg^2)
deltaFrame_2 = deg2pix(P.speedDots2,'none')/fps;  % displacement per frame, based on dot speed (pixels/fram

%size parameters for the second grating if necessary
if P.motionopp_bit1==1
    stimSizePx2=stimSizePx;
    maskradiusPx2=maskradiusPx;
    stimArea2=stimArea;
    
    nrDots2=round(P.dotDensity21*stimArea2);
    
    deltaFrame2 = deg2pix(P.speedDots21,'none')/fps;                 
end

if P.surround_bit1==1 && P.motionopp_bit1==0 
    stimSize2=[P.x_size21 P.y_size21];
    stimSizePx2(1)=deg2pix(P.x_size21,'round');
    stimSizePx2(2)=deg2pix(P.y_size21,'round');
    maskradiusPx2=deg2pix(P.mask_radius21,'round');
    
    stimArea2=stimSize2(1)*stimSize2(2);
    
    nrDots2=round(P.dotDensity21*stimArea2);
    
    deltaFrame2 = deg2pix(P.speedDots21,'none')/fps;                  
end

if P.motionopp_bit2==1
    stimSizePx22=stimSizePx_2;
    maskradiusPx22=maskradiusPx_2;
    stimArea22=stimArea_2;
    
    nrDots22=round(P.dotDensity22*stimArea22);
    
    deltaFrame22 = deg2pix(P.speedDots22,'none')/fps;                 
end

if P.surround_bit2==1 && P.motionopp_bit2==0 
    stimSize22=[P.x_size21 P.y_size22];
    stimSizePx22(1)=deg2pix(P.x_size22,'round');
    stimSizePx22(2)=deg2pix(P.y_size22,'round');
    maskradiusPx22=deg2pix(P.mask_radius22,'round');
    
    stimArea22=stimSize22(1)*stimSize22(2);
    
    nrDots22=round(P.dotDensity22*stimArea2);
    
    deltaFrame22 = deg2pix(P.speedDots22,'none')/fps;                  
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

xypos_2=xypos; %we want the same image on both sides
xypos_2(1,:)=(xypos_2(1,:)-0.5)*stimSizePx_2(1); %now we have between -stimsize/2 and +stimsize/2
xypos_2(2,:)=(xypos_2(2,:)-0.5)*stimSizePx_2(2);

if P.dotLifetime1>0
    lifetime=randi(s,P.dotLifetime1,1,nrDots); %between 1 and dotLifetime
end
if P.dotLifetime2>0
    lifetime2=lifetime; %between 1 and dotLifetime
end

nrSignal=round(nrDots*P.dotCoherence1/100); %nr of signal dots (dots moving with preset orientation)
nrSignal_2=round(nrDots_2*P.dotCoherence2/100); %nr of signal dots (dots moving with preset orientation)

if P.noNetNoise1==0
    dotdir=round(360*rand(s,1,nrDots));
    dotdir(1:nrSignal)=P.ori1; %we can pick the first N dots here because dot position is randomized
else %try to eliminate net noise motion
    %first make sure that there is an even number of noise dots, keeping
    %the overall nr of dots the same
    nrNoise=nrDots-nrSignal;
    nrNoise=nrNoise-rem(nrNoise,2);
    
    dotdir=ones(1,nrDots)*P.ori1;
    tmp=round(360*rand(s,1,nrNoise/2));
    dotdir(1:nrNoise/2)=tmp;
    dotdir(nrNoise/2+1:nrNoise)=mod(tmp+180,360);
end

if P.noNetNoise2==0
    dotdir_2=round(360*rand(s,1,nrDots_2));
    dotdir_2(1:nrSignal_2)=P.ori2; %we can pick the first N dots here because dot position is randomized
else %try to eliminate net noise motion
    %first make sure that there is an even number of noise dots, keeping
    %the overall nr of dots the same
    nrNoise_2=nrDots_2-nrSignal_2;
    nrNoise_2=nrNoise_2-rem(nrNoise_2,2);
    
    dotdir_2=ones(1,nrDots_2)*P.ori2;
    tmp2=round(360*rand(s,1,nrNoise_2/2));
    dotdir_2(1:nrNoise_2/2)=tmp2;
    dotdir_2(nrNoise_2/2+1:nrNoise_2)=mod(tmp2+180,360);
end


%initialize dot positions, lifetime etc for second grating, if necessary
if P.motionopp_bit1==1 || P.surround_bit1==1
    xypos2=rand(s,2,nrDots2);
    xypos2(1,:)=(xypos2(1,:)-0.5)*stimSizePx2(1);
    xypos2(2,:)=(xypos2(2,:)-0.5)*stimSizePx2(2);
    
    if P.dotLifetime21>0 
        lifetime21=randi(s,P.dotLifetime21,1,nrDots2);
    end

    nrSignal2=round(nrDots2*P.dotCoherence21/100);
      
    if P.noNetNoise1==0
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

if P.motionopp_bit2==1 || P.surround_bit2==1
    xypos22=rand(s,2,nrDots22);
    xypos22(1,:)=(xypos2(1,:)-0.5)*stimSizePx2(1);
    xypos22(2,:)=(xypos2(2,:)-0.5)*stimSizePx2(2);
    
    if P.dotLifetime22>0 
        lifetime22=randi(s,P.dotLifetime22,1,nrDots22);
    end

    nrSignal22=round(nrDots2*P.dotCoherence22/100);
      
    if P.noNetNoise1==0
        dotdir22=round(360*rand(s,1,nrDots22));
        dotdir22(1:nrSignal22)=P.ori2; 
    else %try to eliminate net noise motion
        nrNoise22=nrDots22-nrSignal22;
        nrNoise22=nrNoise22-rem(nrNoise22,2);
    
        dotdir22=ones(1,nrDots22)*P.ori2;
        tmp=round(360*rand(s,1,nrNoise22/2));
        dotdir22(1:nrNoise22/2)=tmp;
        dotdir22(nrNoise22/2+1:nrNoise22)=mod(tmp+180,360);
    end
end


%now loop through frames and generate stimuli
for i=1:nrFrames
   
    %%%main RDK code
    
    %check lifetime - at the end of the lifetime, assign either preset
    %direction or random direction according to coherence setting
    %we assume things even out over time, so we don't exactly replace the same number of 
    %noise/signal dots, but rather pick a proportion of noise/signal dots according to the coherence setting 
    if P.dotLifetime1>0         
        idx=find(lifetime==0);
        
        signalid=rand(s,1,length(idx))<P.dotCoherence1/100; %id=1: signal
        
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
        lifetime(idx)=P.dotLifetime1;
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
    if strcmp(P.mask_type1,'disc')
        [~,rad]=cart2pol(xypos(1,:),xypos(2,:));
        idx=find(rad<maskradiusPx);
        dotout=xypos(:,idx);
    else
        dotout=xypos;
    end
    
    
    %%% all of the same computations for the second grating if necessary
    if P.motionopp_bit1==1 || P.surround_bit1==1
        if P.dotLifetime21>0         
            idx=find(lifetime2==0);
        
            signalid=rand(s,1,length(idx))<P.dotCoherence21/100;
            
            if P.noNetNoise1==0
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
        if P.motionopp_bit1==1
            if strcmp(P.mask_type21,'disc')
                [~,rad]=cart2pol(xypos2(1,:),xypos2(2,:));
                idx=find(rad<maskradiusPx2);    
                dotout=[dotout xypos2(:,idx)];
            else
                dotout=[dotout xypos2];
            end
        else
            [~,rad]=cart2pol(xypos2(1,:),xypos2(2,:));
            if strcmp(P.mask_type1,'disc')
                idx1=find(rad>maskradiusPx);
            else
                idx1=find(abs(xypos2(1,:))>stimSizePx(1)/2 | abs(xypos2(2,:))>stimSizePx(2)/2);
            end
            if strcmp(P.mask_type21,'disc')
                idx2=find(rad<maskradiusPx2);
                idx=intersect(idx1,idx2);
            else
                idx=idx1;
            end
            dotout=[dotout xypos2(:,idx)];
        end
         
    end %code for grating 2
      DotFrame{i}=dotout;

%    %Other side   
%    if P.dotLifetime2>0         
%         idx2=find(lifetime==0);
%         
%         signalid2=rand(s,1,length(idx2))<P.dotCoherence2/100; %id=1: signal
%         
%         if P.noNetNoise2==0
%             randdir2=round(360*rand(s,1,length(idx2)));
%         
%             dotdir_2(idx2(signalid2==1))=P.ori;
%             dotdir_2(idx2(signalid2==0))=randdir2(signalid2==0);
%         else
%             nrNoise_2=length(find(signalid2==0));
%             if rem(nrNoise_2,2)==1
%                 nrNoise_2=nrNoise_2-1;
%                 tmp=find(signalid2==0);
%                 signalid2(tmp(1))=1;
%             end
%             dotdir_2(idx2(signalid2==1))=P.ori2;
%             
%             randdir2=round(360*rand(s,1,nrNoise_2/2));
%             randdir2=[randdir2 mod(randdir_2+180,360)];
%             dotdir_2(idx2(signalid2==0))=randdir2;
%         end
%   
%         lifetime_2=lifetime_2-1;
%         lifetime_2(idx2)=P.dotLifetime2;
%    end
%      
%     
%     %generate new positions - everybody moves according to their direction
%     xypos_2(1,:)=xypos_2(1,:)-deltaFrame_2*cos(dotdir_2*pi/180);
%     xypos_2(2,:)=xypos_2(2,:)-deltaFrame_2*sin(dotdir_2*pi/180);
%     
%         
%     %find out how many dots are out of the stimulus window
%     idx2=find(abs(xypos_2(1,:))>stimSizePx_2(1)/2 | abs(xypos_2(2,:))>stimSizePx_2(2)/2);
%    
%     %reset to the other side of the stimulus
%     rvec2=rand(s,size(idx2));
%     for j=1:length(idx2)
%         %get projection of movement vector onto axes 
%         xproj2=-cos(dotdir_2(idx2(j))*pi/180);
%         yproj2=-sin(dotdir_2(idx2(j))*pi/180);
%         if rvec2(j)<= abs(xproj2)/(abs(xproj2)+abs(yproj2))
%             %y axis chosen, so place stimulus at the other x axis and a
%             %random y location
%             xypos_2(1,idx2(j))=-1*sign(xproj2)*stimSizePx_2(1)/2;
%             xypos_2(2,idx2(j))=(rand(s,1)-0.5)*stimSizePx(2);
%         else
%             %x axis chosen
%             xypos_2(1,idx2(j))=(rand(s,1)-0.5)*stimSizePx_2(1);
%             xypos_2(2,idx2(j))=-1*sign(yproj)*stimSizePx_2(2)/2;
%         end
%     end
%     
%     %find the dots that are inside the mask radius if there is a mask
%     if strcmp(P.mask_type2,'disc')
%         [~,rad]=cart2pol(xypos_2(1,:),xypos_2(2,:));
%         idx2=find(rad<maskradiusPx_2);
%         dotout2=xypos_2(:,idx2);
%     else
%         dotout2=xypos_2;
%     end
% 
%    %%% all of the same computations for the second grating if necessary
%     if P.motionopp_bit2==1 || P.surround_bit2==1
%         if P.dotLifetime22>0         
%             idx2=find(lifetime22==0);
%         
%             signalid2=rand(s,1,length(idx2))<P.dotCoherence22/100;
%             
%             if P.noNetNoise2==0
%                 randdir2=round(360*rand(s,1,length(idx2)));
%         
%                 dotdir22(idx2(signalid2==1))=P.ori2;
%                 dotdir22(idx2(signalid2==0))=randdir2(signalid2==0);
%             else
%                 nrNoise2=length(find(signalid==0));
%                 if rem(nrNoise2,2)==1
%                     nrNoise2=nrNoise2-1;
%                     tmp=find(signalid2==0);
%                     signalid2(tmp(1))=1;
%                 end
%             
%                 dotdir22(idx2(signalid2==1))=P.ori2;
%             
%                 randdir2=round(360*rand(s,1,nrNoise2/2));
%                 randdir2=[randdir2 mod(randdir2+180,360)];
%                 dotdir22(idx(signalid==0))=randdir2;
%             end
%   
%             lifetime22=lifetime22-1;
%             lifetime22(id2x)=P.dotLifetime22;
%         end
%      
%     
%         %generate new positions - everybody moves according to their direction
%         xypos22(1,:)=xypos22(1,:)-deltaFrame22*cos(dotdir22*pi/180);
%         xypos22(2,:)=xypos22(2,:)-deltaFrame22*sin(dotdir22*pi/180);
% 
%         
%         %find out how many dots are out of the stimulus window
%         idx2=find(abs(xypos22(1,:))>stimSizePx22(1)/2 | abs(xypos22(2,:))>stimSizePx22(2)/2);
%    
%         %reset to the other side of the stimulus
%         rvec2=rand(s,size(idx2));
%         for j=1:length(idx2)
%             %get projection of movement vector onto axes not assuming 100% coherence
%             xproj2=-cos(dotdir2(idx2(j))*pi/180);
%             yproj2=-sin(dotdir2(idx2(j))*pi/180);
%             if rvec(j)<= abs(xproj2)/(abs(xproj2)+abs(yproj2))
%                 %y axis chosen, so place stimulus at the other x axis and a
%                 %random y location
%                 xypos22(1,idx(j))=-1*sign(xproj2)*stimSizePx22(1)/2;
%                 xypos22(2,idx(j))=(rand(s,1)-0.5)*stimSizePx22(2);
%             else
%                 %x axis chosen
%                 xypos22(1,idx(j))=(rand(s,1)-0.5)*stimSizePx22(1);
%                 xypos22(2,idx(j))=-1*sign(yproj2)*stimSizePx22(2)/2;
%             end
%         end
%         
%         %remove dots when necessary
%         if P.motionopp_bit2==1
%             if strcmp(P.mask_type22,'disc')
%                 [~,rad]=cart2pol(xypos22(1,:),xypos22(2,:));
%                 idx2=find(rad<maskradiusPx22);    
%                 dotout2=[dotout2 xypos22(:,idx2)];
%             else
%                 dotout2=[dotout2 xypos22];
%             end
%         else
%             [~,rad]=cart2pol(xypos22(1,:),xypos22(2,:));
%             if strcmp(P.mask_type2,'disc')
%                 idx1=find(rad>maskradiusPx2);
%             else
%                 idx1=find(abs(xypos22(1,:))>stimSizePx2(1)/2 | abs(xypos22(2,:))>stimSizePx2(2)/2);
%             end
%             if strcmp(P.mask_type22,'disc')
%                 idx2=find(rad<maskradiusPx22);
%                 idx=intersect(idx1,idx2);
%             else
%                 idx=idx1;
%             end
%             dotout2=[dotout2 xypos2(:,idx)];
%         end
%          
%     end %code for grating 2
%     DotFrame2{i}=dotout2;
end
%Save it if 'running' experiment
if Mstate.running
    
    %saveLog_Dots(DotFrame,loopTrial);
end

