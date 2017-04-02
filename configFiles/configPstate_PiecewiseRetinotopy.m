function configPstate_PiecewiseRetinotopy
% Initial Pstate configuration for the piecewise defined V4 stimuli
% Maintained by Ramanujan Srinath
% Accepts:
%   Nothing
% Returns:
%   Nothing

global Pstate

Pstate = struct;

Pstate.param{1}     = {'predelay'       'float'   1             	0       'sec'};
Pstate.param{end+1} = {'postdelay'      'float'   1             	0       'sec'};
Pstate.param{end+1} = {'stim_time'      'float'   4             	0       'sec'};

Pstate.param{end+1} = {'stimIds'        'string'  '[9 10 11 12]'	0       ''};
Pstate.param{end+1} = {'nsize'          'int'     4              	0       ''};

Pstate.param{end+1} = {'x_pos'          'int'     960           	0       'pixels'};
Pstate.param{end+1} = {'y_pos'          'int'     324           	0       'pixels'};
Pstate.param{end+1} = {'x_size'         'float'   46		   	1       'deg'};
Pstate.param{end+1} = {'y_size'         'float'   6		   	1       'deg'};

Pstate.param{end+1} = {'color_r'        'float'   1             	0       ''};
Pstate.param{end+1} = {'color_g'        'float'   1             	0       ''};
Pstate.param{end+1} = {'color_b'        'float'   1             	0       ''};

Pstate.param{end+1} = {'background'     'float'   0             	0       ''};
