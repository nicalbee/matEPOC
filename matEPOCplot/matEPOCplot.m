function matEPOCplot(in_data,varargin)

% updates:
% 14-Mar-2017 NAB updated to accept 'mep' structure, defaulting to show
% just the 14 EEG channels

inputs.varargin = varargin;
inputs.turnOn = {'no_gap','allchs'};
inputs.defaults = struct(...
    'fig_name','matEPOC event marker plot',...
    'Hertz',128,...
    'pos',[.2 .4 .8 .4],...
    'ylim',[-50 200],...
    'xlim',[0 10]);

inputs.defaults.channel_labels = {'a','b','c','d','e','f'};
inputs.defaults.channel_colours = {'b','r','g','m'};
inputs.defaults.visible = {'Ch1','changes','conditions','use'}; % display channels on by default

data.tmp = setGetInputsStruct(inputs);

if ~isstruct(in_data)
    data.tmp.data = in_data;
elseif isstruct(in_data)
    mep = in_data;
     data.tmp.data = mep.matrix(:,mep.EEG_channel_indices);
        data.tmp.channel_labels = mep.EEG_channels;
        data.tmp.visible = mep.EEG_channels;
    
        if data.tmp.allchs
            switch questdlg(sprintf('Are you sure you want all %i channels? This will take a while...',numel(mep.channel_labels)),...
                    'Really...','Yes','No','No')
                case 'Yes'
                    data.tmp.data = mep.matrix;
                    data.tmp.channel_labels = mep.channel_labels;
                otherwise
            end
        end
    data.tmp.channel_colours = colormap;
    while size(data.tmp.channel_colours,1) < size(data.tmp.channel_labels)
        data.tmp.channel_colours = vertcat(data.tmp.channel_colours,data.tmp.channel_colours);
    end
    in_data = data.tmp.data;
end
    

% make sure the first channel/column is the upward going trigger
if max(data.tmp.data(:,1)) < max(data.tmp.data(:,2))
    data.tmp.data(:,1) = in_data(:,2);
    data.tmp.data(:,2) = in_data(:,1);
end

% this needs to be kept intact for reference
data.tmp.use_data = data.tmp.data(:,ismember(data.tmp.channel_labels,'use'));

if ~data.tmp.no_gap && ~isempty(data.tmp.use_data)
    fprintf('Adding extra channel to data: ''gap''\n');
    
%     function out_gap = matEPOCplotGapFlag(use_data)
% 
% % data = get(gcf,'UserData');
% % 
% % sum(ismember(channel_labels,mep.channels{i}))
% % 
% % use_data = use_data;
% % calculate the difference = separation bewteen markers
% use_diff_samples = find(use_data);
% use_diff = diff(use_diff_samples); %*(1/Hertz);
% % probably add an extra column to this to treat as patch
% % put a patch in the middle of large separations
% out_gap = zeros(size(data,1),1);
% sep_flag = use_diff > median(use_diff)*1.5;
% % add a point half-way between markers, make this wider in the patch
% % function at some point but different colour should be enough to begin
% % with
% if sum(sep_flag)
%     out_gap(use_diff_samples(logical(sep_flag))+ ...
%         median(diff(use_diff_samples))) = 1;
% end
    
%     % calculate the difference = separation bewteen markers
%     data.tmp.use_diff_samples = find(data.tmp.use_data);
%     data.tmp.use_diff = diff(data.tmp.use_diff_samples)*(1/data.tmp.Hertz);
%     % probably add an extra column to this to treat as patch
%     % put a patch in the middle of large separations
%     data.tmp.gap_warn = zeros(size(data.tmp.data,1),1);
%     data.tmp.sep_flag = data.tmp.use_diff > median(data.tmp.use_diff)*1.5;
%     % add a point half-way between markers, make this wider in the patch
%     % function at some point but different colour should be enough to begin
%     % with
%     if sum(data.tmp.sep_flag)
%         data.tmp.gap_warn(data.tmp.use_diff_samples(logical(data.tmp.sep_flag))+ ...
%             median(diff(data.tmp.use_diff_samples))) = 1;
%     end
    in_data(:,end+1) = matEPOCplotGapFlag(data.tmp.use_data);
    data.tmp.data = in_data;
    data.tmp.channel_labels{end+1} = 'gap';
end

data.fig.h = figure('units','normalized','position',data.tmp.pos,...
    'UserData',data,'name',data.tmp.fig_name,'NumberTitle','off');

set(data.fig.h,'WindowButtonDownFcn',@matEPOCplotTriggerToggle,...
    'CloseRequestFcn',@matEPOCplotClose);

matEPOCplotComponents(data.fig.h);

