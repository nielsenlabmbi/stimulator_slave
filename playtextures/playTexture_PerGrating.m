function playTexture_PerGrating
%play periodic grating
%types of stimuli: one grating (plaid_bit=0), two overlapping gratings,
%both visible entirely (plaid_bit=1, surround_bit=0), two gratings, one in
%center, one in surround (plaid_bit=0, surround_bit=1); plaid_bit==1 and
%surround_bit==1 defaults to plaid
%assumes normalized color

global Mstate screenPTR screenNum daq loopTrial

global Gtxtr Masktxtr   %Created in makeTexture

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
stimsize=2*sqrt((P.x_size/2).^2+(P.y_size/2).^2);
stimsizeN=deg2pix(stimsize,'round');
stimDst=[P.x_pos-floor(stimsizeN/2)+1 P.y_pos-floor(stimsizeN/2)+1 ...
    P.x_pos+ceil(stimsizeN/2) P.y_pos+ceil(stimsizeN/2)]';

%grating 1 parameters
pixpercycle=deg2pix(1/P.s_freq,'none');
shiftperframe=pixpercycle/P.t_period;
ctr=P.contrast/100*0.5;  %full contrast = .5 (grating goes from -0.5 to 0.5, and is added to background of 0.5)

if P.plaid_bit==1 || P.surround_bit==1
    stimsize2=2*sqrt((P.x_size2/2).^2+(P.y_size2/2).^2);
    stimsizeN2=deg2pix(stimsize2,'round');
    stimDst2=[P.x_pos-floor(stimsizeN2/2)+1 P.y_pos-floor(stimsizeN2/2)+1 ...
        P.x_pos+ceil(stimsizeN2/2) P.y_pos+ceil(stimsizeN2/2)]';
    
    if P.contrast==0 %this is to account for blanks
        ctr2=0;
    else
        ctr2=P.contrast2/100*0.5;
    end
    pixpercycle2=deg2pix(1/P.s_freq2,'none');
    shiftperframe2=pixpercycle2/P.t_period2;
end

%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);


%set sync to black 
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');

%Wake up the daq to improve timing later
DaqDOut(daq, 0, 0); 


%%%Play predelay %%%%
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
    %stop ventilator
    if vSyncState==1
        setVentilator(0);
    end
end
for i = 2:Npreframes
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end


%%%%%Play stimuli%%%%%%%%%%
for i = 1:Nstimframes
    
    %get parameters for grating 1
    
    xoffset = mod((i-1)*shiftperframe+P.phase/360*pixpercycle,pixpercycle);
    stimSrc=[xoffset 0 xoffset + stimsizeN-1 stimsizeN-1];
    
    %get parameters for second grating if necessary
    if P.plaid_bit==1 || P.surround_bit==1
        xoffset2 = mod((i-1)*shiftperframe2+P.phase2/360*pixpercycle2,pixpercycle2);
        stimSrc2=[xoffset2 0 xoffset2 + stimsizeN2 stimsizeN2];
    end
    
  
    %we plot grating2 first, b/c it is the larger of the 2 in the surround
    %case;set blend function so that the global alpha can scale the contrast
    if P.plaid_bit==1 || P.surround_bit==1
        Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
        Screen('DrawTexture', screenPTR, Gtxtr(2), stimSrc2, stimDst2,P.ori2,[],ctr2);
    
        %add mask
        Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawTexture', screenPTR, Masktxtr(2));  
    end
    
    if P.surround_bit==0 || P.plaid_bit==1
        %for individual grating or plaid, plot grating1
        Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
        Screen('DrawTexture', screenPTR, Gtxtr(1), stimSrc, stimDst,P.ori,[],ctr);
    
        %add mask
        Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawTexture', screenPTR, Masktxtr(1)); 
        
    else
        %surround case; clear part where grating 1 will go 
        % Disable alpha-blending, restrict following drawing to alpha channel:
        Screen('BlendFunction', screenPTR, GL_ONE, GL_ZERO, [0 0 0 1]);
        %set alpha value at grating location to 1
        Screen('DrawTexture',screenPTR,Masktxtr(1));
        %now allow plotting to all channels again; will only plot where
        %alpha is 1
        Screen('BlendFunction', screenPTR, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', screenPTR, Gtxtr(1), stimSrc, stimDst,P.ori,[],ctr);
    end
    
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    
    %flip
    Screen(screenPTR, 'Flip');
        
    %generate event
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
    

%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1
        digWord = 1;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
        %start ventilator
        if vSyncState==1
            setVentilator(1);
        end
    end
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');


if loopTrial ~= -1
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end


%set sync to black for next stimulus
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');



