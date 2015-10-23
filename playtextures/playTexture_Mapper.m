function playTexture_Mapper

global  screenPTR  





%%%%%%%%%%%%%%%%%%

symbList = {'ori','width','length','barLum','background'};
valdom{1} = 0:15:359;
valdom{2} = logspace(log10(.1),log10(60),30);
valdom{3} = logspace(log10(.1),log10(60),30);
valdom{4} = [0 0.5 1];
valdom{5} = [0 0.5 1];

state.valId = [1 8 15 3 1];  %Current index for each value domain
state.symId = 1;  %Current symbol index
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%

%initialize the texture
L=deg2pix(valdom{2}(state.valId(2)),'round');
W=deg2pix(valdom{3}(state.valId(3)),'round');
Im = ones(L,W);
Im = Im*valdom{4}(state.valId(4));
Gtxtr = Screen(screenPTR, 'MakeTexture',Im,[],[],2);


symbol = symbList{state.symId};
val = valdom{state.symId}(state.valId(state.symId));
newtext = [symbol ' ' num2str(val)];



Screen(screenPTR, 'FillRect', valdom{5}(state.valId(5)))

%%%%%Play whats in the buffer (the stimulus)%%%%%%%%%%

Screen(screenPTR,'DrawText','ori 0',40,30,1-floor(valdom{5}(state.valId(5))));
Screen('Flip', screenPTR);




bLast = [0 0 0];
keyIsDown = 0;
while ~keyIsDown
    
    [mx,my,b] = GetMouse(screenPTR);
    b=b(1:3);
    
    
    db = bLast - b; %'1' is a button release
           
     
    
    %%%Case 1: Left Button%%%
    if ~sum(abs([1 0 0]-db))
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) > 1
            state.valId(state.symId) = state.valId(state.symId) - 1;
        end       
        
        val = valdom{state.symId}(state.valId(state.symId));

        if state.symId>1 && state.symId<5
            L=deg2pix(valdom{2}(state.valId(2)),'round');
            W=deg2pix(valdom{3}(state.valId(3)),'round');
            Im = ones(L,W);
            Im = Im*valdom{4}(state.valId(4));
            Gtxtr = Screen(screenPTR, 'MakeTexture',Im,[],[],2);
        end
        
        if strcmp(symbol,'background') 
            Screen(screenPTR, 'FillRect', val)
        end
        
        newtext = [symbol ' ' num2str(val)];
        
        Screen(screenPTR,'DrawText',newtext,40,30,1-floor(valdom{5}(state.valId(5))));
        Screen('Flip', screenPTR);
    end
    
    %%%Case 2: Middle Button%%%
    if ~sum(abs([0 0 1]-db))  % [0 0 1] is the scroll bar in the middle
        
        state.symId = state.symId+1; %update the symbol
        if state.symId > length(symbList)
            state.symId = 1; %unwrap
        end
        symbol = symbList{state.symId};
        val = valdom{state.symId}(state.valId(state.symId));
        
        newtext = [symbol ' ' num2str(val)];
        
        Screen(screenPTR,'DrawText',newtext,40,30,1-1*floor(valdom{5}(state.valId(5))));
        Screen('Flip', screenPTR);
    end
    
    %%%Case 3: Right Button%%%
    if ~sum(abs([0 1 0]-db))  %  [0 1 0]  is right click
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) < length(valdom{state.symId})
            state.valId(state.symId) = state.valId(state.symId) + 1;
        end
      
        val = valdom{state.symId}(state.valId(state.symId));        
        
        if state.symId>1 && state.symId<5
            L=deg2pix(valdom{2}(state.valId(2)),'round');
            W=deg2pix(valdom{3}(state.valId(3)),'round');
            Im = ones(L,W);
            Im = Im*valdom{4}(state.valId(4));
            Gtxtr = Screen(screenPTR, 'MakeTexture',Im,[],[],2);
        end
        
        if strcmp(symbol,'background') 
            Screen(screenPTR, 'FillRect', val)
        end
        
        newtext = [symbol ' ' num2str(val)];
        
        Screen(screenPTR,'DrawText',newtext,40,30,1-1*floor(valdom{5}(state.valId(5))));
        Screen('Flip', screenPTR);
    end
   
 
    
    ori = valdom{1}(state.valId(1));
    stimSrc=[0 0 W L];
    stimDst=CenterRectOnPoint(stimSrc,mx,my);
    
    Screen('DrawTextures', screenPTR,Gtxtr,stimSrc,stimDst,ori);    
    Screen(screenPTR,'DrawText',newtext,40,30,1-1*floor(valdom{5}(state.valId(5))));
    xypos = ['x ' num2str(mx) '; y ' num2str(my)];
    Screen(screenPTR,'DrawText',xypos,40,55,1-1*floor(valdom{5}(state.valId(5))));
    Screen('Flip', screenPTR);
    
    bLast = b;
    
    keyIsDown = KbCheck(-1);
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen(screenPTR, 'FillRect', 0.5)
Screen(screenPTR, 'Flip');





