function configPstate_RDK
%periodic grater

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};

Pstate.param{4} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{5} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{6} = {'x_size'      'float'      3       1                'deg'};
Pstate.param{7} = {'y_size'      'float'      3       1                'deg'};
Pstate.param{8} = {'mask_radius' 'float'      6       1                'deg'};
Pstate.param{9} = {'mask_type' 'string'      'disc'       1                ''};

Pstate.param{10} = {'background'      'float'   0.5       0                ''};

Pstate.param{11} = {'sizeDots'      'float'     0.2       1                'deg'};
Pstate.param{12} = {'dotType'      'int'     0       1                ''};

Pstate.param{13} = {'ori'      'int'     0       1                'deg'};
Pstate.param{14} = {'dotDensity'      'float'      100       1                'dots/(deg^2)'};
Pstate.param{15} = {'speedDots'      'float'     5       1                'deg/s'};
Pstate.param{16} = {'dotLifetime'      'int'     0       1                'frames'};
Pstate.param{17} = {'dotCoherence'      'int'     100       1                '%'};
Pstate.param{18} = {'noNetNoise'      'int'     0      1            ''};


Pstate.param{19} = {'motionopp_bit'    'int'     0       0                'binary'};
Pstate.param{20} = {'surround_bit'    'int'     0       0                'binary'};

Pstate.param{21} = {'x_size2'      'float'      3       1                'deg'};
Pstate.param{22} = {'y_size2'      'float'      3       1                'deg'};
Pstate.param{23} = {'mask_radius2' 'float'      6       1                'deg'};
Pstate.param{24} = {'mask_type2' 'string'      'disc'       1                ''};
Pstate.param{25} = {'ori2'      'int'     0       1                'deg'};
Pstate.param{26} = {'dotDensity2'      'float'      100       1                'dots/(deg^2 s)'};
Pstate.param{27} = {'speedDots2'      'float'     5       1                'deg/s'};
Pstate.param{28} = {'dotLifetime2'      'int'     0       1                'frames'};
Pstate.param{29} = {'dotCoherence2'      'int'     100       1                '%'};


Pstate.param{30} = {'redgun' 'float'   1       0             ''};
Pstate.param{31} = {'greengun' 'float'   1       0             ''};
Pstate.param{32} = {'bluegun' 'float'   1       0             ''};

Pstate.param{33} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{34} = {'Reye_bit'    'int'   1       0                ''};



