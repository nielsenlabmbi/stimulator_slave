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

Mlist{1} = {'SG' 'configPstate_PerGrating_Stereo' 'makeTexture_PerGrating_Stereo' 'playTexture_PerGrating_Stereo' };
Mlist{end+1} = {'SD' 'configPstate_RDK_Stereo' 'makeTexture_RDK_Stereo' 'playTexture_RDK_Stereo' };
Mlist{end+1} = {'SR' 'configPstate_RCGrating_Stereo' 'makeTexture_RCGrating_Stereo' 'playTexture_RCGrating_Stereo' };
Mlist{end+1} = {'RT' 'configPstate_RC2Gratings' 'makeTexture_RC2Gratings' 'playTexture_RC2Gratings' };
Mlist{end+1} = {'RP' 'configPstate_RCGratPlaid' 'makeTexture_RCGratPlaid' 'playTexture_RCGratPlaid' };
Mlist{end+1} = {'RN' 'configPstate_RCNGratings' 'makeTexture_RCNGratings' 'playTexture_RCNGratings' };
Mlist{end+1} = {'OF' 'configPstate_OpticFlow' 'makeTexture_OpticFlow' 'playTexture_OpticFlow' };
Mlist{end+1} = {'BR' 'configPstate_Bar' 'makeTexture_Bar' 'playTexture_Bar' };
Mlist{end+1} = {'SK' 'configPstate_Kalatsky_Stereo' 'makeTexture_Kalatsky_Stereo' 'playTexture_Kalatsky_Stereo' };
Mlist{end+1} = {'SB' 'configPstate_RCBars_Stereo' 'makeTexture_RCBars_Stereo' 'playTexture_RCBars_Stereo' };
Mlist{end+1} = {'CK' 'configPstate_CheckerBoard' 'makeTexture_CheckerBoard' 'playTexture_CheckerBoard' };
Mlist{end+1} = {'MS' 'configPstate_MSeq' 'makeTexture_MSeq' 'playTexture_MSeq'};


%playfile for the manual mapper
Mlist{end+1} = {'MG' '' '' 'playTexture_PerGratingManual_Stereo'};
Mlist{end+1} = {'MM' '' '' 'playTexture_Mapper_stereo'};
Mlist{end+1} = {'MR' '' '' 'playTexture_RDKManual'};


%playfile for blanks
Mlist{end+1} = {'' '' '' 'playTexture_Blank'};


