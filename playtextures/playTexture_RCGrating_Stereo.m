function playTexture_RCGrating_Stereo
%reverse correlation with drifting gratings; this handles rotation, sliding
%and contrast
%assumes normalized color

global Mstate screenPTR screenNum daq loopTrial

global Gtxtr Masktxtr Gseq Gtxtr2 Masktxtr2 Gseq2 %Created in makeTexture

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

stimsize2=2*sqrt((P.x_size2/2).^2+(P.y_size2/2).^2);
stimsizeN2=deg2pix(stimsize2,'round');
stimDst2=[P.x_pos2-floor(stimsizeN2/2)+1 P.y_pos2-floor(stimsizeN2/2)+1 ...
    P.x_pos2+ceil(stimsizeN2/2) P.y_pos2+ceil(stimsizeN2/2)]';

%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
N_Im = round(P.stim_time*screenRes.hz/P.h_per); %number of images to present


Screen('SelectStereoDrawBuffer', screenPTR, 0);
%set background
Screen(screenPTR, 'FillRect', 0.5)
%set sync to black 
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst); 

 Screen('SelectStereoDrawBuffer', screenPTR, 1);
% %set background
 Screen(screenPTR, 'FillRect', 0.5)
% %set sync to black 
 Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');

%Wake up the daq to improve timing later
DaqDOut(daq, 0, 0); 
 

%%%Play predelay %%%%
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');

if loopTrial ~= -1
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);
end
for i = 2:Npreframes
    Screen('SelectStereoDrawBuffer', screenPTR, 0);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen('SelectStereoDrawBuffer', screenPTR, 1);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end

%%%%%Play stimuli%%%%%%%%%%

for i = 1:N_Im

    %get orientation, spatial frequency and temporal frequency
    ori=Gseq.oridom(Gseq.oriseq(i));
    p=Gseq.phasedom(Gseq.phaseseq(i));
    
   ori2=Gseq2.oridom(Gseq2.oriseq(i));
   p2=Gseq2.phasedom(Gseq2.phaseseq(i));
    %adjust contrast for blank
    if Gseq.blankflag(i)==1
        sfid=1;
        tpid=1;
        ctr=0;
        sfreq=min(Gseq.sfdom);
        tperiod=min(Gseq.tpdom);
    else
        sfid=Gseq.sfseq(i);
        tpid=Gseq.tpseq(i);
        ctr=P.contrast/100*0.5;  %full contrast = .5 (grating goes from -0.5 to 0.5, and is added to background of 0.5)
        sfreq=Gseq.sfdom(sfid);
        tperiod=Gseq.tpdom(tpid);
    end
    
    if Gseq2.blankflag(i)==1
        sfid2=1;
        tpid2=1;
        ctr2=0;
        sfreq2=min(Gseq2.sfdom);
        tperiod2=min(Gseq2.tpdom);
    else
        sfid2=Gseq2.sfseq(i);
        tpid2=Gseq2.tpseq(i);
        ctr2=P.contrast2/100*0.5;  %full contrast = .5 (grating goes from -0.5 to 0.5, and is added to background of 0.5)
        sfreq2=Gseq2.sfdom(sfid2);
        tperiod2=Gseq2.tpdom(tpid2);
    end

    
    %get shift per frame
    pixpercycle=deg2pix(1/sfreq,'none');
    if P.drift==1
        shiftperframe=pixpercycle/tperiod;
    end
   
    for j = 1:P.h_per 
       if P.StereoDisp== 0 | P.StereoDisp==1
        %determine which part of stimulus to draw
        if P.drift==1
            xoffset = mod((j-1)*shiftperframe+p/360*pixpercycle,pixpercycle);
        else
            xoffset = p/360*pixpercycle;
        end
        stimSrc=[xoffset 0 xoffset + stimsizeN stimsizeN];   
        Screen('SelectStereoDrawBuffer', screenPTR, 0);

        %need to set blend function so that the global alpha can scale the
        %contrast
        Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
        
        %draw stimulus
        Screen('DrawTexture', screenPTR, Gtxtr(sfid), stimSrc, stimDst,ori,[],ctr);
    
%         %add mask
       Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawTexture', screenPTR, Masktxtr);

        %add sync
        Screen('DrawTexture', screenPTR, Stxtr(2-rem(i,2)),syncSrc,syncDst);
        end
       if P.StereoDisp== 0 | P.StereoDisp==2

       Screen('SelectStereoDrawBuffer', screenPTR, 1);
        if P.drift==1
            xoffset2 = mod((j-1)*shiftperframe+p2/360*pixpercycle,pixpercycle);
        else
            xoffset2 = p2/360*pixpercycle;
        end
        stimSrc2=[xoffset2 0 xoffset2 + stimsizeN2 stimsizeN2];
%         need to set blend function so that the global alpha can scale the
%         contrast
        Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE);
        
%         draw stimulus
       Screen('DrawTexture', screenPTR, Gtxtr2(sfid2), stimSrc2, stimDst2,ori2,[],ctr2);

%         add mask
       Screen('BlendFunction', screenPTR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
       Screen('DrawTexture', screenPTR, Masktxtr2);
  
%         add sync
        Screen('DrawTexture', screenPTR, Stxtr(2-rem(i,2)),syncSrc,syncDst);
       end
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
    Screen('SelectStereoDrawBuffer', screenPTR, 0);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen('SelectStereoDrawBuffer', screenPTR, 1);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    %generate event to signal end of stimulus presentation
    if i==1 && loopTrial ~= -1
        digWord = 1;  %toggle 2nd bit to signal stim on
        DaqDOut(daq, 0, digWord);
    end
end
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');


if loopTrial ~= -1
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end


%set sync to black for next stimulus
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');



