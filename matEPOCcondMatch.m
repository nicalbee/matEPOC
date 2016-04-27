function markers = matEPOCcondMatch(varargin)
global plot_data
try
    inputs.varargin = varargin;
    inputs.turnOn = {'plot'};
    inputs.turnOff = {'align_conditions'};
    inputs.defaults = struct(...
        'event_channels',[],...
        'markers',[],...
        'changes',[],...
        'conditions',[],...
        'sort_by','alphabet',... 'number_events',...
        'file_name',[],...
        'times',[], ...
        'time_units','ms',... 'sec'
        'ylim',[-20 200],...
        'Hertz',128 ...
        );
    
    mep.tmp = setGetInputsStruct(inputs);
    
    markers = mep.tmp.markers;
    
    if isempty(mep.tmp.markers)
        fprintf('''markers'' variable is empty - can''t work without this');
        return
    elseif isempty(mep.tmp.times) && isempty(mep.tmp.conditions)
        fprintf('''conditions'' and/or ''times'' variable/s empty - can''t work without these');
        return
    end
    
    if ~isempty(mep.tmp.conditions)
        if iscell(mep.tmp.conditions) && isnumeric(mep.tmp.conditions{1})
            condition_codes = unique(cell2mat(mep.tmp.conditions));
        else
            condition_codes = unique(mep.tmp.conditions);
        end
        
        if ~isnumeric(condition_codes)
            fprintf('Condition variable is non-numeric, needs to be for .mat file\n');
            condition_count = zeros(1,numel(condition_codes));
            condition_first_letters = repmat('a',1,numel(condition_codes));
            for i = 1 : numel(condition_codes)
                condition_first_letters(i) = condition_codes{i}(1);
                condition_count(i) = sum(ismember(mep.tmp.conditions,condition_codes{i}));
            end
            % reorder by most common: set this to lowest number (ie 1 for
            % standard, 2 for deviant in the auditory oddball paradigm)
            switch mep.tmp.sort_by
                case 'number_events'
                    [condition_numbers,cond_order] = sort(condition_count,'descend');
                case 'alphabet'
                    [condition_numbers,cond_order] = sort(condition_first_letters,'ascend');
            end
            mep.tmp.conditions_string = mep.tmp.conditions;
            mep.tmp.conditions_numeric = zeros(size(mep.tmp.conditions));
            for i = 1 : numel(condition_codes)
                fprintf('''%s'' condition code set to: %i (n = %i)\n',condition_codes{cond_order(i)},i,condition_numbers(i));
                mep.tmp.conditions_numeric(ismember(mep.tmp.conditions_string,condition_codes{cond_order(i)})) = i;
            end
        else
            if iscell(mep.tmp.conditions) && isnumeric(mep.tmp.conditions{1})
                mep.tmp.conditions_numeric = cell2mat(mep.tmp.conditions);
            else
                mep.tmp.conditions_numeric = mep.tmp.conditions;
            end
        end
    end
    
    %% check conditions
    % using a plot
    mep.tmp.run = 0;
    while 1
        mep.tmp.run = mep.tmp.run + 1;
        if mep.tmp.run > 1
            % should be an updated set here
            mep.tmp.markers = markers;
        end
        
        mep.okay.conditions = 0;
        mep.okay.times = 0;
        
        % adding the event channels
        if ~isempty(mep.tmp.event_channels)
            mep.tmp.data = [mep.tmp.event_channels,zeros(numel(mep.tmp.markers),1),mep.tmp.markers];
            mep.tmp.data_labels = {'Ch1','Ch2','conditions','use'};
            if ~isempty(mep.tmp.changes)
                mep.tmp.data = [mep.tmp.event_channels,zeros(numel(mep.tmp.markers),1),mep.tmp.changes,mep.tmp.markers];
                mep.tmp.data_labels = {'Ch1','Ch2','conditions','changes','use'};
            end
            
        else
            mep.tmp.data = zeros(numel(mep.tmp.markers),2);
            mep.tmp.data(:,2) = mep.tmp.markers;
            mep.tmp.data_labels = {'conditions','use'};
        end
        mep.tmp.data_rows = size(mep.tmp.data,1);
        %     mep.tmp.data = zeros(numel(mep.tmp.markers),2);
        %     mep.tmp.data(:,2) = mep.tmp.markers;
        
        mep.tmp.markers_samples = find(mep.tmp.markers ~= 0,sum(mep.tmp.markers ~= 0),'first');
        
        sampleSummary(mep.tmp.markers_samples*(1/mep.tmp.Hertz),'EPOC markers');
        
        if ~isempty(mep.tmp.times) && isnumeric(mep.tmp.times)
            mep.okay.times = 1;
            % match up for first marker and go from there
            % - assuming that the numbers are in milliseconds of some kind -
            % probably the computer clock counting up in some way
            % find the first marker time
            mep.tmp.sample_duration = 1/mep.tmp.Hertz;
            mep.tmp.first_marker_sample = find(mep.tmp.markers,1,'first');
            mep.tmp.first_marker_sec = mep.tmp.first_marker_sample*mep.tmp.sample_duration;
            
            mep.tmp.times_adjust = mep.tmp.first_marker_sec + (mep.tmp.times - mep.tmp.times(1));
            switch mep.tmp.time_units
                case {'ms','msec'}
                    mep.tmp.times_adjust = mep.tmp.times_adjust/1000;
%             mep.tmp.times_adjust = mep.tmp.first_marker_sec + (mep.tmp.times - mep.tmp.times(1))/1000;
            end
            mep.tmp.times_samples = round(mep.tmp.times_adjust/mep.tmp.sample_duration);
            sampleSummary(mep.tmp.times_samples*(1/mep.tmp.Hertz),'Condition Times')
            mep.tmp.data(mep.tmp.times_samples,ismember(mep.tmp.data_labels,'conditions')) = 10;
            
            fprintf(['\nAdded %i events from timing data (n = %i events)\n',...
                '- please note, did this by matching to the first EPOC marker.\n',...
                '  If this frist marker wasn''t recorded in the EEG, these ',...
                'won''t line up\n',...
                '- also, assumed millisecond timing of event times and this\n',...
                '  has been converted to samples with %i Hertz sampling.\n',...
                '  This is another reason that the event timing might not match perfectly\n\n'],...
                numel(mep.tmp.times_samples),numel(mep.tmp.markers_samples),mep.tmp.Hertz);
            
            if isfield(mep.tmp,'conditions_numeric') && ...
                    ~isempty(mep.tmp.conditions_numeric)
                if numel(mep.tmp.conditions_numeric) <= numel(mep.tmp.times_samples)
                    fprintf('\nAdding numeric condition values (n = %i) to the sample points\n',...
                        numel(mep.tmp.conditions_numeric));
                    mep.tmp.filt = mep.tmp.times_samples(1:numel(mep.tmp.conditions_numeric));
                    mep.tmp.data(mep.tmp.filt,ismember(mep.tmp.data_labels,'conditions')) = mep.tmp.conditions_numeric;
                    mep.okay.conditions = 1;
                else
                    fprintf('More conditions (n = %i), than event times (n = %i)\n',...
                        numel(mep.tmp.conditions_numeric),numel(mep.tmp.times_samples));
                    fprintf('\tTiming will not be used');
                    mep.okay.times = 0;
                    mep.tmp.data(:,ismember(mep.tmp.data_labels,'conditions')) = 0;
                end
            end
        elseif isfield(mep.tmp,'conditions_numeric') && ~isempty(mep.tmp.conditions_numeric)
            fprintf(['No timing information - just using numeric condition values.\n',...
                '- note, these will be lined up exactly with the EPOC events so this\n',...
                '  allows you to check the condition matching but not timing\n']);
            if numel(mep.tmp.conditions_numeric) <= numel(mep.tmp.markers_samples);
                fprintf(['\tNumber of conditions (n = %i) is less than equal to ',...
                    'the number of markers (n = %i)\n'],...
                    numel(mep.tmp.conditions_numeric),numel(mep.tmp.markers_samples));
                
                mep.tmp.data(mep.tmp.markers_samples(1:numel(mep.tmp.conditions_numeric)),ismember(mep.tmp.data_labels,'conditions')) = ...
                    mep.tmp.conditions_numeric;
                mep.okay.conditions = 1;
            else
                fprintf(['\tNumber of conditions (n = %i) is greater than ',...
                    'the number of markers (n = %i)\n\t',...
                    '- just adding to the number of markers\n'],...
                    numel(mep.tmp.conditions_numeric),numel(mep.tmp.markers_samples));
                mep.tmp.data(mep.tmp.markers_samples,ismember(mep.tmp.data_labels,'conditions')) = ...
                    mep.tmp.conditions_numeric(1:numel(mep.tmp.markers_samples));
                mep.okay.conditions = 1;
            end
        end
        if mep.okay.conditions && numel(unique(mep.tmp.conditions_numeric)) > 1
            mep.tmp.align_question = sprintf(...
                'Align n = %i external conditions with n = %i in ''use'' channel?',...
                numel(unique(mep.tmp.conditions_numeric)),...
                numel(mep.tmp.markers(unique(mep.tmp.markers ~= 0))));
            if mep.tmp.run > 1
                mep.tmp.align_question = strrep(mep.tmp.align_question,'Align','Re-align');
            end
            mep.tmp.keep = 'Yes (keep -99)';
            if sum(mep.tmp.markers == -99)
                mep.tmp.response = questdlg(mep.tmp.align_question,'Align Conditions:','Yes',mep.tmp.keep,'No','Yes');
            else
                mep.tmp.response = questdlg(mep.tmp.align_question,'Align Conditions:','Yes','No','Yes');
            end
            
            switch  mep.tmp.response
                case {'Yes',mep.tmp.keep}
                    % align the condition numbers to the marker channel
                    if numel(mep.tmp.markers_samples) >= numel(mep.tmp.conditions_numeric)
                        mep.tmp.data(mep.tmp.markers_samples(1:numel(mep.tmp.conditions_numeric)),...
                            ismember(mep.tmp.data_labels,'use')) = mep.tmp.conditions_numeric;
                    else
                        mep.tmp.data(mep.tmp.markers_samples,...
                            ismember(mep.tmp.data_labels,'use')) = ...
                            mep.tmp.conditions_numeric(1:numel(mep.tmp.markers_samples));
                    end
                    if strcmp(mep.tmp.response,mep.tmp.keep)
                        fprintf('Events marked -99 will not be replaced by condition values');
                        mep.tmp.markers_samples_99 = find(mep.tmp.markers == -99,sum(mep.tmp.markers == -99),'first');
                        mep.tmp.data(mep.tmp.markers_samples_99,...
                            ismember(mep.tmp.data_labels,'use')) = -99;
                    end
            end
        end
        if mep.okay.conditions || mep.okay.times
            if mep.tmp.plot
                matEPOCplot(mep.tmp.data,...
                    'channel_labels',mep.tmp.data_labels,...
                    'fig_name',['matEPOC Condition Matching: ',mep.tmp.file_name],...'visible',{'conditions','use'},...
                    'ylim',mep.tmp.ylim);
                if exist('plot_data','var') && isfield(plot_data,'tmp') && isfield(plot_data.tmp,'data')
                    if size(plot_data.tmp.data,1) > mep.tmp.data_rows
                        fprintf('Conditions or samples have increased the matrix size: resetting\n');
                        plot_data.tmp.data(mep.tmp.data_rows+1:end,:) = [];
                    end
                    markers = plot_data.tmp.data(:,ismember(mep.tmp.data_labels,'use'));
                end
                switch questdlg('Re-run with updated triggers or finish?','Re-plot?','Re-run','Finish','Finish')
                    case 'Finish'
                        break
                end
            end
        end
    end
catch err
    save(matEPOCdebug);rethrow(err);
end
end
%% embedded function
function sampleSummary(event_samples,event_label)
fprintf('Sample summary for %s\n',event_label);
fprintf('\tn = %i\n',numel(event_samples));
event_diff = diff(event_samples);
fprintf(['\tmean difference = %3.2f (SD = %3.2f, ',...
    'min = %3.2f, max = %3.2f)\n'],...
    mean(event_diff),std(event_diff),...
    min(event_diff),max(event_diff));
end
