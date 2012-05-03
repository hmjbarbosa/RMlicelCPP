% function [list] = dirpath(direc,wildcard)
% 
% Uses dir() and fullfile() intrinsic routines to build a cell array
% of filenames inside directory direc that match the given
% wildcard. To get a list of full paths, fullfile has to be used twice
% because dir() only return the name of the files, without the paths.
%
% Example:
%
% If my files are stored somewhere, I could do:
%
%    >> mylist = dirpath('/path/to/somewhere', 'my_files_start_with*');
%
% And access the list as:
%
%    >> mylist(1)
%
%    ans =  
%        '/path/to/somewhere/my_files_start_with_end_with_this'
%
% But if my files are spread on different directories:
%
%    >> f1 = dirpath('/some/path/','*.bin');
%    >> f2 = dirpath('/other_path/','*.dat');
%
% I can simply concatenate two lists:
%
%    filelist={f1{:} f2{:}};
%
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