function h=expwave(L,m,cent);
%EXPWAVE   Complex exponential wave.
%   Usage:  h=expwave(L,m);
%           h=expwave(L,m,cent);
%
%   EXPWAVE(L,m) returns an exponential wave revolving m times around the
%   origin. The collection of all waves with wave number m=0,...,L-1
%   forms the basis of the discrete Fourier transform.
%
%   The wave has absolute value 1 everywhere. To get an exponential wave
%   with unit $l^2$-norm, divide the wave by _sqrt(L). This is the
%   normalization used in the DFT function.
%M
%   EXPWAVE(L,m,cent) makes it possible to shift the sampling points by
%   the amount cent. Default is cent=0.
%M  
%   See also: dft, pchirp

%   AUTHOR : Peter Soendergaard
%   TESTING: OK
%   REFERENCE: OK

error(nargchk(2,3,nargin));

if nargin==2
  cent=0;
end;

h = exp(2*pi*i*((0:L-1)+cent)/L*m).';

