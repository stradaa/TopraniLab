%% Step 1: Set the path of the BCI2000 main directory here
BCI2000pathparts = regexp(pwd,filesep,'split');
BCI2000path = '';
for i = 1:length(BCI2000pathparts)-2
    BCI2000path = [BCI2000path BCI2000pathparts{i} filesep];
end
settings.BCI2000path = BCI2000path;
clear BCI2000path BCI2000pathparts i

% Add BCI2000 tools to path
addpath(genpath(fullfile(settings.BCI2000path,'tools')))


%% Step 2: Settings
settings.SamplingRate          = '256Hz'; % device sampling rate
settings.SampleBlockSize       = '8';     % number of samples in a block

settings.PreRunDuration        = '2s';
settings.PostRunDuration       = '0.5s';
settings.TaskDuration          = '2s';
settings.InstructionDuration   = '30s';
settings.SyncPulseDuration     = '1s';
settings.BaselineMinDuration   = '0.5s';
settings.BaselineMaxDuration   = '1.5s';
settings.NumberOfSequences     = '1';
settings.StimulusWidth         = '30';
settings.WindowTop             = '0';
settings.WindowLeft            = '0';
settings.WindowWidth           = '640';
settings.WindowHeight          = '480';
settings.BackgroundColor       = '0x000000';
settings.CaptionColor          = '0xFFFFFF';
settings.CaptionSwitch         = '1';
settings.WindowBackgroundColor = '0x000000';
settings.ISIMinDuration        = '0s';
settings.ISIMaxDuration        = '0s';
settings.SubjectName           = 'BCI';
settings.DataDirectory         = fullfile('..','data');
settings.SubjectSession        = 'auto';
settings.SubjectRun            = '01';
settings.parm_filename         = fullfile(settings.BCI2000path,'parms','demo_parms.prm');
settings.UserComment           = 'Enter user comment here';

settings.InstructionsCaption   = {'Stimulus Presentation Task. Press space to continue'; 'End of task.'};

%% Step 3: Get task images
audioPath   = uigetdir('Select folder containing .m files');

task_audio = dir(fullfile(uigetdir(),'*.mat'));
task_images = dir(fullfile(settings.BCI2000path,'prog','images','*.bmp'));

%% Step 4: Set up the different stimuli so they are represented by unique stimulus codes, separated into banks for easy evaluation later
n_stimuli = 301; % Total events
n_rows    = 7;

% break down into blocks for easier analysis later
% 1-50:    image stimuli
% 101-150: inter-stimulus interval (variable duration)
% 201:     instructions
% 301:     sync pulse

% Set up Stimuli
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

param.Stimuli.RowLabels{1}  = 'caption';
param.Stimuli.RowLabels{2}  = 'icon';
param.Stimuli.RowLabels{3}  = 'audio';
param.Stimuli.RowLabels{4}  = 'StimulusDuration';
param.Stimuli.RowLabels{5}  = 'AudioVolume';
param.Stimuli.RowLabels{6}  = 'Category';
param.Stimuli.RowLabels{7}  = 'EarlyOffsetExpression';

%% Step 6: Study images 1-50
for idx = 1:length(task_images)
    param.Stimuli.ColumnLabels{idx} = sprintf('%d',idx);
    param.Stimuli.Value{1,idx}      = '';
    param.Stimuli.Value{2,idx}      = sprintf('%s',fullfile('..','prog','images',task_images(idx).name));
    param.Stimuli.Value{3,idx}      = '';
    param.Stimuli.Value{4,idx}      = settings.TaskDuration;
    param.Stimuli.Value{5,idx}      = '0';      
    param.Stimuli.Value{6,idx}      = 'image'; 
    param.Stimuli.Value{7,idx}      = ''; 
end 

