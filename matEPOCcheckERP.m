function out_events = matEPOCcheckERP(in_data,varargin)
try
    inputs.turnOn = {'plot','plot_all'};
    inputs.varargin = varargin;
    inputs.defaults = struct(...
        'fig_name','matEPOC ERP check',...
        'epoch',[-100 500],...
        'Hertz',128 ...
        );
    
    inputs.defaults.channel_labels = {'data'};
    
    mep.tmp = setGetInputsStruct(inputs);
    if ~exist('in_data','var') || isempty(in_data) || ~ismatrix(in_data) || size(in_data,2) < 2
        mep.tmp.err = sprintf('Problem with the inputted data: aborting (%s)',mfilename);
        fprintf('%s\n',mep.tmp.err);
        warndlg(mep.tmp.err,'Incorrect data type:');
        return;
    end
    mep.data = in_data;
    out_events = in_data(:,end);
    
    mep.event_samples = find(mep.data(:,end) ~= 0);
    mep.n_events = numel(mep.event_samples);
    mep.epoch_samples = round(mep.tmp.epoch/(1000/mep.tmp.Hertz));
    
    
    % not sure about this
    mep.fig.xdata = 0:sum(abs(mep.epoch_samples));
    mep.fig.xdata = mep.fig.xdata + min(mep.epoch_samples);
    mep.fig.xdata  = mep.fig.xdata*(1000/mep.tmp.Hertz);
    
    mep.tmp.data = [];
    for i = 1 : mep.n_events;
        % select a period of data surrounding the trigger to determine when the
        % onset actually is
        mep.tmp.filt_points = mep.event_samples(i) + mep.epoch_samples;
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
    mep.tmp.data_mean = mean(mep.tmp.data(:,1:end-1,:),3);

    if mep.tmp.plot
        h = figure('name',mep.tmp.fig_name);
        plot(mep.fig.xdata,mep.tmp.data_mean); hold;
%         plot([0 0],[-200 200],'m');
        
        uiwait(h);
    end
%     if mep.tmp.plot_all
%         h = figure('name',mep.tmp.fig_name);
%         for i = 1 : mep.n_events;
%             plot(-mep.x_range:mep.x_range,mep.tmp.data(:,:,i)); hold;
%             title(sprintf('Event %u of %u',i,mep.n_events));
%             plot([0 0],[-200 200],'m');
%             ylims = get(gca,'YLim');
%             %     plot(-mep.x_range+mep.tmp.onsets(i)+ones(1,2),[-200 200],'c');
%             for j = 1 : 2 : numel(mep.tmp.points)
%                 tn = mep.tmp.points{j};
%                 tc = mep.tmp.point_colours{j};
%                 plot(-mep.x_range+mep.tmp.(tn)+ones(1,2),ylims,tc);
%                 %             plot(-mep.x_range+mep.tmp.([tn,'s'])(i)+ones(1,2),ylims,[tc,'--']);
%             end
%             pause;
%             hold;
%         end
%         uiwait(h);
%     end
%     
%     %% >  adjust for onset and transmission delay
%     mep.tmp.delay_samples = ceil((mep.tmp.delay/1000)/(1/mep.tmp.Hertz));
%     out_samples = find(out_events,sum(out_events ~= 0),'first');
%     out_values = out_events(out_samples);
%     % make the samples earlier
%     out_events = zeros(size(out_events));
%     if isfield(mep.tmp,'mid') && ~isempty(mep.tmp.mid)
%         out_events(out_samples + (-mep.x_range+mep.tmp.mid) - mep.tmp.delay_samples) = out_values;
%     else
%         fprintf('Serious issue finding event markers: couldn''t identify the pulses\n');
%     end
catch err
    save(matEPOCdebug);rethrow(err);
end
end