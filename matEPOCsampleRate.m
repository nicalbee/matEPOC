function mep = matEPOCsampleRate(mep)
% sampling rate isn't exactly what's on the box
% use the TIME_STAMP_s & ms data columns to estimate actual rate
%
% Created: 2017-Jan-05 NAB

if isstruct(mep) && isfield(mep,'table') && istable(mep.table)
    
    % initial estimate - before I knew about how the ms worked
    %     tmp.data = mep.table.TIME_STAMP_s;
    %     tmp.data(tmp.data == min(tmp.data)) = [];
    %     tmp.data(tmp.data == max(tmp.data)) = [];
    %     tmp.values = unique(tmp.data);
    %     tmp.Hertz2 = numel(tmp.data) / numel(tmp.values);
        mep.Hertz_theoretical = mep.Hertz;
    %     mep.Hertz_actual = tmp.Hertz2;
    %     mep.Hertz = tmp.Hertz2;
    
    % Geoff Mackellar just mentioned that this could be done:
    
    % There is also a millisec column - that way you can use pretty much the first and last
    % samples in the file - just divide the ms by 1000 and add on to
    % seconds. Go for a long file (20 minutes or more) to get the best
    % accuracy.
    tmp.data_ms = mep.table.TIME_STAMP_ms/1000 + mep.table.TIME_STAMP_s;
    
    mep.Hertz = numel(tmp.data_ms) / (max(tmp.data_ms) - min(tmp.data_ms));
    
    % To count samples, calculate the packet difference using the sample
    % counter diff = mod ( c(n) - c(n-1) , 129 ) and then add up the
    % differences. If the headset drops out for more than about 10 samples
    % you should suspect  longer dropout ( j sec + k missing samples, j =
    % 0, 1, 2 ...) - use the time stamps to calculate missing seconds.

%     tmp.diffs = mod ( diff(mep.table.COUNTER), 129 );
    

    
    fprintf('Hertz on the box = %i\nEstimated from time stamp = %3.4f\n',mep.Hertz_theoretical,mep.Hertz);
end
