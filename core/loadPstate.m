function loadPstate(modID)

%update Pstate with info from the analyzer file


global Pstate Mstate setupDefault

%load analyzer file
expt = [Mstate.anim '_u' Mstate.unit '_' Mstate.expt];
fname=fullfile(setupDefault.analyzerRoot,Mstate.anim,[expt '.analyzer']);
Pnew=load(fname,'-mat');

if ~strcmp(Pnew.Analyzer.P.type{1},modID)
    disp('Mismatch in module type, could not update parameters from Analyzer file!');
    return;
end

Pstate.param=Pnew.Analyzer.P.param;

