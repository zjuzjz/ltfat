status=1;

% Add entry to the dynamic classpath if JVM is present.
if ~isempty(which('javaaddpath')) 
   try
      % Here it gets somewhat confusing. This script is called in
      % ltfatstart, but the jar is created in ltfatmex. It prints nasty
      % warning, if it cannot find the jar. Adding a folder to the classpath,
      % which is then filled with compiled classes by ltfatmex is fine. 
      %
      % Moreover, according to the Matlab documentation:
      %
      % MATLAB calls the 'clear java' command whenever you change the dynamic path. 
      % It clears definition of all Java classes defined by files on the dynamic class path,
      % removes all variables from the base workspace, and removes all compiled scripts, functions,
      % and MEX-functions from memory.

      jarFile = 'blockproc.jar';
      javaDirPath = [basepath,filesep,'blockproc',filesep,'java'];
      jarPath = [javaDirPath,filesep,jarFile];
      
      if exist(jarPath,'file')
         if any(cellfun(@(cpEl)strcmp(cpEl,javaDirPath),javaclasspath))
            javarmpath(javaDirPath);
         end
         % Adding a jar file. Once added to the classpath, it cannot be
         % deleted. Removing it from the classpath issues again the 'clear
         % java' command, but the jar canot be romeved while Matlab is
         % running.
         % http://www.mathworks.com/support/solutions/en/data/1-37JYLQ/?product=ML&solution=1-37JYLQ
         javaaddpath([basepath,filesep,'blockproc',filesep,'java',filesep,jarFile]);
      else
         % Adding directory with *.class files. Does not block.
         javaaddpath([basepath,filesep,'blockproc',filesep,'java']);
      end
   catch 
       % Use lasterr for Octave compatibility
       err=lasterr;
       if ltfatstartprint
           warning('%s: JVM support not present.',upper(mfilename));
       end;
   end
else
    if ltfatstartprint
        warning('%s: Java toolbox not present.',upper(mfilename));
    end;
end