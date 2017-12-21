function configPstate_Img
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
Pstate.param{8} = {'usenativesize'    'int'        0       0             'binary'};
Pstate.param{9} = {'keepaspectratio'    'int'        0       0             'binary'};
Pstate.param{10} = {'croptoscale'    'int'        0       0             'binary'};

Pstate.param{11} = {'imgpath'      'string'     '~/images'       1                ''};
Pstate.param{12} = {'imgbase'      'string'     'imgRetinotopy'       1                ''};
Pstate.param{13} = {'imgnr'      'int'     1       1                ''};
Pstate.param{14} = {'filetype'      'string'     'gif'       1                ''};

Pstate.param{15} = {'color'      'int'     1       1                ''};

Pstate.param{16} = {'scramble'      'int'     0       1                ''};
Pstate.param{17} = {'nrblocks'      'int'     8       1                ''};

Pstate.param{18} = {'background'      'float'   0.5       0                ''};
Pstate.param{19} = {'contrast' 'float'   100       0             '%'};


