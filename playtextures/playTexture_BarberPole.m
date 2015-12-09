function playTexture_BarberPole
%play periodic grating
%types of stimuli: one grating (plaid_bit=0), two overlapping gratings,
%both visible entirely (plaid_bit=1, surround_bit=0), two gratings, one in
%center, one in surround (plaid_bit=0, surround_bit=1); plaid_bit==1 and
%surround_bit==1 defaults to plaid
%assumes normalized color

global Mstate screenPTR screenNum daq loopTrial

global Gtxtr Masktxtr   %Created in makeTexture

global Stxtr %Created in makeSyncTexture



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


%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstatframes = ceil(P.stat_time*screenRes.hz);
Nmovframes = ceil(P.stim_time*screenRes.hz);

%set background
Screen(screenPTR, 'FillRect', 0.5)

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
end
for i = 2:Npreframes
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end


%%%%%Play stationary stimulus
for i = 1:Nstatframes
    
    stimSrc=[0 0 stimsizeN-1 stimsizeN-1];
   
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
    Screen('DrawTexture', screenPTR, Gtxtr(1), stimSrc, stimDst,P.ori,[],ctr);
    
    %add mask
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawTexture', screenPTR, Masktxtr(1));
        
    %add sync
    if i==1
        Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    else
        Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    end
    
    %flip
    Screen(screenPTR, 'Flip');
        
    %generate event
    if i==1 && loopTrial ~= -1
        digWord=5; %set 3rd channel high, keep 1st high
        DaqDOut(daq, 0, digWord);
    end        
end


%%%%%Play moving stimulus
for i = 1:Nmovframes
    
    %get parameters for grating 1
    
    xoffset = mod((i-1)*shiftperframe+P.phase/360*pixpercycle,pixpercycle);
    stimSrc=[xoffset 0 xoffset + stimsizeN-1 stimsizeN-1];
    
    
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
    Screen('DrawTexture', screenPTR, Gtxtr(1), stimSrc, stimDst,P.ori,[],ctr);
    
    %add mask
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawTexture', screenPTR, Masktxtr(1));
        
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    
    %flip
    Screen(screenPTR, 'Flip');
        
    %generate event
    if i==1 && loopTrial ~= -1
        digWord=3; %set 2nd channel high, flip 3rd channel low
        DaqDOut(daq, 0, digWord);
    end        
end
    

%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1
        digWord = 1;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
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



