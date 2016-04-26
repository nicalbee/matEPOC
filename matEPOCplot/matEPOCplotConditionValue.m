function out_value = matEPOCplotConditionValue(cond_vector,click_point)
global selected_value
skip_value = -99;
cond_values = [];%skip_value;
unique_values = unique(cond_vector(cond_vector~=0));
cond_values(end+1:end+numel(unique_values)) = unique_values; % could be 0 & 100 & 200
cond_values(end+1:end+2) = [skip_value 0];
if cond_values(1) == skip_value
    cond_values(1) = [];
end
% out_value = 0;%tmp.unique(2);
if click_point(1,2) < 0
    out_value = skip_value;
else
    but.layout_cols = 5;
    but.layout_rows = ceil(numel(cond_values)/but.layout_cols);
    
    but.pos = [.1 .4];
    but.sep = [.05 .05];
    but.text_pos = [but.sep(1) .8 .9 .1];
    
    but.k = 0;
    while 1
        but.k = but.k + 1;
        but.size = [(1-but.pos(1))/but.layout_cols (but.pos(2)+(.05*(1-but.k)))/but.layout_rows];
        but.poss = zeros(but.layout_cols*but.layout_rows,2);
        k = 0;
        for row = 1 : but.layout_rows
            for col = 1 : but.layout_cols
                k = k + 1;
                but.poss(k,:) = ...
                    [but.sep(1) + but.pos(1)*.5 + but.size(1)*(col-1),...
                    1 -  but.pos(2) - but.size(2)*(row-1)];
            end
        end
        if but.poss(1,2) + but.size(2) <= but.text_pos(2)
            break
        end
    end
    % set the position of the figure based on where the mouse is
    screen_size = get(0,'ScreenSize');
    pointer_loc = get(0,'PointerLocation');
    
    pointer_pos = pointer_loc./screen_size(3:4);
    
    fig_size = [.3 .15];
    fig_pos = [pointer_pos fig_size];
    fig_pos(2) = fig_pos(2) - fig_size(2) - .03;
    while sum(fig_pos([1 3])) > 1 || sum(fig_pos([2 4])) > 1
        if sum(fig_pos([1 3])) > 1
            fig_pos(1) = fig_pos(1)-.01;
        end
        if sum(fig_pos([2 4])) > 1
            fig_pos(1) = fig_pos(2)+.01;
        end
    end
    
    h = figure('units','normalized','name','matEPOC Condition value:',...
        'menubar','none','NumberTitle','off',...
        'position',fig_pos);
    but.text_string = ...
        'Select a condition value for the event marker:';
    
    but.text = uicontrol('Parent',h,'String',but.text_string,...
            'style','text','units','normalized',....
            'position',but.text_pos);
    
    for i = 1 : numel(cond_values)
        tmp_pos = but.poss(i,:);
        tmp_string = num2str(cond_values(i));
        tmp_tooltip = sprintf('Click to select ''%i'' value for event marker',cond_values(i));
        switch i
            case numel(cond_values)-1
                tmp_pos = but.poss(end-1,:);
                tmp_pos(2) = 1 -  but.pos(2) - but.size(2)*(but.layout_rows);% + but.sep(2);
                
                tmp_tooltip = sprintf(['Click to select ''%i'' value\n',...
                    'Use as dummy marker for aligning conditions'],cond_values(i));
            case numel(cond_values)
                tmp_pos = but.poss(end,:);
                tmp_pos(2) = 1 -  but.pos(2) - but.size(2)*(but.layout_rows);% + but.sep(2);
                tmp_tooltip = 'Click to cancel/close';
                tmp_string = 'cancel';
        end
        but.h(i) = uicontrol('Parent',h,'String',tmp_string,...
            'style','Pushbutton','units','normalized',....
            'position',[tmp_pos (but.size-but.sep)],...
            'ToolTipString',tmp_tooltip,...
            'Callback',@matEPOCplotConditionValueButton,'UserData',cond_values(i));
    end
    uiwait(h);
    out_value = selected_value;
end

end