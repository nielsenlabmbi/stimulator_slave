function configPstate_TransparentPlaid
%periodic grater

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};

Pstate.param{4} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{5} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{6} = {'x_size'      'float'      10       1                'deg'};
Pstate.param{7} = {'y_size'      'float'      10       1                'deg'};
Pstate.param{8} = {'mask_type'   'string'   'disc'       0                ''};
Pstate.param{9} = {'mask_radius' 'float'      6       1                'deg'};

Pstate.param{10} = {'contrast'    'float'     50       0                '%'};
Pstate.param{11} = {'ori'         'int'        0       0                'deg'};
Pstate.param{12} = {'s_freq'      'float'      1      -1                 'cyc/deg'};
Pstate.param{13} = {'s_duty'      'float'   0.7       0                ''};
Pstate.param{14} = {'t_period'    'int'       20       0                'frames'};

Pstate.param{15} = {'contrast2'    'float'     50       0                '%'};
Pstate.param{16} = {'ori2'         'int'        135       0                'deg'};
Pstate.param{17} = {'s_freq2'      'float'      1      -1                 'cyc/deg'};
Pstate.param{18} = {'s_duty2'      'float'   0.7       0                ''};

Pstate.param{19} = {'lum_intersect'      'float'   0       0                ''};
Pstate.param{20} = {'background'      'float'   0.5       0                ''};
Pstate.param{21} = {'plaid_bit'      'int'   1       0                ''};

Pstate.param{22} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{23} = {'Reye_bit'    'int'   1       0                ''};





