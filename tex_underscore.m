function s = tex_underscore(s)
% 
% s = tex_underscore(s);
%
% Replaces any underscore charecters in string s with their tex equivalent.
% Useful e.g. for displaying filenames with underscores in figure titles.
%
% s can be a char array, a string, or a cell array containing either of the
% former, in which case the replacement is applied to all elements.
%
% Created by Jonathan Hargreaves so long ago I've forgotten!
% Last updated by Jonathan Hargreaves 29/09/2023

if ischar(s) || isstring(s)
    s = strrep(s, '_', '\_');
elseif iscell(s)
    for i = 1:numel(s)
        if ~(ischar(s{i}) || isstring(s{i}))
            error('argument type not recognised');
        end
        s{i} = strrep(s{i}, '_', '\_');
    end
else
    error('argument type not recognised');
end
        