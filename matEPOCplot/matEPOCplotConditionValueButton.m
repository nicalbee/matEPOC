function matEPOCplotConditionValueButton(h,~)
global selected_value
selected_value = get(h,'UserData');

if ~selected_value
    fprintf('\tCancelled - an event marker will not be inserted\n');
else
    fprintf('\t%i value selected\n',selected_value);
end
% assignin('caller','out_value',selected_value);
delete(gcf);
end