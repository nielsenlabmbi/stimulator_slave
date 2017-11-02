function configPstate_Opto
%bar stimulus

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};

Pstate.param{4} = {'pulse_dur'       'int'      100       0                'ms'};
Pstate.param{5} = {'pulse_fr'       'float'      1       0                'Hz'};
Pstate.param{6} = {'indic_stim'       'int'      1       0                'binary'};
Pstate.param{7} = {'background'      'float'   0       0                ''};




