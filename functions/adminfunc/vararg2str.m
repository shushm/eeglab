% vararg2str() - transform arguments into string for
%                evaluation using the eval command
%
% Usage:
%   >> strout = vararg2str( allargs );
%   >> strout = vararg2str( allargs, inputnames, inputnum, nostrconv );
%
% Inputs:
%   allargs    - cell array containing all arguments
%   inputnames - cell array of input names for these argument if any
%   inputnum   - vector of indices for all input. If present, the
%                output in the string may is replaced by varargin{num}.
%                include NaN in the vector to avoid specific parameters
%                to be converted in this way.
%   nostrconv  - Vector of 0 and 1 indicating where string 
%                should be not be converted.
%
% Outputs:
%   strout     - output string
%
% Author: Arnaud Delorme, CNL / Salk Institute, 9 April 2002

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) Arnaud Delorme, CNL / Salk Institute, 9 April 2002
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: not supported by cvs2svn $
% Revision 1.1  2002/04/10 00:33:44  arno
% Initial revision
%

function strout = vararg2str(allargs, inputnam, inputnum, int2str );

if nargin < 1
	help vararg2str;
	return;
end;

% default arguments
% -----------------
if nargin < 2
	inputnam(1:length(allargs)) = {''};	
else
	if length(inputnam) < length(allargs)
		inputnam(end+1:length(allargs)) = {''};	
	end;
end;
if nargin < 3
	inputnum(1:length(allargs)) = NaN;
else
	if length(inputnum) < length(allargs)
		inputnum(end+1:length(allargs)) = NaN;	
	end;
end;
if nargin < 4
	int2str(1:length(allargs)) = 0;
else
	if length(int2str) < length(allargs)
		int2str(end+1:length(allargs)) = 0;	
	end;
end;
if ~iscell( allargs )
	allargs = { allargs };
end;

% actual conversion
% -----------------
strout = '';
for index = 1:length(allargs)
	tmpvar = allargs{index};
	if ~isempty(inputnam{index})
		strout = [ strout ',' inputnam{index} ];
	elseif ~isnan(inputnum(index))
		strout = [ strout ',varargin{' num2str(inputnum(index)) '}' ];
	else
		if isstr( tmpvar )
			if int2str(index)
				strout = [ strout ',' tmpvar ];
			else
				strout = [ strout ',' str2str( tmpvar ) ];
			end;
		elseif isnumeric( tmpvar )
			strout = [ strout ',' array2str( tmpvar ) ];
		elseif iscell( tmpvar )
			strout = [ strout ',{' vararg2str( tmpvar ) '}' ];
		elseif isstruct(tmpvar)
			strout = [ strout ',' struct2str( tmpvar ) ];		
		else
			error('Unrecognized input');
		end;
	end;
	
end;
if ~isempty(strout)
	strout = strout(2:end);
end;

% convert string to string
% ------------------------
function str = str2str( array )
	if isempty( array), str = ''''''; return; end;
	str = '';
	for index = 1:size(array,1)
		str = [ str ', ''' doublequotes(array(index,:)) '''' ];
	end;
	if size(array,1) > 1
		str = [ 'strvcat(' str(2:end) ')'];
	else
		str = str(2:end);
	end;	
return;

% convert array to string
% -----------------------
function str = array2str( array )
	if isempty( array), str = '[]'; return; end;
	if prod(size(array)) == 1, str = num2str(array); return; end;
	if size(array,1) == 1, str = [ '[' contarray(array) '] ' ]; return; end;
	if size(array,2) == 1, str = [ '[' contarray(array') ']'' ' ]; return; end;
	str = '';
	for index = 1:size(array,1)
		str = [ str ';' contarray(array(index,:)) ];
	end;
	str = [ '[' str(2:end) ']' ];
return;

% convert struct to string
% ------------------------
function str = struct2str( structure )
	if isempty( structure )
		str = '[]'; return;
	end;
	str = '';
	allfields = fieldnames( structure );
	for index = 1:length( allfields )
		strtmp = '';
		allcontent = eval( [ '{ structure.' allfields{index} '};' ] );
		str = [ str, '''' allfields{index} ''',{' vararg2str( allcontent ) '},' ];
	end;
	str = [ 'struct(' str(1:end-1) ')' ];
return;

% double the quotes in strings
% ----------------------------
function str = doublequotes( str )
	quoteloc = findstr( str, '''');
	if ~isempty(quoteloc)
		for index = length(quoteloc):-1:1
			str = [ str(1:quoteloc(index)) str(quoteloc(index):end) ];
		end;
	end;
return;
	
% test continuous arrays
% ----------------------
function str = contarray( array )
	if all(round(array) == array)
		str = num2str(array(1));
		skip = 0;
		for index = 2:length(array)
			if array(index) ~= array(index-1)+1
				if skip == 0
					str = [str ' ' num2str(array(index))];
				else
					str = [str ':' num2str(array(index-1)) ',' num2str(array(index))];
				end;
				skip = 0;
			else
				skip = skip + 1;
			end;
		end;
		if array(index) == array(index-1)+1
			str = [str ':' num2str(array(index)) ];
		end;
	else
		str = num2str(double(array));
	end;
	