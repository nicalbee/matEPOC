function mep = matEPOCfixMissed(mep)
% matEPOC - add in missing/dropped data
%
% date: 2018-Nov-08
%
% author: Nic Badcock
%
% Aim:
% Sometimes the Emotiv software misses a sample. May be particularly
% troublesome when using post-TestBench software (ie PURE EEG or Emotiv
% Pro) that may require constant online access/connection.
% This plan for this script is to check when a sample has been dropped
% (looking at the 'COUNTER' channel for this)
% (could be multiple) and interpolate the data using MATLAB's 'linespace'
% function which draws a straight line between 2 numbers.
% Just planning to loop through the skipped samples at add the bits of the
% matrix together. Not sure if there's a better way to do it...
%
% updates:
%

%% find the missed samples
tmp.diffs = diff(mep.table.COUNTER);
% looking for counters that skipped a sample. This difference is usually a
% single number ie 0:127 (127 = max sampling rate) but at then 127 to 0
% difference, looking for a number bigger than the negative max
% sort them so the go in the same sequence, rather than the -max being at
% the end - might be important but I'm not sure yet.
tmp.missed = sort([find(tmp.diffs > 1) find(tmp.diffs < -max(mep.table.COUNTER))]);

tmp.diffs_missed = tmp.diffs(tmp.missed);
plot(tmp.diffs_missed);
tmp.total_missed = sum(tmp.diffs_missed);

fprintf('%i samples missed ~ reflecting %3.2f minutes of data\n',...
    tmp.total_missed, tmp.total_missed*(1/mep.Hertz)/60);
out.table = mep.table(1:(tmp.missed(1)-1),:);
in.table_as_matrix = table2array(mep.table);
fprintf('Interpolating, skipped by column - takes a while:\n');
for i = 1 : numel(tmp.missed)
    tmp.start = mep.table.COUNTER(tmp.missed(i));
    tmp.end = mep.table.COUNTER(tmp.missed(i)+1);
    tmp.matrix = [];
    for j = 1 : size(mep.table,2)
    tmp.matrix(:,j) = linspace(in.table_as_matrix(tmp.missed(i),j),in.table_as_matrix(tmp.missed(i)+1,j),(tmp.end - tmp.start + 1));
    end
    out.table = [out.table;array2table(tmp.matrix,'VariableNames',mep.table.Properties.VariableNames)];
    if i > numel(tmp.missed)
        out.table = [out.table; mep.table(tmp.missed(i)+2:tmp.missed(i+1)-1,:)];
    else
         out.table = [out.table; mep.table(tmp.missed(i)+2:end,:)];
    end
    if mod(i,100)
        fprintf('.');
    end
end
fprintf('\n Complete: %i rows to %i rows\n',size(mep.table,1),size(out.table,1));