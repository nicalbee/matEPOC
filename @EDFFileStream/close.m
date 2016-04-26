function fileStream = close(fileStream)
%
% Close the EDF file
%
    fclose(fileStream.fid);
    fileStream.fid = 0;
end