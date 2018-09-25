function [xdata,ydata_use] = matEPOCsamples2patch(ydata,varargin)

inputs.turnOn = {'update'};
inputs.defaults = struct('offset',[]);
inputs.varargin = varargin;
% inputs.defaults = struct(...
%     'channels','use' ...
%     );
inputs.defaults.channels = {'use','conditions','gap'};
mep = setGetInputsStruct(inputs);

% ch = get(gca,'children');
data = get(gcf,'UserData');
if isempty(mep.channels)
    return
else
    for i = 1 : numel(mep.channels)
        ydata_use = ydata;
        if isempty(ydata_use) && sum(ismember(data.tmp.channel_labels,mep.channels{i}))
            
            ydata_use = data.tmp.data(:,ismember(data.tmp.channel_labels,mep.channels{i}));
        end
        % offset the conditions
        if ~isempty(mep.offset) && strcmp('conditions',mep.channels{i})
            switch mep.offset
                case {'shiftOffsetLeft','resetOffset','shiftOffsetRight'}
                    if ~isfield(data.tmp,'offset')
                        data.tmp.offset = 0;
%                         data.tmp.offset_original = ydata_use;
                        set(gcf,'UserData',data);
                    end
                    switch mep.offset
                        case 'shiftOffsetLeft'
                            data.tmp.offset = data.tmp.offset - 5;
                            ydata_use = [ydata_use(abs(data.tmp.offset)+1:end); zeros(abs(data.tmp.offset),1)];
                        case 'resetOffset'
                            data.tmp.offset = 0;
                            ydata_use = data.offset_original;
                        case 'shiftOffsetRight'
                            data.tmp.offset = data.tmp.offset + 5;
                            ydata_use = [zeros(data.tmp.offset,1); ydata_use(1:(end-data.tmp.offset))];
                            
                    end
                    data.tmp.data(:,ismember(data.tmp.channel_labels,mep.channels{i})) = ydata_use;
                    set(gcf,'UserData',data);
            end
        end
        % sample_times = get(ch(end),'XData'); % doesn't work if it's a patch
        event_samples = find(ydata_use ~= 0);
        % event_conds = ydata_use(ydata_use ~= 0);
        xdata = zeros(4,numel(event_samples));
        for j = 1 : numel(event_samples)
            xdata(:,j) = [event_samples(j) ones(1,2)*event_samples(j)+1 event_samples(j)]*(1/data.tmp.Hertz);
        end
        ylims = get(gca,'YLim');
        % xlims = get(gca,'XLim');
        ydata_use = ones(4,numel(event_samples));
        ydata_use = bsxfun(@times,ydata_use,[ones(1,2)*max(ylims) ones(1,2)*min(ylims)]');
        
        % varargout{1} = xdata;
        % varargout{2} = ydata_use;
        if mep.update
            ch = get(gca,'children');
            tags = get(ch,'Tag');
            
            %     delete(ch(ismember(tags,'use_text')));
            
            patch_h = ch(ismember(tags,mep.channels{i})); % extra step but something's not working
            set(patch_h,'XData',xdata,'YData',ydata_use);
            %     patch_text = ch(ismember(tags,'use_text'));
            
            %     if numel(patch_text) ~= numel(event_samples)
            %         delete(ch(ismember(tags,'use_text')));
            %         text_offset = 3;
            %         fprintf('\nEvent numbers: conditions\n');
            %         for j = 1 : numel(event_samples)
            %             if event_samples(j)*(1/data.tmp.Hertz) > xlims(1) && event_samples(j)*(1/data.tmp.Hertz) < xlims(2)
            %             event_text = [num2str(j),': ',num2str(event_conds(j))];
            %                 fprintf('Writing %i: %s\n',j,event_text);
            %                 text((event_samples(j)+text_offset)*(1/data.tmp.Hertz),ylims(2)*.9,...
            %                 event_text,...
            %                 'Tag','patch','color',matEPOCplotColours('use'));
            %             end
            %         end
            %     end
        end
        if ~isempty(ydata)
            % don't need to run the loop
            break
        end
    end
end