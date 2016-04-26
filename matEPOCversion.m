function varargout = matEPOCversion
% matEPOCversion
%
% reports the version number of the matEPOC toolbox
% see 'readme' for further details
%
% author: Nic Badcock
% email: nicholas.badcock@mq.edu.au
%
% note: version 1 was labelled 'evn' (Emotiv vs Neuroscan)
%
% created: 17-Aug-2015

mep_version = '2.0.0';
mep_date = 'Monday 17th of August 2015';
mep_out = [mep_version,': ',mep_date];
fprintf('Matlab version: %s\n',version);
fprintf('matEPOC version number is %s\n > last modified on %s\n',...
    mep_version,mep_date);

varargout{1} = mep_out;
