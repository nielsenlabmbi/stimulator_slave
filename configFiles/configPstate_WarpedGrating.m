function configPstate_WarpedGrating

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

Pstate.param{8} = {'altazimuth'      'string'   'altitude'       0                ''};
Pstate.param{9} = {'tilt_alt'         'int'        0       0                'deg'};
Pstate.param{10} = {'tilt_az'         'int'        0       0                'deg'};
Pstate.param{11} = {'dx_perpbis'         'float'        0       0                'cm'};
Pstate.param{12} = {'dy_perpbis'         'float'        0       0                'cm'};

Pstate.param{13} = {'mask_type'   'string'   'none'       0                ''};
Pstate.param{14} = {'mask_radius' 'float'      6       1                'deg'};

Pstate.param{15} = {'contrast'    'float'     100       0                '%'};
Pstate.param{16} = {'ori'         'float'        0       0                'deg'};
Pstate.param{17} = {'s_freq'      'float'      1      0                 'cyc/deg'};
Pstate.param{18} = {'s_profile'   'string'   'sin'       0                ''};
Pstate.param{19} = {'s_duty'      'float'   0.5       0                ''};
Pstate.param{20} = {'t_period'    'int'       20       0                'frames'};
Pstate.param{21} = {'phase'    'float'       0       0                'deg'};


Pstate.param{22} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{23} = {'Reye_bit'    'int'   1       0                ''};
Pstate.param{24} = {'use_ch3'    'int'   0       0                'binary'};
Pstate.param{25} = {'background'    'float'   0.5       0                ''};





