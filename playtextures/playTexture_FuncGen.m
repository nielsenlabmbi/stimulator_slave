function playTexture_FuncGen
%play periodic grating
%types of stimuli: one grating (plaid_bit=0), two overlapping gratings,
%both visible entirely (plaid_bit=1, surround_bit=0), two gratings, one in
%center, one in surround (plaid_bit=0, surround_bit=1); plaid_bit==1 and
%surround_bit==1 defaults to plaid
%assumes normalized color
global  screenPTR screenNum daq loopTrial

global FuncGenPort


startStr = '!Start';
stopStr = '!Stop';

%get basic parameters
P = getParamStruct;

%get timing information
screenRes = Screen('Resolution',screenNum);
Npreframes = ceil(P.predelay*screenRes.hz);
Npostframes = ceil(P.postdelay*screenRes.hz);
Nstimframes = ceil(P.stim_time*screenRes.hz);



%Wake up the daq to improve timing later
if ~isempty(daq)
    DaqDOut(daq, 0, 0);
end

%%%Play predelay %%%%
Screen(screenPTR, 'FillRect', 0)
Screen(screenPTR, 'Flip');
if loopTrial ~= -1 && ~isempty(daq)
    digWord = 1;  %Make 1st bit high
    DaqDOut(daq, 0, digWord);    
end
for i = 2:Npreframes
    Screen(screenPTR, 'Flip');
end


%%%%%Play stimuli%%%%%%%%%%
for i = 1:Nstimframes
    Screen(screenPTR, 'Flip');
    
    if i==1
        %start stimulus
        writeline(FuncGenPort, startStr);
                
        %generate event
        if ~isempty(daq) && loopTrial ~= -1
            
            digWord=3;
            DaqDOut(daq, 0, digWord);
        end
    end
    
end
    

%%%Play postdelay %%%%
for i = 1:Npostframes-1
    Screen(screenPTR, 'Flip');
    
    if i==1
        writeline(FuncGenPort, stopStr);
        
        if loopTrial ~= -1 && ~isempty(daq)
            digWord = 1;  %toggle 2nd bit to signal stim on
            DaqDOut(daq, 0, digWord);            
        end
    end
end
Screen(screenPTR, 'Flip');


if loopTrial ~= -1 && ~isempty(daq)
    DaqDOut(daq, 0, 0);  %Make sure 3rd bit finishes low
end






