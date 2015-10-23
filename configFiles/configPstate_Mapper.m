function configPstate_Mapper

%this is not really used, is just a basic place holder

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'ori'         'int'        0       0                'deg'};
Pstate.param{2} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{3} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{4} = {'width'      'float'      3       1                'deg'};
Pstate.param{5} = {'length'      'float'      3       1                'deg'};
Pstate.param{6} = {'background'      'float'   0.5       0                ''};
