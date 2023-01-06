function [ert_data] = ERT_data_create(taskInfo)
% ERT_DATA_CREATE 
% Implements "Emotion Recognition Task" by collecting data (in the form of
% images) given ERT_photos folder in main directory, not current. 
%
% out = ERT_data_create(in)
% 'in' should contain a structure with fields:
% - .random
% 
% 'out' is structure with fields:
% - .name
% - .folder
% - .date
% - .bytes
% - .isdir
% - .datenum
%
%
% Task and BCI2000 Implementation by:
% Alex Estrada, UC Davis BME & CS Undergraduate
% October 1, 2022

ert_data = dir([taskInfo.IconPath, '/*.jpg']);

n = numel(ert_data);
if strcmp(taskInfo.random,'Random')
    ert_data  = ert_data(randperm(n));
end

end

