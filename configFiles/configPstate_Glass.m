function configPstate_Glass
%periodic grater
%edited 9/29/16 Cynthia Steinhardt
global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};

Pstate.param{4} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{5} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{6} = {'x_size'      'float'      25       1                'deg'};
Pstate.param{7} = {'y_size'      'float'      25       1                'deg'};

Pstate.param{8} = {'ori'      'int'     0       1                ''};% angle off original dot
Pstate.param{9} = {'dotCoherence'      'int'     100       1                '%'};%coherence of motion probs as %
Pstate.param{10} = {'deltaDot'      'float'     2.5       1                'deg'}; %shift off from original dot
Pstate.param{11} = {'dotSizes'      'float'     2       1                'deg'};
Pstate.param{12} = {'nrDots'      'int'     20       1                'dots'};%number of dots
Pstate.param{13} = {'dotType'      'int'     0       1                'dots'};%number of dots
%0 is square 1 is circle
%for dot color!
Pstate.param{14} = {'redgun' 'float'   1       0             ''};
Pstate.param{15} = {'greengun' 'float'   1       0             ''};
Pstate.param{16} = {'bluegun' 'float'   1       0             ''};

Pstate.param{17} = {'background'      'float'   0.5       0                ''};

Pstate.param{18} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{19} = {'Reye_bit'    'int'   1       0                ''};

