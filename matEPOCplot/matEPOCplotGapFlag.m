function out_gap = matEPOCplotGapFlag(use_data)

% data = get(gcf,'UserData');
% 
% sum(ismember(channel_labels,mep.channels{i}))
% 
% use_data = use_data;
% calculate the difference = separation bewteen markers
use_diff_samples = find(use_data);
use_diff = diff(use_diff_samples); %*(1/Hertz);
% probably add an extra column to this to treat as patch
% put a patch in the middle of large separations
out_gap = zeros(size(use_data));
sep_flag = use_diff > median(use_diff)*1.5;
% add a point half-way between markers, make this wider in the patch
% function at some point but different colour should be enough to begin
% with
if sum(sep_flag)
    out_gap(use_diff_samples(logical(sep_flag))+ ...
        round(median(diff(use_diff_samples)))) = 1;
else
    % we need something
    out_gap(1) = 1;
end