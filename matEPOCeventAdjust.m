function out_events = matEPOCeventAdjust(in_data,varargin)
try
    inputs.turnOn = {'plot','plot_all'};
    inputs.varargin = varargin;
    inputs.defaults = struct(...
        'fig_name','matEPOC event onset plot',...
        'plot_range',[-200 200],...
        'Hertz',128,...
        'delay',20 ... % delay in ms due to transmission
        );
    
    inputs.defaults.channel_labels = {'Ch1','Ch2','events'};
    
    mep.tmp = setGetInputsStruct(inputs);
    if ~exist('in_data','var') || isempty(in_data) || ~ismatrix(in_data) || size(in_data,2) ~= 3
        mep.tmp.err = sprintf('Problem with the inputted data: aborting (%s)',mfilename);
        fprintf('%s\n',mep.tmp.err);
        warndlg(mep.tmp.err,'Incorrect data type:');
        return;
    end
    mep.data = in_data;
    out_events = in_data(:,3);
    
    mep.event_samples = find(mep.data(:,end) ~= 0);
    mep.n_events = numel(mep.event_samples);
    mep.n_ch = 2; % number of channels
    mep.x_range = 25; % samples for checking channel patterns
    
    
    % not sure about this
    mep.fig.xdata = 0:(1/mep.tmp.Hertz):(size(in_data,1)-1)*(1/mep.tmp.Hertz);
    
    % make sure the first channel/column is the upward going trigger
    if max(mep.data(:,1)) < max(mep.data(:,2))
        mep.tmp.data = mep.data;
        mep.data(:,1) = mep.tmp.data(:,2);
        mep.data(:,2) = mep.tmp.data(:,1);
    end
    
    mep.tmp.data = [];
    for i = 1 : mep.n_events;
        % select a period of data surrounding the trigger to determine when the
        % onset actually is
        mep.tmp.filt_points = mep.event_samples(i) + [-1 1] * mep.x_range;
        mep.tmp.data(:,:,i) = mep.data(mep.tmp.filt_points(1):mep.tmp.filt_points(2),1:2);
        
%         plot(mep.tmp.data(:,1,i),'b');
%         plot(mep.tmp.data(:,2,i),'r');
%         if i == 1; hold; end
    end
    
    % previous (evn scripts pre Aug-2015) adjustments - looking for 'M' & 'W' shapes
    % pre.pos_pre_trig = floor(mean(pre.pre_trig)); % okay but late ~20 msec
    % pre.pos_mid_shape = floor(mean(pre.mid_shape)); % most similar to neuroscan
    % pre.pos_shape_onset = floor(mean(pre.start_shape))-1; % this doesn't seem useful ~40 early
    %
    % pre.pos_mid_shape_wireless =  pre.pos_mid_shape-3; % remove 3 sample delay due to wireless trigger system
    
    % might need some kind of baseline correction
