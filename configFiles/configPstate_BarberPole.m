function configPstate_BarberPole

%periodic grater

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stat_time'  'float'     0.5       0                'sec'};
Pstate.param{4} = {'mov_time'  'float'     1       0                'sec'};

Pstate.param{5} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{6} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{7} = {'x_size'      'float'      3       1                'deg'};
Pstate.param{8} = {'y_size'      'float'      3       1                'deg'};

Pstate.param{9} = {'contrast'    'float'     100       0                '%'};
Pstate.param{10} = {'ori'         'int'        0       0                'deg'};
Pstate.param{11} = {'phase'         'float'        0       0                'deg'};
Pstate.param{12} = {'s_freq'      'float'      1      -1                 'cyc/deg'};
Pstate.param{13} = {'s_profile'   'string'   'sin'       0                ''};
Pstate.param{14} = {'s_duty'      'float'   0.5       0                ''};
Pstate.param{15} = {'t_period'    'int'       20       0                'frames'};

Pstate.param{16} = {'useFrame'    'int'        0       0             'binary'};
Pstate.param{17} = {'frame_width'    'float'        1       0             'deg'};

Pstate.param{18} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{19} = {'Reye_bit'    'int'   1       0                ''};





