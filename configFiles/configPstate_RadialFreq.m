function configPstate_RadialFreq

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
Pstate.param{8} = {'x_stimsize'      'float'      3       1                'deg'};
Pstate.param{9} = {'y_stimsize'      'float'      3       1                'deg'};

Pstate.param{10} = {'xN'      'int'      1       1                ''};
Pstate.param{11} = {'yN'      'int'      1       1                ''};

Pstate.param{12} = {'r0'    'float'     0.25       0                'base radius'};
Pstate.param{13} = {'rAmp'         'float'        0.1       0                'modulation amp'};
Pstate.param{14} = {'rFreq'         'float'       8       0                'radial freq'};
Pstate.param{15} = {'rSig'      'float'     2      0                 'std dev'};
Pstate.param{16} = {'phase'   'float'   0       0                ''};

Pstate.param{17} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{18} = {'Reye_bit'    'int'   1       0                ''};
Pstate.param{19} = {'avg_bit'    'int'   0       0                'binary'};



