function matEPOCplotClose(~,~)
global plot_data
plot_data = get(gcf,'UserData');

% assignin('base','plot_data',plot_data);
delete(gcf);