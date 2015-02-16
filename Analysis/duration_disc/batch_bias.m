
function [] = batch_bias(date)
  
  rat_list = { ...
      'ghazni','d'; ...
      'timur_lang', 'd'; ...
      'attila', 'p' ; ...
      'Babur', 'd' ; ...
      'Akbar', 'd' ; ...
      'Salim', 'p' ; 
   };
  
  for k = 1:length(rat_list)
    if strcmp(rat_list(k, 2), 'd'), task = 'duration_discobj'; 
    else task = 'dual_discobj'; end;
    
    biasv2(rat_list{k,1}, task, date, 'third','lprob');
    
  end;