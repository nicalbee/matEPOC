function [mep,okay] = matEPOCevents(in_data,varargin) % event_channels,event_threshold,pulse_length)
global plot_data
% updates:
% 31-Oct-2017 adjusted the mep.tmp.n_use variable (around line 274). It
%   seemed to be counting the wrong thing: NAB
try
    fprintf('Running %s:\n',mfilename);
    okay = 1;
    inputs.turnOn = {'plot','find_length'};
    inputs.turnOff = {'adjust'};
    inputs.varargin = varargin;
    inputs.defaults = struct(...
        'event_threshold',100,...
        'Hertz',128,...
        'pulse_length',300, ... % milliseconds
        'pulse_separation',500, ... % millseconds
        'delay',20 ... % transmission delay in milliseconds
        );
    inputs.defaults.event_channels = {'O1','O2'};
    
    %% Input check
    if isstruct(in_data)
        mep = in_data;
    else
        mep.matrix = in_data;
    end
    
    mep.tmp = setGetInputsStruct(inputs);
    
    if size(in_data,1) == 2 || size(in_data,2) == 2 % two rows or columns
        % just have two rows or columns
        
        % convert columns
        if size(in_data,1) == 2
            mep.matrix = mep.matrix'; % transpose
        end
    elseif  ~isempty(mep.tmp.event_channels) && numel(mep.tmp.event_channels) == 2 ...
            && isfield(mep,'channel_labels')
        % check if it's a cell array with string information in it
        if iscell(mep.tmp.event_channels) && ~isnumeric(mep.tmp.event_channels{1})
            fprintf('Searching for event indices:\n');
            mep.event_indices = zeros(size(mep.tmp.event_channels));
            for i = 1 : numel(mep.tmp.event_channels)
                mep.event_indices(i) = find(ismember(mep.channel_labels,mep.tmp.event_channels{i}),1,'first');
                fprintf('\tevent %i: %s = column %i\n',i,mep.tmp.event_channels{i},mep.event_indices(i));
            end
        elseif isnumeric(mep.tmp.event_channels)
            mep.event_indices = mep.tmp.event_channels;
        else
            msg = sprintf(['''event_channels'' input isn''t recognised\n',...
                'Needs to be channels names (e.g., ''O1'', ''O2'') or numbers']);
            fprintf('%s\n',msg);
            warndlg(msg,sprintf('Input error: %s',mfilename))
            return
        end
    elseif ~isfield(in_data,'channel_labels')
        msg = 'a ''mep.channel_labels'' variable is expected as part of the data structure';
        fprintf('%s\n',msg);
        warndlg(msg,sprintf('Input error: %s',mfilename));
        return
    end
    
    mep.event_channels = [];
    if size(mep.matrix,2) > 2
        mep.event_channels = mep.matrix(:,mep.event_indices);
    else
        mep.event_channels = mep.matrix;
    end
    
    %% Find the events
    %% Filter the low frequency components
    % Shift the signal's starting sample to zero
    % (subtract the 1st number from all other numbers to convert to microvolts)
    %     tmp.makers = mep.event_channels - mep.event_channels(ones(size(mep.event_channels,1),1),:);
    % Apply 1st order difference
    mep.tmp.markers = zeros(size(mep.event_channels)); % start with a bunch of zeros
    mep.tmp.markers(2:end,:) = mep.event_channels(2:end,:) - mep.event_channels(1:end-1,:);
    
    mep.tmp.marker_diff = diff(mep.tmp.markers,1,2);
    
    %% Detect the pulse
    % threshold = 100; % microvolts
    % adjusting this threshold gets the start of the ramp - increase and get
    % peak - so slightly after onset... maybe
    % Flag the samples whose amplitude exceeds the threshold
    mep.tmp.flag = abs(mep.tmp.marker_diff) >= mep.tmp.event_threshold;
    % added the absolute for Mel Hickey's data - I think it's just that the
    % wires are connected to the opposite electrodes so we should be
    % looking for negative rather than positive values - this should work
    % in both cases... NAB 2nd April 2013 in Adelaide!
    
    % the lower and upper limits doesn't work - still a few spurious things in
    % there causing problems - better to make sure the difference between
    % markers in okay
    mep.tmp.pulse = [0; diff(mep.tmp.flag)] > 0;
    mep.tmp.pulse_samples = find(mep.tmp.pulse);
    mep.tmp.pulse_diff = diff(mep.tmp.pulse_samples)*(1/mep.tmp.Hertz);
    
    mep.tmp.use = zeros(size(mep.tmp.pulse_samples));% [0; mep.tmp.pulse_diff > sprintf(];
    
    % check for length of pulse differences
    mep.tmp.pulse_diff_okay = mep.tmp.pulse_diff > (mep.tmp.pulse_separation/1000);
    % this gives us time until the next pulse
    
    mep.tmp.k = 2; % counter, start after the first one
    if numel(mep.tmp.pulse_samples)
        mep.use.pulse_length = mep.tmp.pulse_length;
        if mep.tmp.pulse_length(1) > 20% 50 % assume that it's in msec
            mep.use.pulse_length = mep.tmp.pulse_length/1000;
        end
        mep.use.pulse_separation = mep.tmp.pulse_separation;
        if mep.tmp.pulse_separation > 20
            mep.use.pulse_separation = mep.tmp.pulse_separation/1000;
        end
        
        % run from largest to smallest
        mep.tmp.pulses_sorted = sort(mep.use.pulse_length,'descend');
        
        for i = 1 : numel(mep.use.pulse_length)
            mep.tmp.event_code = find(mep.use.pulse_length == mep.tmp.pulses_sorted(i));
            % is the first marker correct?
            % first difference should be less than the pulse length
            %             if sum(mep.tmp.pulse_diff < mep.use.pulse_separation) < numel(mep.tmp.pulse_diff)*.3
            %                 for k = 1 : numel(mep.tmp.pulse_diff)
            %                     if  mep.tmp.pulse_diff(k) > (mep.use.pulse_separation - min(mep.use.pulse_length))
            %                         mep.tmp.use(k) = mep.tmp.event_code;
            %                         mep.tmp.previous_k = k;
            %                     end
            %                 end
            %                 mep.tmp.use(k+1) = mep.tmp.event_code;
            %             else % probably a bunch of double pulses
            if ~isempty(mep.tmp.pulse_diff)
%                 if ~mep.tmp.find_length
                    if mep.tmp.pulse_diff(1) < mep.tmp.pulses_sorted(i) || mep.tmp.pulse_diff(1) > mep.use.pulse_separation
                        mep.tmp.use(1) = mep.tmp.event_code;
                    else
                        % find the first difference that fits this setting
                        for k = mep.tmp.k : numel(mep.tmp.pulse_diff)
                            if mep.tmp.pulse_diff(k) < mep.tmp.pulses_sorted(i)
                                break
                            end
                        end
                        mep.tmp.k = k;
                    end
%                 end
                % if the gap between the markers is less pulse_length, should be a pair...
                % also needs to be separated from the previous marker by the pulse
                % separation
                mep.tmp.previous_k = 1;
                mep.tmp.event_count = 0;
                for k = mep.tmp.k : numel(mep.tmp.pulse_diff)+1
                    %                     if ~mep.tmp.find_length
                    if mep.tmp.pulse_diff(k-1) > (mep.use.pulse_separation - min(mep.use.pulse_length)) || ...
                            sum(mep.tmp.pulse_diff(mep.tmp.previous_k:k-1)) > (mep.use.pulse_separation)
                        %                     and(mep.tmp.pulse_diff(k) < mep.tmp.pulses_sorted(i), ...
                        %                             mep.tmp.pulse_diff(k-1) > (mep.use.pulse_separation - min(mep.use.pulse_length)))
                        
                        % mep.tmp.pulses_sorted(i)*2% d(i) > 50 && d(i) < 160
                        % if separation k is the first item in a pair &&
                        % if the previous one is fair enough away
                        if numel(mep.tmp.pulses_sorted) > 1 && k < numel(mep.tmp.pulse_diff)+1 && ...
                                mep.tmp.pulse_diff(k) < mep.tmp.pulses_sorted(i)
                            mep.tmp.use(k) = mep.tmp.event_code;
                            mep.tmp.previous_k = k;
                        elseif numel(mep.tmp.pulses_sorted) == 1
                            mep.tmp.use(k) = mep.tmp.event_code;
                            mep.tmp.previous_k = k;
                        end
                        
                        %         elseif mep.tmp.pulse_diff(k) < mep.tmp.pulses_sorted(i) && ...
                        %                 mep.tmp.pulse_diff(k-1) < (mep.use.pulse_separation - min(mep.use.pulse_length)) && ...
                        %                 sum(mep.tmp.pulse_diff(mep.tmp.previous_k:k)) > (mep.use.pulse_separation - min(mep.tmp.pulse_length))
                        %             mep.tmp.use(k) = mep.tmp.event_code;
                        %             mep.tmp.previous_k = k;
                    end
                    
                    % pre-2016-07-04
                    %                     if mep.tmp.use(k) && mep.tmp.find_length && numel(mep.tmp.pulses_sorted) > 1
                    %                         if k == numel(mep.tmp.pulse_diff)+1 || mep.tmp.pulse_diff_okay(k)  % something to sort
                    %                             assume that it's new (2016) wobbly pulses and
                    %                             we can check for the length of them and code
                    %                             appropriately
                    %                                                         if k < numel(mep.tmp.pulse_diff)+1 % not the last one
                    %                             if ~mep.tmp.event_count % first one
                    %                                 mep.tmp.previous_onset = 1;
                    %                                 mep.tmp.filt = mep.tmp.previous_onset:k-1;
                    %                             else
                    %                                 mep.tmp.previous_onset = find(mep.tmp.pulse_diff_okay(1:k-1),1,'last');
                    %                                 mep.tmp.filt = mep.tmp.previous_onset+1:k-1;
                    %                             end
                    %                                                         else % last one
                    %                             %                                 mep.tmp.previous_onset = length(mep.tmp.pulse_diff_okay);
                    %                                                         end
                    %
                    %
                    %                                                          t = 100;
                    %                                                          plot(-t:t,mep.tmp.pulse_diff(k-t:k+t));
                    %                             mep.tmp.pulse_width = sum(mep.tmp.pulse_diff(mep.tmp.filt)); % in msec
                    %                                                         fprintf('\t%i: pulse width = %3.2f (%3.2f sec, code = %i, n = %i)\n',...
                    %                                                                 k,mep.tmp.pulse_width,mep.tmp.pulses_sorted(i),mep.tmp.event_code,mep.tmp.event_count +1);
                    %                             if mep.tmp.pulse_width < mep.tmp.pulses_sorted(i) && mep.tmp.pulse_width > min(mep.tmp.pulses_sorted)*.75
                    %
                    %                                                                 mep.tmp.use(mep.tmp.previous_onset) = mep.tmp.event_code;
                    %                                 if ~mep.tmp.event_count
                    %                                     mep.tmp.use(mep.tmp.previous_onset) = mep.tmp.event_code;
                    %                                     mep.tmp.event_count = mep.tmp.event_count + 1;
                    %                                 end
                    %                                 mep.tmp.previous_k = k;
                    %                                  mep.tmp.use(k-1) = mep.tmp.event_code;
                    %                                 mep.tmp.event_count = mep.tmp.event_count + 1;
                    %
                    %                                 fprintf('\t using k = %i: pulse width = %3.3f (%3.2f sec, code = %i, n = %i)\n',...
                    %                                     k,mep.tmp.pulse_width,mep.tmp.pulses_sorted(i),mep.tmp.event_code,mep.tmp.event_count);
                    %
                    %                             end
                    %                         end
                    %                     end
                    
                end
                
                
                % vertically concatenating the 0 to the diff array (d)
                % fixes this too.
                %                 % losing the last marker
                %                 if mep.tmp.pulse_diff(end-1) > mep.tmp.pulses_sorted(i) && ...
                %                         mep.tmp.pulse_diff(end-1) < (mep.use.pulse_separation - min(mep.use.pulse_length)) %mep.tmp.pulses_sorted(i)*2
                %                     % minus the minimum separation here but it's looking at the changes
                %                     % to pairs and we have to take into the second item of the pair,
                %                     % and ignore it
                %                     mep.tmp.use(end-1) = mep.tmp.event_code;
                %                 end
                % the above works for pairs...
                %     if sum(mep.tmp.pulse_diff > mep.use.pulse_separation) > numel(mep.tmp.pulse_diff)*.5
                %         % if the pulses aren't in pairs
                %         mep.tmp.use(end-1) = mep.tmp.event_code;
                %     end
                %             end
            end
        end
        
        %         if mep.tmp.find_length && numel(mep.tmp.pulses_sorted) > 1
        % %             h = figure;
        %             mep.tmp.use_samples = find(mep.tmp.use ~= 0);
        %             mep.tmp.use_alt = mep.tmp.use;
        %             % look at all the events for their width/length
        %             for i = 1 : numel(mep.use.pulse_length)
        %                 mep.tmp.event_code = find(mep.use.pulse_length == mep.tmp.pulses_sorted(i));
        %                 for k = 1 : numel(mep.tmp.use_samples)
        %                     if k < numel(mep.tmp.use_samples)
        %                         mep.tmp.filt = mep.tmp.use_samples(k):mep.tmp.use_samples(k+1)-2;
        %                     else
        %                         mep.tmp.filt = mep.tmp.use_samples(k):numel(mep.tmp.use_samples);
        %                     end
        %                     mep.tmp.pulse_width(k) = sum(mep.tmp.pulse_diff(mep.tmp.filt));
        %                     if mep.tmp.pulse_width(k) < mep.tmp.pulses_sorted(i)
        %                         mep.tmp.use_alt(mep.tmp.use_samples(k)) = mep.tmp.event_code;
        %                     end
        %                     mep.tmp.filt = mep.tmp.use_samples(k)-2:mep.tmp.use_samples(k+1)+50;
        % %                     plot(mep.tmp.pulse_diff(mep.tmp.filt));
        % %                     pause
        %                 end
        %             end
        %         end
        if ~isempty(mep.tmp.pulse_diff)
            mep.tmp.pulse_use = zeros(size(mep.tmp.flag));
            %             if exist('marker_width','var') && ~isempty(marker_width)
            %                 mep.tmp.pulse_use(marker_index) = marker_value;
            %             else
            mep.tmp.pulse_use(mep.tmp.pulse_samples(logical(mep.tmp.use))) = mep.tmp.use(find(mep.tmp.use,sum(logical(mep.tmp.use)),'first'));
            %             end
            mep.tmp.n = sum(mep.tmp.pulse);
%             mep.tmp.n_use = sum(mep.tmp.pulse_use); % 31-Oct-2017 NAB -
%             doesn't work in the loop below...
            mep.tmp.p = find(mep.tmp.pulse_use);
            mep.tmp.n_use = numel(mep.tmp.p);
            
            % I think the code to this point does a good job at picking up
            % the start of the events - now really just need to determine
            % the width.
            if mep.tmp.find_length && numel(mep.tmp.pulses_sorted) > 1
                % Johnson's code
                x = smooth(abs(mep.tmp.markers(:,1)));
                fs = mep.tmp.Hertz; %128;
                t = (0:length(x)-1)'/fs;
                
                baseline = median(x(1:fs,1));
                %                         figure(1), clf
                %                         plot(t, x-baseline, '.-');
                % Set the thresholds for transition to the pulse and return to baseline
                threshold = [mep.tmp.event_threshold*.3 baseline]; %[-120 0];
                
                marker_width = zeros(size(mep.tmp.n_use));
                found_marker = 0;
%                 n = 1;
                for i = 1 : mep.tmp.n_use
                    j = -1;
                    while j < numel(x)
                        j = j + 1; % work along from the n_use point
                        if ~found_marker && x(mep.tmp.p(i)+j) > baseline+threshold(1)
                            onset = j;
                            found_marker = 1;
                        end
                        if found_marker && mean(x(mep.tmp.p(i)+j-1:mep.tmp.p(i)+j)) < baseline+threshold(2)
                            marker_width(i) = (j - onset)/fs;%*1000; % msec
                            %                             marker_code(i) = find(mep.use.pulse_length > marker_width(i),1,'first');
                            for jj = 1 : numel(mep.tmp.pulses_sorted)
                                mep.tmp.event_code = find(mep.use.pulse_length == mep.tmp.pulses_sorted(jj));
                                if marker_width(i) < mep.tmp.pulses_sorted(jj)
                                    mep.tmp.pulse_use(mep.tmp.p(i)) = mep.tmp.event_code;
                                end
                                %     mep.tmp.pulse_use(mep.tmp.n(i)) = find(marker_width(i) < mep.tmp.pulses_sorted(jj),1,'first');
                            end
                            found_marker = 0;
                            break
                        end
                    end
%                     if (found_marker == 0) && (x(mep.tmp.n_use(i)) > (baseline+threshold(1)))
%                         found_marker = 1;
%                         marker_index(n) = i;
%                     end
%                     if (found_marker == 1) && numel(x) > i+5 && (mean(x(i:i+5)) < (baseline+threshold(2)))
%                         found_marker = 0;
%                         marker_width(n) = i - marker_index(n);
%                         n = n+1;
%                     end
                end
               mep.tmp.marker_width = marker_width;
                % looping through all the points
%                 for i = 1:length(x)
%                     if (found_marker == 0) && (x(i) > (baseline+threshold(1)))
%                         found_marker = 1;
%                         marker_index(n) = i;
%                     end
%                     if (found_marker == 1) && numel(x) > i+5 && (mean(x(i:i+5)) < (baseline+threshold(2)))
%                         found_marker = 0;
%                         marker_width(n) = i - marker_index(n);
%                         n = n+1;
%                     end
%                 end
%                 marker_index = marker_index(1:(n-1));
%                 marker_value = zeros(size(marker_index));
%                 marker_time = t(marker_index);
%                 marker_width = marker_width(1:(n-1))/fs*1000;
%                 for i = 1 : numel(mep.use.pulse_length)
%                     mep.tmp.event_code = find(mep.use.pulse_length == mep.tmp.pulses_sorted(i));
%                     for j = 1 : numel(marker_width)
%                         if marker_width(j) < mep.tmp.pulses_sorted(i)*1000
%                             marker_value(j) = mep.tmp.event_code;
%                         end
%                     end
%                 end
                %             mep.tmp.pulse_diff = 1;
            end
            
            
            %% plot
            mep.tmp.data = [mep.event_channels,mep.tmp.marker_diff,mep.tmp.pulse*100,mep.tmp.pulse_use];
            mep.tmp.data_labels = {'Ch1','Ch2','difference','changes','use'};
            
            mep.tmp.fig_name = 'event plot';
            if isfield(mep,'filename')
                mep.tmp.fig_name = mep.filename;
            end
            if mep.tmp.plot
                matEPOCplot(mep.tmp.data,'channel_labels',mep.tmp.data_labels,...
                    'fig_name',mep.tmp.fig_name);
                % check for any adjustments made
                if exist('plot_data','var') && isfield(plot_data,'tmp') && isfield(plot_data.tmp,'data')
                    mep.tmp.pulse_use = plot_data.tmp.data(:,ismember(mep.tmp.data_labels,'use'));
                end
            end
            
            %% set data
            mep.markers = mep.tmp.pulse_use;
            mep.changes = mep.tmp.pulse*100;
            
            %% report
            fprintf('Finished running %s:\n',mfilename);
            fprintf(['\nFor a threshold of %i, pulse length/s of ',...
                matEPOCvariableType(mep.tmp.pulse_length),', and a pulse ',...
                'separation of ',matEPOCvariableType(mep.tmp.pulse_separation),':\n'],...
                mep.tmp.event_threshold,mep.tmp.pulse_length,mep.tmp.pulse_separation);
            fprintf('\t%i changes found\n',sum(mep.changes ~= 0));
            fprintf('\t%i event markers placed\n\n',sum(mep.markers ~= 0));
            mep.tmp.marker_count = zeros(numel(mep.tmp.pulse_length),2);
            if numel(unique(mep.markers)) > 1
                for i = 1 : numel(mep.tmp.pulse_length)
                    mep.tmp.marker_count(i,:) = [mep.tmp.pulse_length(i) sum(mep.markers == i)];
                    fprintf('\t\t%i @ %i milliseconds in length\n',...
                        mep.tmp.marker_count(i,2),...
                        mep.tmp.pulse_length(i));
                end
            end
        else
            
            okay = 0;
        end
        
    else
        okay = 0;
    end
    if ~okay
        mep.tmp.warn = 'There are no events in these event channels.';
        fprintf('%s\n',mep.tmp.warn);
        warndlg(mep.tmp.warn,sprintf('No events: %s',mfilename));
    end
    % %% adjust event
    % % not sure whether to keep this function in the events function or not
    % if mep.tmp.adjust
    %     mep.tmp.data = [mep.event_channels,mep.markers];
    %     mep.tmp.data_labels = {'Ch1','Ch2','events'};
    %     mep.markers = matEPOCeventAdjust(mep.tmp.data,'channel_labels',mep.tmp.data_labels,...
    %         'Hertz',mep.tmp.Hertz,'delay',20);
    % end
catch err
    save(matEPOCdebug);rethrow(err);
end