%% inter-stimulus interval (fixation cross) 101-150
% variable duration from 0.5-1.5s
SamplingRate = str2double(settings.SamplingRate(1:end-2));
BlockSize    = str2double(settings.SampleBlockSize);
MinDuration  = str2double(settings.BaselineMinDuration(1:end-1));
MaxDuration  = str2double(settings.BaselineMaxDuration(1:end-1));
for idx = 101:100+length(task_images)
    blockvals = MinDuration:BlockSize/SamplingRate:MaxDuration;
    randval   = randi(length(blockvals));
    duration  = blockvals(randval);
    
    param.Stimuli.ColumnLabels{idx} = sprintf('%d',idx);
    param.Stimuli.Value{1,idx}      = '+';
    param.Stimuli.Value{2,idx}      = '';
    param.Stimuli.Value{3,idx}      = '';
    param.Stimuli.Value{4,idx}      = strcat(num2str(duration,7),'s');
    param.Stimuli.Value{5,idx}      = '0';      
    param.Stimuli.Value{6,idx}      = 'fixation'; 
    param.Stimuli.Value{7,idx}      = ''; 
end

%% Instructions 201-202
idx_iter = 1;
for idx = 201:200+length(settings.InstructionsCaption)
    param.Stimuli.ColumnLabels{idx} = sprintf('%d',idx);
    param.Stimuli.Value{1,idx}      = settings.InstructionsCaption{idx_iter};
    param.Stimuli.Value{2,idx}      = '';
    param.Stimuli.Value{3,idx}      = '';
    param.Stimuli.Value{4,idx}      = settings.InstructionDuration;
    param.Stimuli.Value{5,idx}      = '0';    
    param.Stimuli.Value{6,idx}      = 'instruction'; 
    param.Stimuli.Value{7,idx}      = 'KeyDown == 32'; % space key 
    
    idx_iter = idx_iter + 1;
end 

%% Sync pulse 301
idx = 301;
param.Stimuli.ColumnLabels{idx} = sprintf('%d',idx);
param.Stimuli.Value{1,idx}      = '';
param.Stimuli.Value{2,idx}      = '';
param.Stimuli.Value{3,idx}      = '';
param.Stimuli.Value{4,idx}      = settings.SyncPulseDuration;
param.Stimuli.Value{5,idx}      = '0';      
param.Stimuli.Value{6,idx}      = 'sync'; 
param.Stimuli.Value{7,idx}      = '';    

%% Sequence
% 1-50:    image stimuli
% 101-150: inter-stimulus interval (variable duration)
% 201:     instructions
% 301:     sync pulse

randOrder = randperm(length(task_images));
taskseq   = [];
for i = 1:length(task_images)
    currentImage = randOrder(i);
    taskseq      = [taskseq (100+currentImage) currentImage];
end

seq = [301 201 taskseq 202 301]';

param.Sequence.Section      = 'Application';
param.Sequence.Type         = 'intlist';
param.Sequence.DefaultValue = '1';
param.Sequence.LowRange     = '1';
param.Sequence.HighRange    = '';
param.Sequence.Comment      = 'Sequence in which stimuli are presented (deterministic mode)/ Stimulus frequencies for each stimulus (random mode)';
param.Sequence.Value        = cellfun(@num2str, num2cell(seq), 'un',0);
param.Sequence.NumericValue = seq;

%%
param.SamplingRate.Section         = 'Source';
param.SamplingRate.Type            = 'int';
param.SamplingRate.DefaultValue    = '256Hz';
param.SamplingRate.LowRange        = '1';
param.SamplingRate.HighRange       = '';
param.SamplingRate.Comment         = 'sample rate';
param.SamplingRate.Value           = {settings.SamplingRate};

%% write the param struct to a bci2000 parameter file
parameter_lines = convert_bciprm( param );
fid = fopen(settings.parm_filename, 'w');

for i=1:length(parameter_lines)
    fprintf( fid, '%s', parameter_lines{i} );
    fprintf( fid, '\r\n' );
end
fclose(fid);
