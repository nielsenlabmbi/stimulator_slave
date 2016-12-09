function playTexture_Mapper

global  screenPTR  





%%%%%%%%%%%%%%%%%%

symbList = {'ori','width','length','barColor','background','visible'};
valdom{1} = 0:15:359;
valdom{2} = logspace(log10(.1),log10(60),30);
valdom{3} = logspace(log10(.1),log10(60),30);
valdom{4} = 1:9;
valdom{5} = 0:0.2:1;
valdom{6} = [0 1];

%these are the colors for the bar
colorvec=[1 1 1;... %white
    0.5 0.5 0.5;... %gray
    0 0 0;... %black
    1 0 0;... %red 
    0 1 0;... %green
    0 0 1;... %blue
    1 1 0;... %yellow
    1 0 1;... %magenta
    0 1 1];   %cyan


state.valId = [1 8 15 1 1 2];  %Current index for each value domain
state.symId = 1;  %Current symbol index

%shorthand index
vID=6; %visible

%initialize the texture
L=deg2pix(valdom{2}(state.valId(2)),'round');
W=deg2pix(valdom{3}(state.valId(3)),'round');
Im = ones(L,W,3);
for i=1:3
    Im(:,:,i) = colorvec(valdom{4}(state.valId(4)),i);
end
Gtxtr = Screen(screenPTR, 'MakeTexture',Im,[],[],2);


symbol = symbList{state.symId};
val = valdom{state.symId}(state.valId(state.symId));
newtext = [symbol ' ' num2str(val)];



Screen(screenPTR, 'FillRect', valdom{5}(state.valId(5))) %set background color
Screen(screenPTR,'DrawText','ori 0',40,30,1-floor(valdom{5}(state.valId(5))));
Screen('Flip', screenPTR);

%mac and linux assign mouse buttons differently
if ismac
    leftB=[1 0 0];
    middleB=[0 0 1];
    rightB=[0 1 0];
else
    leftB=[1 0 0];
    middleB=[0 1 0];
    rightB=[0 0 1];
end



bLast = [0 0 0];
keyIsDown = 0;
while ~keyIsDown
    
    [mx,my,b] = GetMouse(screenPTR);
    b=b(1:3);
    
    
    db = bLast - b; %'1' is a button release
           
     
    
    %%%Case 1: Left Button%%%
    if ~sum(abs(leftB-db))
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) > 1
            state.valId(state.symId) = state.valId(state.symId) - 1;
        elseif state.symId == 1
            state.valId(state.symId) = length(valdom{state.symId});
        end       
        
        val = valdom{state.symId}(state.valId(state.symId));

        if state.symId>1 && state.symId<5
            L=deg2pix(valdom{2}(state.valId(2)),'round');
            W=deg2pix(valdom{3}(state.valId(3)),'round');
            Im = ones(L,W,3);
            for i=1:3
                Im(:,:,i) = colorvec(valdom{4}(state.valId(4)),i);
            end
            Gtxtr = Screen(screenPTR, 'MakeTexture',Im,[],[],2);
        end
        
        if strcmp(symbol,'background') 
            Screen(screenPTR, 'FillRect', val)
        end
        
        newtext = [symbol ' ' num2str(val)];
    end
    
    %%%Case 2: Middle Button%%%
    if ~sum(abs(middleB-db))  % [0 0 1] is the scroll bar in the middle
        
        state.symId = state.symId+1; %update the symbol
        if state.symId > length(symbList)
            state.symId = 1; %unwrap
        end
        symbol = symbList{state.symId};
        val = valdom{state.symId}(state.valId(state.symId));
        
        newtext = [symbol ' ' num2str(val)];
    end
    
    %%%Case 3: Right Button%%%
    if ~sum(abs(rightB-db))  %  [0 1 0]  is right click
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) < length(valdom{state.symId})
            state.valId(state.symId) = state.valId(state.symId) + 1;
        elseif state.symId == 1
            state.valId(state.symId) = 1;
        end
      
        val = valdom{state.symId}(state.valId(state.symId));        
        
        if state.symId>1 && state.symId<5
            L=deg2pix(valdom{2}(state.valId(2)),'round');
            W=deg2pix(valdom{3}(state.valId(3)),'round');
            Im = ones(L,W,3);
            for i=1:3
                Im(:,:,i) = colorvec(valdom{4}(state.valId(4)),i);
            end
            Gtxtr = Screen(screenPTR, 'MakeTexture',Im,[],[],2);
        end
        
        if strcmp(symbol,'background') 
            Screen(screenPTR, 'FillRect', val)
        end
        
        newtext = [symbol ' ' num2str(val)];

    end
   
 
    
    ori = valdom{1}(state.valId(1));
    stimSrc=[0 0 W L];
    stimDst=CenterRectOnPoint(stimSrc,mx,my);
    
    %only draw if visible
    if valdom{vID}(state.valId(vID))==1
        Screen('DrawTextures', screenPTR,Gtxtr,stimSrc,stimDst,ori);
    end
    
    Screen(screenPTR,'DrawText',newtext,40,30,1-floor(valdom{5}(state.valId(5))));
    xypos = ['x ' num2str(mx) '; y ' num2str(my)];
    Screen(screenPTR,'DrawText',xypos,40,55,1-floor(valdom{5}(state.valId(5))));
    Screen('Flip', screenPTR);
    
    bLast = b;
    
    keyIsDown = KbCheck;
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen(screenPTR, 'FillRect', 0.5)
Screen(screenPTR, 'Flip');





