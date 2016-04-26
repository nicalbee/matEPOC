function save_fullfile  =  matEPOCdebug
% matEPOC: matEPOCdebug
%
% returns an appropriate file name for save matEPOC error files into
%
% Created: 17-Aug-2015 NAB (borrowed from dopOSCCI (dopStep)
% Edits:
% 22-Aug-2014 NAB updated save_dir and variable names to be more transparent
% 16-Sep-2014 NAB fixed up auto save directory


matEPOCindent;
tmp  =  dbstack;
crash_func = 'test';
if numel(tmp) > 1
    crash_func  =  tmp(2).name;
end
commandwindow; % bring command window to front
fprintf('\n%s\n',['!!! Caught matEPOC error in ',crash_func,'!!!']);

try
    matEPOCversion; % report the version - or at least try to
end
% close any open files:
fclose all;

% get the location of the dopOSCCI function - should be on matlab path
mep_fullfile = which('matEPOCversion'); % dopOSCCI file location
mep_dir = fileparts(mep_fullfile); % dopOSCCI location

% play sound to alert user
try
    dopOSCCIalert('crash');
end
% set save path on same level as dopOSCCI but different directory

save_dir = fullfile([mep_dir,'Data'],mfilename);
% check that the directory exists
if ~exist(save_dir,'dir')
    fprintf('\n\t%s\n','Making directory');
    mkdir(save_dir);
end

% make file name
save_file = ['caught_',crash_func,'_',datestr(now,30)]; % caught file name
save_fullfile = fullfile(save_dir,save_file); % caught file name location

tmp_number = 0; % tmp number for file renaming
while exist([save_fullfile,'.mat'],'file') % add number to make it original
    fprintf('\t%s\n','File exists, creating unique name...');
    tmp_number = tmp_number+1;
    save_file = ['caught_',crash_func,'_',datestr(now,30),'_',num2str(tmp_number)]; % crash file
    save_fullfile = [save_dir,save_file];
end

fprintf('\t%s\n\n\t%s\n\t%s\n\n\n\t%s\n\t\t%s\n\n',...
    'Saving caught variables to:',...
    ['Dir: ',save_dir],['File: ',save_file],...
    'Access by typing: (suggest copy & paste)',['load(''',save_fullfile,''')']);

matEPOCindent('done');
% change something in the gui - later: 25-Apr-2013
% enable 'Run' button of gui so don't have to keep resetting if there's a
% problem
% try
%     set(dg.run.but.h(1),'enable','on')
%     clear dg
% end




