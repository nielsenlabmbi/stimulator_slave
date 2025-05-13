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
Mlist{end+1} = {'RD' 'configPstate_RDK' 'makeTexture_RDK' 'playTexture_RDK' };
Mlist{end+1} = {'RG' 'configPstate_RCGrating' 'makeTexture_RCGrating' 'playTexture_RCGrating' };
Mlist{end+1} = {'RT' 'configPstate_RC2Gratings' 'makeTexture_RC2Gratings' 'playTexture_RC2Gratings' };
Mlist{end+1} = {'RP' 'configPstate_RCGratPlaid' 'makeTexture_RCGratPlaid' 'playTexture_RCGratPlaid' };
Mlist{end+1} = {'RN' 'configPstate_RCNGratings' 'makeTexture_RCNGratings' 'playTexture_RCNGratings' };
Mlist{end+1} = {'OF' 'configPstate_OpticFlow' 'makeTexture_OpticFlow' 'playTexture_OpticFlow' };
Mlist{end+1} = {'IM' 'configPstate_Img' 'makeTexture_Img' 'playTexture_Img' };
Mlist{end+1} = {'GA' 'configPstate_GA' 'makeTexture_GA' 'playTexture_GA' };
Mlist{end+1} = {'AD' 'configPstate_Adapt' 'makeTexture_Adapt' 'playTexture_Adapt' };
Mlist{end+1} = {'RA' 'configPstate_RCAdaptGrating' 'makeTexture_RCAdaptGrating' 'playTexture_RCAdaptGrating' };
Mlist{end+1} = {'PC' 'configPstate_PerGratingColor' 'makeTexture_PerGratingColor' 'playTexture_PerGratingColor' };
Mlist{end+1} = {'BP' 'configPstate_BarberPole' 'makeTexture_BarberPole' 'playTexture_BarberPole' };
Mlist{end+1} = {'TP' 'configPstate_TransPlaid' 'makeTexture_TransPlaid' 'playTexture_TransPlaid' };
Mlist{end+1} = {'BR' 'configPstate_Bar' 'makeTexture_Bar' 'playTexture_Bar' };
Mlist{end+1} = {'BK' 'configPstate_Kalatsky' 'makeTexture_Kalatsky' 'playTexture_Kalatsky' };
Mlist{end+1} = {'RB' 'configPstate_RCBars' 'makeTexture_RCBars' 'playTexture_RCBars' };
Mlist{end+1} = {'FR' 'configPstate_RadialFreq' 'makeTexture_RadialFreq' 'playTexture_RadialFreq' };
Mlist{end+1} = {'PM' 'configPstate_Pacman' 'makeTexture_Pacman' 'playTexture_Pacman' };
Mlist{end+1} = {'GL' 'configPstate_Glass' 'makeTexture_Glass' 'playTexture_Glass' };
Mlist{end+1} = {'CK' 'configPstate_CheckerBoard' 'makeTexture_CheckerBoard' 'playTexture_CheckerBoard' };
Mlist{end+1} = {'CG' 'configPstate_CounterBar' 'makeTexture_CounterBar' 'playTexture_CounterBar' };
Mlist{end+1} = {'SG' 'configPstate_SimpleGrating' 'makeTexture_SimpleGrating' 'playTexture_SimpleGrating' };
Mlist{end+1} = {'WG' 'configPstate_WarpedGrating' 'makeTexture_WarpedGrating' 'playTexture_WarpedGrating' };
Mlist{end+1} = {'WC' 'configPstate_WarpedChecker' 'makeTexture_WarpedChecker' 'playTexture_WarpedChecker' };
Mlist{end+1} = {'PW' 'configPstate_Piecewise' 'makeTexture_Piecewise' 'playTexture_Piecewise' };
Mlist{end+1} = {'PR' 'configPstate_PiecewiseRetinotopy' 'makeTexture_PiecewiseRetinotopy' 'playTexture_PiecewiseRetinotopy' };
Mlist{end+1} = {'RI' 'configPstate_RCImg' 'makeTexture_RCImg' 'playTexture_RCImg' };
Mlist{end+1} = {'IG' 'configPstate_ImgGrating' 'makeTexture_ImgGrating' 'playTexture_ImgGrating' };
Mlist{end+1} = {'IT' 'configPstate_ImgTexture' 'makeTexture_ImgTexture' 'playTexture_ImgTexture' };
Mlist{end+1} = {'OS' 'configPstate_Opto' 'makeTexture_Opto' 'playTexture_Opto' };
Mlist{end+1} = {'IS' 'configPstate_ImgScanning' 'makeTexture_ImgScanning' 'playTexture_ImgScanning'};
Mlist{end+1} = {'TT' 'configPstate_TestTrial' 'makeTexture_TestTrial' 'playTexture_TestTrial'};
Mlist{end+1} = {'MS' 'configPstate_MSeq' 'makeTexture_MSeq' 'playTexture_MSeq'};
Mlist{end+1} = {'RS' 'configPstate_RCTransPlaid' 'makeTexture_RCTransPlaid' 'playTexture_RCTransPlaid' };
Mlist{end+1} = {'FG' 'configPstate_FuncGen' 'makeTexture_FuncGen' 'playTexture_FuncGen'};
Mlist{end+1} = {'PF' 'configPstate_PerGratingFG' 'makeTexture_PerGratingFG' 'playTexture_PerGratingFG' };
Mlist{end+1} = {'OG' 'configPstate_OpticFlowG' 'makeTexture_OpticFlowG' 'playTexture_OpticFlowG' };
Mlist{end+1} = {'ZT' 'configPstate_ZaberTrial' 'makeTexture_ZaberTrial' 'playTexture_ZaberTrial' };
Mlist{end+1} = {'ZR' 'configPstate_ZaberRot' 'makeTexture_ZaberRot' 'playTexture_ZaberRot' };
Mlist{end+1} = {'LV' 'configPstate_LED' 'makeTexture_LED' 'playTexture_LED' };
Mlist{end+1} = {'NB' 'configPstate_NoiseBar' 'makeTexture_NoiseBar' 'playTexture_NoiseBar' };



%playfile for the manual mapper
Mlist{end+1} = {'MG' '' '' 'playTexture_PerGratingManual'};
Mlist{end+1} = {'MM' '' '' 'playTexture_Mapper'};
Mlist{end+1} = {'MR' '' '' 'playTexture_RDKManual'};
Mlist{end+1} = {'MI' '' '' 'playTexture_ImgManual'};
Mlist{end+1} = {'MP' '' '' 'playTexture_PacmanManual'};
Mlist{end+1} = {'MC' '' '' 'playTexture_PiecewiseManual'};


%playfile for blanks
Mlist{end+1} = {'' '' '' 'playTexture_Blank'};




