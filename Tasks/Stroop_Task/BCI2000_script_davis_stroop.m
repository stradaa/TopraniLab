
addpath('../tools/mex')

clear variables
close all

%% global task definitions

settings.relative                   = '../';
settings.PreRunDuration             = '5s';
settings.PostRunDuration            = '5s';
settings.NumberOfSequences          = '1';
settings.WindowTop                  = '0';
settings.WindowLeft                 = '0';
settings.WindowWidth                = '640';
settings.WindowHeight               = '480';
settings.BackgroundColor            = '0x000000';
settings.WindowBackgroundColor      = '0x000000';
settings.ISIMinDuration             = '0ms';
settings.ISIMaxDuration             = '0ms';
settings.StimulusDuration           = '360s';
settings.SubjectName                = 'ECOG';
settings.DataDirectory              = '..\data\Davis\StroopTestTask';
settings.SubjectSession             = '001';
settings.SubjectRun                 = '01';
settings.NumRuns                    = 1; 



%% find the image files

captions    = {'PURPLE'  ,'GREEN'   ,'RED'     ,'ORANGE'  ,'BLUE'    ,'GREY'    ,'WHITE'   ,'YELLOW'  ,'PINK'     ,'BROWN'   };
color_codes = {'0x800080','0x008000','0xFF0000','0xFFA500','0x0000FF','0x808080','0xFFFFFF','0xFFFF00','0xFF69B4','0x8B4513'};			

num_captions = length(captions);

num_stimuli = num_captions * num_captions; 

%%

for idx_run = 1:settings.NumRuns

settings.prm_filename = sprintf('../parms/stroop_test_task_%d.prm',idx_run);
settings.UserComment  = sprintf('Davis Stroop Task Run %d',idx_run);    
    

%% program stimulus code

param.Stimuli.Section      = 'Application';
param.Stimuli.Type         = 'matrix';
param.Stimuli.DefaultValue = '';
param.Stimuli.LowRange     = '';
param.Stimuli.HighRange    = '';
param.Stimuli.Comment      = 'captions and icons to be displayed, sounds to be played for different stimuli';
param.Stimuli.Value        = cell(6,num_stimuli);
param.Stimuli.RowLabels    = cell(6,1);
param.Stimuli.ColumnLabels = cell(1,num_stimuli);

param.Stimuli.RowLabels{1} = 'caption';
param.Stimuli.RowLabels{2} = 'icon';
param.Stimuli.RowLabels{3} = 'audio';
param.Stimuli.RowLabels{4} = 'CaptionColor';
param.Stimuli.RowLabels{5} = 'CaptionColorName';
param.Stimuli.RowLabels{6} = 'EarlyOffsetExpression';


% initialize all stimuli
for idx=1:num_stimuli
    param.Stimuli.ColumnLabels{idx} = '';
    param.Stimuli.Value{1,idx}      = '';
    param.Stimuli.Value{2,idx}      = '';
    param.Stimuli.Value{3,idx}      = '';
    param.Stimuli.Value{4,idx}      = '';    
    param.Stimuli.Value{5,idx}      = '';    
    param.Stimuli.Value{6,idx}      = '';    
end


idx = 1;
for idx_caption = 1:num_captions
    for idx_color = 1:num_captions
        param.Stimuli.ColumnLabels{idx} = sprintf('%d',idx);
        param.Stimuli.Value{1,idx}      = captions{idx_caption};
        param.Stimuli.Value{2,idx}      = '';
        param.Stimuli.Value{3,idx}      = '';
        param.Stimuli.Value{4,idx}      = color_codes{idx_color};    
        param.Stimuli.Value{5,idx}      = captions{idx_color};
        param.Stimuli.Value{6,idx}      = 'KeyDown == 37 || KeyDown == 39';        
        idx = idx + 1;
    end
end
   



%% global settings for sequence

param.Sequence.Section                   = 'Application';
param.Sequence.Type                      = 'intlist';
param.Sequence.DefaultValue              = '1';
param.Sequence.LowRange                  = '1';
param.Sequence.HighRange                 = '';
param.Sequence.Comment                   = 'Sequence in which stimuli are presented (deterministic mode)/ Stimulus frequencies for each stimulus (random mode)';

%% write sequence

sequence = ones(1,num_stimuli);

param.Sequence.Value                     = cell(length(sequence),1);

for idx=1:length(sequence)
    param.Sequence.Value{idx,1} = sprintf('%d',sequence(idx));    
end



%% remaining global settings from hereon
    
%%

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
param.SequenceType.Value                = {'1'};

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
param.IconSwitch.Value            = {'0'};

%%

param.AudioSwitch.Section         = 'Application';
param.AudioSwitch.Type            = 'int';
param.AudioSwitch.DefaultValue    = '1';
param.AudioSwitch.LowRange        = '0';
param.AudioSwitch.HighRange       = '1';
param.AudioSwitch.Comment         = 'Present audio files (boolean)';
param.AudioSwitch.Value           = {'0'};

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
param.CaptionHeight.Value        = {'8'};

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


%% write paramter file

parameter_lines = convert_bciprm( param );

fid = fopen(settings.prm_filename,'w');

for idx=1:length(parameter_lines)
    fprintf(fid,'%s',parameter_lines{idx});
    fprintf(fid,'\r\n');
end

fclose(fid);

end
