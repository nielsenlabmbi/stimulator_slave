function saveLog_Dots(x,loopTrial)

%this function saves the position of randomly placed dots in a frame or
%trial
%we're keeping everything in one file, so it needs to
%save every trial as a structure with a unique name

global Mstate

root = '/home/nielsenlab/log_files/';
root2 = '/Volumes/NielsenHome/Ephys/log_files/';


expt = [Mstate.anim '_' Mstate.unit '_' Mstate.expt];

fname = [root expt '.log'];
fname2 = [root2 expt '.log'];

frate = Mstate.refresh_rate;

eval(['DotFrame' num2str(loopTrial) '=x;' ])

if loopTrial==1
    save(fname,'DotFrame1','frate')    
else     
    eval(['save ' fname ' DotFrame' num2str(loopTrial) ' -append'])    
end


if exist(root2,'dir')
    if loopTrial==1
        save(fname2,'DotFrame1','frate')    
    else     
        eval(['save ' fname2 ' DotFrame' num2str(loopTrial) ' -append'])    
    end
end