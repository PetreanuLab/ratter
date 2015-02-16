function SC = state_colors(obj) %#ok<INUSD>

% Colors that the various states take when plotting
% can i label the states differently?
SC = struct( ...
    'delay2start',      [.6 .6 .6],...
    'wait_for_poke1',   [1 .8 .8],              ...
    'poke1sound',    [1 .7 0.4],    ...
    'wait_for_poke2',   [1 .9 .6],   ...
    'poke2sound',    [.7 1 .7], ...
    'wait_for_poke3',   [0.6 0.66 1],    ...
    'wait_for_poke3_aftertemperror',   0.7*[0.6 0.66 1],    ...
	'soft_drink_time',   [0.66 0.98 0.57], ...
    'hit_iti',          [0.35 1 0.3],    ...
    'miss_iti',         [1 0 0.17],    ...
    'violation_iti',    [.5 0.01 0.01],    ...
    'wd_warning',       [0.3  0    0],    ...
    'wd_danger',        [0.5  0.05 0.05] ...
    );


