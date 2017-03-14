function col_out = matEPOCplotColours(type,comment)
% dopOSCCI3: dopNew
%
% notes:
% basic structure of a function to save time when creating a new one
%
% * not yet implemented (19-Dec-2013)
%
% Use:
%
% [dop,okay,msg] = dopNew(dop,[]);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 29-Aug-2014 NAB
% Last edit:
% 29-Aug-2014 NAB
% 14-Mar-2017 NAB random colour if it's not included (using colormap)
% 14-Mar-2017 NAB adjust to 'know' the 14 regular channels

% if ~exist('okay','var') || isempty(okay)
%     okay = 0;
% end
% if ~exist('msg','var')
%     msg = [];
% end
% msg{end+1} = sprintf('Run: %s',mfilename);
%
col_out = [0 0 1]; % default colour
if ~exist('type','var') || isempty(type)
    type = [];
end
if ~exist('comment','var') || isempty(comment)
    comment = 0;
end
try
%     dopOSCCIindent('run',comment);%fprintf('\nRunning %s:\n',mfilename);
    % rgb (red geen blue) coordindates
    cmap = colormap('HSV');
    colours = struct(...
        'AF3',cmap(1,:),...
        'F7',cmap(5,:),...
        'F3',cmap(9,:),...
        'FC5',cmap(14,:),...
        'T7',cmap(19,:),...
        'P7',cmap(24,:),...
        'O1',cmap(29,:),...
        'O2',cmap(34,:),...
        'P8',cmap(39,:),...
        'T8',cmap(44,:),...
        'FC6',cmap(49,:),...
        'F4',cmap(54,:),...
        'F8',cmap(59,:),...
        'AF4',cmap(64,:),...
        'a',[0 0 1],...
        'b',[1 0 0],...
        'c',[0 1 0],...
        'Ch1',[.2 .5 .9],...
        'Ch2',[1 .5 0],...
        'use',[0 .8 .3],...
        'gap',[.5 0 .5],...
        'flag',[.3 0 .3],...
        'changes',[1 0 0],... % red; [1 0 1], ... % magenta/pink
        'difference',[.8 .8 0],...
        'conditions',[0 0 1],...
        'markers',[0 .8 .3],...
        'act_correct',[0 .5 .5],... ?
        'rawleft',[0 1 1],... % cyan
        'rawright',[1 0 1],... % magenta
        'correctleft',[0 0 .8],...
        'correctright',[.8 0 0],...
        'hc_events',[.8 .6 0],...
        'xzero',[.9 .9 .9], ... % faint grey
        'yzero',[.9 .9 .9], ... % faint grey
        'zero',[.9 .9 .9], ... % faint grey
        'left',[0 0 .8],... % blue
        'right',[.8 0 0],... % red
        'event',[0 .7 .2],... % green
        'average',[.4 0 .4],... ?
        'epoch',[.8 .6 0], ... orange?
        'poi',[0 1 .2],... % light green
        'act_window',[.8 .8 0],... yellow?
        'baseline',[0 0 0]... % black
        );
    if isempty(type)
        col_out = colours;
    else
        if isfield(colours,type)
            col_out = colours.(type);
            if comment
                fprintf('Colour for %s: [%1.1f %1.1f %1.1f]',type,col_out);
            end
        else
            fprintf('Type (%s) unknown colour, defaulting to random\n',type');
            cmap = colormap;
            cmap_perm = randperm(size(cmap,1));
            col_out = cmap(cmap_perm(1),:);
        end
    end
    
%     dopOSCCIindent('done',comment);%fprintf('\nRunning %s:\n',mfilename);
catch err
%     save(dopOSCCIdebug);
rethrow(err);
end
end
