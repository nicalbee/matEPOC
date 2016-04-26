function matEPOCplotTrialText(varargin)
inputs.turnOn = {'delete','draw','comment'};
% inputs.turnOff = {'comment'};
inputs.varargin = varargin;
inputs.defaults.channel_names = {'use','conditions'};

mep = setGetInputsStruct(inputs);
if mep.delete
    ch = get(gca,'children');
    tags = get(ch,'Tag');
    for i = 1 : numel(mep.channel_names)
        delete(ch(ismember(tags,[mep.channel_names{i},'_text'])));
        % delete(ch(ismember(tags,'condition_text')));
    end
end
if mep.draw
    data = get(gcf,'UserData');
    xoffset = 3;
    yoffsets = [.8 .9];
    xlims = get(gca,'XLim');
    ylims = get(gca,'YLim');
    for i = 1 : numel(mep.channel_names)
        if mep.comment
            fprintf('\nEvent numbers/conditions: %s\n',mep.channel_names{i});
        end
        if sum(ismember(data.tmp.channel_labels,mep.channel_names{i}))
            event_data = data.tmp.data(:,ismember(data.tmp.channel_labels,mep.channel_names{i}));
            event_conds = event_data(event_data ~= 0);
            event_samples = find(event_data ~= 0);
            for j = 1 : numel(event_samples)
                if event_samples(j)*(1/data.tmp.Hertz) > xlims(1) && event_samples(j)*(1/data.tmp.Hertz) < xlims(2)
                    event_text = [num2str(j),': ',num2str(event_conds(j))];
                    if mep.comment
                        fprintf('Writing %s\n',event_text);
                    end
                    text((event_samples(j)+xoffset)*(1/data.tmp.Hertz),ylims(2)*yoffsets(i),...
                        event_text,...
                        'Tag',[mep.channel_names{i},'_text'],'color',matEPOCplotColours(mep.channel_names{i}));
                end
            end
        end
    end
end