function Mlist = moduleListStereo

%list of all stereo modules on the slave
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
Mlist{end+1} = {'RD' 'configPstate_RDK' 'makeTexture_RDK' 'playTexture_RDK' };
Mlist{end+1} = {'RG' 'configPstate_RCGrating' 'makeTexture_RCGrating' 'playTexture_RCGrating' };
Mlist{end+1} = {'RT' 'configPstate_RC2Gratings' 'makeTexture_RC2Gratings' 'playTexture_RC2Gratings' };
Mlist{end+1} = {'RP' 'configPstate_RCGratPlaid' 'makeTexture_RCGratPlaid' 'playTexture_RCGratPlaid' };
Mlist{end+1} = {'RN' 'configPstate_RCNGratings' 'makeTexture_RCNGratings' 'playTexture_RCNGratings' };
Mlist{end+1} = {'OF' 'configPstate_OpticFlow' 'makeTexture_OpticFlow' 'playTexture_OpticFlow' };
Mlist{end+1} = {'BR' 'configPstate_Bar' 'makeTexture_Bar' 'playTexture_Bar' };
Mlist{end+1} = {'BK' 'configPstate_Kalatsky' 'makeTexture_Kalatsky' 'playTexture_Kalatsky' };
Mlist{end+1} = {'RB' 'configPstate_RCBars' 'makeTexture_RCBars' 'playTexture_RCBars' };
Mlist{end+1} = {'CK' 'configPstate_CheckerBoard' 'makeTexture_CheckerBoard' 'playTexture_CheckerBoard' };
Mlist{end+1} = {'MS' 'configPstate_MSeq' 'makeTexture_MSeq' 'playTexture_MSeq'};


%playfile for the manual mapper
Mlist{end+1} = {'MG' '' '' 'playTexture_PerGratingManual'};
Mlist{end+1} = {'MM' '' '' 'playTexture_Mapper'};
Mlist{end+1} = {'MR' '' '' 'playTexture_RDKManual'};


%playfile for blanks
Mlist{end+1} = {'' '' '' 'playTexture_Blank'};


