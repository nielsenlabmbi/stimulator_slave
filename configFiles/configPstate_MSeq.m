function configPstate_MSeq
%m sequence noise stimulus

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     300       0                'sec'};


Pstate.param{4} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{5} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{6} = {'size'      'float'      3       1                'deg'};

Pstate.param{7} = {'seqfile'      'string'     '~/'       1                ''};

Pstate.param{8} = {'h_per'      'int'   2      0                'frames'};
Pstate.param{9} = {'startOffset'    'int'   0       0                'sequence start'};

Pstate.param{10} = {'background'      'float'   0.5       0                ''};



