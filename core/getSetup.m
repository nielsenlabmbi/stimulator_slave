function getSetup
%get the default parameters for this setup
%format of setupDefault.txt for slave:
%setupID: XXX
%masterIP: XXX
%defaultMonitor: XXX
%monitorList: name of monitor file (do not include path!!!)
%logRoot: root folder for log file
%useDaq: use measurement computing daq device?
%
%do not change the names of these fields!!!

global setupDefault

setupDefault=struct;


%location of setup file
filePath='/usr/local/';
fileName='setupDefault.txt';

%open file
fId=fopen(fullfile(filePath,fileName));

%read the text (logic: parameter name: parameter setting)
c=textscan(fId,'%s %s');

%transform into structure

for i=1:length(c{1})
    %get parameter name minus the trailing colon
    pn=c{1}{i}(1:end-1);
    
    %get parameter value
    vn=c{2}{i};
    
    %need to deal with multiple entries under one name
    if isfield(setupDefault,pn)==0
        setupDefault.(pn)=vn;
    else
        tmp=setupDefault.(pn);
        setupDefault.(pn)=[tmp '; ' vn];
    end
end

%parameter conversion where necessary
if isfield(setupDefault,'useMCDaq')
    setupDefault.useMCDaq=str2num(setupDefault.useMCDaq);
end

fclose(fId);
