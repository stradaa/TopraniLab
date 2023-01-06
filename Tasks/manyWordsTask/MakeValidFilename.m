% MakeValidFilename.m
%
% Takes a string for a desired filename and makes any changes necessary
% to making this a filename:
%    1. Replace '.' with '_'
%    2. Replace ':' with '-'
%    3. No space at start of file
%    4. no carriage returns
%
% NOTE: Totally not robust yet. As I encounter string properties that I need
% to fix, I'll add them to this list.
%
% USAGE: [ fname ] = MakeValidFilename( str )
%
% EXAMPLE:  
%
% INPUTS:
%     str                       string that may or may not be a valid filename
%
% OUTPUTS:
%     fname                     string which is a valid filename
%
% Created by Sergey Stavisky on 13 Mar 2012

function [ fname ] = MakeValidFilename( str )
    % 1,2
    str = regexprep( str, '\.', '\_' );
    fname = regexprep( str, '\:', '\-' );
    fname = regexprep( fname, '\n', '' );

    % 3
    i = 1;
    while str(i) == ' ';
        i = i + 1;
    end
    if i > 1
        fname = str(i:end);
    end



end