% Implements "Digit Span" as a stimulus for experiment using the 
% default BCI2000 stimulus presentation module.
%
% Task and BCI2000 Implementation by:
% Alex Estrada, UC Davis BME & CS Undergraduate
% August 31, 2022


%%
clear variables; close all

%% Set the path of the BCI2000 main directory here
% addpath('../tools/mex')                                                    % from stroop test demo file

% from tutorial ---
BCI2000pathparts = regexp(pwd,filesep,'split');                            % pwd = identity current folder, filesep = '\'
BCI2000path = '';
for i = 1:length(BCI2000pathparts)-2
    BCI2000path = [BCI2000path BCI2000pathparts{i} filesep];
end
settings.BCI2000path = BCI2000path;
clear BCI2000path BCI2000pathparts i

% Add BCI2000 tools to path
addpath(genpath(fullfile(settings.BCI2000path,'tools')))
%% Settings Specific to Task
settings.SamplingRate          = '256Hz';                                  % device sampling rate
settings.SampleBlockSize       = '8';                                      % number of samples in a block

settings.PreRunDuration        = '5s';
settings.PostRunDuration       = '5s';
settings.InstructionDuration   = '30s';
settings.SyncPulseDuration     = '1s';
settings.BaselineMinDuration   = '0.5s';
settings.BaselineMaxDuration   = '1.5s';
settings.NumberOfSequences     = '1';
settings.StimulusWidth         = '30';
settings.WindowTop             = '0';
settings.WindowLeft            = '0';
settings.WindowWidth           = '1280';
settings.WindowHeight          = '960';
settings.BackgroundColor       = '0xECF0F1';                               % cool gray
settings.CaptionColor          = '0xFFFFFF';                               % white
settings.CaptionHeight         = {'8'};
settings.CaptionSwitch         = '1';
settings.WindowBackgroundColor = '0x000000';
settings.ISIMinDuration        = '0s';
settings.ISIMaxDuration        = '0s';
settings.SubjectName           = 'BCI';
settings.DataDirectory         = '..\data\Davis\StroopTestTask';
settings.SubjectSession        = 'auto';
settings.SubjectRun            = '01';
settings.parm_filename         = fullfile(settings.BCI2000path,'parms','demo_parms.prm');
settings.UserComment           = 'Verbal Span Task Run';
settings.InstructionsCaption   = {['In this task, there will be digits' ...
    'being read, and you will be asked to repeat them back in the order' ...
    'that is required. Wait for the sound to indicate when it is your' ...
    'turn to respond after every digit is read till completion']};

settings.TaskDigitDuration     = '1s';                                     % time to say each digit
settings.TaskSoundDuration     = '1s';                                     % time for sound
settings.StimulusDuration      = '180s';                                   % total time
settings.spanLength            = 2;                                        % starting span length
settings.orientation           = 'Forward';                                % Forward/Backward/Sequential
settings.numSpanPerRun         = 6;                                        % number of spans per run


% Patient Information
% app.NameIDEditField.Value               = '';
% app.DateDatePicker.Value                = NaT;
% app.DemographicsTextArea.Value          = '';
% app.CommentsTextArea.Value              = '';
% % BCI_Settings
% app.SamplingRateEditField.Value         = 256;
% app.SampleBlockSizeEditField.Value      = 8;
% app.PreRunDurationEditField.Value       = 5;
% app.PostRunDurationEditField.Value      = 5;
% app.InstructionDurationEditField.Value  = 30;
% app.StimulusWidthEditField.Value        = 30;
% app.WindowWidthEditField.Value          = 1280;
% app.WindowHeightEditField.Value         = 960;
% app.SyncPulseDurationEditField.Value    = 0;
% app.BaselineMinDurationEditField.Value  = 0.5;
% app.BaselineMaxDurationEditField.Value  = 1.5;
% app.NumberofSequencesEditField.Value    = 1;
% app.ISIMinDurationEditField.Value       = 0;
% app.ISIMaxDurationEditField.Value       = 0;

