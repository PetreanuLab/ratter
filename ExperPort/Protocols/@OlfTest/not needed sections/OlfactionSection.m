% Typical section code-- this file may be used as a template to be added
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles
% belonging to this section, then calls 'init' at the proper GUI position
% again.


% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI.
%
%


function [x, y] = OlfactionSection(obj, action, x, y)

% obj = class(struct, mfilename, soundmanager);

GetSoloFunctionArgs;


switch action

    case 'init',
        SoloParamHandle(obj, 'myfig', 'value', 0);
        myfig.value = figure;
        name = 'Olfaction'; 
        set(value(myfig), 'Name', name, 'Tag', name, ...
              'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        set(value(myfig), 'Position', [900   400   832   315]);
        x = 5; y = 5; maxy = 5;     % Initial position on main GUI window

%         PushbuttonParam(obj, 'SetWaitingTimeVector', x, y, 'label','Set waiting time vector', ...
%         'position', [x y 200 25], 'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1);
%         set_callback(SetWaitingTimeVector, {'OlfactionSection', 'setWaitingTimeVector'}); %next_row(y,1);
%         NumeditParam(obj, 'minWaitingTimeOlf', 0.2, x, y, 'label','Minimum waiting time',...
%               'labelfraction', 0.53); next_row(y,1);
% %         set_callback(minWaitingTime, {'OlfactionSection', 'set'});
%         NumeditParam(obj, 'maxWaitingTimeOlf', 0.5, x, y, 'label','Maximum waiting time',...
%               'labelfraction', 0.53); next_row(y,1);  
% %         set_callback(maxWaitingTime, {'OlfactionSection', 'set'});
%         
%         DispParam(obj, 'waitingTimeOlf', 0, x, y, 'labelfraction', 0.53, 'label','Waiting time');
%         next_row(y,1.5);

%         SoloParamHandle(obj, 'valveNumber', 'value', 0);
        DispParam(obj, 'odorPresent', 'No', x, y, 'label', ' Odor Present'); next_row(y,1.5);
%         
        SoloParamHandle(obj, 'valveNumber', 'value', 0);
        SoloParamHandle(obj, 'baseValveNumber', 'value', 0);

%         SubHeaderParam(obj, 'GeneralParams', 'General Parameters', x, y);
%         next_row(y,2);
        
%         SoloParamHandle(obj, 'waitingTimeOlfVector');
%         waitingTimeOlfVector.value = zeros(1,1000);
        
%         waitingTimeOlf.value = value(waitingTimeOlfVector(1, n_started_trials + 1));

    
%         SoloFunctionAddVars('StateMatrixSection', 'ro_args', {'waitingTimeOlf'});
        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'valveNumber', 'odorPresent', 'baseValveNumber'});
        SoloFunctionAddVars('YesOrNoSection', 'rw_args', {'valveNumber', 'odorPresent'});
        SoloFunctionAddVars('RandomSection', 'rw_args', {'valveNumber', 'odorPresent'});
        
    % -----------------------  WaitingTimeOlfSection -----------------------
    
         [x, y] = WaitingTimeOlfSection(obj, 'init', x, y); next_row(y,2);
         
         
    % -----------------------  GoSignalSection -----------------------------
  
        [x, y] = GoSignalSection(obj, 'init', x, y); next_row(y,2);
        
        
    % -----------------------  OdorSection ---------------------------------
  
        [x, y] = OdorSection(obj, 'init', x, y); next_row(y,2);
        
        
    % -----------------------  OdorProtocolSection -----------------------
  
        [x, y] = OdorProtocolSection(obj, 'init', x, y); next_row(y,2);
        
        
    % -----------------------  ChoiceSection -----------------------
        
        [x, y] = ChoiceSection_Olf(obj, 'init', x, y); %next_row(y,2);
        
        
        maxy = max(y, maxy); next_column(x); y = 5;
    
    % Make the main figure window as wide as it needs to be and as tall as
    % it needs to be; that way, no matter what each plugin requires in terms of
    % space, we always have enough space for it.
    maxy = max(y, maxy);
    pos = get(value(myfig), 'Position');
    set(value(myfig), 'Position', [pos(1:2) x+220 maxy+25]);
        
    
     % -----------------------  OlfactometerSection -----------------------
 
        [x, y] = OlfactometerSection(obj, 'init', x, y); next_row(y,2);
        
%      % -----------------------  SoundsSection -----------------------
%  
%         [x, y] = SoundsSection(obj, 'init', x, y); next_row(y,2);
            
        
%     case 'set',
%         minWaitingTime.value = value(minWaitingTime);
%         maxWaitingTime.value = value(maxWaitingTime);
    
%     case 'setWaitingTimeVector'
%         waitingTimeOlfVector.value = value(minWaitingTimeOlf) + (value(maxWaitingTimeOlf) - ...
%             value(minWaitingTimeOlf)) * rand(1,1000);
%         
%         waitingTimeOlf.value = value(waitingTimeOlfVector(1, n_started_trials + 1));
        

    case 'next_trial',
%         waitingTimeOlf.value = value(waitingTimeOlfVector(1, n_started_trials + 1));
%         waitingTimeOlf.value = value(minWaitingTimeOlf) + (value(maxWaitingTimeOlf) - ...
%             value(minWaitingTimeOlf)) * rand;
        WaitingTimeOlfSection(obj, 'next_trial');
        GoSignalSection(obj, 'next_trial');
        OdorSection(obj, 'next_trial');
        OlfactometerSection(obj, 'next_trial');
        OdorProtocolSection(obj, 'next_trial');
        ChoiceSection_Olf(obj, 'next_trial');
%         SoundsSection(obj, 'next_trial');
        
%     case 'trial_completed',  
%         ChoiceSection_Olf(obj, 'trial_completed');
       
    case 'update' 
        OlfactometerSection(obj, 'update');
        
        
%   ------------------------------------------------------------------
%                CLOSE
%   ------------------------------------------------------------------    
  case 'close'    
    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;    
    delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', ['^' mfilename '_']);

    
  % ------------------------------------------------------------------
  %              REINIT
  % ------------------------------------------------------------------    
%   case 'reinit'
%     x = my_xyfig(1); y = my_xyfig(2); origfig = my_xyfig(3);
%     currfig = gcf;
%     
%     feval(mfilename, obj, 'close');
%     
%     figure(origfig);
%     feval(mfilename, obj, 'init', x, y);
%     figure(currfig);

    
 
%   case 'reinit',
%     currfig = gcf;
% 
%     % Get the original GUI position and figure:
%     x = my_gui_info(1); y = my_gui_info(2); origfig = my_gui_info(3);
% 
%     
%     feval(mfilename, obj, 'close');
%     figure(origfig);
% %     delete_sphandle('owner', ['^@' class(obj) '$'], ...
% %       'fullname', ['^' mfilename]);
% 
%     % Reinitialise at the original GUI position and figure:
%     [x, y] = feval(mfilename, obj, 'init', x, y);
% 
%     % Restore the current figure:
%     figure(currfig);
end;