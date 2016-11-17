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
if ~exist('pres_file','var') || isempty(pres_file)
    [file_name_only,file_dir] = uigetfile('*.*');
    pres_file = fullfile(file_dir,file_name_only);
end
if exist(pres_file,'file')
    fprintf('Reading %s:\n',pres_file);
    try
        pres = readtable(pres_file,'delimiter','\t');
    catch
        pres = importdata(pres_file,'\t',1);
    end
    
    if exist('istable','file') && istable(pres)
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
        pres.headers =  [];
        for i = 1 : size(pres.textdata,2);
            pres.headers{i} = pres.textdata{1,i};
        end
        
%          pres.condition_column = 0;
%        
%         if ~iscell(condition_header) 
%             tmp_cond{1} = condition_header;
%         else % && numel(condition_header) > 1 
%             tmp_cond = condition_header;
%         end
%         for i = 1 : numel(tmp_cond)
%             for j = 1 : numel(pres.headers)
%             if strcmp(tmp_cond{i},pres.headers{j})
%                 pres.condition_column = j;
%                 break
%             end
%             end
%         end
%         
%         if pres.condition_column
%             out.condition = pres.textdata(2:end,pres.condition_column);
%             if isempty(out.condition{2})
%                 % find where the text data becomes empty
%                 tmp_empty = 0;
%                 for i = 1 : numel(pres.headers)
%                     if isempty(pres.textdata{2,i})
%                         tmp_empty = i;
%                         break
%                     end
%                 end
%                 pres.cond_data_column = 1 + tmp_empty - pres.condition_column;
%                 out.condition = pres.data(1:end,pres.cond_data_column);
%             end
%         end
        tmp_search = {'condition','time'};
        for k = 1 : numel(tmp_search);
        tmp_column = 0;
       eval(sprintf('tmp_headers = %s_header;',tmp_search{k}));
        if ~iscell(condition_header) 
            tmp_find{1} = tmp_headers;
        else % && numel(tmp_headers) > 1 
            tmp_find = tmp_headers;
        end
        for i = 1 : numel(tmp_find)
            for j = 1 : numel(pres.headers)
            if strcmp(tmp_find{i},pres.headers{j})
                tmp_column = j;
                break
            end
            end
        end
        
        if tmp_column
            out.(tmp_search{k}) = pres.textdata(2:end,tmp_column);
            if isempty(out.(tmp_search{k}){2})
                % find where the text data becomes empty
                tmp_empty = 0;
                for i = 1 : numel(pres.headers)
                    if isempty(pres.textdata{2,i})
                        tmp_empty = i;
                        break
                    end
                end
                tmp_data_column = 1 + tmp_column - tmp_empty;
                out.(tmp_search{k}) = pres.data(1:end,tmp_data_column);
            end
        end
        end
%         out.times = pres.data(1:end,1);
out.times = out.time;
        
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