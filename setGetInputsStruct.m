function so=setGetInputsStruct(inList,varargin)
%% setGetInputsStrcut (packaged with dopOSCCIm2)
%
% settings=setGetInputsStruct(inList,[comments])
%
% function to set on/off inputs and place varargin info in a structure for
% use within a program
%
% * requires inList stucture:
% inList.varargin = varargin from calling function
% inList.turnOn
% inList.turnOff
% inList.defaults - defaults for the settings
% - in format 'settings',value,...
% - e.g., .defaults={'tester','name','codeNumber',999}
%
%
% For example:
% egFunction(varargin)
%
%   egFunction inList
%       inList.varargin=varargin;
%       inList.turnOn={'test'};
%       inList.turnOff={'comment'};
%       inList.defaults=struct('codeNumber',999,'gender',1);
%
%       settings=setGetInputs(inList)
%
% - in the egFunction the setGetInputs will:
%      * set the 'test' value to 0 (i.e., starts off and is turned on)
%      * set the 'comment' value to 1 (i.e., starts on and is turned off)
%      * set 'codeNumber' and 'gender' values to 999 and 1 respectively
%      * then it will examine the inList.varargin variable for the presence
%       of the turnOn, turnOff, and settings strings.
%       - the presence of the turnOn or turnOff strings toggles their
%       values
%       - the settings values will be set to the i+1 value of varargin
%       e.g., inList.varargin={'codeNumber',555,'gender',2} results in:
%           codeNumber=555;
%           gender=2;
%       ==> this is similar to the defaults arrangements
%

% global so inList
    

% -------------------------------------------------------------------------
%     'dopOSCCI' summarises functional transcranial Doppler ultrasonography
%     (fTCD) data.  The primary function of the software is to assess the
%     hemispheric lateralization of cognitive function.
%
%     Copyright (C) 2011 the Chancellor, Masters and Scholars of the
%     University of Oxford.
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/> 
%     or write to the Free Software Foundation, Inc., 51 Franklin Street,
%     Fifth Floor, Boston, MA 02110-1301, USA.
%
%     Authors: Nic Badcock, Georgina Holt, Anneka Holden, & Dorothy Bishop.
%       contact: nicholas.badcock@gmail.com
%
try
if isfield(inList,'defaults')
    % set default values for the settings
    % 
    so=inList.defaults;
    so.setGet.defaults=inList.defaults; % shortcut using struct
    so.setGet.settings=fieldnames(so.setGet.defaults);
    so.setGet.list=[];
    for i=1:length(so.setGet.settings)
        so.setGet.list{end+1}=so.setGet.settings{i};
    end
else
    so.setGet.list=[];
    fprintf('%s\n','No ''defaults'' input.');
end
% set setGetInputs Inputs...
so.tmp.tc=0; % temp comment
% if ~isempty(varargin)
%     so.tmp.tc=varargin{1};
% end

if so.tmp.tc
    fprintf('%s\n',['Running ',mfilename]);
end
%% set turnOn/Off values
so.tmp.onOff={'On','Off'};
for i=1:length(so.tmp.onOff)
    so.tmp.OO=['turn',so.tmp.onOff{i}];
    if isfield(inList,so.tmp.OO)
        if ~isempty(inList.(so.tmp.OO))
            for ii=1:length(inList.(so.tmp.OO))
                so.(inList.(so.tmp.OO){ii})=i-1; % starts on/off
                if so.tmp.tc % comment on the way through
                    fprintf('%s\n',['Turn ',so.tmp.onOff{i},' - ',inList.(so.tmp.OO){ii}]);
                end
                so.setGet.list{end+1}=inList.(so.tmp.OO){ii};
            end
        end
    else
        if so.tmp.tc
        fprintf('%s\n',['No ',so.tmp.OO,' input found.']);
        end
        inList.(so.tmp.OO)=[]; % create empty version
    end
end
%% get inputs if there are any
so.setGet.foundList={}; 

if isfield(inList,'varargin')
    so.tmp.nIn=length(inList.varargin);
    if so.tmp.nIn>0
        % check to see what sort of array we have
        if iscell(inList.varargin{1}(1))
            if so.tmp.tc
            fprintf('%s\n','cell array within a cell array - need to get it out');
            end
            for i=1:length(inList.varargin{1})
                try
                    inList.temp{i}=char(inList.varargin{1}(i));
                catch msg
                    inList.msg=msg;
                    inList.temp{i}=inList.varargin{1}{i};
                end
            end
            inList.varargin=inList.temp;
            if ~isnan(str2double(inList.temp));
                inList.varargin=str2double(inList.temp);
            end
            %             display(inList.varargin);
            so.tmp.nIn=length(inList.varargin);
        end
        so.tmp.skip=0;
        for i=1:so.tmp.nIn
            if ~so.tmp.skip
                if so.tmp.tc
                fprintf('%s\n',['varargin ',num2str(i),' = ',inList.varargin{i}]);
                end
                if sum(strcmp(inList.varargin{i},inList.turnOn))==1
                    so.(inList.varargin{i})=1; so.setGet.foundList{end+1}=inList.varargin{i};
                elseif sum(strcmp(inList.varargin{i},inList.turnOff))==1
                    so.(inList.varargin{i})=0; so.setGet.foundList{end+1}=inList.varargin{i};
                elseif sum(strcmp(inList.varargin{i},so.setGet.settings))==1
                    so.(inList.varargin{i})=inList.varargin{i+1}; so.setGet.foundList{end+1}=inList.varargin{i};
                    %                 if ~isnan(str2double(inList.varargin{i+1}));
                    %                     so.(inList.varargin{i})=str2double(inList.varargin{i+1});
                    %                 end
%                     try
%                         if ~isnan(str2double(inList.varargin{i+1}));
%                             so.(inList.varargin{i})=str2double(inList.varargin{i+1});
%                         end
%                     catch
%                         if ~isstruct(inList.varargin{i+1})
%                             if numel(inList.varargin{i+1})==1 && ~isnumeric(inList.varargin{i+1}); % is it a string
%                                 % and then, is can the string be converted to a number
%                                 if isnumeric(str2double(inList.varargin{i+1}))
%                                     so.(inList.varargin{i})=str2double(inList.varargin{i+1});
%                                 end
%                             else
%                                 so.(inList.varargin{i})=inList.varargin{i+1};
%                             end
%                         end
%                     end
                    so.tmp.skip=1;
                end
            else
                so.tmp.skip=0;
            end
        end
        
    end
%     so=rmfield(so,'tmp');
else
    fprintf('\n%s\n\t%s\n',['Error in ',mfilename,...
        ': couldn''t find ''varargin'' inputs.'],...
        'Make sure everything is spelt correctly.');
end

clear inList so.tmp.nIn so.tmp.skip
catch err
    %% catch dopOSCCI error
    % 
    commandwindow; % bring command window to front
    cl=[fileparts(which('dopOSCCI')),'Data\dopOSCCIdebug\']; % caught location
    cfn=['caught_',mfilename,'_',datestr(now,30)]; % caught file name
    cfnl=[cl,cfn]; % caught file name location
    save(cfnl); % save all variables to a mat file
    fprintf('\t%s\n\n\t%s\n\t%s\n\n\n\t%s\n\t\t%s\n',...
            'Error: Saving caught variables:',...
            ['Dir: ',cl],['File: ',cfn],...
            'Access by typing:',['load(''',cfnl,''')']);
    rethrow(err); 
end
