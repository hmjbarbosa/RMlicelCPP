% function [head, chphy, chraw] = profile_read_many(list, dbin, dtime, ach)
%
% Reads many Raymetrics/Licel data files at once, applying an analog
% displacement and a dead time correction to each one. Data is output
% as a matlab-structure that span all channels. There are separate
% output for physical and raw units. Headers are also returned.
%
% Input:
% 
%    list: cell array of full path to each data file
% 
%    dbin: delay, in number of bins, between analog and PC channels
%
%   dtime: dead time (in us) for a correction like like S/(1-S*dtime)
%
%     ach: read only channel number 'ach', instead of all channels
%
% Output:
%
%    head: Is an array of matlab structures each containing all
%          information in the header of one file. Its size is the same
%          as the size of list.
%
%   chphy: Is an array of size equal to the number of channels. Each
%          position holds a variable called data() which is a matrix
%          with vertical bins as rows, and files (time) as
%          columns. Values are in physical units.
%
%          This way, chphy(1) is a matrix of time x vertical of
%          first channel.
%
%   chraw: Same as chphy, but with raw data. 
%
% Note:
%
% No test is made to weather all files are in chronological order!
% or even if they all have the same number of channels!! or
% even more, if all channels have the same number of bins!!!
%
% Usage:
%
% The list of files can be built using dirpath() and you should read
% its documentation. Now, if your files are all in the same directory,
% and they need 10 bin analog and 4ms dead-time corrections you should
% do:
%
%    >> f1 = dirpath('/lidar_path/','RM*');
%
%    >> [allhead, chphy] = profile_read_many(f1, 10, 0.04);
%
% If you have files spread over two directories and they need no
% correction and you also want to have the raw data:
%
%    >> f1 = dirpath('/lidar_path/','RM*');
%    >> f2 = dirpath('/lidar_path/','RM*');
%
%    >> files = {f1{:} f2{:}};
%    >> numel(files)
%    ans = 
%             253
%
%    >> [allhead, chphy, chraw] = profile_read_many(files);
%
% Your data will be available as a matrix with one column for each
% file, and one row for each vertical bin.  Let's look at channel
% 3, if the first and last profiles have the same size:
%
%    >> allhead(1).ndata(3)
%    ans = 
%            4000
%
%    >> allhead(253).ndata(3)
%    ans = 
%            4000
%
%    >> size(chphy(3).data)
%    ans =
%          4000     253    
%
%  You can plot this data as:
%
%    >> contourf( (1:253), (1:4000), chphy(3).data );
%
function [head, chphy, chraw] = profile_read_many(list, dbin, dtime, ach)

% size of file list
nfile = numel(list);
if (nfile < 1)
  error('No file listed!');
end

% if dbin not given, displace by zero
if ~exist('dbin','var') dbin=0; end
% if dtime not given, no dead time correction
if ~exist('dtime','var') dtime=0; end
% if ach not requested, return all channels
if ~exist('ach','var') allch=true; else allch=false; end 

%% READ EACH FILE
['READING ' num2str(nfile) ' files']
for nf=1:nfile
  if mod(nf, floor(nfile/10))==0
    ['file= ' num2str(nf) '/' num2str(nfile)]
  end
  
  % read file 
  if allch
    [head(nf), tmpphy, tmpraw]=profile_read(list{nf}, dbin, dtime);
  else
    [head(nf), tmpphy, tmpraw]=profile_read(list{nf}, dbin, dtime, ach);
  end

  % time-stamp of current file
  if (nf>1)
    if (head(nf).jdf < head(nf-1).jdf)
      ['WARNING: list of files not in chronological order!']
    end
  end
  
  % separate data by channel
  % struct variable 'phy' is nz:nfile
  for ch=1:head(nf).nch
    % NOTE: nf is the index of the file just read. User must pay
    % atention and provide a list of files in chronological order!
    chphy(ch).data(:,nf) = tmpphy(:,ch);
    chraw(ch).data(:,nf) = tmpraw(:,ch);
  end
  
end
clear tmpphy;
clear tmpraw;
%