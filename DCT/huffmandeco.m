function deco = huffmandeco(comp, dict)
%HUFFMANDECO Huffman decoder.
%    
%    DECO = HUFFMANDECO(COMP, DICT) decodes the numeric Huffman code vector
%    COMP using the code dictionary, DICT. The encoded signal is
%    generated by the HUFFMANENCO function. The code dictionary can be
%    generated using the HUFFMANDICT function.  The decoded signal will be
%    a numeric vector if the original signals are only numeric. If any
%    signal value in DICT is alphanumeric, then the decoded signal will be
%    represented as a single-dimensional cell array.
%    
%    Example:
%         letters = [1:6]; % Distinct symbols the data source can produce
%         p = [.5 .125 .125 .125 .0625 .0625]; % Probability distribution
%         [dict,avglen] = huffmandict(letters,p); % Get Huffman code.
%         sig  = randsrc(1,20,[letters; p]) % Create data using p.
%         comp = huffmanenco(sig,dict)  % Encode the data.
%         deco = huffmandeco(comp,dict) % Decode the encoded signal.
%         equal = isequal(sig,deco) % Check whether the decoding is correct.
%    
%    See also HUFFMANDICT, HUFFMANENCO.

%    References:
%        [1] Sayood, K., Introduction to Data Compression,  Morgan
%             Kaufmann, 2000, Chapter 3, Section 3.2.
%             ISBN: 1-55860-558-4    
%    Copyright 1996-2008 The MathWorks, Inc. 
%    $Revision: 1.1.6.6 $  $Date: 2008/09/13 06:45:59 $


% Error checking ------------------

msg=nargchk(2,2, nargin);
if ( msg )
	error('comm:huffmandeco:InputArgumentCount', msg)
end

[m,n] = size(comp);
if ( m ~= 1 && n ~= 1)
    error('comm:huffmandeco:VectorInputSignal', 'The input signal must be a vector.');
end

%checkDictValidity(dict);

if ( strcmp(class(comp), 'double') == 0 )
	error('comm:huffmandeco:InvalidCodeType', ...
        'The encoded signal has to be a vector of type double.')
end

% End of error checking ----------------------


% isSigNon Numeric is used to later convert the decoded signal from cell
% array format to a double vector.
isSigNonNumeric = max(cellfun('isclass', {dict{:,1}}, 'char') );

deco = {};

i = 1;
while(i <= length(comp))
    tempcode = comp(i); 
    found_code = is_a_valid_code(tempcode, dict);
    while(isempty(found_code) && i < length(comp))
        i = i+1;
        tempcode = [tempcode, comp(i)];
        found_code = is_a_valid_code(tempcode, dict);
    end
    if( i == length(comp) && isempty(found_code) )
        error('comm:huffmanenco:CodeNotFound', ...
            'The encoded signal contains a code which is not present in the dictionary.');
    end
	deco{end+1} = found_code;
    i=i+1;
end

if( n == 1 )         % if input was a column vector
    deco = deco';    % the decoded output should also be a column vector
end

if ( ~isSigNonNumeric )
    decoMat = zeros(size(deco));
    decoMat = feval(class(dict{1,1}), decoMat);  % to support single precision
    for i = 1 : length(decoMat)
        decoMat(i) = deco{i};
    end
    deco = decoMat;
end

%--------------------------------------------------------------------------
% This functions does a reverse lookup for a signal. This function will
% compare the code with the entries in the codebook and return the signal
% if there is  a match
function found_code = is_a_valid_code(code, dict)
found_code = [];
m = size(dict);
for i=1:m(1)
    if ( isequal(code, dict{i,2}) )  
        found_code = dict{i,1};
        return;
    end
end