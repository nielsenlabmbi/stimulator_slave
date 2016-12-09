function playTexture_PacmanManual

global  screenPTR screenNum

global DotCoord   %Created in makePacman

%call configure file to preset Pstate - we're doing it this way so that we
%don't overwrite Pstate on the master and confuse stimulus modules and
%manual mappers
configPstate_Pacman;


screenRes = Screen('Resolution',screenNum);


%define the list of parameters that can be accessed with the mouse and
%their settings
symbList = {'ori','acute','r_size','stim_type','sharp','background','stim_color','visible'};
valdom{1} = 0:15:359;
valdom{2} = 0:30:180;
valdom{3} = logspace(log10(.1),log10(60),30);  %deg
valdom{4} = [1 2];
valdom{5} = [0 1];
valdom{6} = 0:0.2:1;
valdom{7} = 1:9;
valdom{8} = [0 1];

%shorthand indices
smID=5; %sharp
bID=6; %background
sID=7; %color
vID=8; %visible


%these are the colors for the stimulus
colorvec=[1 1 1;... %white
    0.5 0.5 0.5;... %gray
    0 0 0;... %black
    1 0 0;... %red
    0 1 0;... %green
    0 0 1;... %blue
    1 1 0;... %yellow
    1 0 1;... %magenta
    0 1 1];   %cyan

%set starting value and symbol
state.valId = [1 3 5 1 2 1 1 2];  %Current index for each value domain
state.symId = 1;  %Current symbol index


%update the parameters that can be updated directly
for i = 1:5
    symbol = symbList{i};
    val = valdom{i}(state.valId(i));
    updatePstate(symbol,num2str(val));
end

%also update position (we need to handle offset here)
updatePstate('x_pos','0');
updatePstate('y_pos','0');

%initialize texture
makeTexture_Pacman %this populates Gtxtr and Masktxtr

%initialize text
symbol = symbList{state.symId};
val = valdom{state.symId}(state.valId(state.symId));
newtext = [symbol ' ' num2str(val)];

%initialize convexity setting (we start with smooth curves)
isConvex = 1;

%initialize screen
Screen(screenPTR, 'FillRect', valdom{bID}(state.valId(bID)))
Screen(screenPTR,'DrawText',newtext,40,30,1-floor(valdom{bID}(state.valId(bID))));
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

%start the actual loop
bLast = [0 0 0];
keyIsDown = 0;
TextrIdx = 1;
while ~keyIsDown
    
    [mx,my,b] = GetMouse(screenPTR);
    b=b(1:3);
    
    db = bLast - b; %'1' is a button release
    
    %%%Case 1: Left Button:  decrease value%%%
    if ~sum(abs(leftB-db))
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) > 1
            state.valId(state.symId) = state.valId(state.symId) - 1;
        elseif state.symId == 1
            state.valId(state.symId) = length(valdom{state.symId});
        end
        
        val = valdom{state.symId}(state.valId(state.symId));
        
        if state.symId<bID
            updatePstate(symbol,num2str(val));
            if state.symId==smID %need to set convexity setting correctly
                isConvex=val;
            end
        elseif state.symId==bID %background
            Screen(screenPTR, 'FillRect', val);
        end
        
        makeTexture_Pacman
        %reset position matrix
        DotCoord2=DotCoord;
        
        newtext = [symbol ' ' num2str(val)];
    end
    
    %%%Case 2: Middle Button:  change parameter%%%
    if ~sum(abs(middleB-db))  % [0 0 1] is the scroll bar in the middle
        
        state.symId = state.symId+1; %update the symbol
        if state.symId > length(symbList)
            state.symId = 1; %unwrap
        end
        symbol = symbList{state.symId};
        val = valdom{state.symId}(state.valId(state.symId));
        
        newtext = [symbol ' ' num2str(val)];
        
    end
    
    %%%Case 3: Right Button: increase value%%%
    if ~sum(abs(rightB-db))  %  [0 1 0]  is right click
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) < length(valdom{state.symId})
            state.valId(state.symId) = state.valId(state.symId) + 1;
        elseif state.symId == 1
            state.valId(state.symId) = 1;
        end
        
        val = valdom{state.symId}(state.valId(state.symId));
        
        if state.symId<bID
            updatePstate(symbol,num2str(val));
        elseif state.symId==bID %background
            Screen(screenPTR, 'FillRect', val);
        end
        
        makeTexture_Pacman
        %reset position matrix
        DotCoord2=DotCoord;
        
        newtext = [symbol ' ' num2str(val)];
    end
    
    %shift position
    DotCoord2(1,:) =mx+DotCoord(1,:);
    DotCoord2(2,:) =my+DotCoord(2,:); 
    
    % Draw the shape to the screen
    if valdom{vID}(state.valId(vID))==1
        Screen('FillPoly', screenPTR, colorvec(valdom{sID}(state.valId(sID)),:), [DotCoord2(1,:); DotCoord2(2,:)]', isConvex);
    end
    
    %add text
    Screen(screenPTR,'DrawText',newtext,40,30,1);
    xypos = ['x ' num2str(mx) '; y ' num2str(my)];
    Screen(screenPTR,'DrawText',xypos,40,55,1-floor(valdom{bID}(state.valId(bID))));
    Screen('Flip', screenPTR);
    
    bLast = b;
    
    keyIsDown = KbCheck;
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen(screenPTR, 'FillRect', 0.5)
Screen(screenPTR, 'Flip');