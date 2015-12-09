function configPstate_Bar
%bar stimulus

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};

Pstate.param{4} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{5} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{6} = {'x_size'      'float'      3       1                'deg'};
Pstate.param{7} = {'y_size'      'float'      3       1                'deg'};
Pstate.param{8} = {'max_posdelta'       'float'      10       0         'deg'};

Pstate.param{9} = {'ori'      'int'     0       1                'deg'};
Pstate.param{10} = {'speed'      'float'     0       1                'deg/s'};

Pstate.param{11} = {'background'      'float'   0       0                ''};
Pstate.param{12} = {'redgun' 'float'   1       0             ''};
Pstate.param{13} = {'greengun' 'float'   1       0             ''};
Pstate.param{14} = {'bluegun' 'float'   1       0             ''};

Pstate.param{15} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{16} = {'Reye_bit'    'int'   1       0                ''};



