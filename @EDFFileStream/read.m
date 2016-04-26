function [fileStream, data] = read(fileStream)
% 
% Output data that has been stored in the class's internal buffer according
% to the sample index.
%

% switch opt
%     case 1

% Set buffer size for convenience
bufsize = fileStream.duration * fileStream.samplerate(1);

% Set sample offset
so = mod(fileStream.sample_index,bufsize);

% Update the buffer whenever we start at the first sample of each record
if (so == 0)
    fileStream.buffer = fread(fileStream.fid, [bufsize fileStream.channels], 'int16');
    if isempty(fileStream.buffer), data = []; return, end
end
% Acquire data from the buffer
if (so+fileStream.nDataRead) <= bufsize
    data = fileStream.buffer( so+(1:fileStream.nDataRead), :);
else
    % If the required data is in the next record, we need to update the 
    % buffer after acquiring the data in the current buffer.
    data = fileStream.buffer( (so+1):end, :);
    fileStream.buffer = fread(fileStream.fid, [bufsize fileStream.channels], 'int16');
    if isempty(fileStream.buffer), data = []; return, end
    data = [data; fileStream.buffer( 1:(fileStream.nDataRead - (bufsize-so)), :)];
end
% Convert the data from its digital range to physical range
digimin = fileStream.digimin';
physmin = fileStream.physmin';
scale = ((fileStream.physmax-fileStream.physmin) ./ (fileStream.digimax-fileStream.digimin))';
data = (data - digimin(ones(size(data,1),1),:)) .* scale(ones(size(data,1),1),:) ...
    + physmin(ones(size(data,1),1),:);

% Update the sample index
fileStream.sample_index = fileStream.sample_index + fileStream.nDataRead;


end