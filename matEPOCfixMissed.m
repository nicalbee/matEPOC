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

fprintf('Running: %s\n',mfilename);
mep.missed.progress_comment = 0;
mep.missed.progress_bar = 1;

%% find the missed samples
mep.missed.diffs = diff(mep.table.COUNTER);
% looking for counters that skipped a sample. This difference is usually a
% single number ie 0:127 (127 = max sampling rate) but at then 127 to 0
% difference, looking for a number bigger than the negative max
% sort them so the go in the same sequence, rather than the -max being at
% the end - might be important but I'm not sure yet.
mep.missed.missed = sort([find(mep.missed.diffs > 1); ...
    find(mep.missed.diffs > -max(mep.table.COUNTER) & mep.missed.diffs < 0)]);
mep.missed.one_sample_gap = [];
if isempty(mep.missed.missed)
    fprintf('\tNothing missed\n');
else
    mep.missed.diffs_missed = mep.missed.diffs(mep.missed.missed);
    % plot(mep.missed.diffs_missed);
    % some of these are negative but it doesn't tell you about the actual
    % gap because it's going over the 0 mark
    mep.missed.gap_filt = mep.missed.diffs_missed < 0;
    mep.missed.diffs_missed(mep.missed.gap_filt) = mep.missed.diffs_missed(mep.missed.gap_filt) + max(mep.table.COUNTER);
    
    % this is minus 1 for each difference - this isn't perfect...
    % - seems to be okay once the over-max gap is accounted for; i.e., +
    % + sum(mep.missed.gap_filt)); on the end
    mep.missed.total_missed = sum(mep.missed.diffs_missed)-numel(mep.missed.diffs_missed) + sum(mep.missed.gap_filt);
    
    fprintf('\t%i disruptions/skips, %i samples missed ~ reflecting %3.2f minutes of data\n',...
        numel(mep.missed.missed),mep.missed.total_missed, mep.missed.total_missed*(1/mep.Hertz)/60);
    
    out.table = mep.table(1:(mep.missed.missed(1)-1),:);
    in.table_as_matrix = table2array(mep.table);
    fprintf('\n\tInterpolating, # skipped rows x columns - takes a while:\n');
    if mep.missed.progress_bar
        mep.missed.bar = waitbar(0,'matEPOC: adding missed data...');
        fprintf('\tsee ''waitbar'' for progress... (''waitbar'' = MATLAB function name)\n');
    end
    mep.missed.added = [];
    for i = 1 : numel(mep.missed.missed)
        mep.missed.start = mep.table.COUNTER(mep.missed.missed(i));
        mep.missed.end = mep.table.COUNTER(mep.missed.missed(i)+1);
        mep.missed.matrix = [];
        for j = 1 : size(mep.table,2)
            % this won't work for the COUNTER variable if is crossed from
            % max to min
            if j == 1 && in.table_as_matrix(mep.missed.missed(i),1) > in.table_as_matrix(mep.missed.missed(i)+1,1)
                % haven't seen a case of this yet: 2018-Nov-08 NAB
                %                 if j == 1
                mep.tmp.counter = [in.table_as_matrix(mep.missed.missed(i),j): max(in.table_as_matrix(:,j)) ...
                    0:in.table_as_matrix(mep.missed.missed(i)+1,j)];
                mep.missed.matrix(:,j) = mep.tmp.counter;
                
                % this might work... 2018-Nov-08 NAB
                mep.missed.end = mep.missed.start + numel(mep.tmp.counter)-1;
                
                %                     mep.missed.start = 120;
                %                     mep.missed.end = 10;
                %                     mep.tmp.counter = [mep.missed.start:127 0:mep.missed.end];
                %                     e = 3.41;
                %                     f = 8.62;
                %                       % na, this isn't the scenario
                %                     d = linspace(e,f,mep.missed.end-mep.missed.start+1); % but this won't be a problem or will it
                %                 else
                %                 end
            else
                mep.missed.matrix(:,j) = linspace(in.table_as_matrix(mep.missed.missed(i),j),...
                    in.table_as_matrix(mep.missed.missed(i)+1,j),...
                    (mep.missed.end - mep.missed.start + 1));
            end
        end
        mep.missed.table = array2table(mep.missed.matrix,'VariableNames',mep.table.Properties.VariableNames);
        if mep.missed.progress_comment
            fprintf('\t%i: Adding missed %i rows (mep.missed.table), to %i rows (out.table)\n',...
                i,size(mep.missed.table,1),size(out.table,1));
        end
        mep.missed.added(end+1) = size(out.table,1)+1;
        out.table = [out.table;mep.missed.table];
        % add on the non missed bits
        if i < numel(mep.missed.missed)
            % can't be the next sample
            if mep.missed.missed(i+1) - mep.missed.missed(i) == 1
%                 msg = sprintf('%i: 1 difference: %i vs %i',i,...
%                     mep.missed.missed(i+1), mep.missed.missed(i));
%                 fprintf('!!! %s\n',msg);
                mep.missed.one_sample_gap(end+1) = i;
                % seems best to remove the previous/last row
                out.table(end,:) = [];
%                 warndlg(msg);
%                 close all hidden
%                 close all force
            else
                mep.missed.table = mep.table(mep.missed.missed(i)+2:mep.missed.missed(i+1)-1,:);
                if mep.missed.progress_comment
                    fprintf('\t\t%ia:Adding non-missed %i rows (mep.missed.table), to %i rows (out.table)\n',...
                        i,size(mep.missed.table,1),size(out.table,1));
                end
                out.table = [out.table; mep.missed.table];
            end
        else
            mep.missed.table = mep.table(mep.missed.missed(i)+2:end,:);
            if mep.missed.progress_comment
                
                fprintf('\t\t%ia:Adding non-missed %i rows (mep.missed.table), to %i rows (out.table)\n',...
                    i,size(mep.missed.table,1),size(out.table,1));
            end
            
            out.table = [out.table; mep.missed.table];
        end
        if ~mod(i,100) % progress indicator
            % could draw this more often but it adds time...
            if mep.missed.progress_bar; waitbar(i/numel(mep.missed.missed),mep.missed.bar); else; fprintf('.'); end
        end
    end
    if mep.missed.progress_bar; close(mep.missed.bar); end
    
    %     mep.missed = tmp;
    mep.missed.table = mep.table;
    mep.table = out.table;
    fprintf('\n\tComplete: %i rows to %i rows (difference = %i)\n',...
        size(mep.missed.table,1),size(mep.table,1), ...
        size(mep.table,1)-size(mep.missed.table,1));
    fprintf('\tOrignal table available in: ''mep.missed.table'' variable.\n')
    fprintf('\tWorkings for missing data available in ''mep.missed'' variable\n');
end
fprintf('\nFinished running: %s\n',mfilename);

%% testing
% used x & y when testing in the console for easy recall
% x = 17; mep.missed.table(mep.missed.missed(x)-1:mep.missed.missed(x)+2,1:4)
% y = x; mep.table(mep.missed.added(y)-2:mep.missed.added(y)+mep.missed.diffs_missed(y)+2,1:4)
% also:
% unique(diff(mep.missed.table.COUNTER))
% This gives you the gaps - should be 1 + -max when clean