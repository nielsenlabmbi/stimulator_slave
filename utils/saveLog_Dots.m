function saveLog_Dots(x,trialNo)

%this function saves the position of randomly placed dots in a frame or
%trial
%we're keeping everything in one file, so it needs to
%save every trial as a structure with a unique name

global Mstate setupDefault

disp(trialNo)

rootDirs=strtrim(strsplit(setupDefault.logRoot,';'));

for i=1:length(rootDirs)
    if exist(rootDirs{i},'dir')
        
        expt = [Mstate.anim '_' Mstate.unit '_' Mstate.expt];
        fname = fullfile(rootDirs{i}, [expt '.log']);

        eval(['DotFrame' num2str(trialNo) '=x;' ])

        %need to handle saving differently from rc files because there are
        %blank trials - nothing will be saved in them
        if ~exist(fname,'file')
            eval(['save ' fname ' DotFrame' num2str(trialNo)])
        else
            eval(['save ' fname ' DotFrame' num2str(trialNo) ' -append']) 
        end
        
    end
end