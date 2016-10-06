function configPstate_Pacman
%periodic grater

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};

Pstate.param{4} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{5} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{6} = {'r_size'      'float'      3       1                'deg'};
Pstate.param{7} = {'ori'      'int'     0       1                'deg'};%rotation of angle
Pstate.param{8} = {'acute'      'int'     0       1                'deg'};%size of angle
Pstate.param{9} = {'stim_type'   'int'   1       0                ''};
%options: convex(1),concave(2), line/angleonly (3)
Pstate.param{10} = {'sharp'      'int'     0       1                ''};
Pstate.param{11} = {'lineWidth'    'int'   1       0                'pixels'};

Pstate.param{12} = {'maskRadius'    'int'   1       0                'deg'};
Pstate.param{13} = {'maskType'    'string'   'none'       0                ''};
%none or gauss
Pstate.param{14} = {'redgun' 'float'   1       0             ''};
Pstate.param{15} = {'greengun' 'float'   1       0             ''};
Pstate.param{16} = {'bluegun' 'float'   1       0             ''};

Pstate.param{17} = {'background'      'float'   0.5       0                ''};

Pstate.param{18} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{19} = {'Reye_bit'    'int'   1       0                ''};



