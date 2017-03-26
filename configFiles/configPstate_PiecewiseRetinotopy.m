function configPstate_PiecewiseRetinotopy
% Initial Pstate configuration for the piecewise defined V4 stimuli
% Maintained by Ramanujan Srinath
% Accepts:
%   Nothing
% Returns:
%   Nothing

global Pstate

Pstate = struct;

Pstate.param{1}     = {'predelay'    	'float'   1       		0       'sec'};
Pstate.param{end+1} = {'postdelay'   	'float'   1       		0       'sec'};
Pstate.param{end+1} = {'stim_time'   	'float'   1       		0       'sec'};

Pstate.param{end+1} = {'stimIds'     	'string'  '[1 2 3]' 	0       ''};

Pstate.param{end+1} = {'a'       		'int'     2     		0       ''};
Pstate.param{end+1} = {'b'       		'int'     0     		0       ''};
Pstate.param{end+1} = {'n_hStrips'		'int'     5     		0       ''};
Pstate.param{end+1} = {'n_vStrips'   	'int'     8     		0       ''};
Pstate.param{end+1} = {'nsize'        	'int'     2       		1       ''};

Pstate.param{end+1} = {'color_r'     	'float'   1       		0       ''};
Pstate.param{end+1} = {'color_g'     	'float'   1       		0       ''};
Pstate.param{end+1} = {'color_b'     	'float'   1       		0       ''};

Pstate.param{end+1} = {'background'  	'float'   0       		0       ''};