function f=involute(f,dim);
%INVOLUTE  Involution 
%   Usage: finv=involute(f);
%          finv=involute(f,dim);
%
%   INVOLUTE(f) will return the involution of f.
%
%   INVOLUTE(f,dim) will return the involution of f along dimension dim.
%   This can for instance be used to calculate the 2D involution:
%M
%C        f=involute(f,1);
%C        f=involute(f,2);
%M
%   The involution finv of f is given by
%M
%C        finv(l+1)=conj(f(mod(-l,L)+1));
%M
%   for $l=0,...,L-1$.
%
%   The relation between conjugation, Fourier transformation and involution
%   is expressed by
%M
%C      conj(dft(f)) == dft(involute(f))
%M
%   for all signals f. The inverse discrete Fourier transform can be
%   expressed by
%M
%C      idft(f) == conj(involute(dft(f)));
%M
%   See also:  dft, pconv

% Assert correct input.

%   AUTHOR : Peter Soendergaard
%   TESTING: TEST_INVOLUTE
%   REFERENCE: OK

error(nargchk(1,2,nargin));

if nargin==1
  dim=[];
end;

L=[];
[f,L,Ls,W,dim,permutedsize,order]=assert_sigreshape_pre(f,L,dim,'INVOLUTE');

% This is where the calculation is performed.
% The reshape(...,size(f) ensures that f will keep its
% original shape if it is multidimensional.
f=reshape(conj([f(1,:); ...
	  flipud(f(2:L,:))]),size(f));

f=assert_sigreshape_post(f,dim,permutedsize,order);
