function getSetup
%get the default parameters for this setup
%format of setupDefault.txt for slave:
%setupID: XXX
%masterIP: XXX
%defaultMonitor: XXX
%monitorList: name of monitor file (do not include path!!!)
%logRoot: root folder for log file
%analyzerRoot: root folder for analyzer file
%useDaq: use measurement computing daq device?
%TCPforParams: tcp or analyzer file for params
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
c=textscan(fId,'%s %s', 'Delimiter', ':', 'CommentStyle', '%');

%transform into structure

for i=1:length(c{1})
    %get parameter name and remove whitespace
    pn=strtrim(c{1}{i}); 
    
    %get parameter value and remove whitespace
    vn=strtrim(c{2}{i});
    
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

if isfield(setupDefault,'useSecondGfx')
    setupDefault.useSecondGfx=str2num(setupDefault.useSecondGfx);
else
    setupDefault.useSecondGfx=0;
end


fclose(fId);
