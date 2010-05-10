function s=otoclick()
%OTOCLICK  Load the 'otoclick' test signal.
%   Usage:  s=otoclick;
%
%   OTOCLICK loads the 'otoclick' signal. The signal is a click-evoked
%   otoacoustic emission. It consists of two clear clicks followed by a
%   ringing.
%
%   It was measured by Sarah Verhulst at CAHR (Centre of Applied Hearing
%   Research) at Department of Eletrical Engineering, Technical University
%   of Denmark
%
%   The signal is 2210 samples long and sampled at 44.1 kHz.

%   AUTHOR : Peter Soendergaard
%   TESTING: TEST_SIGNALS
%   REFERENCE: OK
  
if nargin>0
  error('This function does not take input arguments.')
end;

f=mfilename('fullpath');

s=load('-ascii',[f,'.asc']);