data.fig.ch = get(data.fig.h,'children');
data.fig.ax = data.fig.ch(strcmp(get(data.fig.ch,'Type'),'axes'));
data.fig.xdata = 0:(1/data.tmp.Hertz):(size(in_data,1)-1)*(1/data.tmp.Hertz);
% if size(in_data,2) == 2 %numel(tmp.data.channel_labels);
for i = 1 : size(in_data,2)
    %         data.tmp.ev_plot = [tmp.data.channel_labels{i},'_plot'];
    
    %         if numel(unique(in_data(:,i))) == 2 && ...
    %                 or(isfield(data.data,data.tmp.ev_plot),...
    %                 isfield(data.data,data.tmp.ev_patch))
    %
    %                 % event data has been set to ones and zeros
    %                 data.tmp.events = find(in_data(:,i));
    %                 data.tmp.ylim = get(data.fig.ax,'Ylim');
    %                 %                                 for j = 1 : numel(data.tmp.events)
    %                 plot(tmp.data.(data.tmp.ev_plot)(:,2)*(1/data.Hertz),...
    %                     tmp.data.(data.tmp.ev_plot)(:,1)*max(data.tmp.ylim),....
    %                     'color',matEPOCplotColours(tmp.data.channel_labels{i}),...tmp.data.channel_colours{i},...
    %                     'Tag',tmp.data.channel_labels{i},...
    %                     'DisplayName',tmp.data.channel_labels{i});
    %                 %                                 end
    %
    %         else
    data.tmp.name = data.tmp.channel_labels{i};
    xdata = data.fig.xdata;
    ydata = data.tmp.data(:,i);
    switch data.tmp.name
        case {'conditions','use','gap'}

            [xdata,ydata] = matEPOCsamples2patch(ydata);%,(1/data.tmp.Hertz));
            
            data.tmp.(data.tmp.name).h = ...
                patch(xdata,ydata,matEPOCplotColours(data.tmp.channel_labels{i}),...'XDataSource','xdata','YDataSource','ydata',...in_data(:,i),...'color',matEPOCplotColours(data.tmp.channel_labels{i}),...tmp.data.channel_colours{i},...
                'EdgeColor',matEPOCplotColours(data.tmp.channel_labels{i}),...
                'Tag',data.tmp.channel_labels{i},...
                'DisplayName',data.tmp.channel_labels{i});
        otherwise
            data.tmp.(data.tmp.name).h = ...
                plot(xdata,ydata,'XDataSource','xdata','YDataSource','ydata',...in_data(:,i),...
                'color',matEPOCplotColours(data.tmp.channel_labels{i}),...tmp.data.channel_colours{i},...
                'Tag',data.tmp.channel_labels{i},...
                'DisplayName',data.tmp.channel_labels{i});
    end
    if ~sum(strcmpi(data.tmp.visible,data.tmp.name));
        set(data.tmp.(data.tmp.name).h,'Visible','off');
    end
    
    if i == 1; hold; end
end
matEPOCplotLegend(data.fig.h);
% else
%     plot(data.fig.ax,data.fig.xdata,in_data);
% end
set(get(data.fig.ax,'YLabel'),'string','Amplitude');
set(get(data.fig.ax,'XLabel'),'string',...
    sprintf('Recording time in seconds (Total = %i)',...
    ceil(max(data.fig.xdata))));
set(data.fig.ax,'Ylim',data.tmp.ylim);
set(data.fig.ax,'Xlim',data.tmp.xlim);

% for i = 1 : size(in_data,2)
%     data.tmp.name = data.tmp.channel_labels{i};
%     xdata = data.fig.xdata;
%     ydata = data.tmp.data(:,i);
%     switch data.tmp.name
%         case {'conditions','use'}
%             event_samples = find(ydata ~= 0);
%             event_conds = ydata(ydata ~= 0);
%             [xdata,ydata] = matEPOCsamples2patch(ydata);%,(1/data.tmp.Hertz));
%             % write the text... might work here
%             %                     if numel(patch_text) ~= numel(event_samples)
%             %                         delete(ch(ismember(tags,'patch')));
%             text_offset = 3;
%             yadj = .8;
%             ylims = get(gca,'YLim');
%             xlims = get(gca,'XLim');
%             if strcmp(data.tmp.name,'conditions')
%                 yadj = .9;
%             end
%             for j = 1 : numel(event_samples)
%                 if event_samples(j)*(1/data.tmp.Hertz) > xlims(1) && event_samples(j)*(1/data.tmp.Hertz) < xlims(2)
%                     text((event_samples(j)+text_offset)*(1/data.tmp.Hertz),ylims(2)*yadj,...
%                         [num2str(j),': ',num2str(event_conds(j))],...
%                         'Tag',[data.tmp.name,'_text'],'color',matEPOCplotColours('use'));
%                 end
%             end
%     end
% end
matEPOCplotSetAxes(data);
matEPOCplotTrialText('draw');
matEPOCplotTitle;
set(data.fig.h,'UserData',data);
% if data.tmp.wait; uiwait(data.fig.h); end

uiwait(data.fig.h); % need to get the data before it's closed...

% data = get(data.fig.h,'UserData');
% out_data = plot_data.tmp.data(:,ismember(data.tmp.channel_labels,'use'));

