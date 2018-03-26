function configPstate_ImgScanning

    global Pstate

    Pstate = struct;

    Pstate.param{1} 	= {'predelay'       'float'         0.5         0       'sec'};
    Pstate.param{end+1} = {'postdelay'      'float'         0.5         0       'sec'};
    Pstate.param{end+1} = {'stim_time'      'float'         2           0       'sec'};

    Pstate.param{end+1} = {'x_pos'          'int'           960         0       'pixels'};
    Pstate.param{end+1} = {'y_pos'          'int'           540         0       'pixels'};

    Pstate.param{end+1} = {'rf_box_size'    'float'         16          1       'deg'};
    Pstate.param{end+1} = {'rf_protrude'    'float'         1           1       'deg'};
    Pstate.param{end+1} = {'tube_diam'      'float'         2           1       'deg'};
    Pstate.param{end+1} = {'tube_sep'       'float'         4           1       'deg'};
    Pstate.param{end+1} = {'arc_rad'        'float'         4           1       'deg'};

    Pstate.param{end+1} = {'threeD'         'int'           1           1       'binary'};

    Pstate.param{end+1} = {'tilt_angle'     'float'         0           1       'deg'};
    Pstate.param{end+1} = {'ori_inplane'    'float'         0           1       'deg'};
    Pstate.param{end+1} = {'repeats'        'int'           12          1       ''};
    Pstate.param{end+1} = {'nShifts'        'int'           11          0       ''};

    Pstate.param{end+1} = {'zuckerise'      'int'           0           0       'binary'};

    Pstate.param{end+1} = {'imgpath'        'string'        '~/images'  1       ''};
    Pstate.param{end+1} = {'imgbase'        'string'        'scanningL' 1       ''};
    Pstate.param{end+1} = {'shiftID'        'int'           1           1       ''};

    Pstate.param{end+1} = {'background'     'float'         0.3         0       ''};
    Pstate.param{end+1} = {'contrast'       'float'         100         0       '%'};