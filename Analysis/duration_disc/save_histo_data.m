function [] = save_histo_data()

global Solo_datadir;
fname = [Solo_datadir filesep 'Shraddha' filesep 'Histo' filesep 'scoring_0805.mat'];

fprintf(1,'%s\n', fname);

ACx_lesionyesno__LEFT = { ...
    'Eaglet', '000000000011110001110000111000000', ...
    'Gryphon', '000011100011110111001111100000000', ...
    'Legolas', '101011100000111101100000111110000', ...
    'Sauron', '101001110001111001110000111000000', ...
    'Boromir', '000000000001111100011111101111000', ...
    'Bilbo', '000000111111111001110111000000000', ...
    'Lory', '000111000001111100011100000000000', ...
    'Gandalf', '111001110001111110011100111110000', ...
    'Aragorn', '000011100001111000011110111111100', ...
    'Gimli', '111100000001111100001110111011100', ...
    };

ACx_lesionyesno__RIGHT = {...
    'Eaglet', '101000001110000000111011111000000', ...
    'Gryphon', '000011111011110111001110000111000', ...
    'Legolas', '101111000111011001110000111110000', ...
    'Sauron', '000011100001111110001110011111100', ...
    'Boromir', '000000000001111000011111100011111', ...
    'Bilbo', '000111001111111000111011100000000', ...
    'Lory', '010110000001111000111001110000000', ...
    'Gandalf', '000011100001111110001110011111000', ...
    'Aragorn', '000000000011111110011101111111111', ...
    'Gimli', '111100000000001111100011111100000', ...
    };

ACx_lesion_yesno = { ...
    'Eaglet','101000001111110001111011111000000', ...
    'Gryphon',       '000011111011110111001111100111000',...
    'Legolas',        '101111100111111101110000111110000',...
    'Sauron',        '101011110001111111111110111111100', ...
    'Boromir',        '000000000001111100011111101111111',...
    'Bilbo',        '000111111111111001111111100000000', ...
    'Lory',        '010111000001111100111101110000000',...
    'Gandalf',        '111011110001111110011110111111000',...
    'Aragorn',       '000011100011111110011111111111111',...
    'Gimli',        '111100000001111111101111111111100'...
    };
ACx_task = 'dddddppppp';

PFC_lesion_yesno = ...
    {'Celeborn','000111011010000000000', ...
    'Wraith', '000111101000000000100', ...
    'Shelob', '000001010101000000000', ...
    'Nazgul', '000011001000000100000', ...
    'Treebeard', '000101001000000000000', ...
    'Hudson', '000010110110000000000', ...
    'Sherlock', '000111101011000000000', ...
    'Shadowfax', '000011011010000000000', ...
    'Moria',  '001001001000011000000', ...
    'Evenstar',  '001010100100010000000', ...
    'Watson','000111101000010000000'...
    };
PFC_task = 'ddddddppppp';

save(fname, 'ACx_lesionyesno__LEFT', 'ACx_lesionyesno__RIGHT', ...
    'ACx_lesion_yesno', ...
    'PFC_lesion_yesno',...
    'ACx_task',   'PFC_task');

