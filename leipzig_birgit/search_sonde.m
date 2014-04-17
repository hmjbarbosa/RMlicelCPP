
ff=dirpath(radiodir,'82332*.dat');

% Check if any files were found
nfile=numel(ff);
if (nfile < 1)
  disp(['No files found!']);
  return
end

% from all files listed, check those closer to [jdi, jdf]
for i=1:nfile
  jd(i)=datenum(SONDEname2date(ff{i}));
end
[minjdi, posjdi]=min(abs(jd-jdi));
[minjdf, posjdf]=min(abs(jd-jdf));

radiofile=ff{posjdi};
disp(['*** distance do jdi = ' num2str(minjdi) ' days'])
%