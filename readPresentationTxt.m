function out = readPresentationTxt(pres_file,condition_header,time_header)

if exist('condition_header','var') && ...
        ~isempty(condition_header) && ~iscell(condition_header)
    condition_headers{1} = condition_header;
else
    condition_headers = {'Code','new_code'};
end

if exist('time_header','var') && ...
        ~isempty(time_header) && ~iscell(time_header)
    time_headers{1} = time_header;
else
    time_headers = {'Time','time1'};
end


out = [];
if exist(pres_file,'file')
    fprintf('Reading %s:\n',pres_file);
    try
        pres = readtable(pres_file,'delimiter','\t');
    catch
        pres = importdata(pres_file,'\t',1);
    end
    
    if istable(pres)
        var4 = find(ismember(pres.Properties.VariableNames,'Var4'));
        tmp_names = pres.Properties.VariableNames;
        if ~isempty(var4)
            for i = var4+1 : numel(pres.Properties.VariableNames)
                tmp_names{i-1} = pres.Properties.VariableNames{i};
            end
            tmp_names{end} = 'RT';
            pres.Properties.VariableNames = tmp_names;
        end
        out.condition = [];
        for i = 1 : numel(condition_headers)
            if sum(ismember(tmp_names,condition_headers{i}))
                out.condition = table2cell(pres(:,ismember(tmp_names,condition_headers{i})));
                break
            end
        end
        out.times = [];
        for i = 1 : numel(time_headers)
            if sum(ismember(tmp_names,time_headers{i}))
                out.times = table2array(pres(:,ismember(tmp_names,time_headers{i})));
                break
            end
        end
    else
        % NAB 4-Apr-2016 for original/2012 Emotiv vs Neuroscan data files -
        % table read isn't working for some reason...
        out.condition = pres.textdata(2:end,3);
        out.times = pres.data(1:end,1);
    end
    if isempty(out.condition) || isempty(out.times)
        out.warn = 'Problem finding condition or time column in condition file';
        fprintf('%s\n',out.warn);
        warndlg(out.warn,'Condition file issue:');
    end
    
    % original
%     pres_data = importdata(pres_file);
%     trial_type = zeros(size(pres_data.textdata,1)-1,1);
%     trial_text = evn.set.cond_names; %{'standard','deviant'};
%     %     trial_text = unique(pres_data.textdata(2:end,3));
%     j = 1;
%     while j < size(pres_data.textdata,1) && ~isempty(pres_data.textdata{j+1,3})
%         %         for j = 2 : size(pres_data.textdata,1)
%         j = j + 1;
%         trial_type(j-1) = find(strcmp(trial_text,pres_data.textdata{j,3}));
%     end
else
    tmp.warn = sprintf('File not found: can''t import: %s',pres_file);
    fprintf('%s\n',tmp.warn);
    warndlg(tmp.warn,sprintf('%s import error:',mfilename));
end