function [gameData, gameKey] = Verbal_Digit_Span(taskInfo)
    %% ABOUT
    % Generates random digit span cell matrix with digits 0-9. 
    % Digits can repeat.
    % 
    % INPUT:  Structure with .spanLength component = integer.
    % OUTPUTS: gameData: 15x(max_span - taskInfo.spanLength)x cell matrix. 
    %         Each column considers span number, with each of the 15 rows
    %         containing a different set of random digits.
    % 
    %         gameKey: same size as gameData, with the correct answers to
    %         the prompt given the specified orientation.
    %
    %
    % Created by: Alex Estrada 9/4/2022
    % UC Davis
    %% Code
   
    % quick parameters settings
    max_span            = 10;                                              % limit is 10 (could be changed)
    start_span          = taskInfo.spanLength;
    orientation         = taskInfo.orientation;
    max_trials_per_span = 15;

    test_length  = max_span - start_span;                                  % computing max number of possible trials
    gameData     = cell(max_trials_per_span, test_length+1);               % rows = trial, column = span_length
    gameKey      = cell(size(gameData));
    
    % number generation
    col = 1;                                                               % initializing
    for i = start_span:max_span                                            % looping per column (controls span length)
        row = 1;
        for j = 1:max_trials_per_span                                      % fills in each row  (controls each trial)
            span_num_rand = randi([0,9], 1, i);                                % random 1-9 digit, can repeat, i-length
            gameData{row,col} = span_num_rand;                             % fills into cell array
            row = row + 1;                                                 % updates row
        end
        col = col + 1;                                                     % udpates column
    end

    % key generation
    total_num = size(gameData,1)*size(gameData,2);
    switch orientation
        case 'Backward'
            for i = 1:total_num
                temp = gameData{i};
                gameKey{i} = flip(temp);                                   % reverse order
            end
        case 'Forward'
            gameKey = gameData;                                            % no change
        case 'Sequential'
            for i = 1:total_num
                temp = gameData{i};
                gameKey{i} = sort(temp);                                   % sorting low to high
            end
    end
    
    disp("Span Task & Key Data Created!")
end