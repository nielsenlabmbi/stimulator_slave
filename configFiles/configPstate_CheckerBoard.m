function configPstate_CheckerBoard

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
Pstate.param{8} = {'mask_type'   'string'   'none'       0                ''};
Pstate.param{9} = {'mask_radius' 'float'      6       1                'deg'};

Pstate.param{10} = {'block_size'  'float'     2         0               'deg'};
Pstate.param{11} = {'t_period'    'int'       20       0                'frames'};

Pstate.param{12} = {'max_posdelta'       'float'      10       0         'deg'};
Pstate.param{13} = {'offset'       'float'      0       0         'deg'};
Pstate.param{14} = {'speed'      'float'     0       1                'deg/s'};
Pstate.param{15} = {'ori'      'float'     0       1                'deg'};


Pstate.param{16} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{17} = {'Reye_bit'    'int'   1       0                ''};
Pstate.param{18} = {'use_ch3'    'int'   0       0                'binary'};
Pstate.param{19} = {'avg_bit'    'int'   0       0                'binary'};
Pstate.param{20} = {'background'    'float'   0.5       0                ''};





