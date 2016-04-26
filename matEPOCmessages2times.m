function out = matEPOCmessages2times(message_fullfile)

if ~exist('message_fullfile','var') || isempty(message_fullfile)
    message_fullfile = '/Users/mq20111600/Google Drive/nWorkProjects/emotiv_context/data/raw/p2/p2_m_23_r_up/messages.txt';
end
dat = readtable(message_fullfile,'ReadVariableNames',0,'Delimiter',' ');
data.stim_times = [];
data.cond_code = [];
data.condition = [];
data.resp_times = [];
data.resp_text = [];
data.resp_code = []; % not sure about this

data.k = [0 0]; % condition & response
for i = 1 : size(dat,1)
    [tmp.ttl,tmp.code] = strtok(dat.Var1{i});
    tmp.ttl = str2double(tmp.ttl);
    tmp.code(isspace(tmp.code)) = [];
    tmp.code = str2double(tmp.code);    
            if ~isempty(strfind(dat.Var2{i},'_'))
                % condition
                data.k(1) = data.k(1) + 1;
                data.stim_times(data.k(1)) = tmp.ttl;
                data.cond_code(data.k(1)) = tmp.code;
                data.condition{data.k(1)} = dat.Var2{i};
            else
                % response
                data.k(2) = data.k(2) + 1;
                data.resp_times(data.k(2)) = tmp.ttl;
                data.resp_code(data.k(2)) = tmp.code;
                data.resp_text{data.k(2)} = dat.Var2{i};
            end        
end
out.conditions = data.condition;
out.times = data.stim_times;