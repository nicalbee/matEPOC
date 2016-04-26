function matEPOCplotTitle(~,~)

data = get(gcf,'UserData');

tmp.use = data.tmp.data(:,ismember(data.tmp.channel_labels,'use'));

tmp.n = numel(find(tmp.use ~= 0));

tmp.title = sprintf('%i events',tmp.n);

if tmp.n == 1
    tmp.title(end) = [];
else
    tmp.unique = unique(tmp.use(tmp.use ~= 0));
    if numel(tmp.unique) > 1
        tmp.title = [tmp.title,' ('];
        for i = 1 : numel(tmp.unique)
            tmp.title = sprintf('%s n = %i @ %i',tmp.title,...
                numel(find(tmp.use == tmp.unique(i))), tmp.unique(i));
            if i < numel(tmp.unique)
                tmp.title = [tmp.title,','];
            end
        end
        tmp.title = [tmp.title,')'];
    end
end

title(gca, tmp.title);