function saveLog_Dots(x,loopTrial)

global Mstate

root = '/log_files/';


expt = [Mstate.anim '_' Mstate.unit '_' Mstate.expt];

fname = [root expt '.mat'];

frate = Mstate.refresh_rate;

if loopTrial==1
    DotFrame1 = x; 
    save(fname,'DotFrame1','frate')    
else 
    eval(['DotFrame' num2str(loopTrial) '=x;' ])
    eval(['save ' fname ' DotFrame' num2str(loopTrial) ' -append'])    
end

