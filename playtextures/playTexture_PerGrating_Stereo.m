function playTexture_PerGrating_Stereo
%play periodic grating
%types of stimuli: one grating (plaid_bit=0), two overlapping gratings,
%both visible entirely (plaid_bit=1, surround_bit=0), two gratings, one in
%center, one in surround (plaid_bit=0, surround_bit=1); plaid_bit==1 and
%surround_bit==1 defaults to plaid
%assumes normalized color

global Mstate screenPTR screenNum daq loopTrial

global Gtxtr Masktxtr Gtxtr2 Masktxtr2 %Created in makeTexture

global Stxtr %Created in makeSyncTexture

global vSyncState %ventilator sync

%get basic parameters
P = getParamStruct;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

%get sync size and position
syncWX = round(pixpercmX*Mstate.syncSize); %syncsize is in cm to be independent of screen distance
syncWY = round(pixpercmY*Mstate.syncSize);
syncSrc = [0 0 syncWX-1 syncWY-1]';
syncDst = [0 0 syncWX-1 syncWY-1]';

%stimulus size and position - this has to be larger than set by the user to
%deal with the rotation

if P.mirrorXCoord==0
    x_pos1=P.x_pos1;
    x_pos2=P.x_pos2; 
    
elseif P.mirrorXCoord==1
    x_pos1=P.x_pos1;
    x_pos2=1920-P.x_pos1;
   
elseif P.mirrorXCoord==2
    x_pos1=1920-P.x_pos2;
    x_pos2=P.x_pos2; 
end


stimsize=2*sqrt((P.x_size1/2).^2+(P.y_size1/2).^2);
stimsizeN=deg2pix(stimsize,'round');
stimDst=[x_pos1-floor(stimsizeN/2)+1 P.y_pos1-floor(stimsizeN/2)+1 ...
    x_pos1+ceil(stimsizeN/2) P.y_pos1+ceil(stimsizeN/2)]';

stimsize_2=2*sqrt((P.x_size2/2).^2+(P.y_size2/2).^2);
stimsizeN_2=deg2pix(stimsize_2,'round');
stimDst_2=[x_pos2-floor(stimsizeN_2/2)+1 P.y_pos2-floor(stimsizeN_2/2)+1 ...
    x_pos2+ceil(stimsizeN_2/2) P.y_pos2+ceil(stimsizeN_2/2)]';
%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);


%grating 1 parameters
pixpercycle=deg2pix(1/P.s_freq1,'none');
shiftperframe=pixpercycle/P.t_period1;
%grating goes from -1 to 1. contrast sets scaling so that after adding the grating 
%to the background, the range remains between 0 and 1 and the grating is
%equiluminant to the background. maximum amplitude the grating can have is
%either the background (if smaller than 0.5), or 1-background.

ctrBase=P.contrast1/100*min(P.background,1-P.background);
if P.tmod_bit1==0
    %static contrast
    ctrFrame=repmat(ctrBase,1,Nstimframes);
else
    %contrast modulation
    ctr=cos([0:Nstimframes-1]*2*pi/P.tmod_tperiod1);
    if strcmp(P.tmod_tprofile1,'square')
        ctr=sign(ctr);
    end
    %scale between min and max
    ctramp=1/2*(P.tmod_max1-P.tmod_min1)/100*ctrBase;
    ctroff=1/2*(P.tmod_max1+P.tmod_min1)/100*ctrBase;
    ctrFrame=ctroff+ctramp*ctr;
end
    
% if P.plaid_bit==1 || P.surround_bit==1
%     stimsize2=2*sqrt((P.x_size2/2).^2+(P.y_size2/2).^2);
%     stimsizeN2=deg2pix(stimsize2,'round');
%     stimDst2=[P.x_pos-floor(stimsizeN2/2)+1 P.y_pos-floor(stimsizeN2/2)+1 ...
%         P.x_pos+ceil(stimsizeN2/2) P.y_pos+ceil(stimsizeN2/2)]';
%     
%     ctr2=P.contrast2/100*min(P.background,1-P.background);
%     pixpercycle2=deg2pix(1/P.s_freq2,'none');
%     shiftperframe2=pixpercycle2/P.t_period2;
% end

%Other side

%grating 1 parameters
pixpercycle2=deg2pix(1/P.s_freq2,'none');
shiftperframe2=pixpercycle2/P.t_period2;
%grating goes from -1 to 1. contrast sets scaling so that after adding the grating 
%to the background, the range remains between 0 and 1 and the grating is
%equiluminant to the background. maximum amplitude the grating can have is
%either the background (if smaller than 0.5), or 1-background.

