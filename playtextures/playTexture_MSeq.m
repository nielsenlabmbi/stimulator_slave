function playTexture_MSeq

%generates noise pattern based on M sequence


global Mstate screenPTR screenNum loopTrial 

global Gtxtr daq  Gseq 

global Stxtr %Created in makeSyncTexture

P = getParamStruct;

%get stimulus size
screenRes = Screen('Resolution',screenNum);
pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

syncWX = round(pixpercmX*Mstate.syncSize);
syncWY = round(pixpercmY*Mstate.syncSize);

syncSrc = [0 0 syncWX-1 syncWY-1]';
syncDst = [0 0 syncWX-1 syncWY-1]';


%size in pixels - make sure stimulus size is multiple of 16
pN=deg2pix(P.size,'round');
pN=round(pN/16)*16;

stimDst=CenterRectOnPoint([0 0 pN-1 pN-1],P.x_pos,P.y_pos);


%timing
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);

N_Im = round(P.stim_time*screenRes.hz/P.h_per); 
MseqFrames=size(Gseq.Mseq,3);


Screen(screenPTR, 'FillRect', P.background)

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

%%%%%Play the stimulus
digWord=3;
sidx=1;
for i=1:N_Im
    
    %need to first make the stimulus
    tidx=mod(i-1,MseqFrames)+1;
    img=squeeze(Gseq.Mseq(:,:,tidx));
    Gtxtr = Screen('MakeTexture',screenPTR, img,[],[],2);
    
    for j = 1:P.h_per
        Screen('DrawTexture', screenPTR, Gtxtr,[], stimDst, [], 0); %need to make sure interpolation is off
   
        %add sync - update every 5 stimuli
        if mod(i-1,10)==0
            sidx=~sidx;
        end
        Screen('DrawTexture', screenPTR, Stxtr(sidx+1),syncSrc,syncDst);
        
        %flip
        Screen(screenPTR, 'Flip');

        %generate event - toggle between up and down on third channel
        if j==1 && loopTrial ~= -1
            if digWord==3
                digWord=7;
            elseif digWord==7
                digWord=3;
            end
            DaqDOut(daq, 0, digWord);
        end
        
    end
end



%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);
    Screen(screenPTR, 'Flip');
    if i==1 && loopTrial ~= -1
        digWord = 1;  %toggle 2nd bit to signal stim off
        DaqDOut(daq, 0, digWord);
    end
end
Screen('DrawTexture', screenPTR, Stxtr(1),syncSrc,syncDst);
Screen(screenPTR, 'Flip');
if loopTrial ~= -1
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('DrawTexture', screenPTR, Stxtr(2),syncSrc,syncDst);  
Screen(screenPTR, 'Flip');

