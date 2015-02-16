% [x, y] = PBupsSection(obj, action, tname, varargin)
%
% This plugin makes a window that manages the making of Poisson bups, which
% are bups that occur as independent Poisson processes on the left and
% right.
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%   'init'     Initializes the plugin. Sets up internal variables
%               and the GUI window.
%
% BWB, Dec. 2008
% significant overhaul, February 2009





function [x, y] = PBupsSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,
    
%% init    
  case 'init'
    if length(varargin) < 2,
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end;
    x = varargin{1}; y = varargin{2};

    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
    
    
    ToggleParam(obj, 'pbup_show', 0, x, y, ...
       'OnString', 'PBup window Showing', ...
       'OffString', 'PBup window Hidden', ...
       'TooltipString', 'Show/Hide PBup window'); next_row(y);
    set_callback(pbup_show, {mfilename, 'show_hide';});  %#ok<NODEF>
    
    screen_size = get(0, 'ScreenSize'); fig = gcf;
    SoloParamHandle(obj, 'pbup_fig', ...
        'value', figure('Position', [200 screen_size(4)-500 600 460], ...
        'closerequestfcn', [mfilename '(' class(obj) ', ''hide''' ');'], 'MenuBar', 'none', ...
        'NumberTitle', 'off', 'Name', 'PBups'), 'saveable', 0);
    origfig_xy = [x y]; 
    
    x = 10; y = 10;
	% TESTING SECTION
    NumeditParam(obj, 'test_gamma', 2, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Pushing the Play button will play a sample sound of this gamma');
	set_callback(test_gamma, {mfilename, 'test_gamma'});
	set_callback_on_load(test_gamma, 1);
	DispParam(obj, 'test_lrate', 0, x, y, 'position', [x+100 y 100 20], ...
		'labelfraction', 0.7, ...
		'TooltipString', 'left rate of test_gamma');
	DispParam(obj, 'test_rrate', 0, x, y, 'position', [x+200 y 100 20], ...
		'labelfraction', 0.7, ...
		'TooltipString', 'right rate of test_gamma');
	NumeditParam(obj, 'sduration', 1, x, y, 'position', [x+300 y 100 20], ...
		'labelfraction', 0.7, ...
		'TooltipString', 'duration of test sound');
    PushbuttonParam(obj, 'test_play', x, y, 'position', [x+400 y 80 20], ...
        'label', 'test Play');
    PushbuttonParam(obj, 'test_stop', x, y, 'position', [x+480 y 80 20], ...
        'label', 'test Stop');
    set_callback(test_play, {mfilename, 'test_play'});
    set_callback(test_stop, {mfilename, 'test_stop'});
	next_row(y);
    SubheaderParam(obj, 'title1', 'Testing Section', x, y);
    next_row(y, 1.5);
	
	% ANTIBIAS SECTION
	LogsliderParam(obj, 'HitFracTau', 30, 10, 400, x, y, 'position', [x y 160 20], ...
		'label', 'hits frac tau', ...
		'TooltipString', 'Number of trials back over which to compute fraction correct (display only)');
	set_callback(HitFracTau, {mfilename, 'update_hitfrac'});
	DispParam(obj, 'RtHitFrac', 0, x, y, 'position', [x y+20 160 20]);
	DispParam(obj, 'LtHitFrac', 0, x, y, 'position', [x y+40 160 20]);
	DispParam(obj, 'HitFrac',   0, x, y, 'position', [x y+60 160 20]);
	offset = 180;
	LogsliderParam(obj, 'BiasTau', 30, 10, 400, x, y, 'position', [x+offset y 400 20], ...
		'label', 'antibias tau', ...
		'TooltipString', 'Number of trials back over which to compute the antibias function');
	DispParam(obj, 'RtHits', 0, x, y, 'position', [x+offset y+20 200 20], ...
		'labelfraction', 0.3);
	DispParam(obj, 'RtPostProb', 0, x, y, 'position', [x+200+offset y+20 200 20], ...
		'labelfraction', 0.3);
	DispParam(obj, 'LtHits', 0, x, y, 'position', [x+offset y+40 200 20], ...
		'labelfraction', 0.3);
	DispParam(obj, 'LtPostProb', 0, x, y, 'position', [x+200+offset y+40 200 20], ...
		'labelfraction', 0.3);
	NumeditParam(obj, 'Beta', 0, x, y, 'position', [x+offset y+60 200 20], ...
		'TooltipString', 'Antibias weight.  0 means past performance has no effect on next trial.  This affects left and right trials independently.');
	set_callback({BiasTau; Beta}, {mfilename, 'update_biashitfrac'});
	SoloParamHandle(obj, 'LocalPrevSides',  'value', []);
	SoloParamHandle(obj, 'LocalPrevSounds', 'value', []);
	next_row(y, 4);
	SubheaderParam(obj, 'title2', 'Antibias Section', x, y);
	next_row(y, 1.5);

	
	% SAMPLE DURATION SECTION
	NumeditParam(obj, 'DurationBeta', 0, x, y, 'position', [x y 200 20], ...
		'TooltipString', 'Duration-based L/R antibias weight');
	LogsliderParam(obj, 'DurationTau', 100, 50, 400, x, y, 'position', [x+offset y 250 20], ...
		'label', 'duration antibias tau');
	next_row(y);
	DispParam(obj, 'DurationBias', 1, x, y, 'position', [x y 420 20], ...
		'label', 'bias per duration', ...
		'labelfraction', 0.3, ...
		'TooltipString', sprintf(['as a function of sample durations (T), the left/right bias.' ...
		                          '\nin other words, this is the ratio lt_hitfrac/rt_hitfrac ' ...
								  '\nconditioned on each of the 10 possible T"s. ']));
    next_row(y);
	NumeditParam(obj, 'T_probe', x, y, 0.5, 'position', [x y 150 20], ...
		'TooltipString', 'in addition to the T''s specified by T_min and T_max, T can be this value with probability p_probe');
	NumeditParam(obj, 'p_probe', x, y, 0, 'position', [x+150 y 150 20], ...
		'TooltipString', 'probability T will be T_probe');
	next_row(y);
	DispParam(obj, 'T', 0.5, x, y, 'position', [x y 100 20], ...
		'labelfraction', 0.3, ...
		'TooltipString', sprintf(['sample duration, is T_probe with probability p_probe, otherwise drawn between T_min and T_max uniformly'...
                           '\n Note that T controls the maximum sound duration in the RT version of the task!']));
	NumeditParam(obj, 'T_min', 0.2, x, y, 'position', [x+100 y 80 20], ...
		'TooltipString', 'the minimum sample duration');
	NumeditParam(obj, 'T_max', 0.2, x, y, 'position', [x+180 y 80 20], ...
		'TooltipString', 'the maximum sample duration');
	PushbuttonParam(obj, 'T_resample', x, y, 'position', [x+260 y 100 20], ...
		'label', 'Resample', ...
		'TooltipString', 'resample T, the sample duration');
	set_callback({T_min; T_max; T_resample; T_probe; p_probe}, {mfilename, 'T_resample'}); %#ok<NODEF>
	next_row(y);

	SubheaderParam(obj, 'title3', 'Sample Duration Section', x, y);
	next_row(y, 1.5);
	
	% PBUPS SPECIFICATION
    NumeditParam(obj, 'R_gammas', 2, x, y, 'position', [x+50 y 200 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'gammas for sounds whose rates in the right ear are larger; these must all be > 0');
	NumeditParam(obj, 'R_pprobs', 0.5, x, y, 'position', [x+250 y 200 20], ...
		'labelfraction', 0.3, ...
		'TooltipString', 'prior probability for R sounds');
    next_row(y);
    NumeditParam(obj, 'L_gammas', -2, x, y, 'position', [x+50 y 200 20], ...
        'labelfraction', 0.3, ...
        'TooltipString', 'gammas for sounds whose rates in the left ear are larger; these must all be < 0');
	NumeditParam(obj, 'L_pprobs', 0.5, x, y, 'position', [x+250 y 200 20], ...
		'labelfraction', 0.3, ...
		'TooltipString', 'prior probability for R sounds');
	PushbuttonParam(obj, 'normalize_pprobs', x, y, 'position', [x+475 y 60 20], ...
		'label', 'normalize', ...
		'TooltipString', 'Normalize pprobs');
	set_callback(normalize_pprobs, {mfilename, 'normalize_pprobs'});
	next_row(y);
	ToggleParam(obj, 'gamma_style', 0, x, y, 'position', [x y 200 20], ...
		'OffString', 'Specify Gammas by Range', ...
		'OnString',  'Use Gammas Below', ...
		'TooltipString', 'write something here');
	set_callback(gamma_style, {mfilename, 'gamma_style'});
	set_callback_on_load(gamma_style, 1);
	NumeditParam(obj, 'easiest', 2.5, x, y, 'position', [x+200 y 150 20], ...
		'labelfraction', 0.4, ...
		'TooltipString', 'the easiest (endpoints) gamma; this value must be positive');
	NumeditParam(obj, 'hardest', 0.5, x, y, 'position', [x+350 y 150 20], ...
		'labelfraction', 0.4, ...
		'TooltipString', 'the hardest (closest to 0 midpoint) gamma; this value must be positive');
	NumeditParam(obj, 'N', 3, x, y, 'position', [x+500 y 60 20], ...
		'labelfraction', 0.4, ...
		'TooltipString', sprintf(['the number of gamma points between easiest and hardest;' ...
		                          '\nnote that there will actually be 2N trial types (l/r)' ...
								  '\nif N == 1, then the range will consist only of the easiest endpoint gammas']));
                              
    next_row(y);
    set_callback({R_gammas, L_gammas, easiest, hardest, N}, {mfilename, 'gammas'}); %#ok<NODEF>
 
    NumeditParam(obj, 'bup_width', 3, x, y, 'position', [x y 180 20], ...
        'label', 'bup_width (ms)', 'TooltipString', 'the bup width in units of msec');
    NumeditParam(obj, 'bup_ramp', 2, x, y, 'position', [x+180 y 180 20], ...
        'label', 'bup_ramp (ms)', 'TooltipString', 'the duration in units of msec of the upwards and downwards volume ramps for individual bups');
    NumeditParam(obj, 'base_freq', 2000, x, y, 'position', [x+360 y 140 20], ...
        'TooltipString', 'the base frequency of individual bup; the bup consists of this frequency together with ntones-1 higher octaves');
    NumeditParam(obj, 'ntones', 5, x, y, 'position', [x+500 y 100 20], ...
        'TooltipString', 'total number of tones used to generate individual bup; so ntones-1 higher octaves are combined with base_freq');
    next_row(y);
    
	NumeditParam(obj, 'total_rate', 40, x, y, 'position', [x y 190 20], ...
        'TooltipString', 'the sum of left and right bup rates');
	ToggleParam(obj, 'first_bup_stereo', 1, x, y, 'position', [x+200 y 150 20], ...
		'OffString', 'no stereo bup', ...
		'OnString',  'first bup stereo', ...
		'TooltipString', 'If on, an extra stereo bup is added in front of the first bup');
	NumeditParam(obj, 'crosstalk', 0, x, y, 'position', [x+350 y 150 20], ...
		'TooltipString', 'if >0, then is the amount the left clicks leak into the right channel, and vice versa.');    
    NumeditParam(obj, 'vol', 0.5, x, y, 'position', [x+500 y 70 20], ...
        'labelfraction', 0.35, ...
        'TooltipString', 'volume multiplier for all sounds');
    next_row(y);
    SubheaderParam(obj, 'title4', 'Stimulus Properties Section', x, y);
	next_row(y, 1.5);

    
    DispParam(obj, 'ThisGamma', 0, x, y, 'position', [x y 120 20], ...
        'labelfraction', 0.6, ...
        'TooltipString', 'the gamma of the present trial; if r_R and r_L are the rates of Poisson events on the right and left, then gamma = log(r_R/r_L)');
    DispParam(obj, 'ThisLeftRate', 10, x, y, 'position', [x+120 y 130 20], ...
        'labelfraction', 0.6, ...
        'TooltipString', 'the average rate of Poisson events on the left for this trial');
    DispParam(obj, 'ThisRightRate', 10, x, y, 'position', [x+240 y 130 20], ...
        'labelfraction', 0.6, ...
        'TooltipString', 'the average rate of Poisson events on the right for this trial');
    
	next_row(y, 1);
	HeaderParam(obj, 'panel_title', 'PBups plugin, v.2', x, y, 'position', [x y 600 20]);
	
    % this soloparamhandle stores the actual bup times (in seconds) on the left and right
    % for the present trial, as well as the side response of an ideal
    % observer that counts the number of bups on either side.
    % ThisBupTimes.observer is -1 for left, 1 for right, and 0 if the
    % numbers of bups on either side are equal.
    % ThisBupTimes.left and ThisBupTimes.right are updated as the next
    % sound is prepared and pushed to history to be saved with the data
    SoloParamHandle(obj, 'ThisBupTimes', 'value', {});
	
	% stores the set of gamma values used to make pbups from
	% trial to trial.  
	% these values may be specified either by range or by enumeration
	SoloParamHandle(obj, 'left_gammas', 'value', -2);
	SoloParamHandle(obj, 'right_gammas', 'value', 2);
    
	feval(mfilename, obj, 'gamma_style');
    feval(mfilename, obj, 'show_hide');                     
                         
    figure(fig);
    x = origfig_xy(1); y = origfig_xy(2);

   

%% get_bup_times  
  case 'get_bup_times',
    x = value(ThisBupTimes); %#ok<NODEF>
    return;
    
    
%% get_all_bup_times
  case 'get_all_bup_times'
    x = get_history(ThisBupTimes); %#ok<NODEF>
    return;
      
    
%% get
  case 'get'
     switch varargin{1},
         case 'nstimuli',
             x = length(left_gammas)+length(right_gammas); %#ok<NODEF>
         case 'nleft',
             x = length(left_gammas); %#ok<NODEF>
         case 'nright',
             x = length(right_gammas); %#ok<NODEF>
		 case 'all_sides',
			 x = [char('l'*ones(1,length(left_gammas))) char('r'*ones(1,length(right_gammas)))]; %#ok<NODEF>
		 case 'sample_duration', 
			 x = value(T);
		 case 'pprobs',
			 x = [value(L_pprobs) value(R_pprobs)];
     end;
     
%% next_trial
  case 'next_trial'  
      % takes an additional argument that specifies the next side choice
	  % and vectors previous_sides and previous_sounds
      % returns the id of the next sound picked
	  % and the sample duration 
	  
	  side = varargin{1};
	  
	  if isempty(side), % if we are not given which side the next trial is,
		  if rand(1) < sum(LtPostProb(:)), side = 'l';
		  else                             side = 'r';
		  end;
	  end;
	  
	  LocalPrevSides.value  = varargin{2};
	  LocalPrevSounds.value = varargin{3};
	  
	  feval(mfilename, obj, 'normalize_pprobs');
	  feval(mfilename, obj, 'T_resample');
	  feval(mfilename, obj, 'update_hitfrac');
	  feval(mfilename, obj, 'update_biashitfrac');
	  
	  if side == 'l',
		  x = find(cumsum(LtPostProb(:)) > rand(1)/2, 1, 'first');
		  if isempty(x), x = 1; end; % a catch so things don't break
		  ThisGamma.value = left_gammas(x);
		  x = -x;
	  elseif side == 'r',
		  x = find(cumsum(RtPostProb(:)) > rand(1)/2, 1, 'first');
		  if isempty(x), x = 1; end; % a catch so things don't break
		  ThisGamma.value = right_gammas(x);
	  end;
	  
	  y = value(T);

      feval(mfilename, obj, 'make_this_sound');
	  feval(mfilename, obj, 'push_history');
      
%% push_history
  case 'push_history'
	  push_history(ThisBupTimes);

%% count_this_bups
  case 'count_last_trial_bups'
	  sample_duration = varargin{1};
	  
	  x = time;
	  y = observer;

%% make_sounds
  case 'make_this_sound',
	srate = SoundManagerSection(obj, 'get_sample_rate');
	% the sound made is at least 1 sec long, or as long as T
	[snd lrate rrate data] = make_pbup(value(total_rate), value(ThisGamma), srate, max(1,value(T)), ...
									   'bup_width', value(bup_width), 'first_bup_stereo', value(first_bup_stereo), ...
									   'crosstalk', value(crosstalk), 'base_freq', value(base_freq), ...
                                       'ntones', value(ntones), 'bup_ramp', value(bup_ramp)); %#ok<NODEF>
	snd = snd*vol;

	if ~SoundManagerSection(obj, 'sound_exists', 'PBupsSound'),
		SoundManagerSection(obj, 'declare_new_sound', 'PBupsSound');
		SoundManagerSection(obj, 'set_sound', 'PBupsSound', snd);
	else
		snd_prev = SoundManagerSection(obj, 'get_sound', 'PBupsSound');
		if ~isequal(snd, snd_prev),
			SoundManagerSection(obj, 'set_sound', 'PBupsSound', snd);
		end;
	end;

	ThisLeftRate.value = lrate;
	ThisRightRate.value = rrate;

	bpt.gamma = value(ThisGamma);
	bpt.left = data.left;
	bpt.right = data.right;
	ThisBupTimes.value = bpt;

%% update_hitfrac
  case 'update_hitfrac',
	PrevSides = colvec(value(LocalPrevSides));

	if ~isempty(hit_history),
		kernel = exp(-(0:length(hit_history)-1)/HitFracTau)';
        kernel = kernel(end:-1:1);
		HitFrac.value = sum(hit_history .* kernel)/sum(kernel);
		
		if ~isempty(PrevSides),
			PrevSides = PrevSides(1:length(hit_history));
		end;
		
		u = find(PrevSides == 'l');
		if isempty(u), LtHitFrac.value = NaN;
		else           LtHitFrac.value = sum(hit_history(u) .* kernel(u))/sum(kernel(u));
		end;
		
		u = find(PrevSides == 'r');
		if isempty(u), RtHitFrac.value = NaN;
		else           RtHitFrac.value = sum(hit_history(u) .* kernel(u))/sum(kernel(u));
		end;
	else
		HitFrac.value   = NaN;
		LtHitFrac.value = NaN;
		RtHitFrac.value = NaN;
	end;
	  
%% update_biashitfrac
  case 'update_biashitfrac', 	  
      PrevSides = colvec(value(LocalPrevSides));  
	  PrevSounds  = colvec(value(LocalPrevSounds));
	  
	  if ~isempty(hit_history),
		  if ~isempty(PrevSounds),
			  PrevSides  = PrevSides(1:length(hit_history));
			  PrevSounds = PrevSounds(1:length(hit_history));
		  end;
		  
		  u = find(PrevSides == 'l');
		  if isempty(u), 
			  LtHits.value     = ones(size(L_pprobs));
			  LtPostProb.value = value(L_pprobs);
		  else
			  biashitfrac_value = exponential_hitfrac(PrevSounds(u), hit_history(u), value(BiasTau), -(1:length(L_pprobs(:))));
			  LtHits.value     = biashitfrac_value;
			  LtPostProb.value = probabilistic_trial_selector(biashitfrac_value, value(L_pprobs), value(Beta))*sum(L_pprobs(:));
			  if isnan(value(LtPostProb)), LtPostProb.value = value(L_pprobs); end;
		  end;

		  u = find(PrevSides == 'r');
		  if isempty(u), 
			  RtHits.value     = ones(size(R_pprobs));
			  RtPostProb.value = value(R_pprobs);
		  else
			  biashitfrac_value = exponential_hitfrac(PrevSounds(u), hit_history(u), value(BiasTau), 1:length(R_pprobs(:)));
			  RtHits.value     = biashitfrac_value;
			  RtPostProb.value = probabilistic_trial_selector(biashitfrac_value, value(R_pprobs), value(Beta))*sum(R_pprobs(:));
			  if isnan(value(RtPostProb)), RtPostProb.value = value(R_pprobs); end;
		  end;	
	  else
		  LtHits.value = NaN;
		  RtHits.value = NaN;
		  LtPostProb.value = value(L_pprobs);
		  RtPostProb.value = value(R_pprobs);
	  end;
	  
        
%% test_gamma
  case 'test_gamma'
	srate = SoundManagerSection(obj, 'get_sample_rate');
    [snd lrate rrate] = make_pbup(value(total_rate), value(test_gamma), srate, value(sduration), ...
                     'bup_width', value(bup_width), 'first_bup_stereo', value(first_bup_stereo), ...
                     'crosstalk', value(crosstalk), 'base_freq', value(base_freq), ...
                     'ntones', value(ntones), 'bup_ramp', value(bup_ramp), 'generate_sound', 0);
		
	test_lrate.value = lrate;
	test_rrate.value = rrate;
	
%% test_play
  case 'test_play',
    srate = SoundManagerSection(obj, 'get_sample_rate');
    [snd] = make_pbup(value(total_rate), value(test_gamma), srate, value(sduration), ...
                     'bup_width', value(bup_width), 'first_bup_stereo', value(first_bup_stereo), ...
                     'crosstalk', value(crosstalk), 'base_freq', value(base_freq), ...
                     'ntones', value(ntones), 'bup_ramp', value(bup_ramp)); 
    snd = snd*vol;

    if ~SoundManagerSection(obj, 'sound_exists', 'TestSound'),
      SoundManagerSection(obj, 'declare_new_sound', 'TestSound');
    end;

    SoundManagerSection(obj, 'set_sound', 'TestSound', snd);
    
    SoundManagerSection(obj, 'play_sound', 'TestSound');
      
      
%% stop_sound      
  case 'test_stop',
      
    SoundManagerSection(obj, 'stop_sound', 'TestSound');
    
%% T_resample
  case 'T_resample'
	if p_probe > 1, p_probe.value = 1; end;
	if p_probe < 0, p_probe.value = 0; end;
	if T_probe < 0, T_probe.value = 0; p_probe.value = 0; end;
	if T_max < T_min, T_max.value = T_min(1); end;
	
	if rand(1) < p_probe,
		T.value = value(T_probe);
	else
		T.value = value(T_min)+rand(1)*(T_max-T_min);
	end;
	
%% normalize_pprobs
  case 'normalize_pprobs',
	nlefts = length(L_pprobs(:));
	p = [L_pprobs(:); R_pprobs(:)];
	p = p/sum(p);
	L_pprobs.value = p(1:nlefts);
	R_pprobs.value = p(nlefts+1:end);
    
%% gammas
  case 'gammas'
    L_gammas.value = -abs(value(L_gammas)); %#ok<NODEF>
    R_gammas.value = abs(value(R_gammas)); %#ok<NODEF>
	easiest.value = abs(value(easiest)); %#ok<NODEF>
	hardest.value = abs(value(hardest)); %#ok<NODEF>
	if N < 1, N.value = 1; end; %#ok<NODEF>
	feval(mfilename, obj, 'gamma_style');
	
%% gamma_style
  case 'gamma_style'
	if gamma_style == 0, % if we're going by the range
		enable(easiest);
		enable(hardest);
		enable(N);
		disable(L_gammas);
		disable(R_gammas);
		if N == 1,
			g = easiest(1);
		else
			g = linspace(easiest(1), hardest(1), N(1));
		end;
		left_gammas.value  = -g;  % internal soloparam
		right_gammas.value = g;   % internal soloparam
		L_gammas.value = value(left_gammas);  % for display 
		R_gammas.value = value(right_gammas); % for display
		if length(L_pprobs) ~= length(L_gammas),	L_pprobs.value = ones(1, N(1)); end;
		if length(R_pprobs) ~= length(R_gammas),    R_pprobs.value = ones(1, N(1)); end;
		feval(mfilename, obj, 'normalize_pprobs');
	else                 % if we're going by L_gammas and R_gammas
		disable(easiest);
		disable(hardest);
		disable(N);
		enable(L_gammas);
		enable(R_gammas);
		left_gammas.value  = L_gammas(:);
		right_gammas.value = R_gammas(:);
		if length(L_pprobs) ~= length(L_gammas),	L_pprobs.value = ones(1, length(L_gammas)); end;
		if length(R_pprobs) ~= length(R_gammas),    R_pprobs.value = ones(1, length(R_gammas)); end;
		feval(mfilename, obj, 'normalize_pprobs');
	end;

%% hide, show_hide
  case 'hide',
    pbup_show.value = 0;
    feval(mfilename, obj, 'show_hide');
    
  case 'show_hide',
    if value(pbup_show) == 1, set(value(pbup_fig), 'Visible', 'on');  %#ok<NODEF>
    else                      set(value(pbup_fig), 'Visible', 'off');
    end;
    
%% close
  case 'close'   
    try %#ok<TRYNC>
        if ishandle(value(pbup_fig)), delete(value(pbup_fig)); end;
        delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', [mfilename '_' tname]);
    end;
    
%% reinit
  case 'reinit'
    % Get the original GUI position and figure:
    my_gui_info = value(my_gui_info);
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
    
    % close everything involved with the plugin
    feval(mfilename, obj, 'close');

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init', x, y);
        
%% otherwise    
  otherwise
    warning('%s : action "%s" is unknown!', mfilename, action); %#ok<WNTAG> (This line OK.)

end; %     end of switch action

function [x] = colvec(x)
    if size(x,2) > size(x,1), x = x'; end;
    return;