%% Get Span Digits (assumming sound .wav files are already created)
[span_data, span_key] = Verbal_Digit_Span(settings);
settings.sound = cell(10,1);
temp = 0;
for l = 1:10
    settings.sound{l} = sprintf('Digit_%d.wav', temp);
    temp = temp + 1;
end
clear temp;
%% Starting Loop to Create All Parameter Files
for i = 1:size(span_data, 2) % 1:9
    span_index            = size(span_data{1, i}, 2);
    settings.prm_filename = sprintf('..parms/many_words_task_Span_%d.prm', i);
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
    
    for idx=1:n_stimuli                                                        % initializing All Stimuli
        param.Stimuli.ColumnLabels{idx} = sprintf('%d',idx);                   % create all column labels (generic)
        param.Stimuli.Value{1,idx}      = '';
        param.Stimuli.Value{2,idx}      = '';
        param.Stimuli.Value{3,idx}      = '';
        param.Stimuli.Value{4,idx}      = '';    
        param.Stimuli.Value{5,idx}      = '';    
        param.Stimuli.Value{6,idx}      = '';  
    end
    
    %% Populate Parameter Matrix
    k = repmat(1:span_index, 1, settings.numSpanPerRun);        % repeating selector of spans

    r = repelem(1:settings.numSpanPerRun, span_index);                     % indexing into row of span_data per n_stimuli iteration
    c = span_index - 1;                                                    % indexing the column of span_data
    l = 1;                                                                 % cycle through the digit in selection
    for idx = 1:n_stimuli                                    
        % unchanging params
        param.Stimuli.Value{5,idx}   = '100';                              % audio volume
        param.Stimuli.Value{6,idx}   = 'KeyDown == 32';                    % EarlyOffsetExpression (space key)
        param.Stimuli.Value{2,idx}   = '';
        switch mod(idx,span_index+1)~=0
            case 1
                num = span_data{r(l),c}(k(l));
                param.Stimuli.Value{1, idx}     = num2str(num);
                param.Stimuli.Value{4, idx}     = '1s';
                if num == 0
                    param.Stimuli.Value{3, idx} = settings.sound{1};
                else
                    param.Stimuli.Value{3,idx}  = settings.sound{num+1};
                end
                % updating 
                l = l + 1;
            case 0
                param.Stimuli.Value{1,idx} = 'BEEP';
                param.Stimuli.Value{3,idx} = 'Go.wav';
                param.Stimuli.Value{4, idx}= '30s';
        end
    end 
    
    %% Settings for Sequence
    param.Sequence.Section                   = 'Application';
    param.Sequence.Type                      = 'intlist';
    param.Sequence.DefaultValue              = '1';
    param.Sequence.LowRange                  = '1';
    param.Sequence.HighRange                 = '';
    param.Sequence.Comment                   = 'Sequence in which stimuli are presented (deterministic mode)/ Stimulus frequencies for each stimulus (random mode)';
    
    %% write sequence
    
    sequence = 1:n_stimuli;
    param.Sequence.Value            = cell(length(sequence),1);
    for idx = 1:length(sequence)
        param.Sequence.Value{idx,1} = sprintf('%d',sequence(idx));    
    end
    
    %% Remaining global settings from hereon
    
    param.NumberOfSequences.Section         = 'Application';
    param.NumberOfSequences.Type            = 'int';
    param.NumberOfSequences.DefaultValue    = '1';
    param.NumberOfSequences.LowRange        = '0';
    param.NumberOfSequences.HighRange       = '';
    param.NumberOfSequences.Comment         = 'number of sequence repetitions in a run';
    param.NumberOfSequences.Value           = {settings.NumberOfSequences};
    
    %%
    
    param.SequenceType.Section              = 'Application';
    param.SequenceType.Type                 = 'int';
    param.SequenceType.DefaultValue         = '0';
    param.SequenceType.LowRange             = '0';
    param.SequenceType.HighRange            = '1';
    param.SequenceType.Comment              = 'Sequence of stimuli is 0 deterministic, 1 random (enumeration)';
    param.SequenceType.Value                = {'0'};
    
    %%
    
    % param.StimulusDuration.Section           = 'Application';
    % param.StimulusDuration.Type              = 'float';
    % param.StimulusDuration.DefaultValue      = '40ms';
    % param.StimulusDuration.LowRange          = '0';
    % param.StimulusDuration.HighRange         = '';
    % param.StimulusDuration.Comment           = 'stimulus duration';
    % param.StimulusDuration.Value             = {settings.StimulusDuration};
    
    %%
    
    param.ISIMaxDuration.Section       = 'Application';
    param.ISIMaxDuration.Type          = 'float';
    param.ISIMaxDuration.DefaultValue  = '80ms';
    param.ISIMaxDuration.LowRange      = '0';
    param.ISIMaxDuration.HighRange     = '';
    param.ISIMaxDuration.Comment       = 'maximum duration of inter-stimulus interval';
    param.ISIMaxDuration.Value         = {settings.ISIMaxDuration};
    
    %%
    
    param.ISIMinDuration.Section       = 'Application';
    param.ISIMinDuration.Type          = 'float';
    param.ISIMinDuration.DefaultValue  = '80ms';
    param.ISIMinDuration.LowRange      = '0';
    param.ISIMinDuration.HighRange     = '';
    param.ISIMinDuration.Comment       = 'minimum duration of inter-stimulus interval';
    param.ISIMinDuration.Value         = {settings.ISIMinDuration};
    
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
    param.PreRunDuration.Value         = {settings.PreRunDuration};
    
    %%
    
    param.PostRunDuration.Section       = 'Application';
    param.PostRunDuration.Type          = 'float';
    param.PostRunDuration.DefaultValue  = '2000ms';
    param.PostRunDuration.LowRange      = '0';
    param.PostRunDuration.HighRange     = '';
    param.PostRunDuration.Comment       = 'pause following last squence';
    param.PostRunDuration.Value         = {settings.PostRunDuration};
    
    
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
    param.CaptionColor.Value        = {'0x000000'};
    
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
    param.IconSwitch.Value            = {'1'};
    
    %%
    
    param.AudioSwitch.Section         = 'Application';
    param.AudioSwitch.Type            = 'int';
    param.AudioSwitch.DefaultValue    = '1';
    param.AudioSwitch.LowRange        = '0';
    param.AudioSwitch.HighRange       = '1';
    param.AudioSwitch.Comment         = 'Present audio files (boolean)';
    param.AudioSwitch.Value           = {'1'};
    
    %%
    
    param.CaptionSwitch.Section       = 'Application';
    param.CaptionSwitch.Type          = 'int';
    param.CaptionSwitch.DefaultValue  = '1';
    param.CaptionSwitch.LowRange      = '0';
    param.CaptionSwitch.HighRange     = '1';
    param.CaptionSwitch.Comment       = 'Present captions (boolean)';
    param.CaptionSwitch.Value         = {'1'};
    
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
    param.WindowHeight.Value          = {settings.WindowHeight};
    
    %%
    
    param.WindowWidth.Section        = 'Application';
    param.WindowWidth.Type           = 'int';
    param.WindowWidth.DefaultValue   = '480';
    param.WindowWidth.LowRange       = '0';
    param.WindowWidth.HighRange      = '';
    param.WindowWidth.Comment        = 'width of application window';
    param.WindowWidth.Value          = {settings.WindowWidth};
    
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
    param.StimulusWidth.Value        = {'0'};
    
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
    
    
    %% write the param structure to a bci2000 parameter file
    parameter_lines = convert_bciprm(param);
    fid = fopen(settings.param_filename, 'w');
    
    for i = 1:length(parameter_lines)
        fprintf(fid, '%s', parameter_lines{i});
        fprintf(fid, '\r\n');
    end
    
    fclose(fid);

end