ctrBase2=P.contrast2/100*min(P.background,1-P.background);
if P.tmod_bit2==0
    %static contrast
    ctrFrame2=repmat(ctrBase2,1,Nstimframes);
else
    %contrast modulation
    ctr_2=cos([0:Nstimframes-1]*2*pi/P2.tmod_tperiod);
    if strcmp(P.tmod_tprofile2,'square')
        ctr_2=sign(ctr);
    end
    %scale between min and max
    ctramp2=1/2*(P.tmod_max2-P.tmod_min2)/100*ctrBase2;
    ctroff2=1/2*(P.tmod_max2+P.tmod_min2)/100*ctrBase2;
    ctrFrame2=ctroff2+ctramp2*ctr_2;
end
    
% if P2.plaid_bit==1 || P2.surround_bit==1
%     stimsize2_2=2*sqrt((P2.x_size2/2).^2+(P2.y_size2/2).^2);
%     stimsizeN2_2=deg2pix(stimsize2_2,'round');
%     stimDst2_2=[P2.x_pos-floor(stimsizeN2_2/2)+1 P2.y_pos-floor(stimsizeN2_2/2)+1 ...
%         P2.x_pos+ceil(stimsizeN2_2/2) P2.y_pos+ceil(stimsizeN2_2/2)]';
%     
%     ctr2_2=P2.contrast2/100*min(P2.background,1-P2.background);
%     pixpercycle2_2=deg2pix(1/P2.s_freq2,'none');
%     shiftperframe2_2=pixpercycle2_2/P2.t_period2;
% end
%disp(P.background)

%set background
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen(screenPTR, 'FillRect', P.background)
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen(screenPTR, 'FillRect', P.background)

%set sync to black 
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');

%Wake up the daq to improve timing later
if ~isempty(daq)
    DaqDOut(daq, 0, 0);
end

%%%Play predelay %%%%
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1 && ~isempty(daq)
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
    %stop ventilator
    if vSyncState==1
        setVentilator(0);
    end
end
for i = 2:Npreframes
    Screen('SelectStereoDrawBuffer', screenPTR, 0);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen('SelectStereoDrawBuffer', screenPTR, 1);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end


%%%%%Play stimuli%%%%%%%%%%
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen(screenPTR, 'FillRect', P.background) %sets the level that the gratings will be added to
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen(screenPTR, 'FillRect', P.background) %sets the level that the gratings will be added to

for i = 1:Nstimframes
    
    %get parameters for grating 1   
    xoffset = mod((i-1)*shiftperframe+P.phase1/360*pixpercycle,pixpercycle);
    stimSrc=[xoffset 0 xoffset + stimsizeN-1 stimsizeN-1];
    
%     %get parameters for second grating if necessary
%     if P.plaid_bit==1 || P.surround_bit==1
%         xoffset2 = mod((i-1)*shiftperframe2+P.phase2/360*pixpercycle2,pixpercycle2);
%         stimSrc2=[xoffset2 0 xoffset2 + stimsizeN2 stimsizeN2];
%     end
    

%andother side
    %get parameters for grating 1   
    xoffset_2 = mod((i-1)*shiftperframe+P.phase2/360*pixpercycle,pixpercycle);
    stimSrc_2=[xoffset_2 0 xoffset_2 + stimsizeN_2-1 stimsizeN_2-1];
    
%     %get parameters for second grating if necessary
%     if P2.plaid_bit==1 || P2.surround_bit==1
%         xoffset2_2 = mod((i-1)*shiftperframe2+P2.phase2/360*pixpercycle2,pixpercycle2);
%         stimSrc2_2 =[xoffset2_2  0 xoffset2_2  + stimsizeN2_2  stimsizeN2_2 ];
%     end
    
  
  
    %we plot grating2 first, b/c it is the larger of the 2 in the surround
    %case;set blend function so that the global alpha can scale the contrast
%     if P.plaid_bit==1 || P.surround_bit==1
%             Screen('SelectStereoDrawBuffer', screenPTR, 0);
% 
%         Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
%         Screen('DrawTexture', screenPTR, Gtxtr(2), stimSrc2, stimDst2,P.ori2,[],ctr2);
%     
%         %add mask
%         Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%         Screen('DrawTexture', screenPTR, Masktxtr(2));  
%     end
%     
%     if P.surround_bit==0 || P.plaid_bit==1
%         Screen('SelectStereoDrawBuffer', screenPTR, 0);
% 
%         %for individual grating or plaid, plot grating1
%         Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
%         Screen('DrawTexture', screenPTR, Gtxtr(1), stimSrc, stimDst,P.ori,[],ctrFrame(i));
%     
%         %add mask
%         Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%         Screen('DrawTexture', screenPTR, Masktxtr(1)); 
%         
%     else
Screen('SelectStereoDrawBuffer', screenPTR, 0);

