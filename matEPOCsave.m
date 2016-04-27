
% edits:
%   27-Apr-2016: added load printout to command window

function matEPOCsave(in_data,varargin)

inputs.varargin = varargin;
inputs.turnOn = {'noconfirm'};
inputs.defaults = struct(...
    'dir',[fileparts(which('matEPOCversion')),'Data'],...
    'file_name','matEPOCoutput',...
    'type','mat',... % csv, txt
    'delim','\t' ... % comma if type set to csv
    );
% save EEG channels only
inputs.defaults.channels = {...
    'AF3','F7','F3','FC5','T7','P7','O1',...
    'O2','P8','T8','FC6','F4','F8','AF4'};
% all channels: EPOC original
inputs.defaults.column_labels = {'COUNTER','INTERPOLATED',...
    'AF3','F7','F3','FC5','T7','P7','O1',...
    'O2','P8','T8','FC6','F4','F8','AF4',...
    'RAW_CQ',...
    'CQ_AF3','CQ_F7','CQ_F3','CQ_FC5','CQ_T7','CQ_P7','CQ_O1',...
    'CQ_O2','CQ_P8','CQ_T8','CQ_FC6','CQ_F4','CQ_F8','CQ_AF4',...
    'CQ_CMS','CQ_DRL','GYROX','GYROY','MARKER'};

% check inputs
sav.tmp = setGetInputsStruct(inputs);


sav.data = [];
if isstruct(in_data) && isfield(in_data,'matrix')
    sav.data = in_data.matrix;
elseif ismatrix(in_data)
    sav.data = in_data;
    
end

%% check save information
if isempty(sav.tmp.dir)
    sav.tmp.dir = pwd;
end
if ~exist(sav.tmp.dir,'dir');
    mkdir(sav.tmp.dir);
end
if isempty(sav.tmp.file_name)
    sav.tmp.file_name = sav.tmp.setGet.defaults.file_name;
end
sav.file_name = sav.tmp.file_name;
[~,~,ext] = fileparts(sav.file_name);
% if using the EPOC output names, fileparts will find a .something so need
% to make sure the extension has .mat in it.
if isempty(ext) || ~strcmp(ext,sav.tmp.type)
    sav.file_name = sprintf('%s.%s',sav.file_name,sav.tmp.type);
end
sav.fullfile = fullfile(sav.tmp.dir,sav.file_name);

sav.tmp.confirm_choice = 'Yes';
if ~sav.tmp.noconfirm
    sav.tmp.confirm_choice = questdlg(...
        sprintf('Save data to: %s?\n (dir: %s)',sav.file_name,sav.tmp.dir),...
        'Save matEPOC data file:',...
        'Yes','No','Yes');
end

if strcmp(sav.tmp.confirm_choice,'Yes')
    %% set the data
    matEPOC = sav.data; % by default, dump everything
    if ~isempty(sav.tmp.column_labels) && ~isempty(sav.tmp.channels)
        sav.columns = zeros(size(sav.tmp.channels));
        for i = 1 : numel(sav.tmp.channels)
            sav.columns(i) = find(ismember(sav.tmp.column_labels,sav.tmp.channels{i}),1,'first');
        end
        matEPOC = sav.data(:,sav.columns);
    end
    if isstruct(in_data) && isfield(in_data,'markers')
        if size(matEPOC,1) == numel(in_data.markers)
            matEPOC(:,end+1) = in_data.markers;
        else
            sav.tmp.warn = sprintf(...
                ['Event channel has different number of elements ',...
                'to channel data: %u vs %u. Saved data will not ',...
                'have event channel.'],numel(in_data.markers),size(sav.out_data,1));
            fprintf('%s\n',sav.tmp.warn);
            warndlg(sav.tmp.warn,'Element dimension mismatch:');
        end
    end
    fprintf('Attempting to write data to ''%s'' file: %s\n',sav.tmp.type,sav.fullfile);
    
    switch sav.tmp.type
        case 'mat'
            save(sav.fullfile,'matEPOC');
            fprintf('Done\n\tData written to ''%s'' file (EEGLAB):\n\t- file = %s\n\t- dir = %s\n',...
                sav.tmp.type,sav.file_name,sav.tmp.dir);
             fprintf('Import note:\n\tLoad with:\n\tload(''%s'')\n\n',sav.fullfile);
        case {'csv','txt'}
            fprintf('\t... this can take a little while...\n\n');
            if strcmp(sav.tmp.type,'csv')
                sav.tmp.delim = ',';
            end
            sav.tmp.fid = fopen(sav.fullfile,'w');
            sav.tmp.use_delim = sav.tmp.delim;
            for i = 1 : size(matEPOC,2)
                if i <= numel(sav.tmp.channels)
                    sav.tmp.label = sav.tmp.channels{i};
                elseif i == size(matEPOC,2)
                    % assume event channel
                    sav.tmp.label = 'markers';
                else
                    sav.tmp.label = sprintf('unknown%i',i);
                end
                if i == size(matEPOC,2)
                    sav.tmp.use_delim = '\n';
                end
                fprintf(sav.tmp.fid,['%s',sav.tmp.use_delim],sav.tmp.label);
            end
            fclose(sav.tmp.fid);
            dlmwrite(sav.fullfile,matEPOC,'delimiter',sav.tmp.delim,'-append');
            fprintf('Done\n\tData written to ''%s'' file:\n\t- file = %s\n\tdir = %s\n',...
                sav.tmp.type,sav.file_name,sav.tmp.dir);
            
        otherwise
            if ~isnumeric(sav.tmp.type)
                sav.tmp.err = sprintf('Inputted type variable (%s), not recognised',sav.tmp.type);
            else
                sav.tmp.err = sprintf('Inputted type variable must be a string');
            end
            fprintf('%s\n',sav.tmp.err);
            warndlg(sav.tmp.err,'Incorrect save file type:');
    end
end