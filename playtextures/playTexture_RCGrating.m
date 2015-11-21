function playTexture_RCGrating
%reverse correlation with drifting gratings; this handles rotation, sliding
%and contrast
%assumes normalized color

global Mstate screenPTR screenNum daq loopTrial

global Gtxtr Masktxtr Gseq  %Created in makeTexture

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


%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
N_Im = round(P.stim_time*screenRes.hz/P.h_per); %number of images to present



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

%%%%%Play stimuli%%%%%%%%%%

for i = 1:N_Im
    
    %get orientation and spatial frequency
    ori=Gseq.oridom(Gseq.oriseq(i));
    p=Gseq.phasedom(Gseq.phaseseq(i));

    %adjust contrast for blank
    if Gseq.blankflag(i)==1
        sfid=1;
        ctr=0;
        sfreq=min(Gseq.sfdom);
    else
        sfid=Gseq.sfseq(i);
        ctr=P.contrast/100*0.5;  %full contrast = .5 (grating goes from -0.5 to 0.5, and is added to background of 0.5)
        sfreq=Gseq.sfdom(sfid);
    end
    
    %get shift per frame
    pixpercycle=deg2pix(1/sfreq,'none');
    if P.drift==1
        shiftperframe=pixpercycle/P.t_period;
    end
    
    for j = 1:P.h_per 
        %determine which part of stimulus to draw
        if P.drift==1
            xoffset = mod((j-1)*shiftperframe+p/360*pixpercycle,pixpercycle);
        else
            xoffset = p/360*pixpercycle;
        end
        stimSrc=[xoffset 0 xoffset + stimsizeN stimsizeN];
    
        %need to set blend function so that the global alpha can scale the
        %contrast
        Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
        
        %draw stimulus
        Screen('DrawTexture', screenPTR, Gtxtr(sfid), stimSrc, stimDst,ori,[],ctr);
    
        %add mask
        Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawTexture', screenPTR, Masktxtr);
  
        %add sync
        Screen('DrawTexture', screenPTR, Stxtr(2-rem(i,2)),syncSrc,syncDst);
    
        %flip
        Screen(screenPTR, 'Flip');
        
        %generate event 
        if j==1 && loopTrial ~= -1
            digWord = 7;  %toggle 2nd bit high to signal stim on
            DaqDOut(daq, 0, digWord);
        end
        if j==floor(P.h_per/2) && loopTrial ~= -1
            digWord = 3;  %reset 2nd bit to low
            DaqDOut(daq, 0, digWord);
        end
    end
end


    

%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    %generate event to signal end of stimulus presentation
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



