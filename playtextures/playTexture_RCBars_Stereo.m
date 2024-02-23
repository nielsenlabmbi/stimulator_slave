function playTexture_RCBars_Stereo


global Mstate screenPTR screenNum loopTrial

global Gtxtr Gseq Gtxtr2 Gseq2 daq  %Created in makeGratingTexture

global Stxtr %Created in makeSyncTexture


P = getParamStruct;

screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

%get sync size and position
syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);
syncSrc = [0 0 syncWX-1 syncWY-1]';
syncDst = [0 0 syncWX-1 syncWY-1]';

%stimulus size and position
barW=deg2pix(P.barWidth,'round');
barL=deg2pix(P.barLength,'round');
stimSrc=[0 0 barW barL];
stimSrc=stimSrc'*ones(1,P.N_bar);

barW2=deg2pix(P.barWidth2,'round');
barL2=deg2pix(P.barLength2,'round');
stimSrc2=[0 0 barW2 barL2];
stimSrc2=stimSrc2'*ones(1,P.N_bar2);

%get timing information
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);

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

%Wake up the daq
DaqDOut(daq, 0, 0); 

%%%Play predelay %%%%
Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    digWord = 1; 
    DaqDOut(daq, 0, digWord);
end
for i = 2:Npreframes
    Screen('SelectStereoDrawBuffer', screenPTR, 0);
    Screen('DrawTexture', screenPTR, Stxtr(2), syncSrc,syncDst);
    Screen('SelectStereoDrawBuffer', screenPTR, 1);
    Screen('DrawTexture', screenPTR, Stxtr(2), syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
end

%%%%%Play stimuli%%%%%%%%%%
for i = 1:length(Gtxtr)
    ori=Gseq.oridom(Gseq.oriseq(:,i));
    ori2=Gseq2.oridom(Gseq2.oriseq(:,i));

    for j=1:P.h_per
        Screen('SelectStereoDrawBuffer', screenPTR, 0);
        Screen('DrawTextures', screenPTR, [Gtxtr{i} Stxtr(2-rem(i,2))],...
            [stimSrc syncSrc],[Gseq.stimDst{i,j} syncDst],[ori 0]);
        Screen('SelectStereoDrawBuffer', screenPTR, 1);
        Screen('DrawTextures', screenPTR, [Gtxtr2{i} Stxtr(2-rem(i,2))],...
            [stimSrc syncSrc],[Gseq2.stimDst{i,j} syncDst],[ori2 0]);
        Screen(screenPTR, 'Flip');  
    end
    
    %generate event 
    if mod(i,2)==1 && loopTrial ~= -1
        digWord = 7;  %toggle 2nd bit high to signal stim on
        DaqDOut(daq, 0, digWord);
    end
    if mod(i,2)==0 && loopTrial ~= -1
        digWord = 1;  %reset 2nd bit to low
        DaqDOut(daq, 0, digWord);
    end
end

%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen('SelectStereoDrawBuffer', screenPTR, 0);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen('SelectStereoDrawBuffer', screenPTR, 1);
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
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

