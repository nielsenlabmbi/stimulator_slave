function configPstate_RCImg
%periodic grater

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};

Pstate.param{3} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{4} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{5} = {'x_size'      'float'      3       1                'deg'};

Pstate.param{6} = {'stimfile'      'string'     '~/manualImg'       1                ''};

Pstate.param{7} = {'h_per'      'int'   60       0                'frames'};
Pstate.param{8} = {'nReps'    'int'   2       0                'rep per img'};
Pstate.param{9} = {'nBlanks'    'int'   7       0                'blanks total'};

Pstate.param{10} = {'background'      'float'   0.3       0                ''};



