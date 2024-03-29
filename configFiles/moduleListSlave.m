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
Mlist{6} = {'RN' 'configPstate_RCNGratings' 'makeTexture_RCNGratings' 'playTexture_RCNGratings' };
Mlist{7} = {'OF' 'configPstate_OpticFlow' 'makeTexture_OpticFlow' 'playTexture_OpticFlow' };
Mlist{8} = {'IM' 'configPstate_Img' 'makeTexture_Img' 'playTexture_Img' };
Mlist{9} = {'GA' 'configPstate_GA' 'makeTexture_GA' 'playTexture_GA' };
Mlist{10} = {'AD' 'configPstate_Adapt' 'makeTexture_Adapt' 'playTexture_Adapt' };
Mlist{11} = {'RA' 'configPstate_RCAdaptGrating' 'makeTexture_RCAdaptGrating' 'playTexture_RCAdaptGrating' };
Mlist{12} = {'PC' 'configPstate_PerGratingColor' 'makeTexture_PerGratingColor' 'playTexture_PerGratingColor' };
Mlist{13} = {'BP' 'configPstate_BarberPole' 'makeTexture_BarberPole' 'playTexture_BarberPole' };
Mlist{14} = {'TP' 'configPstate_TransPlaid' 'makeTexture_TransPlaid' 'playTexture_TransPlaid' };
Mlist{15} = {'BR' 'configPstate_Bar' 'makeTexture_Bar' 'playTexture_Bar' };
Mlist{16} = {'BK' 'configPstate_Kalatsky' 'makeTexture_Kalatsky' 'playTexture_Kalatsky' };
Mlist{17} = {'RB' 'configPstate_RCBars' 'makeTexture_RCBars' 'playTexture_RCBars' };
Mlist{18} = {'FR' 'configPstate_RadialFreq' 'makeTexture_RadialFreq' 'playTexture_RadialFreq' };
Mlist{19} = {'PM' 'configPstate_Pacman' 'makeTexture_Pacman' 'playTexture_Pacman' };
Mlist{20} = {'GL' 'configPstate_Glass' 'makeTexture_Glass' 'playTexture_Glass' };
Mlist{21} = {'CK' 'configPstate_CheckerBoard' 'makeTexture_CheckerBoard' 'playTexture_CheckerBoard' };
Mlist{22} = {'CG' 'configPstate_CounterBar' 'makeTexture_CounterBar' 'playTexture_CounterBar' };
Mlist{23} = {'WG' 'configPstate_WarpedGrating' 'makeTexture_WarpedGrating' 'playTexture_WarpedGrating' };
Mlist{24} = {'WC' 'configPstate_WarpedChecker' 'makeTexture_WarpedChecker' 'playTexture_WarpedChecker' };
Mlist{25} = {'PW' 'configPstate_Piecewise' 'makeTexture_Piecewise' 'playTexture_Piecewise' };
Mlist{26} = {'PR' 'configPstate_PiecewiseRetinotopy' 'makeTexture_PiecewiseRetinotopy' 'playTexture_PiecewiseRetinotopy' };
Mlist{27} = {'RI' 'configPstate_RCImg' 'makeTexture_RCImg' 'playTexture_RCImg' };
Mlist{28} = {'IG' 'configPstate_ImgGrating' 'makeTexture_ImgGrating' 'playTexture_ImgGrating' };
Mlist{29} = {'IT' 'configPstate_ImgTexture' 'makeTexture_ImgTexture' 'playTexture_ImgTexture' };
Mlist{30} = {'OS' 'configPstate_Opto' 'makeTexture_Opto' 'playTexture_Opto' };
Mlist{31} = {'IS' 'configPstate_ImgScanning' 'makeTexture_ImgScanning' 'playTexture_ImgScanning'};
Mlist{32} = {'TT' 'configPstate_TestTrial' 'makeTexture_TestTrial' 'playTexture_TestTrial'};
Mlist{33} = {'MS' 'configPstate_MSeq' 'makeTexture_MSeq' 'playTexture_MSeq'};
Mlist{34} = {'RS' 'configPstate_RCTransPlaid' 'makeTexture_RCTransPlaid' 'playTexture_RCTransPlaid' };
Mlist{35} = {'FG' 'configPstate_FuncGen' 'makeTexture_FuncGen' 'playTexture_FuncGen'};
Mlist{36} = {'PF' 'configPstate_PerGratingFG' 'makeTexture_PerGratingFG' 'playTexture_PerGratingFG' };
Mlist{37} = {'OG' 'configPstate_OpticFlowG' 'makeTexture_OpticFlowG' 'playTexture_OpticFlowG' };
Mlist{38} = {'ZT' 'configPstate_ZaberTrial' 'makeTexture_ZaberTrial' 'playTexture_ZaberTrial' };
Mlist{39} = {'ZR' 'configPstate_ZaberRot' 'makeTexture_ZaberRot' 'playTexture_ZaberRot' };
Mlist{40} = {'LV' 'configPstate_LED' 'makeTexture_LED' 'playTexture_LED' };
Mlist{41} = {'NB' 'configPstate_NoiseBar' 'makeTexture_NoiseBar' 'playTexture_NoiseBar' };



%playfile for the manual mapper
Mlist{end+1} = {'MG' '' '' 'playTexture_PerGratingManual'};
Mlist{end+1} = {'MM' '' '' 'playTexture_Mapper'};
Mlist{end+1} = {'MR' '' '' 'playTexture_RDKManual'};
Mlist{end+1} = {'MI' '' '' 'playTexture_ImgManual'};
Mlist{end+1} = {'MP' '' '' 'playTexture_PacmanManual'};
Mlist{end+1} = {'MC' '' '' 'playTexture_PiecewiseManual'};


%playfile for blanks
Mlist{end+1} = {'' '' '' 'playTexture_Blank'};




