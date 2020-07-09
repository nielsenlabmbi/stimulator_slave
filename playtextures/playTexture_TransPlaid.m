function playTexture_TransPlaid
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


%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);


%grating  parameters
pixpercycle=deg2pix(1/P.s_freq,'none');
shiftperframe=pixpercycle/P.t_period;
%grating goes from -1 to 1. contrast sets scaling so that after adding the grating 
%to the background, the range remains between 0 and 1 and the grating is
%equiluminant to the background. maximum amplitude the grating can have is
%either the background (if smaller than 0.5), or 1-background.
ctr=P.contrast/100*0.5;


%set background
Screen(screenPTR, 'FillRect', 0.5)

%set sync to black 
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');

%Wake up the daq to improve timing later
if ~isempty(daq)
    DaqDOut(daq, 0, 0);
end

%%%Play predelay %%%%
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
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end


%%%%%Play stimuli%%%%%%%%%%
Screen(screenPTR, 'FillRect', 0.5) %sets the level that the gratings will be added to

for i = 1:Nstimframes
    
    %get parameters for grating    
    xoffset = mod((i-1)*shiftperframe+P.phase/360*pixpercycle,pixpercycle);
    stimSrc=[xoffset 0 xoffset + stimsizeN-1 stimsizeN-1];
       
  
    %plot grating 1
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
    Screen('DrawTexture', screenPTR, Gtxtr(1), stimSrc, stimDst,P.ori,[],ctr);
    
    %if plaid, plot grating 2 and intersections    
    if P.plaid_bit==1 
        Screen('DrawTexture', screenPTR, Gtxtr(1), stimSrc, stimDst,P.ori2,[],ctr);
    
        %change luminance at intersections
        %Disable alpha-blending, restrict following drawing to alpha channel:
        Screen('BlendFunction', screenPTR, GL_ONE, GL_ZERO, [0 0 0 1]);
        %set alpha value at grating 1 location to 1
        Screen('DrawTexture', screenPTR, Masktxtr(2), stimSrc, stimDst,P.ori);
        %now add second grating - need to change blend function so that
        %only intersections remain
        Screen('BlendFunction', screenPTR, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [0 0 0 1]);
        Screen('DrawTexture', screenPTR, Masktxtr(2), stimSrc, stimDst,P.ori2);
    
        %now allow plotting to all channels again; will only plot where
        %alpha is 1
        Screen('BlendFunction', screenPTR, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
        %plot intersection
        Screen('DrawTexture', screenPTR, Gtxtr(2),[],stimDst);
    end     
    %add large mask
    Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawTexture', screenPTR, Masktxtr(1));
    
    %add sync
    Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
    
    %flip
    Screen(screenPTR, 'Flip');
        
    %generate event
    if ~isempty(daq)       
        if i==1 && loopTrial ~= -1
            digWord=3;
            DaqDOut(daq, 0, digWord);
        end
    end
 
    
end
    

%%%Play postdelay %%%%
Screen(screenPTR, 'FillRect', 0.5) 
for i = 1:Npostframes-1
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
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');


if loopTrial ~= -1 && ~isempty(daq)
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end


%set sync to black for next stimulus
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');




