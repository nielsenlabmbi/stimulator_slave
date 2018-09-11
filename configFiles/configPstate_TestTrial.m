function configPstate_TestTrial
global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};

Pstate.param{4} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{5} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{6} = {'x_size'      'float'      3       1                'deg'};
Pstate.param{7} = {'y_size'      'float'      3       1                'deg'};
Pstate.param{8} = {'Intensity'      'float'      1       0                ''};

Pstate.param{9} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{10} = {'Reye_bit'    'int'   1       0                ''};
Pstate.param{11} = {'mask_radius' 'float'      6       1                'deg'};
Pstate.param{12} = {'mask_type'   'string'   'none'       0                ''};
Pstate.param{13} = {'use_ch3'    'int'   0       0                'binary'};