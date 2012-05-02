function [list] = dirpath(direc,wildcard)

filelist=dir(fullfile(direc,wildcard));
files={filelist.name}';

if numel(files)>0
  for i=1:numel(files)
    list{i}=fullfile(direc,files{i});
  end
else
  list=cell(1);
end



%