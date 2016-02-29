function configPstate_RCBars

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};

Pstate.param{4} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{5} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{6} = {'x_size'      'float'      25       1                'deg'};
Pstate.param{7} = {'y_size'      'float'      .5       1                'deg'};

Pstate.param{8} = {'background'      'float'   0.5       0                ''};

Pstate.param{9} = {'min_ori'         'int'        0       0                'deg'};
Pstate.param{10} = {'orirange'         'int'        360       0                'deg'};
Pstate.param{11} = {'n_ori'    'int'   16       0                ''};

Pstate.param{12} = {'h_per'      'int'   8       0                'frames'};

Pstate.param{13} = {'N_bar'    'int'   1       0                ''};
Pstate.param{14} = {'N_x'    'int'   30       0                ''};
Pstate.param{15} = {'N_y'    'int'   1       0                ''};
Pstate.param{16} = {'gridType'    'string'   'polar'       0                ''};

Pstate.param{17} = {'speed'    'float'   0       0                'deg/s'};

Pstate.param{18} = {'barWidth'      'float'   2       1                'deg'};
Pstate.param{19} = {'barLength'      'float'   30       1                'deg'};
Pstate.param{20} = {'bw_bit'    'int'   2       0                ''};

Pstate.param{21} = {'rseed'    'int'   1       0                ''};

Pstate.param{22} = {'eye_bit'    'int'   0       0                ''};
Pstate.param{23} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{24} = {'Reye_bit'    'int'   1       0                ''};