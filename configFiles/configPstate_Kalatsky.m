function configPstate_Kalatsky
%bar stimulus

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};

Pstate.param{4} = {'width'      'float'      3       1                'deg'};

Pstate.param{5} = {'axis'      'int'     0       1                'binary'};
Pstate.param{6} = {'dir'      'int'     0       1                'binary'};
Pstate.param{7} = {'speed'      'float'     0       1                'deg/s'};

Pstate.param{8} = {'background'      'float'   0       0                ''};
Pstate.param{9} = {'redgun' 'float'   1       0             ''};
Pstate.param{10} = {'greengun' 'float'   1       0             ''};
Pstate.param{11} = {'bluegun' 'float'   1       0             ''};

Pstate.param{12} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{13} = {'Reye_bit'    'int'   1       0                ''};



