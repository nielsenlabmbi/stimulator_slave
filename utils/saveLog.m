function saveLog(seq,seed,trialno)

%this function saves the sequence structure and domains for flashed stimuli; 
%we're keeping everything in one file, so it needs to
%save every trial as a structure with a unique name

global Mstate

root = '/home/nielsenlab/log_files/';
root2 = '/Volumes/NielsenHome/Ephys/log_files/';

expt = [Mstate.anim '_' Mstate.unit '_' Mstate.expt];

fname = [root expt '.log'];
fname2 = [root2 expt '.log'];


seq.frate = Mstate.refresh_rate;


eval(['rseed' num2str(seed) '=seq;' ])
if trialno==1
    eval(['save ' fname ' rseed' num2str(seed)])    
else
    eval(['save ' fname ' rseed' num2str(seed) ' -append'])    
end

if exist(root2,'dir')
    if trialno==1
        eval(['save ' fname2 ' rseed' num2str(seed)])    
    else
        eval(['save ' fname2 ' rseed' num2str(seed) ' -append'])    
    end
end