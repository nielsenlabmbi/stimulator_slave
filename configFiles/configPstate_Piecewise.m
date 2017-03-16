function configPstate_Piecewise
% Initial Pstate configuration for the piecewise defined V4 stimuli
% Maintained by Ramanujan Srinath
% Accepts:
%   Nothing
% Returns:
%   Nothing

global Pstate

Pstate = struct;

Pstate.param{1}     = {'predelay'    'float'   1       0       'sec'};
Pstate.param{end+1} = {'postdelay'   'float'   1       0       'sec'};
Pstate.param{end+1} = {'stim_time'   'float'   1       0       'sec'};

Pstate.param{end+1} = {'stimId'      'int'     1       0       ''};
Pstate.param{end+1} = {'contrast'    'float'   100     0       '%'};
Pstate.param{end+1} = {'ori'         'float'   0       0       'deg'};

Pstate.param{end+1} = {'x_pos'       'int'     960     0       'pixels'};
Pstate.param{end+1} = {'y_pos'       'int'     540     0       'pixels'};
Pstate.param{end+1} = {'size'        'float'   3       1       'deg'};
Pstate.param{end+1} = {'mask_type'   'string'  'none'  0       ''};

Pstate.param{end+1} = {'movement_x'  'int'     0       0       'pixels'};
Pstate.param{end+1} = {'movement_y'  'int'     0       0       'pixels'};

Pstate.param{end+1} = {'color_r'     'float'   0.5     0       ''};
Pstate.param{end+1} = {'color_g'     'float'   0.5     0       ''};
Pstate.param{end+1} = {'color_b'     'float'   0.5     0       ''};

Pstate.param{end+1} = {'background'  'float'   0.5     0       ''};