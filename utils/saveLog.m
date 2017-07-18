function saveLog(seq,seed,trialno)

%this function saves the sequence structure and domains for flashed stimuli; 
%we're keeping everything in one file, so it needs to
%save every trial as a structure with a unique name

global Mstate setupDefault


rootDirs=strtrim(strsplit(setupDefault.logRoot,';'));

for i=1:length(rootDirs)
    if exist(rootDirs{i},'dir')
        
        expt = [Mstate.anim '_' Mstate.unit '_' Mstate.expt];
        fname = fullfile(rootDirs{i}, [expt '.log']);
        
        seq.frate = Mstate.refresh_rate;
        
        eval(['rseed' num2str(seed) '=seq;' ])
        if trialno==1
            eval(['save ' fname ' rseed' num2str(seed)])
        else
            eval(['save ' fname ' rseed' num2str(seed) ' -append'])
        end
    end
end
