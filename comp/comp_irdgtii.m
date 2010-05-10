function [cout]=comp_irdgtii(cin,a)
%COMP_IRDGTII Compute inverse real DGT type II
%

M=size(cin,1);
N=size(cin,2);
W=size(cin,3);
L=N*a;

Mhalf=ceil(M/2);
Mend=Mhalf*2-1;

cout=zeros(M,N,W);

% Copy the first coefficient, it is real
cout(1,:,:)=cin(1,:,:);

cout(2:Mhalf,:,:)=(cin(2:2:Mend,:,:)- i*cin(3:2:Mend,:,:))/sqrt(2);
cout(M-Mhalf+2:M,:,:)= -(cin(Mend-1:-2:2,:,:)  +i*cin(Mend:-2:3,:,:))/sqrt(2);

% If f has an even length, we must also copy the Nyquest-wave
% (it is imaginary)
if mod(M,2)==0
  cout(M/2+1,:,:)=-i*cin(M,:,:);
end;

