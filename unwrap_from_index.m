function Q = unwrap_from_index(P, varargin)
%
% Q = unwrap(P,i)
% Q = unwrap(P,i,tol)
% Q = unwrap(P,i,[],dim)
% Q = unwrap(P,i,tol,dim)
%
% As unwrap, but starts from bin i and unwraps bidirectionally from there.
% Useful when data at both ends of a spectrum is noisy, so you want to
% start the phase unwrapping from a known bin where the data is reliable.

switch nargin
    
    case 1
        error('unwrap_from_index requires at least two arguments')
        
    case 2
        i = varargin{1};
        tol = [];
        dim = find(size(P)>1,1,'first');
        
    case 3
        i = varargin{1};
        tol = varargin{2};
        dim = find(size(P)>1,1,'first');
        
    case 4
        tol = varargin{1};
        dim = varargin{2};
        i = varargin{3};
        
    otherwise
        error('unwrap_from_index accepts at most four arguments')
        
        
end

if (dim<=0) || (dim>ndims(P))
    error('dim must be positive and smaller than or equal to ndims(P)')
end

if (i<2) || (i>size(P,dim))
    error('i must be greater than 1 and smaller than or equal to size(P,dim)')
end

% Get a multi-dimensional slice of P (uses cell-array indexing trick from
% https://uk.mathworks.com/matlabcentral/answers/757464-how-can-i-extract-a-slice-from-a-multidimensional-array)    
c1 = repmat({':'},1,ndims(P));
c2 = repmat({':'},1,ndims(P));
c1{dim} = 1:i-1;
c2{dim} = i:size(P,dim);

% Perform the unwrapping on the two slices independently, using the
% built-in unwrap function, then concatenate:
Q = cat(dim, flip(unwrap(flip(P(c1{:}), dim), tol, dim), dim), unwrap(P(c2{:}), tol, dim));
