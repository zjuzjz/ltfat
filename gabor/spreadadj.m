function cadj=spreadadj(coef);
%SPREADADJ  Symbol of adjoint spreading function.
%   Usage: cadj=spreadadj(c);
%
%   `cadj=spreadadj(c)` computes the symbol *cadj* of the spreading
%   operator that is the adjoint of the spreading operator with symbol *c*.
%
%   See also:  spreadop, tconv, spreadfun, spreadinv

%   AUTHOR: Florent Jaillet
%   TESTING: TEST_SPREAD
%   REFERENCE: REF_SPREADADJ REF_SPREADADJ_1
  
error(nargchk(1,1,nargin));

if ~isnumeric(coef) || ndims(coef)~=2 || size(coef,1)~=size(coef,2)
    error('Input symbol coef must be a square matrix.');
end;

L=size(coef,1);

% The algorithm used to compute the adjoint symbol can be expressed by
% the following code. See ref_spreadadj_1
%
% cadj=zeros(L);
% for ii=0:L-1
%   for jj=0:L-1
%     cadj(ii+1,jj+1)=conj(coef(mod(L-ii,L)+1,mod(L-jj,L)+1))...
%         *exp(-i*2*pi*ii*jj/L);
%   end;
% end;
%
% The two algorithms below for full and sparse matrices are adaptations
% of this algorithm.

if issparse(coef)
  % implementation for sparse matrix without loop
  
  [row,col,val]=find(coef);
  
  % This array keeps all possible values of the exponential that we could
  % possible need. Indexing this array is faster than computing the
  % exponential directly.
  temp=exp((-i*2*pi/L)*(0:L-1)');
  
  ii=mod(L-row+1, L);
  jj=mod(L-col+1, L);
  cadj=sparse(ii+1,jj+1,conj(val).*temp(mod(ii.*jj,L)+1),L,L);        
  
else
  
  % implementation for full matrix.
  %
  % This implementation uses the direct formula with 
  % the following Optimizations :
  % - Avoiding mod : In the loop of for the explicit case, we see that 
  %   mod(L-ii,L)~=L-ii only for ii==0 (idem for jj), so we can
  %   remove the mod by processing separetly the cases ii==0 or
  %   jj==0.
  % - Precomputation of exp : In the loop of the explicit case, we see that we
  %   compute many time complex exponential terms with the same 
  %   values. Using precomputation and modulo, we can reduce the
  %   computation time
  %    
  
  cadj=zeros(L);
  
  % Proceesing for ii==0 or jj==0
  cadj(1,1)=conj(coef(1,1));
  cadj(2:end,1)=conj(coef(end:-1:2,1));
  cadj(1,2:end,1)=conj(coef(1,end:-1:2));
  
  % Proceesing for ii~=0 and jj~=0
  
  % Precomputation for exponential term  
  temp2=exp((-i*2*pi/L)*(0:L-1));
  
  % Optimization note : Here we are computing indexes for all the
  % exponential terms, which leads to a highly structured matrix
  % which strcture can be formalized (notably it is symetric) and
  % used to reduce the computation cost
  temp=mod((1:L-1)'*(1:L-1),L)+1;
    
  % Finaly we construct the matrix containing all the needed exponential
  % terms. This is (part of) the DFT matrix.
  temp=temp2(temp);
  
  cadj(2:L,2:L)=conj(coef(L:-1:2,L:-1:2)).*temp;    
end;

