function playTexture_RDKManual

global  screenPTR  loopTrial

global DotFrame   



%call configure file to preset Pstate - we're doing it this way so that we
%don't overwrite Pstate on the master and confuse stimulus modules and
%manual mappers
loopTrial=-1;
configPstate_RDK;




%define the list of parameters that can be accessed with the mouse and
%their settings
symbList = {'ori','dotDensity','sizeDots','speedDots','dotCoherence','mask_radius','background'};
valdom{1} = 0:15:359;
valdom{2} = logspace(log10(1),log10(100),20);
valdom{3} = linspace(.2,5,10);  
valdom{4} = logspace(log10(5),log10(50),20);
valdom{5} = 0:10:100;
valdom{6} = logspace(log10(.5),log10(60),20);
valdom{7} = [0 0.3 0.5];

%set starting value and symbol 
state.valId = [7 10 5 10 11 10 1];  %Current index for each value domain
state.symId = 1;  %Current symbol index

%update the parameters
for i = 1:length(valdom)
    symbol = symbList{i};
    val = valdom{i}(state.valId(i));
    updatePstate(symbol,num2str(val));
end
xsize = 2*valdom{6}(state.valId(6));  %width = 2*radius
ysize = xsize;
updatePstate('x_size',num2str(xsize));
updatePstate('y_size',num2str(ysize));


%make sure the movie is long enough
updatePstate('stim_time',num2str(10));

%initialize texture
makeTexture_RDK %this populates Gtxtr and Masktxtr

%initialize text
symbol = symbList{state.symId};
val = valdom{state.symId}(state.valId(state.symId));
newtext = [symbol ' ' num2str(val)];


%initialize screen
Screen(screenPTR, 'FillRect', valdom{7}(state.valId(7)))
Screen(screenPTR,'DrawText','ori 0',40,30,1-floor(valdom{7}(state.valId(7))));
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
FrameIdx = 0;
while ~keyIsDown
    
    [mx,my,b] = GetMouse(screenPTR);
    b=b(1:3);
    
    db = bLast - b; %'1' is a button release
           
    %%%Case 1: Left Button:  decrease value%%%
    if ~sum(abs(leftB-db))  
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) > 1
            state.valId(state.symId) = state.valId(state.symId) - 1;
        end       
        
        
        val = valdom{state.symId}(state.valId(state.symId));
        
        updatePstate(symbol,num2str(val));  
        newtext = [symbol ' ' num2str(val)];
        
        
        if strcmp(symbol,'mask_radius')
            %update size
            xsize = 2*valdom{6}(state.valId(6));  %width = 2*radius
            ysize = xsize;
            updatePstate('x_size',num2str(xsize));
            updatePstate('y_size',num2str(ysize));
        end
        
        if strcmp(symbol,'background') 
            Screen(screenPTR, 'FillRect', val)
        end
        
        makeTexture_RDK;
        FrameIdx = 0;
               
        Screen(screenPTR,'DrawText',newtext,40,30,1-floor(valdom{7}(state.valId(7))));
        Screen('Flip', screenPTR);
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
        
        FrameIdx = 0;
        
        Screen(screenPTR,'DrawText',newtext,40,30,1-floor(valdom{7}(state.valId(7))));
        Screen('Flip', screenPTR);
    end
    
    %%%Case 3: Right Button: increase value%%%
    if ~sum(abs(rightB-db))  %  [0 1 0]  is right click
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) < length(valdom{state.symId})
            state.valId(state.symId) = state.valId(state.symId) + 1;
        end
      
        val = valdom{state.symId}(state.valId(state.symId));        
        
        updatePstate(symbol,num2str(val));
        newtext = [symbol ' ' num2str(val)];
       
        
        if strcmp(symbol,'mask_radius')
            %update size
            xsize = 2*valdom{6}(state.valId(6));  %width = 2*radius
            ysize = xsize;
            updatePstate('x_size',num2str(xsize));
            updatePstate('y_size',num2str(ysize));
        end
        
        if strcmp(symbol,'background') 
            Screen(screenPTR, 'FillRect', val)
        end
        
        FrameIdx = 0;
        
        makeTexture_RDK;
        
        Screen(screenPTR,'DrawText',newtext,40,30,1-floor(valdom{7}(state.valId(7))));
        Screen('Flip', screenPTR);
    end
    
    FrameIdx = mod(FrameIdx,length(DotFrame))+1;
   
    sizeDotsPx=deg2pix(valdom{3}(state.valId(3)),'round');
    if ~isempty(DotFrame{FrameIdx})
        Screen('DrawDots', screenPTR, DotFrame{FrameIdx}, sizeDotsPx, [1 1 1],[mx my],1);
    end
    
    %add text
    Screen(screenPTR,'DrawText',newtext,40,30,1-floor(valdom{7}(state.valId(7))));
    xypos = ['x ' num2str(mx) '; y ' num2str(my)];
    Screen(screenPTR,'DrawText',xypos,40,55,1-floor(valdom{7}(state.valId(7))));
    Screen('Flip', screenPTR);
    
    bLast = b;
    
    keyIsDown = KbCheck;
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen(screenPTR, 'FillRect', 0.5)
Screen(screenPTR, 'Flip');


