function configPstate_WarpedChecker

%warped checker board

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};

Pstate.param{4} = {'width'      'float'      20       1                'deg'};

Pstate.param{5} = {'altazimuth'      'string'   'altitude'       0                ''};
Pstate.param{6} = {'tilt_alt'         'int'        0       0                'deg'};
Pstate.param{7} = {'tilt_az'         'int'        0       0                'deg'};
Pstate.param{8} = {'dx_perpbis'         'float'        0       0                'cm'};
Pstate.param{9} = {'dy_perpbis'         'float'        0       0                'cm'};

Pstate.param{10} = {'rotated'   'int'   0       0                ''};

Pstate.param{11} = {'ori'         'int'        0       0                'deg'};
Pstate.param{12} = {'speed'    'float'       10       0                'deg/s'};
Pstate.param{13} = {'phase'    'float'       0       0                'deg'};
Pstate.param{14} = {'noise_lifetime'    'int'       20       0                'frames'};
Pstate.param{15} = {'noise_width'    'float'       10       0                'deg'};

Pstate.param{16} = {'x_zoom'    'int'       1       0                ''};
Pstate.param{17} = {'y_zoom'    'int'       1       0                ''};

Pstate.param{18} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{19} = {'Reye_bit'    'int'   1       0                ''};
Pstate.param{20} = {'use_ch3'    'int'   0       0                'binary'};





