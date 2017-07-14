function playTexture_PiecewiseManual

global  screenPTR screenPTROff

%call configure file to preset Pstate - we're doing it this way so that we
%don't overwrite Pstate on the master and confuse stimulus modules and
%manual mappers
configPstate_Piecewise;

screenPTROff = Screen('OpenOffscreenWindow',screenPTR,[],[],[],[],8);
Screen(screenPTROff,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%define the list of parameters that can be accessed with the mouse and
%their settings
symbList = {'stimId','ori','size','contrast','background','color','visible'};
valdom{1} = 1:10;
valdom{2} = 0:45:359;
valdom{3} = 0.5:0.5:10;
valdom{4} = [5 15 50 100];
valdom{5} = [0 0.25 0.5 0.75 1];
valdom{6} = 0:7;
valdom{7} = [0 1];

%set starting value and symbol 
state.valId = [1 1 3 4 3 2 2];  %Current index for each value domain
state.symId = 1;  %Current symbol index

%shorthand indices
vID=7; % visible
cID=6; % color

%update the parameters
for i = 1:length(valdom)-2
    symbol = symbList{i};
    val = valdom{i}(state.valId(i));
    updatePstate(symbol,num2str(val));
end
color = de2bi(valdom{cID}(state.valId(cID)),3);
updatePstate('color_r',num2str(color(1)));
updatePstate('color_g',num2str(color(2)));
updatePstate('color_b',num2str(color(3)));

%initialize text
symbol = symbList{state.symId};
val = valdom{state.symId}(state.valId(state.symId));
newtext = [symbol ' ' num2str(val)];

%initialize screen
Screen(screenPTR, 'FillRect', valdom{5}(state.valId(5)))
Screen(screenPTR,'DrawText','stimId 1',40,30,1);
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
        else
            state.valId(state.symId) = length(valdom{state.symId});
        end       
        
        val = valdom{state.symId}(state.valId(state.symId));
        
        if state.symId~=vID && state.symId~=cID
            updatePstate(symbol,num2str(val));
        elseif state.symId == cID
            color = de2bi(val,3);
            updatePstate('color_r',num2str(color(1)));
            updatePstate('color_g',num2str(color(2)));
            updatePstate('color_b',num2str(color(3)));
        end
    
        newtext = [symbol ' ' num2str(val)];

        TextrIdx = 1; 
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
        
        TextrIdx = 1;
    end
    
    %%%Case 3: Right Button: increase value%%%
    if ~sum(abs(rightB-db))  %  [0 1 0]  is right click
        
        symbol = symbList{state.symId};
        if state.valId(state.symId) < length(valdom{state.symId})
            state.valId(state.symId) = state.valId(state.symId) + 1;
        else
            state.valId(state.symId) = 1;
        end
      
        val = valdom{state.symId}(state.valId(state.symId));        
        
        if state.symId~=vID && state.symId~=cID
            updatePstate(symbol,num2str(val));
        elseif state.symId == cID
            color = de2bi(val,3);
            updatePstate('color_r',num2str(color(1)));
            updatePstate('color_g',num2str(color(2)));
            updatePstate('color_b',num2str(color(3)));
        end
            
        newtext = [symbol ' ' num2str(val)];
        
        TextrIdx = 1;
    end
    
    updatePstate('x_pos',num2str(mx));
    updatePstate('y_pos',num2str(my));
    makeTexture_Piecewise(true);
        
    TextrIdx = TextrIdx+1;
    
    %only draw if visible
    if valdom{vID}(state.valId(vID))==0
        Screen(screenPTR, 'FillRect', valdom{5}(state.valId(5)))
    else
        Screen('CopyWindow',screenPTROff,screenPTR);
    end
    
    %add text
    Screen(screenPTR,'DrawText',newtext,40,30,1);
    xypos = ['x ' num2str(mx) '; y ' num2str(my)];
    Screen(screenPTR,'DrawText',xypos,40,55,1);
    Screen('Flip', screenPTR);
    
    bLast = b;
    
    keyIsDown = KbCheck;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen(screenPTR, 'FillRect', 0.5)
Screen(screenPTR, 'Flip');
