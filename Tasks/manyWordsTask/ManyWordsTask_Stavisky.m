% Very simple text-on-screen displaying task. It reads the "420 words" prompts that I've
% prepared into a .mat file (one per block), and puts up a new word with each keyboard press.
% A beep is played 
%
% Sergey Stavisky, UC Davis Neuroprosthetics Translational Laboratory, 4 November 2021 

addpath(genpath('.'))                                                      % Add all the files in the repo
listFile = load( 'fiftyWordsTask_firstN.mat' ); % 50 total words designed for repeating first N phonemes
rng(1); % random seed


% Intro passage is displayed at first, before task starts
introText = 'In this task, we would like you to speak the word that appears on the screen out loud. When the word appears, prepare to speak it. Once the go click occurs, speak the word. When you have finished the word, the experimenter will bring up the next word. To the extent that it is comfortable for you, try to look straight at the screen and avoid making other movements, such as moving your head around or attempting to your arms. Feel free to take pauses in between words as needed.';

startWithWord = 1; % which word in the list
params.backgroundColor = [0.1 0.1 0.1]; % 
params.textColor = [1 1 1];
params.FontSize = 60;
params.FontSizeIntro = 40;
params.FontWeight = 'bold'; % 'normal' or 'bold'
params.pos = [0.15 0.2 0.7 0.75];    % font the intro text
params.maxChars = numel( introText ); % only used for intro (near-vestigal)


% Random delay
params.expRandMu = 1400;
params.expRandMin = 1200;
params.expRandMax = 1800;
params.expRandBinSize = 20;

% center square
params.squareSize = 1000;

%% Randomize the order
allWords = listFile.wordList;
myOrder = randperm( numel( allWords ) );
wordsInRandomOrder = allWords( myOrder );

%% audio play
params.beepAtPrompt = true; 
params.clickAtGo = true; 
% Audio .mat files live here:
% audioPath = ['C:\Users\Klay\Documents\Stavisky\manyWordsTask\manyWordsTask\'];
audioPath= uigetdir('Select folder containing .m audio files');
soundList = {...
    'beep';  % prompt is up cue
    'metronomeShort'; % SPEAK GO CUE
    };
% Load all the audio files and generate sequence list
for i = 1 : numel( soundList )
    mySound = soundList{i} ;
    in = load( [audioPath '\' mySound '.mat'] );
    sobjs.(mySound) = audioplayer( in.y, in.Fs );
    fprintf('Loaded sound %s\n', mySound )
end

%% calculate the random relays
% Random delay
params.expRandMu = 1400;
params.expRandMin = 1200;
params.expRandMax = 1800;
params.expRandBinSize = 20;

% copied from our nptl rig code, e.g. t5MovementCue_lotsOfWords_set1
wordsInRandomOrder = 50;    % just for now
delaysInRandomOrder = nan( numel(wordsInRandomOrder), 1 );
for iN = 1: numel( delaysInRandomOrder )
    thisTrialDelay = uint16(0);
    while double(thisTrialDelay) < params.expRandMin || double(thisTrialDelay) > params.expRandMax
        thisTrialDelay = uint16(params.expRandMu * -log(rand([1 1])));
    end
    thisTrialDelay = uint16(round(double(thisTrialDelay) / double(params.expRandBinSize))*params.expRandBinSize);
    delaysInRandomOrder(iN) = thisTrialDelay;
end
delaysInRandomOrder = delaysInRandomOrder / 1000; % in seconds

%% Generate figure

figh = figure('Position',[560 528 350 250]);
figh.MenuBar = 'none';
figh.Color = params.backgroundColor ;
figh.Name = 'Reading Passage Prompter';
fprintf('Move text window to the participant monitor, then press any key to populate intro text\n');
pause

% Make a text uicontrol to wrap in Units of Pixels
% Create it in Units of Pixels, 100 wide, 10 high
ht = uicontrol('Style','Text', 'Units', 'normalized');
ht.FontSize = params.FontSizeIntro;
ht.BackgroundColor = params.backgroundColor ;
ht.HorizontalAlignment = 'left';
ht.FontWeight = params.FontWeight;
ht.Position = params.pos;

% expand intro text to fixed length
myStr = introText;
myStrExpanded = [myStr repmat( ' ', 1, params.maxChars-1 - numel( myStr ) ) , '.'];
[outtext,newpos] = textwrap( ht, {myStrExpanded} );
set(ht,'String',outtext,'Position',newpos, 'ForegroundColor', params.textColor)
axh = gca;
axh.Visible = 'off';
axh.XLim = [0 1];
axh.YLim = [0 1];
hold on;

pause
% START MAIN LOOP
delete(ht);
drawnow

th1 = text( 0.5, 0.52, 'Test1', 'FontSize', params.FontSize, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
    'FontWeight', params.FontWeight, 'Color', params.textColor );
% center square
hsquare = scatter( 0.5, 0.5, 's', 'filled', 'SizeData', params.squareSize, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'none' );

% word coutner
numStr = sprintf('#%i', 0 );
thn = text(0, 0, numStr, 'FontSize', 20, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'Color', 0.5.*params.textColor  );


onScreenWord = {};
displayTimestamp = [];
for iWord = startWithWord : numel( wordsInRandomOrder )
    % Word #
    numStr = sprintf('#%i', iWord );
    thn.String = iWord;

    % PREPARE
    myStr1 = sprintf('Prepare:\n"%s"', wordsInRandomOrder{iWord} );
    th1.String = myStr1;
    hsquare.MarkerFaceColor = 'r';
    drawnow
    if params.beepAtPrompt
        sobjs.beep.play
    end
    pause( delaysInRandomOrder(iWord) )
    
    % GO
    myStr1 = 'Go';
    th1.String = myStr1;
    if params.clickAtGo
        sobjs.metronomeShort.play
    end
    hsquare.MarkerFaceColor = 'g';
    drawnow
    
    pause
    onScreenWord{end+1} = myStr1;
    displayTimestamp(end+1) = now;
end
hsquare.Visible = 'off';
th1.String = 'Block finished, thanks!';

%% Save
myFile = MakeValidFilename( sprintf('manyWordsTaskLog_%s', datestr(now) ) );
myFile = regexprep( myFile, ' ', '_' );
save( myFile, 'onScreenWord', 'displayTimestamp', 'wordsInRandomOrder' );
fprintf( 'Saved log to %s\n', myFile )

