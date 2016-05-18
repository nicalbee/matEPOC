%% converts TestBench EDF file to data matrix
%
% use:
%
% [data_matrix,data.channel_labels,data_table] = edf2mat(file_name,data_Hertz)
%
% where:
%
% INPUTS:
%
% file_name = edf file to be converted, file name on the MATLAB path or
%   full path to file name
%
% data_Hertz = sampling rate of the data recording: EPOC = 128, EPOC+ = 256
%
% OUTPUT: structured variable
%
% data.matrix = data matrix from edf file
%
% data.channel_labels = column labels of the data matrix
%
% data.table = table variable of matrix and channel_labels
%
% date created: 27-July-2015
% author: Nic Badcock using some of Johnson Thie's code
%
% updates:
% 18-May-2016: NAB auto get file if there isn't an input

function data = edf2mat(file_name,data_Hertz)

data.matrix = [];
data.channel_labels = [];
data.table = [];


if ~exist('file_name','var') || isempty(file_name)
    [file_name_only,file_dir] = uigetfile('*.edf');
    file_name = fullfile(file_dir,file_name_only);
    %     if ~exist(file_name,'file')
    %         msg = sprintf('''file_name'' input variable doesn''t exist or is empty. Aborting %s.',mfilename);
    %         warndlg(msg,sprintf('%s function error',mfilename));
    %         return
    %     end
end


if isempty(file_name) || ~exist(file_name,'file')
    msg = sprintf('File (%s) not found. Check path or use full path to file. Aborting %s.',mfilename);
    warndlg(msg,sprintf('%s function error',mfilename));
    return
end

[data.dir,data.filename,data.file_ext] = fileparts(file_name);

%% Set default variables
default_on = 0;
if ~exist('data_Hertz','var') || isempty(data_Hertz)
    default_on = 1;
    data_Hertz  = 128; % 1 second of data == record size
end
data.Hertz = data_Hertz; % put it in the structure
%% report what's happening:
fprintf('Running: %s\n',mfilename)
fprintf('\nImporting: %s\n',file_name)
fprintf('\tRecorded at %i Hertz (default = %i)',data_Hertz,default_on);
fprintf('\nThis will take a little while:\n\t');

%% Initialise EDF file_stream object
file_stream = EDFFileStream(file_name, ceil(data_Hertz));
file_stream = open(file_stream);
data.channel_labels = getChannelLabels(file_stream);
i = 0;
while 1
    i = i + 1;
    [file_stream, new_data] = read(file_stream);
    if isempty(new_data)
        % finished
        break
    end
    data.matrix = vertcat(data.matrix,new_data);
    if ~mod(i,100);fprintf('.'); end
end
fprintf('\nFinished importing %s\n',file_name);
fprintf('\tImported %i samples for %i columns/variables\n',size(data.matrix));
data.seconds = size(data.matrix,1)*(1/data.Hertz);
fprintf('\tCorresponds to about %3.2f seconds, %3.2f minutes\n',data.seconds,data.seconds/60);

%% Close the EDF file_stream object
close(file_stream);

%% subtract constant
data.EEG_channels = {'AF3','F7','F3','FC5','T7','P7','O1','O2','P8','T8','FC6','F4','F8','AF4'};
data.EEG_channel_indices = zeros(1,numel(data.EEG_channels));
for i = 1 : numel(data.EEG_channels)
    data.EEG_channel_indices(i) = find(ismember(data.channel_labels,data.EEG_channels{i}),1,'first');
end
% changed to median as had some poor results 12-Sep-2015 NAB
% data.matrix(:,data.EEG_channel_indices) = bsxfun(@minus,median(data.matrix(:,data.EEG_channel_indices)),data.matrix(:,data.EEG_channel_indices));
% data.matrix(:,data.EEG_channel_indices) = bsxfun(@minus,data.matrix(:,data.EEG_channel_indices),median(data.matrix(:,data.EEG_channel_indices)));
data.matrix = bsxfun(@minus,data.matrix,median(data.matrix));
%% convert to table
if exist('array2table','file')
    fprintf('\nCreating table array:\t');
    data.table = array2table(data.matrix,'VariableNames',data.channel_labels);
    fprintf('complete\n');
else
    msg = '''array2table'' function does not exist, therefore cannot convert data matrix to table';
    fprintf('%s\n',msg);
end