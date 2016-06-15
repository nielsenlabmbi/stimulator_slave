function configPstate_RCAdaptGrating

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     10       0                'sec'};

Pstate.param{4} = {'x_pos'       'int'      800       0                'pixels'};
Pstate.param{5} = {'y_pos'       'int'      500       0                'pixels'};
Pstate.param{6} = {'x_size'      'float'      10       1                'deg'};
Pstate.param{7} = {'y_size'      'float'      10       1                'deg'};
Pstate.param{8} = {'mask_type'   'string'   'none'       0                ''};
Pstate.param{9} = {'mask_radius' 'float'      6       1                'deg'};

Pstate.param{10} = {'contrast'    'float'     100       0                '%'};

Pstate.param{11} = {'adapt_ori'         'int'        0       0                'deg'};
Pstate.param{12} = {'adapt_sf'         'float'        0.125       0                'deg'};
Pstate.param{13} = {'adapt_interv'         'int'        2       0                ''};

Pstate.param{14} = {'min_ori'         'int'        0       0                'deg'};
Pstate.param{15} = {'orirange'         'int'        360       0                'deg'};
Pstate.param{16} = {'n_ori'    'int'   16       0                ''};

Pstate.param{17} = {'min_sf'   'float'   0.125       0                'c/deg'};
Pstate.param{18} = {'max_sf'   'float'   0.125       0                'c/deg'};
Pstate.param{19} = {'n_sfreq' 'int'   1       0             ''};
Pstate.param{20} = {'sf_domain'   'string'   'log'       0                ''};

Pstate.param{21} = {'n_phase'   'int'   4       0                ''};

Pstate.param{22} = {'h_per'      'int'   40       0                'frames'};
Pstate.param{23} = {'blankProb'    'float'   0.05       0                ''};

Pstate.param{24} = {'s_profile'   'string'   'sin'       0                ''};
Pstate.param{25} = {'s_duty'      'float'   0.5       0                ''};
Pstate.param{26} = {'drift'    'int'   1         0                 'binary'};
Pstate.param{27} = {'t_period'    'int'       20       0                'frames'};

Pstate.param{28} = {'rseed'    'int'   1       0                ''};

Pstate.param{29} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{30} = {'Reye_bit'    'int'   1       0                ''};