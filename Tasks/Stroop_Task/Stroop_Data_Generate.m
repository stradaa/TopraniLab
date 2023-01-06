function gameData = Stroop_Data_Generate(num)
%STROOP_DATA_GENERATE: This function generates the data required by the
%troop task given number of colors.
%
%   Randomly organizes color and label for use of the Stroop_Task.mlapp.
%
%   INPUT:  num (any positive integer) indicating number of colors to be
%           used for simulation. Notice that the captions (or 'labels') 
%           don't change.
%   OUTPUT: 10*num x 2 cell array containing color label on first column,
%           and integer on second. Integers 1-10 are associated with color
%           rgb values utilized by the Stroop_Task.mlapp. More info about
%           the colors below.
%
%             1  = [130/255, 0, 172/255];                        % purple
%             2  = [0, 149/255, 67/255];                         % green
%             3  = [225/255, 6/255, 0/255];                      % red
%             4  = [253/255, 130/255, 42/255];                   % orange
%             5  = [0, 71/255, 189/255];                         % blue
%             6  = [136/255, 139/255, 141/255];                  % grey
%             7  = [240/255, 243/255, 244/255];                  % white
%             8  = [255/255, 230/255, 50/255];                   % yellow
%             9  = [251/255, 72/255, 196/255];                   % pink
%             10 = [101/255, 56/255, 24/255];                    % brown
%
% Created by: Alex Estrada 9/7/2022
% UC Davis


captions    = {'PURPLE','GREEN','RED','ORANGE','BLUE','GREY','WHITE',...
                'YELLOW','PINK','BROWN'};                                  % more words can be added
num_stimuli = length(captions)*num;                                        % total number of stimuli

temp = cell(num_stimuli,1);                                                % initiating gameData cell
idx = 1;
for i = captions                                                           % permutating through captions and colors
    for j = 1:num                                                          % specifying number of colors used
        temp{idx} = [i{:}, ' ', num2str(j)];                               % adding space between numbers for simplicity
        idx = idx + 1;
    end
end
temp2 = temp(randperm(numel(temp)));                                       % shuffles cell array randomly
gameData = cellfun(@(x) strsplit(x,' '), temp2, 'UniformOutput',false);    % splitting for ease of use in app

disp("Created Stroop Test Data!")
end