if P.StereoDisp==0 | P.StereoDisp==1
    

        %surround case; clear part where grating 1 will go 
        % Disable alpha-blending, restrict following drawing to alpha channel:
        Screen('BlendFunction', screenPTR, GL_ONE, GL_ZERO, [0 0 0 1]);
        %set alpha value at grating location to 1
        Screen('DrawTexture',screenPTR,Masktxtr(1));
        %now allow plotting to all channels again; will only plot where
        %alpha is 1
        Screen('BlendFunction', screenPTR, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', screenPTR, Gtxtr(1), stimSrc, stimDst,P.ori1);
   % end
end
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);

    %And draw the other one

    %we plot grating2 first, b/c it is the larger of the 2 in the surround
    %case;set blend function so that the global alpha can scale the contrast
  %  if P2.plaid_bit==1 || P2.surround_bit==1
%         Screen('SelectStereoDrawBuffer', screenPTR,1 );
% 
%         Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
%         Screen('DrawTexture', screenPTR, Gtxtr(4), stimSrc2, stimDst2,P.ori2,[],ctr2);
%     
%         %add mask
%         Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%         Screen('DrawTexture', screenPTR, Masktxtr(4));  
%     end
%     
%     if P2.surround_bit==0 || P2.plaid_bit==1
%         Screen('SelectStereoDrawBuffer', screenPTR,1 );
%                     
%         %for individual grating or plaid, plot grating1
%         Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
%         Screen('DrawTexture', screenPTR, Gtxtr(3), stimSrc, stimDst,P.ori,[],ctrFrame(i));
%     
%         %add mask
%         Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%         Screen('DrawTexture', screenPTR, Masktxtr(3)); 
%         
%     else      
Screen('SelectStereoDrawBuffer', screenPTR,1 );


if P.StereoDisp==0 | P.StereoDisp==2


        %surround case; clear part where grating 1 will go 
        % Disable alpha-blending, restrict following drawing to alpha channel:
        Screen('BlendFunction', screenPTR, GL_ONE, GL_ZERO, [0 0 0 1]);
        %set alpha value at grating location to 1
        Screen('DrawTexture',screenPTR,Masktxtr2(1));
        %now allow plotting to all channels again; will only plot where
        %alpha is 1
        Screen('BlendFunction', screenPTR, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', screenPTR, Gtxtr2(1), stimSrc_2, stimDst_2,P.ori2);
%     end
end
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
   
    
    %flip
    Screen(screenPTR, 'Flip');
        
    %generate event
    if ~isempty(daq)
        if P.use_ch3==1   %indicate cycles using the 3rd channel
            if mod(i-1,P.t_period)==0 && loopTrial ~= -1
                digWord = 7;  %toggle 2nd and 3rd bit high to signal stim on
                DaqDOut(daq, 0, digWord);
            elseif mod(i-1,P.t_period)==10 && loopTrial ~=-1
                digWord=3;
                DaqDOut(daq, 0, digWord);
            end
        else %just signal stimulus on/off
            if i==1 && loopTrial ~= -1
                digWord=3;
                DaqDOut(daq, 0, digWord);
            end
        end
    end
    
end
    

%%%Play postdelay %%%%
Screen('SelectStereoDrawBuffer', screenPTR,0 );
Screen(screenPTR, 'FillRect', P.background) 
Screen('SelectStereoDrawBuffer', screenPTR,1 );
Screen(screenPTR, 'FillRect', P.background) 
for i = 1:Npostframes-1
    Screen('SelectStereoDrawBuffer', screenPTR,0 );
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen('SelectStereoDrawBuffer', screenPTR,1);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1 && ~isempty(daq)
        digWord = 1;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
        %start ventilator
        if vSyncState==1
            setVentilator(1);
        end
    end
end
%Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');


if loopTrial ~= -1 && ~isempty(daq)
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end


%set sync to black for next stimulus
Screen('SelectStereoDrawBuffer', screenPTR,0 );
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen('SelectStereoDrawBuffer', screenPTR,1 );
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  

Screen(screenPTR, 'Flip');




