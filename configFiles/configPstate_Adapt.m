function configPstate_Adapt

%periodic grater

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};
Pstate.param{4} = {'adapt_time'  'float'     4       0                'sec'};
Pstate.param{5} = {'cycPerDir'  'int'     1       0                'cycles'};

Pstate.param{6} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{7} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{8} = {'x_size'      'float'      3       1                'deg'};
Pstate.param{9} = {'y_size'      'float'      3       1                'deg'};
Pstate.param{10} = {'mask_type'   'string'   'none'       0                ''};
Pstate.param{11} = {'mask_radius' 'float'      6       1                'deg'};

Pstate.param{12} = {'contrast'    'float'     100       0                '%'};
Pstate.param{13} = {'ori'         'int'        0       0                'deg'};
Pstate.param{14} = {'phase'         'float'        0       0                'deg'};
Pstate.param{15} = {'s_freq'      'float'      1      -1                 'cyc/deg'};
Pstate.param{16} = {'s_profile'   'string'   'sin'       0                ''};
Pstate.param{17} = {'s_duty'      'float'   0.5       0                ''};
Pstate.param{18} = {'t_period'    'int'       20       0                'frames'};

Pstate.param{19} = {'x_pos2'       'int'      600       0                'pixels'};
Pstate.param{20} = {'y_pos2'       'int'      400       0                'pixels'};
Pstate.param{21} = {'x_size2'      'float'      3       1                'deg'};
Pstate.param{22} = {'y_size2'      'float'      3       1                'deg'};
Pstate.param{23} = {'mask_type2'   'string'   'none'       0                ''};
Pstate.param{24} = {'mask_radius2' 'float'      6       1                'deg'};

Pstate.param{25} = {'contrast2'    'float'     100       0                '%'};
Pstate.param{26} = {'ori2'         'int'        90       0                'deg'};
Pstate.param{27} = {'phase2'         'float'        0       0                'deg'};
Pstate.param{28} = {'s_freq2'      'float'      1      -1                 'cyc/deg'};
Pstate.param{29} = {'s_profile2'   'string'   'sin'       0                ''};
Pstate.param{30} = {'s_duty2'      'float'   0.5       0                ''};
Pstate.param{31} = {'t_period2'    'int'       20       0                'frames'};

Pstate.param{32} = {'adapt_only'    'int'       0       0                ''};

Pstate.param{33} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{34} = {'Reye_bit'    'int'   1       0                ''};


