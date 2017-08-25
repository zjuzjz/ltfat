function test_failed = test_libltfat_maxtree(varargin)
test_failed = 0;

fprintf(' ===============  %s ================ \n',upper(mfilename));

definput.flags.complexity={'double','single'};
[flags]=ltfatarghelper({},definput,varargin);
dataPtr = [flags.complexity, 'Ptr'];

Larr =    [100,101,500,501,1025];
darr =    1:10;

for repeat = 1:10000
  for depth = darr
    
for Lidx = 1:numel(Larr)
    
    L = Larr(Lidx);

    
    f = cast(randn(L,1)',flags.complexity);

    fPtr = libpointer(dataPtr,f);
    
    funname = makelibraryname('maxtree_initwitharray',flags.complexity,0);
    
    p = libpointer();
    
    calllib('libltfat',funname,L,depth,fPtr,p);
    
    maxPtr = libpointer(dataPtr,5);
    maxposPtr = libpointer('int64Ptr',cast(5,'int64'));
    
    
    funname = makelibraryname('maxtree_findmax',flags.complexity,0);
    status=calllib('libltfat',funname,p,maxPtr,maxposPtr);
    
    fprintf('max=%.3f, maxPos=%d\n',maxPtr.value, maxposPtr.value);
    
    fPtr.value(end) = 1000;
    
    funname = makelibraryname('maxtree_updaterange',flags.complexity,0);
    status=calllib('libltfat',funname,p,L-1,L);
    
    funname = makelibraryname('maxtree_findmax',flags.complexity,0);
    status=calllib('libltfat',funname,p,maxPtr,maxposPtr);
    
    fprintf('max=%.3f, maxPos=%d\n',maxPtr.value, maxposPtr.value);
    
    
    [fmax,fIdx] = max(fPtr.value);
    
    fprintf('max=%.3f, maxPos=%d\n', fmax, fIdx -1);
    
    [test_failed,fail]=ltfatdiditfail(maxPtr.value-fmax + maxposPtr.value - (fIdx -1) ,test_failed,0);
    fprintf(['MAXTREE L:%3i, %s %s %s\n'],L,flags.complexity,ltfatstatusstring(status),fail);
    
    funname = makelibraryname('maxtree_done',flags.complexity,0);
    calllib('libltfat',funname,p);

end
  end
end


