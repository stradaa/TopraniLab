function param = bci_creator(bci_settings, task_settings)
%BCI_CREATOR Summary of this function goes here
%   Detailed explanation goes here


root = task_settings.parm_filename;
switch task_settings.name
    case 'ManyWords'
        disp('Many Words Selected')
    case 'Stroop'
        disp('Stroop Selected')
    case 'DigitSpan'
        % Get Span Digits
        [span_data, ~] = Verbal_Digit_Span(task_settings);
        % Get Audio
        task_settings.sound = audio_bci('DigitSpan');
        % Create % Write Create Parameter File(s)
        for i = 1:size(span_data, 2) % 1:9
            param = param_create(task_settings, bci_settings);
            task_settings.current_parm_filename = [root, '\', bci_settings.NameID, '_Span_', sprintf('%d', i)];
            [param, task_settings] = matrix_create(param, span_data, task_settings, i);
            write_prm(param, task_settings);
        end
    case 'ERT'
        [ert_data] = ERT_data_create(task_settings);
        task_settings.current_parm_filename = [root, '\', bci_settings.NameID, '_ERT'];

        param = param_create(task_settings, bci_settings);
        [param, ~] = matrix_create(param, ert_data, task_settings, 0);
        write_prm(param, task_settings);
    case 'React'
        task_settings.current_parm_filename = [root, '\', bci_settings.NameID, '_ERT'];
        param = param_create(task_settings, bci_settings);
        [param, ~] = matrix_create(param, 0, task_settings, 0);
%         write_prm(param, task_settings);
end

end


%% FUN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function out = audio_bci(task)
switch task
    case 'DigitSpan'
        out.sound = cell(10,1);
        temp = 0;
        for l = 1:10
            out.sound{l} = sprintf('Digit_%d.wav', temp);
            temp = temp + 1;
        end
end
end

%%
function [param, settings] = matrix_create(param, task_data, settings, i)

switch settings.name
    case 'DigitSpan'
        span_index            = size(task_data{1, i}, 2);
        n_stimuli             = (span_index + 1)*settings.numSpanPerRun;       % total events
        n_rows                = 6;                                             % 1- Caption
                                                                               % 2- Icon 
                                                                               % 3- Audio
                                                                               % 4- Stimulus Duration
                                                                               % 5- AudioVolume
                                                                               % 6- EarlyOffsetExpression
        %% Initialize Stimuli (Doesn't change)
        param.Stimuli.Section         = 'Application';                            
        param.Stimuli.Type            = 'matrix';
        param.Stimuli.DefaultValue    = '';
        param.Stimuli.LowRange        = '';
        param.Stimuli.HighRange       = '';
        param.Stimuli.Comment         = 'captions and icons to be displayed, sounds to be played for different stimuli';
        param.Stimuli.Value           = cell(n_rows,n_stimuli);
        param.Stimuli.Value(:)        = {''};
        param.Stimuli.RowLabels       = cell(n_rows,1);
        param.Stimuli.RowLabels(:)    = {''};
        param.Stimuli.ColumnLabels    = cell(1,n_stimuli);
        param.Stimuli.ColumnLabels(:) = {''};
        
        %% Subject to Change...
        param.Stimuli.RowLabels{1}  = 'caption';
        param.Stimuli.RowLabels{2}  = 'icon';
        param.Stimuli.RowLabels{3}  = 'audio';
        param.Stimuli.RowLabels{4}  = 'StimulusDuration';
        param.Stimuli.RowLabels{5}  = 'AudioVolume';
        param.Stimuli.RowLabels{6}  = 'EarlyOffsetExpression';
        
        for idx=1:n_stimuli                                                % initializing All Stimuli
            param.Stimuli.ColumnLabels{idx} = sprintf('%d',idx);           
            param.Stimuli.Value{1,idx}      = '';
            param.Stimuli.Value{2,idx}      = '';
            param.Stimuli.Value{3,idx}      = '';
            param.Stimuli.Value{4,idx}      = '';    
            param.Stimuli.Value{5,idx}      = '';    
            param.Stimuli.Value{6,idx}      = '';  
        end
        
        % Populate Parameter Matrix
        k = repmat(1:span_index, 1, settings.numSpanPerRun);        % repeating selector of spans
    
        r = repelem(1:settings.numSpanPerRun, span_index);                     % indexing into row of span_data per n_stimuli iteration
        l = 1;                                                                 % cycle through the digit in selection
        for idx = 1:n_stimuli                                    
            % unchanging params
            param.Stimuli.Value{5,idx}   = '100';                              % audio volume
            param.Stimuli.Value{6,idx}   = 'KeyDown == 32';                    % EarlyOffsetExpression (space key)
            param.Stimuli.Value{2,idx}   = '';
            switch mod(idx,span_index+1)~=0
                case 1
                    num = task_data{r(l),i}(k(l));
                    param.Stimuli.Value{1, idx}     = num2str(num);
                    param.Stimuli.Value{4, idx}     = '1s';
                    if num == 0
                        param.Stimuli.Value{3, idx} = ['sounds/',settings.sound.sound{1}];
                    else
                        param.Stimuli.Value{3,idx}  = ['sounds/',settings.sound.sound{num+1}];
                    end
                    % updating 
                    l = l + 1;
                case 0
                    param.Stimuli.Value{1,idx} = 'BEEP';
                    param.Stimuli.Value{3,idx} = 'sounds/go.wav';
                    param.Stimuli.Value{4, idx}= '30s';
            end
        end
        % Settings for Sequence
        param.Sequence.Section                   = 'Application';
        param.Sequence.Type                      = 'intlist';
        param.Sequence.DefaultValue              = '1';
        param.Sequence.LowRange                  = '1';
        param.Sequence.HighRange                 = '';
        param.Sequence.Comment                   = 'Sequence in which stimuli are presented (deterministic mode)/ Stimulus frequencies for each stimulus (random mode)';

        % write sequence
        sequence = 1:n_stimuli;
        
        param.Sequence.Value            = cell(length(sequence), 1);
        for idx = 1:length(sequence)
            param.Sequence.Value{idx,1} = sprintf('%d',sequence(idx));    
        end


    case "ERT"
        l = length(settings.StimulusDuration);
        n_stimuli = str2double(settings.StimulusDuration(1:l-1))*3;
        n_rows    = 6;                                                     % 1- Caption
                                                                           % 2- Icon 
                                                                           % 3- Audio
                                                                           % 4- Stimulus Duration
                                                                           % 5- AudioVolume
                                                                           % 6- EarlyOffsetExpression
        %% Initialize Stimuli (Doesn't change)
        param.Stimuli.Section         = 'Application';                            
        param.Stimuli.Type            = 'matrix';
        param.Stimuli.DefaultValue    = '';
        param.Stimuli.LowRange        = '';
        param.Stimuli.HighRange       = '';
        param.Stimuli.Comment         = 'captions and icons to be displayed, sounds to be played for different stimuli';
        param.Stimuli.Value           = cell(n_rows,n_stimuli);
        param.Stimuli.Value(:)        = {''};
        param.Stimuli.RowLabels       = cell(n_rows,1);
        param.Stimuli.RowLabels(:)    = {''};
        param.Stimuli.ColumnLabels    = cell(1,n_stimuli);
        param.Stimuli.ColumnLabels(:) = {''};
        
        % Subject to Change...
        param.Stimuli.RowLabels{1}  = 'caption';
        param.Stimuli.RowLabels{2}  = 'icon';
        param.Stimuli.RowLabels{3}  = 'audio';
        param.Stimuli.RowLabels{4}  = 'StimulusDuration';
        param.Stimuli.RowLabels{5}  = 'AudioVolume';
        param.Stimuli.RowLabels{6}  = 'EarlyOffsetExpression';
        
        for idx=1:n_stimuli                                                % initializing All Stimuli
            param.Stimuli.ColumnLabels{idx} = sprintf('%d',idx);           
            param.Stimuli.Value{1,idx}      = '';
            param.Stimuli.Value{2,idx}      = '';
            param.Stimuli.Value{3,idx}      = '';
            param.Stimuli.Value{4,idx}      = '';    
            param.Stimuli.Value{5,idx}      = '';    
            param.Stimuli.Value{6,idx}      = '';  
        end

        % Populate Parameter Matrix
        k   = repmat(1:3, 1, n_stimuli);
        max = 898;                                                         % number of images available
        s = 1;                                                             % keeps track of stimulus
        icon = 1;
        early_off = key_code('ERT');
        for n = k
            % unchanging
            param.Stimuli.Value{1,s} = num2str(s);  % caption
            param.Stimuli.Value{3,s} = '';          % sound
            param.Stimuli.Value{5,s} = '';          % AudioVolume
            switch n
                case 1
                    param.Stimuli.Value{2,s} = ['images/ERT_photos/',sprintf('%s', task_data(icon).name)];
                    param.Stimuli.Value{4,s} = settings.StimulusDurationFlash;    
                    param.Stimuli.Value{6,s} = '';
                    icon = icon + 1;
                case 2
                    param.Stimuli.Value{2,s} = 'images/ERT_photos/ER_options.jpg';
                    param.Stimuli.Value{4,s} = settings.StimulusDurationChoice;    
                    param.Stimuli.Value{6,s} = '';
                case 3
                    param.Stimuli.Value{2,s} = '';
                    param.Stimuli.Value{4,s} = settings.StimulusDurationNext;    
                    param.Stimuli.Value{6,s} = early_off;
                    if icon == max + 1; break;end   % checking for limit
            end
            s = s + 1;
        end

        % Settings for Sequence
        param.Sequence.Section                   = 'Application';
        param.Sequence.Type                      = 'intlist';
        param.Sequence.DefaultValue              = '1';
        param.Sequence.LowRange                  = '1';
        param.Sequence.HighRange                 = '';
        param.Sequence.Comment                   = 'Sequence in which stimuli are presented (deterministic mode)/ Stimulus frequencies for each stimulus (random mode)';

        % write sequence
        sequence = 1:s;
        
        param.Sequence.Value            = cell(length(sequence), 1);
        for idx = 1:length(sequence)
            param.Sequence.Value{idx,1} = sprintf('%d',sequence(idx));    
        end

end
end

%%
function param = param_create(settings, settings2)

% Remaining global settings from hereon
    
param.NumberOfSequences.Section         = 'Application';
param.NumberOfSequences.Type            = 'int';
param.NumberOfSequences.DefaultValue    = '1';
param.NumberOfSequences.LowRange        = '0';
param.NumberOfSequences.HighRange       = '';
param.NumberOfSequences.Comment         = 'number of sequence repetitions in a run';
param.NumberOfSequences.Value           = {settings2.NumberOfSequences};

%%

param.SequenceType.Section              = 'Application';
param.SequenceType.Type                 = 'int';
param.SequenceType.DefaultValue         = '0';
param.SequenceType.LowRange             = '0';
param.SequenceType.HighRange            = '1';
param.SequenceType.Comment              = 'Sequence of stimuli is 0 deterministic, 1 random (enumeration)';
param.SequenceType.Value                = {'0'};

%%

param.StimulusDuration.Section           = 'Application';
param.StimulusDuration.Type              = 'float';
param.StimulusDuration.DefaultValue      = '40ms';
param.StimulusDuration.LowRange          = '0';
param.StimulusDuration.HighRange         = '';
param.StimulusDuration.Comment           = 'stimulus duration';
param.StimulusDuration.Value             = {settings.StimulusDuration};

%%

param.ISIMaxDuration.Section       = 'Application';
param.ISIMaxDuration.Type          = 'float';
param.ISIMaxDuration.DefaultValue  = '80ms';
param.ISIMaxDuration.LowRange      = '0';
param.ISIMaxDuration.HighRange     = '';
param.ISIMaxDuration.Comment       = 'maximum duration of inter-stimulus interval';
param.ISIMaxDuration.Value         = {settings2.ISIMaxDuration};

%%

param.ISIMinDuration.Section       = 'Application';
param.ISIMinDuration.Type          = 'float';
param.ISIMinDuration.DefaultValue  = '80ms';
param.ISIMinDuration.LowRange      = '0';
param.ISIMinDuration.HighRange     = '';
param.ISIMinDuration.Comment       = 'minimum duration of inter-stimulus interval';
param.ISIMinDuration.Value         = {settings2.ISIMinDuration};

%%

param.PreSequenceDuration.Section       = 'Application';
param.PreSequenceDuration.Type          = 'float';
param.PreSequenceDuration.DefaultValue  = '2s';
param.PreSequenceDuration.LowRange      = '0';
param.PreSequenceDuration.HighRange     = '';
param.PreSequenceDuration.Comment       = 'pause preceding sequences/sets of intensifications';
param.PreSequenceDuration.Value         = {'0s'};

%%

param.PostSequenceDuration.Section       = 'Application';
param.PostSequenceDuration.Type          = 'float';
param.PostSequenceDuration.DefaultValue  = '2s';
param.PostSequenceDuration.LowRange      = '0';
param.PostSequenceDuration.HighRange     = '';
param.PostSequenceDuration.Comment       = 'pause following sequences/sets of intensifications';
param.PostSequenceDuration.Value         = {'0s'};

%%

param.PreRunDuration.Section       = 'Application';
param.PreRunDuration.Type          = 'float';
param.PreRunDuration.DefaultValue  = '2000ms';
param.PreRunDuration.LowRange      = '0';
param.PreRunDuration.HighRange     = '';
param.PreRunDuration.Comment       = 'pause preceding first sequence';
param.PreRunDuration.Value         = {settings2.PreRunDuration};

%%

param.PostRunDuration.Section       = 'Application';
param.PostRunDuration.Type          = 'float';
param.PostRunDuration.DefaultValue  = '2000ms';
param.PostRunDuration.LowRange      = '0';
param.PostRunDuration.HighRange     = '';
param.PostRunDuration.Comment       = 'pause following last squence';
param.PostRunDuration.Value         = {settings2.PostRunDuration};


%%

param.BackgroundColor.Section      = 'Application';
param.BackgroundColor.Type         = 'string';
param.BackgroundColor.DefaultValue = '0x00FFFF00';
param.BackgroundColor.LowRange     = '0x00000000';
param.BackgroundColor.HighRange    = '0x00000000';
param.BackgroundColor.Comment      = 'Color of stimulus background (color)';
param.BackgroundColor.Value        = {settings.BackgroundColor};

%%

param.CaptionColor.Section      = 'Application';
param.CaptionColor.Type         = 'string';
param.CaptionColor.DefaultValue = '0x00FFFF00';
param.CaptionColor.LowRange     = '0x00000000';
param.CaptionColor.HighRange    = '0x00000000';
param.CaptionColor.Comment      = 'Color of stimulus caption text (color)';
param.CaptionColor.Value        = {settings.CaptionColor};

%%

param.WindowBackgroundColor.Section      = 'Application';
param.WindowBackgroundColor.Type         = 'string';
param.WindowBackgroundColor.DefaultValue = '0x00FFFF00';
param.WindowBackgroundColor.LowRange     = '0x00000000';
param.WindowBackgroundColor.HighRange    = '0x00000000';
param.WindowBackgroundColor.Comment      = 'background color (color)';
param.WindowBackgroundColor.Value        = {settings.WindowBackgroundColor};

%%

param.IconSwitch.Section          = 'Application';
param.IconSwitch.Type             = 'int';
param.IconSwitch.DefaultValue     = '1';
param.IconSwitch.LowRange         = '0';
param.IconSwitch.HighRange        = '1';
param.IconSwitch.Comment          = 'Present icon files (boolean)';
param.IconSwitch.Value            = {settings.IconSwitch};

%%

param.AudioSwitch.Section         = 'Application';
param.AudioSwitch.Type            = 'int';
param.AudioSwitch.DefaultValue    = '1';
param.AudioSwitch.LowRange        = '0';
param.AudioSwitch.HighRange       = '1';
param.AudioSwitch.Comment         = 'Present audio files (boolean)';
param.AudioSwitch.Value           = {settings.AudioSwitch};

%%

param.CaptionSwitch.Section       = 'Application';
param.CaptionSwitch.Type          = 'int';
param.CaptionSwitch.DefaultValue  = '1';
param.CaptionSwitch.LowRange      = '0';
param.CaptionSwitch.HighRange     = '1';
param.CaptionSwitch.Comment       = 'Present captions (boolean)';
param.CaptionSwitch.Value         = {settings.CaptionSwitch};

%%

param.UserComment.Section         = 'Application';
param.UserComment.Type            = 'string';
param.UserComment.DefaultValue    = '';
param.UserComment.LowRange        = '';
param.UserComment.HighRange       = '';
param.UserComment.Comment         = 'User comments for a specific run';
param.UserComment.Value           = {settings.UserComment};

%%

param.WindowHeight.Section        = 'Application';
param.WindowHeight.Type           = 'int';
param.WindowHeight.DefaultValue   = '480';
param.WindowHeight.LowRange       = '0';
param.WindowHeight.HighRange      = '';
param.WindowHeight.Comment        = 'height of application window';
param.WindowHeight.Value          = {settings2.WindowHeight};

%%

param.WindowWidth.Section        = 'Application';
param.WindowWidth.Type           = 'int';
param.WindowWidth.DefaultValue   = '480';
param.WindowWidth.LowRange       = '0';
param.WindowWidth.HighRange      = '';
param.WindowWidth.Comment        = 'width of application window';
param.WindowWidth.Value          = {settings2.WindowWidth};

%%

param.WindowLeft.Section        = 'Application';
param.WindowLeft.Type           = 'int';
param.WindowLeft.DefaultValue   = '0';
param.WindowLeft.LowRange       = '';
param.WindowLeft.HighRange      = '';
param.WindowLeft.Comment        = 'screen coordinate of application window''s left edge';
param.WindowLeft.Value          = {settings.WindowLeft};

%%

param.WindowTop.Section        = 'Application';
param.WindowTop.Type           = 'int';
param.WindowTop.DefaultValue   = '0';
param.WindowTop.LowRange       = '';
param.WindowTop.HighRange      = '';
param.WindowTop.Comment        = 'screen coordinate of application window''s top edge';
param.WindowTop.Value          = {settings.WindowTop};

%%

param.StimulusWidth.Section      = 'Application';
param.StimulusWidth.Type         = 'int';
param.StimulusWidth.DefaultValue = '0';
param.StimulusWidth.LowRange     = '0';
param.StimulusWidth.HighRange    = '100';
param.StimulusWidth.Comment      = 'StimulusWidth in percent of screen width (zero for original pixel size)';
param.StimulusWidth.Value        = {settings2.StimulusWidth};

%%

param.CaptionHeight.Section      = 'Application';
param.CaptionHeight.Type         = 'int';
param.CaptionHeight.DefaultValue = '0';
param.CaptionHeight.LowRange     = '0';
param.CaptionHeight.HighRange    = '100';
param.CaptionHeight.Comment      = 'Height of stimulus caption text in percent of screen height';
param.CaptionHeight.Value        = settings.CaptionHeight;

%%

param.WarningExpression.Section      = 'Filtering';
param.WarningExpression.Type         = 'string';
param.WarningExpression.DefaultValue = '';
param.WarningExpression.LowRange     = '';
param.WarningExpression.HighRange    = '';
param.WarningExpression.Comment      = 'expression that results in a warning when it evaluates to true';
param.WarningExpression.Value        = {''};

%%

param.Expressions.Section      = 'Filtering';
param.Expressions.Type         = 'matrix';
param.Expressions.DefaultValue = '';
param.Expressions.LowRange     = '';
param.Expressions.HighRange    = '';
param.Expressions.Comment      = 'expressions used to compute the output of the ExpressionFilter';
param.Expressions.Value        = {''};

%%

param.SubjectName.Section      = 'Storage';
param.SubjectName.Type         = 'string';
param.SubjectName.DefaultValue = 'Name';
param.SubjectName.LowRange     = '';
param.SubjectName.HighRange    = '';
param.SubjectName.Comment      = 'subject alias';
param.SubjectName.Value        = {settings.SubjectName};

%%

param.DataDirectory.Section      = 'Storage';
param.DataDirectory.Type         = 'string';
param.DataDirectory.DefaultValue = '..\data';
param.DataDirectory.LowRange     = '';
param.DataDirectory.HighRange    = '';
param.DataDirectory.Comment      = 'path to top level data directory (directory)';
param.DataDirectory.Value        = {settings.DataDirectory};

%%

param.SubjectRun.Section      = 'Storage';
param.SubjectRun.Type         = 'string';
param.SubjectRun.DefaultValue = '00';
param.SubjectRun.LowRange     = '';
param.SubjectRun.HighRange    = '';
param.SubjectRun.Comment      = 'two-digit run number';
param.SubjectRun.Value        = {settings.SubjectRun};

%%

param.SubjectSession.Section      = 'Storage';
param.SubjectSession.Type         = 'string';
param.SubjectSession.DefaultValue = '00';
param.SubjectSession.LowRange     = '';
param.SubjectSession.HighRange    = '';
param.SubjectSession.Comment      = 'three-digit session number';
param.SubjectSession.Value        = {settings.SubjectSession};

end

%%
function write_prm(param, settings)
parameter_lines = convert_bciprm(param);

fid = fopen([settings.current_parm_filename,'.prm'], 'w');
for i = 1:length(parameter_lines)
    fprintf(fid, '%s', parameter_lines{i});
    fprintf(fid, '\r\n');
end

fclose(fid);
disp(['Created file: ', settings.current_parm_filename,'.prm'])
end

%%
function keybinds = key_code(task)
% Key        Code
% Left Mouse    1
% Right Mouse    2
% Middle Mouse    4
% A        65
% B        66
% C        67
% D        68
% E        69
% F        70G        71
% H        72
% I        73
% J        74
% K        75
% L        76
% M        77
% N        78
% O        79
% P        80
% Q        81
% R        82
% S        83
% T        84
% U        85
% V        86
% W        87
% X        88
% Y        89
% Z        90
% 0        48
% 1        49
% 2        50
% 3        51
% 4        52
% 5        53
% 6        54
% 7        55
% 8        56
% 9        57
% Numpad 0    96
% Numpad 1    97
% Numpad 2    98
% Numpad 3    99
% Numpad 4    100
% Numpad 5    101
% Numpad 6    102
% Numpad 7    103
% Numpad 8    104
% Numpad 9    105
% Multiply    106
% Add        107
% Enter        13
% Subtract    109
% Decimal        110
% Divide        111
% F1        112
% F2        113
% F3        114
% F4        115
% F5        116
% F6        117
% F7        118
% F8        119
% F9        120
% F10        121
% F11        122
% F12        123
% Backspace    8
% Tab        9
% Enter        13
% Shift        16
% Lcontrol    162
% Rcontrol    163
% Lalt        164
% Ralt        165
% Caps Lock    20
% Esc        27
% Spacebar    32
% Page Up        33
% Page Down    34
% End        35
% Home        36
% Left Arrow    37
% Up Arrow    38
% Right Arrow    39
% Down Arrow    40
% Insert        45
% Delete        46
% Num Lock    144
% ScrLk        145
% Pause/Break    19
% ; :        186
% = +        187
% - _        189
% / ?        191
% ` ~        192
% [ {        219
% \ |        220
% ] }        221
% " '        222
% ,        188
% .        190
% /        191
% LShift        160
% RShift        161
% PrintSCrn    44
% L-Win        91
% R-Win        92
% Menu        93
% Num Enter    108

text_1 = 'KeyDown ==  ';
text_2 = '  ||  ';

keybinds = '';
switch task
    case 'ERT'
        for i = 96:105
            keybinds = [keybinds, text_1, num2str(i), text_2];
        end
        keybinds = keybinds(1:end-6);
end
end










