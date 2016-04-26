function numsamp = getNumSample(fileStream)
%
% numsamp = getNumSample(fileStream)
%
numsamp = fileStream.records * fileStream.duration * getSamplingRate(fileStream);
end % function

