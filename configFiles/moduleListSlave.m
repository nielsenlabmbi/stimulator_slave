function Mlist = moduleListSlave

%list of all modules on the slave
%organization: module code (for communication with the master), parameter
%file name, maketexture file name, playtexture file name
%the first one is the module that is automatically loaded when starting
%stimulator
%in contrast to the master, this list contains both the modules used by
%paramSelect and the manualMapper
%for the manualMapper, the makeTexture file and config file are not used
%ordering of modules here is independent of ordering of modules on master
%(identification is via the code)
%similarly, the blanks only have the playTexture file. blank file is listed here
%so that all make/play/config files are listed in the same place. blank
%should always be the last entry in Mlist

Mlist{1} = {'PG' 'configPstate_PerGrating' 'makeTexture_PerGrating' 'playTexture_PerGrating' };
Mlist{2} = {'RD' 'configPstate_RDK' 'makeTexture_RDK' 'playTexture_RDK' };
Mlist{3} = {'RG' 'configPstate_RCGrating' 'makeTexture_RCGrating' 'playTexture_RCGrating' };
Mlist{4} = {'RT' 'configPstate_RC2Gratings' 'makeTexture_RC2Gratings' 'playTexture_RC2Gratings' };
Mlist{5} = {'RP' 'configPstate_RCGratPlaid' 'makeTexture_RCGratPlaid' 'playTexture_RCGratPlaid' };
Mlist{6} = {'OF' 'configPstate_OpticFlow' 'makeTexture_OpticFlow' 'playTexture_OpticFlow' };
Mlist{7} = {'IM' 'configPstate_Img' 'makeTexture_Img' 'playTexture_Img' };
Mlist{8} = {'GA' 'configPstate_GA' 'makeTexture_GA' 'playTexture_GA' };
Mlist{9} = {'AD' 'configPstate_Adapt' 'makeTexture_Adapt' 'playTexture_Adapt' };
Mlist{10} = {'PC' 'configPstate_PerGratingColor' 'makeTexture_PerGratingColor' 'playTexture_PerGratingColor' };
Mlist{11} = {'BP' 'configPstate_BarberPole' 'makeTexture_BarberPole' 'playTexture_BarberPole' };


%playfile for the manual mapper
Mlist{end+1} = {'MG' '' '' 'playTexture_PerGratingManual'};
Mlist{end+1} = {'MM' '' '' 'playTexture_Mapper'};
Mlist{end+1} = {'MR' '' '' 'playTexture_RDKManual'};
Mlist{end+1} = {'MI' '' '' 'playTexture_ImgManual'};

%playfile for blanks
Mlist{end+1} = {'' '' '' 'playTexture_Blank'};


