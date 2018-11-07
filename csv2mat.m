%% converts TestBench CSV file to matEPOC data matrix
%
% use:
%
% [data_matrix,data.channel_labels,data_table] = csv2mat(file_name,data_Hertz,remove_constant)
%
% where:
%
% INPUTS:
%
% file_name = csv file to be converted, file name on the MATLAB path or
%   full path to file name
%
% data_Hertz = sampling rate of the data recording: EPOC = 128, EPOC+ = 256
%
% remove_constant = 1 or 0 to switch between removing the median of each
%   channel from itself. Correcting for overall units of measurement - 4000
%   or so directly from TestBench. Default = 1.
%
% OUTPUT: structured variable
%
% data.matrix = data matrix from edf file
%
% data.channel_labels = column labels of the data matrix
%
% data.table = table variable of matrix and channel_labels
%
% date created: 20-Mar-2018
% author: Nic Badcock
%
% updates:


function data = csv2mat(file_name,data_Hertz,remove_constant)

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
if ~exist('remove_constant','var') || isempty(remove_constant)
    remove_constant = 1;
end
data.Hertz = data_Hertz; % put it in the structure
%% report what's happening:
fprintf('Running: %s\n',mfilename)
fprintf('\nImporting: %s\n',file_name)
fprintf('\tRecorded at %i Hertz (default = %i)',data_Hertz,default_on);
fprintf('\nThis will take a little while:\n\t');

%% importing
data.import = importdata(file_name);%,1,',');
if isfield(data.import,'data')
    data.matrix = data.import.data;
else
    data.warn = ['Problem importing file - I''m not sure what the ',...
        'problem is, but send me an email and I''ll see if I can figue it out.'];
    fprintf('%s\n',data.warn);
    warndlg(data.warn,'Import issue:');
    return
end
data.fid = fopen(file_name,'r');
data.headers = fgetl(data.fid);
fclose(data.fid);
tmp.header = data.headers;
while 1
    [tmp.head,tmp.header] = strtok(tmp.header,',');
    if isempty(tmp.head)
        break
    end
    [tmp.name,tmp.value] = strtok(tmp.head,':');
    tmp.name = strrep(tmp.name,' ','');
    data.(tmp.name) = strrep(tmp.value,':','');
    switch tmp.name
        case 'labels'
            tmp.columns = size(data.matrix,2);
            tmp.data = textscan(data.(tmp.name),repmat('%s',1,tmp.columns),'delimiter',' ');
            data.channel_labels = cell(1,tmp.columns);
            for i = 1 : tmp.columns
                data.channel_labels{i} = tmp.data{i}{1};
            end
        case 'sampling'
            data.(tmp.name) = str2double(data.(tmp.name));
            if data.Hertz ~= data.(tmp.name)
                data.([tmp.name,'_warn']) = sprintf(['!!! Inputted (or default) ',...
                    'sampling rate (%i) is different to that found in file (%s). ',...
                    'Please check'],data.Hertz,data.(tmp.name));
                fprintf('%s\n',data.([tmp.name,'_warn']));
                warndlg(data.([tmp.name,'_warn']),'Check sampling rate:');
            end
    end
end


% data.matrix = [];
% while 1
%     tmp_line = fgetl(data.fid);
%     if ~isempty(tmp_line)
%         data.matrix(end+1,:) =
%     else
%         break
%     end
% end
% data.matrix = csvread(file_name,); %,'delimiter',',');
fprintf('\nFinished importing %s\n',file_name);
fprintf('\tImported %i samples for %i columns/variables\n',size(data.matrix));
data.seconds = size(data.matrix,1)*(1/data.Hertz);
fprintf('\tCorresponds to about %3.2f seconds, %3.2f minutes\n',data.seconds,data.seconds/60);

%% subtract constant
data.EEG_channels = {'AF3','F7','F3','FC5','T7','P7','O1','O2','P8','T8','FC6','F4','F8','AF4'};
data.EEG_channel_indices = zeros(1,numel(data.EEG_channels));
for i = 1 : numel(data.EEG_channels)
    data.EEG_channel_indices(i) = find(ismember(data.channel_labels,data.EEG_channels{i}),1,'first');
end
% changed to median as had some poor results 12-Sep-2015 NAB
% data.matrix(:,data.EEG_channel_indices) = bsxfun(@minus,median(data.matrix(:,data.EEG_channel_indices)),data.matrix(:,data.EEG_channel_indices));
% data.matrix(:,data.EEG_channel_indices) = bsxfun(@minus,data.matrix(:,data.EEG_channel_indices),median(data.matrix(:,data.EEG_channel_indices)));
if remove_constant
    data.matrix(:,data.EEG_channel_indices) = bsxfun(@minus,data.matrix(:,data.EEG_channel_indices),median(data.matrix(:,data.EEG_channel_indices)));
end
%% convert to table
if exist('array2table','file')
    fprintf('\nCreating table array:\t');
    data.table = array2table(data.matrix,'VariableNames',data.channel_labels);
    fprintf('complete\n');
else
    msg = '''array2table'' function does not exist, therefore cannot convert data matrix to table';
    fprintf('%s\n',msg);
end
