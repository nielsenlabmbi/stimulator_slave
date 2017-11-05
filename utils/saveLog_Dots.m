function saveLog_Dots(x,loopTrial)

%this function saves the position of randomly placed dots in a frame or
%trial
%we're keeping everything in one file, so it needs to
%save every trial as a structure with a unique name

global Mstate setupDefault


rootDirs=strtrim(strsplit(setupDefault.logRoot,';'));

for i=1:length(rootDirs)
    if exist(rootDirs{i},'dir')
        
        expt = [Mstate.anim '_' Mstate.unit '_' Mstate.expt];
        fname = fullfile(rootDirs{i}, [expt '.log']);

        frate = Mstate.refresh_rate;

        eval(['DotFrame' num2str(loopTrial) '=x;' ])

        if loopTrial==1
               save(fname,'DotFrame1','frate')    
        else     
            eval(['save ' fname ' DotFrame' num2str(loopTrial) ' -append'])    
        end
    end
end