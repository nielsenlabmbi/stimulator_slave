function saveLog(seq,seed,trialno)

%this function saves the sequence structure and domains; 
%we're keeping everything in one file, so it needs to
%save every trial with a unique name

global Mstate

root = '/log_files/';

expt = [Mstate.anim '_' Mstate.unit '_' Mstate.expt];

fname = [root expt '.mat'];


seq.frate = Mstate.refresh_rate;


eval(['rseed' num2str(seed) '=seq;' ])
if trialno==1
    eval(['save ' fname ' rseed' num2str(seed)])    
else
    eval(['save ' fname ' rseed' num2str(seed) ' -append'])    
end

