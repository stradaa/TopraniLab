% Implements "Emotion Recognition Task"
%
% Task and BCI2000 Implementation by:
% Alex Estrada, UC Davis BME & CS Undergraduate
% August 31, 2022


% Focus BCI
%
% Notes on the task: 
% images are shown for 1 second
% options shown for expressions labels prior to start of task
%  photodiode
% use keystroke to select expression
% random
% one image at a time is shown
% images: six expressions male, six expressions female
% no beep
% trial length = 3.5 minutes
% webcam on
% no audio recording
% escape 'Esc' early exit
%
%
% IDEA:
% image shown length = 1 sec + split second photodiode
% one second pause
% show options
% repeat
%
% 
% capture:
% which image was shown
% reaction time (image disappears = timer starts. label chosen = time stop)
% subtract second that is waiting for images to pop
% disable early option selection
% time between trial roughly 1 second
% 
