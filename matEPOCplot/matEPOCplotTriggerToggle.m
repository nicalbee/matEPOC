function matEPOCplotTriggerToggle(~,~) % (object, eventdata)
tmp.point = get(gca, 'CurrentPoint');
tmp.xlims = get(gca,'XLim');
tmp.ylims = get(gca,'YLim');
if tmp.point(1,1) > tmp.xlims(1) && tmp.point(1,1) < tmp.xlims(2) && ... % tmp.point(1,1) > 0 &&
        tmp.point(1,2) > tmp.ylims(1) && tmp.point(1,2) < tmp.ylims(2)
    % which sample is this?
    data = get(gcf,'UserData');
    % convert X value (in seconds) to samples
    tmp.sample = fix(tmp.point(1,1)/(1/data.tmp.Hertz));
    tmp.sample_range = 5;
    tmp.range = tmp.sample + tmp.sample_range.*[-1 1];
    
    tmp.use = data.tmp.data(:,ismember(data.tmp.channel_labels,'use'));
    
    tmp.changes = [];
    if sum(ismember(data.tmp.channel_labels,'changes'))
        tmp.changes = data.tmp.data(:,ismember(data.tmp.channel_labels,'changes'));
    end
    % check the original data first - could be slightly different to the
    % position clicked
    if sum(tmp.use(tmp.range(1):tmp.range(2))) ~= 0
%         fprintf('There was an event here previously, removing:\n')
        tmp.trigger_sample = tmp.range(1) + find(tmp.use(tmp.range(1):tmp.range(2)) ~= 0,1,'first') - 1;
        tmp.use(tmp.trigger_sample) = 0;
    elseif sum(data.tmp.use_data(tmp.range(1):tmp.range(2))) ~= 0 && sum(tmp.use(tmp.range(1):tmp.range(2))) == 0
        % lock onto the original 'use' variable if there was something
        % there
        tmp.trigger_sample = tmp.range(1) + ...
            find(data.tmp.use_data(tmp.range(1):tmp.range(2)) ~= 0,1,'first') - 1;
        tmp.value = matEPOCplotConditionValue(tmp.use,tmp.point);
        tmp.use(tmp.trigger_sample) = tmp.value;
    elseif ~isempty(tmp.changes) && ...
            sum(tmp.changes(tmp.range(1):tmp.range(2))) ~= 0
        % lock onto the changes variable if there is something there
        tmp.trigger_sample = tmp.range(1) + ...
            find(tmp.changes(tmp.range(1):tmp.range(2)) ~= 0,1,'first') - 1;
        tmp.value = matEPOCplotConditionValue(tmp.use,tmp.point);
        tmp.use(tmp.trigger_sample) = tmp.value;
        
    elseif sum(ismember(data.tmp.channel_labels,'gap')) && ...
            sum(data.tmp.data(tmp.range(1):tmp.range(2),ismember(data.tmp.channel_labels,'gap'))) ~= 0
        tmp.trigger_sample = tmp.range(1) + ...
            find(data.tmp.data(tmp.range(1):tmp.range(2),ismember(data.tmp.channel_labels,'gap')) ~= 0,1,'first') - 1;
        
        tmp.value = matEPOCplotConditionValue(tmp.use,tmp.point);
        tmp.use(tmp.trigger_sample) = tmp.value;
    else
        tmp.value = matEPOCplotConditionValue(tmp.use,tmp.point);
        %         tmp.unique = unique(tmp.use); % could be 0 & 100 & 200
        %         tmp.value = tmp.unique(2);
        %         if numel(tmp.unique) > 2
        %             tmp.value = str2double(questdlg('Which value?','Trigger value:',...
        %                 num2str(tmp.unique(2)),num2str(tmp.unique(3)),...
        %                 num2str(tmp.unique(2))));
        %             if isnan(tmp.value)
        %                 tmp.value = tmp.unique(2);
        %             end
        %         end
        tmp.use(tmp.sample) = tmp.value; % max(tmp.use);
    end
    
    data.tmp.data(:,ismember(data.tmp.channel_labels,'use')) = tmp.use;
    
    if sum(ismember(data.tmp.channel_labels,'gap'))
        data.tmp.data(:,ismember(data.tmp.channel_labels,'gap')) = matEPOCplotGapFlag(tmp.use);
    end
    set(gcf,'UserData',data);
    %         data.tmp.name = 'use';
    %         set(data.tmp.(data.tmp.name).h,'NextPlot','replace');
    %         xdata = data.fig.xdata;
    %         ydata = tmp.use;
    % send xdata & ydata to workspace for 'refreshdata' function to
    % access
    %         assignin('base','xdata',xdata);
    %         assignin('base','ydata',ydata);
    %         refreshdata(data.tmp.(data.tmp.name).h);
    
    matEPOCsamples2patch([],'update');%,'channels',{'use','conditions','gap'}); % 
    matEPOCplotTrialText('delete','draw');
    %         [xdata,ydata] = matEPOCsamples2patch(tmp.use,'update');
    %         ch = get(gca,'children');
    %         tags = get(ch,'Tag');
    %         patch_h = ch(ismember(tags,'use')); % extra step but something's not working
    %         set(patch_h,'XData',xdata,'YData',ydata);
    
    
    %         delete(data.tmp.(data.tmp.name).h);
    %             data.tmp.(data.tmp.name).h = ...
    %                 plot(data.fig.xdata,tmp.use,...
    %                 'color',matEPOCplotColours(data.tmp.name),...tmp.data.channel_colours{i},...
    %                 'Tag',data.tmp.name,...
    %                 'DisplayName',data.tmp.name);
    %     drawnow;
    %     data.tmp.data(:,ismember(data.tmp.channel_labels,'use')) = tmp.use;
    %     set(gcf,'UserData',data);
    matEPOCplotTitle;
end

end
%% embedded function/s

% %% > whichValue
% % need to do this twice so keep the code consistent
% function outValue = whichValue(inVector,click_point)
% tmp.unique = unique(inVector); % could be 0 & 100 & 200
% outValue = tmp.unique(2);
% if click_point(1,2) < 0
%     outValue = -100;
% else
%     if numel(tmp.unique) > 2
%         outValue = str2double(questdlg('Which value?','Trigger value:',...
%             '-100',num2str(tmp.unique(2)),num2str(tmp.unique(3)),...
%             num2str(tmp.unique(2))));
%         if isnan(outValue)
%             outValue = 0;%tmp.unique(2);
%         end
%     end
% end
% end