%     mep.tmp.base = bsxfun(@minus,mep.tmp.data,mep.tmp.data(1,:,:));
    
    % what about if we just look at the means, rather than each individual
    % trigger?
    mep.tmp.data_mean = mean(mep.tmp.data,3);
    
    
    % should be a flat period and then the trigger starts
    % multiply 100 so that the zero point doesn't mess up the
    % calculations
    mep.tmp.data_diff = diff(mep.tmp.data_mean+100);
    mep.tmp.onset = mep.x_range;
    mep.okay.onset = 0;
    mep.okay.apart = 0;
    mep.okay.mid = 0;
    for i = 1 : mep.x_range
        if ~mep.okay.onset && mean(abs(mep.tmp.data_diff(i,:))) > 1
            mep.tmp.onset = i-1; % sample before = nothing
            mep.okay.onset = 1;
        end
        if mep.okay.onset && ~mep.okay.apart && mean(abs(mep.tmp.data_diff(i,:))) > mean(abs(mep.tmp.data_diff(i+1,:)))
            mep.tmp.apart = i; % a maximum
            mep.okay.apart = 1;
        end
        if mep.okay.onset && mep.okay.apart && ~mep.okay.mid && mean(abs(mep.tmp.data_diff(i,:))) < mean(abs(mep.tmp.data_diff(i+1,:)))
            mep.tmp.mid = i; % mid-shape
            mep.okay.mid = 1;
        end
    end
    
    % check the differences at the trigger points, it's it big, adjust the
    % adjusted trigger to be one sample earlier
    mep.trig_diff = sum(abs(mep.data(mep.data(:,3)~=0,1:2)),2);
    
    % adjust by samples when the separation between the triggers is larger,
    % scaling (e.g., > 200, >150) may be useful
    mep.tmp.points = {'onset','apart','mid'};
    mep.tmp.point_colours = {'c','r','k'};
    for i = 1 : numel(mep.tmp.points)
        if isfield(mep.tmp,mep.tmp.points{i})
        mep.tmp.([mep.tmp.points{i},'s']) = ones(mep.n_events,1)*mep.tmp.(mep.tmp.points{i});
        mep.tmp.([mep.tmp.points{i},'s'])(mep.trig_diff < 100) = mep.tmp.(mep.tmp.points{i})+1;
        mep.tmp.([mep.tmp.points{i},'s'])(mep.trig_diff > 200) = mep.tmp.(mep.tmp.points{i})-2;
        mep.tmp.([mep.tmp.points{i},'s'])(mep.trig_diff > 150) = mep.tmp.(mep.tmp.points{i})-1;
        else
            fprintf('''%s'' summary missing\n',mep.tmp.points{i});
        end
    end
    
    
    if mep.tmp.plot
        h = figure('name',mep.tmp.fig_name);
        plot(-mep.x_range:mep.x_range,mep.tmp.data_mean); hold;
        plot([0 0],mep.tmp.plot_range,'m');
        
        for i = 1 : numel(mep.tmp.points)
            
            tn = mep.tmp.points{i};
            tc = mep.tmp.point_colours{i};
            if isfield(mep.tmp,tn)
            plot(-mep.x_range+mep.tmp.(tn)+ones(1,2),[-200 200],tc);
            plot(-mep.x_range+mean(mep.tmp.([tn,'s']))+ones(1,2),[-200 200],[tc,'--']);
            end
        end
        uiwait(h);
    end
    if mep.tmp.plot_all
        h = figure('name',mep.tmp.fig_name);
        for i = 1 : mep.n_events;
            plot(-mep.x_range:mep.x_range,mep.tmp.data(:,:,i)); hold;
            title(sprintf('Event %u of %u',i,mep.n_events));
            plot([0 0],mep.tmp.plot_range,'m');
            ylims = get(gca,'YLim');
            %     plot(-mep.x_range+mep.tmp.onsets(i)+ones(1,2),mep.tmp.plot_range,'c');
            for j = 1 : 2 : numel(mep.tmp.points)
                tn = mep.tmp.points{j};
                tc = mep.tmp.point_colours{j};
                plot(-mep.x_range+mep.tmp.(tn)+ones(1,2),ylims,tc);
                %             plot(-mep.x_range+mep.tmp.([tn,'s'])(i)+ones(1,2),ylims,[tc,'--']);
            end
            pause;
            hold;
        end
        uiwait(h);
    end
    
    %% >  adjust for onset and transmission delay
    mep.tmp.delay_samples = ceil((mep.tmp.delay/1000)/(1/mep.tmp.Hertz));
    out_samples = find(out_events,sum(out_events ~= 0),'first');
    out_values = out_events(out_samples);
    % make the samples earlier
    out_events = zeros(size(out_events));
    if isfield(mep.tmp,'mid') && ~isempty(mep.tmp.mid)
        out_events(out_samples + (-mep.x_range+mep.tmp.mid) - mep.tmp.delay_samples) = out_values;
    else
        fprintf('Serious issue finding event markers: couldn''t identify the pulses\n');
    end
catch err
    save(matEPOCdebug);rethrow(err);
end
end