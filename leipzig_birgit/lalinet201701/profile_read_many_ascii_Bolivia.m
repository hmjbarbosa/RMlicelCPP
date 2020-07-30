% function [head, chphy, chraw] = profile_read_many_ascii(list, dbin, dtime, ach)
%
% Reads many Raymetrics/Licel data files at once, applying an analog
% displacement and a dead time correction to each one. Data is output
% as a matlab-structure that span all channels. There are separate
% output for physical and raw units. Headers are also returned.
%
% A test is made to weather all files are in chronological order but
% only a warning is given on the screen! It is also verified if all
% file have the same number of channels or if all channels have the
% same number of bins! In case of differences, empty channels and
% NaN data are added to the smaller files.
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
function [head, chphy] = ...
    profile_read_many_ascii_Bolivia(list, dbin, dtime, ach, maxz)

% size of file list
nfile = numel(list);
if (nfile < 1)
  error('No file listed!');
end

% if dbin not given, displace by zero
if ~exist('dbin','var') dbin=0; end
if isempty(dbin) dbin=0; end
% if dtime not given, no dead time correction
if ~exist('dtime','var') dtime=0; end
if isempty(dtime) dtime=0; end
% if ach not requested, return all channels
if ~exist('ach','var') ach=0; end 
if isempty(ach) ach=0; end 
% if maxz not requested, return all levels
if ~exist('maxz','var') maxz=0; end
if isempty(maxz) maxz=0; end

%% READ EACH FILE
disp(['profile_read_many::READING ' num2str(nfile) ' files']);

for nf=1:nfile
    if (mod(nf, floor(nfile/10))==0)
        disp(['file= ' num2str(nf) '/' num2str(nfile)])
    end
  
  % read file 
  [tmphead, tmpphy]=profile_read_ascii_Bolivia(list{nf}, dbin, dtime, ach, maxz);
  
  %
  if (true)
      disp(['Averaging into 1min bins'])
      minday = floor(tmphead(1).jdi);
      maxday = minday+1;
      dt = 1; %min
      [binphy bintimes bincount]=bins(minday, maxday, dt, tmphead, tmpphy);
      
      n=length(bincount);
      for i=n:-1:1
          if bincount(i)==0
              bincount(i)=[];
              bintimes(i)=[];
              binphy(:,i)=[];
          end
      end
      disp(['Number of bins= ' num2str(length(bincount))])
      disp(['Max bin count= ' num2str(max(bincount))])
      disp(['Min bin count= ' num2str(min(bincount))])
      
      for i=1:length(bintimes)
          tmphead(i).jdi=bintimes(i);
          tmphead(i).jdf=bintimes(i)+dt/1440.;
          tmp=datevec(tmphead(i).jdi);
          tmphead(i).houri = tmp(4:6);
          tmp=datevec(tmphead(i).jdf);
          tmphead(i).hourf = tmp(4:6);
          tmphead(i).nshoots = tmphead(i).nshoots * bincount(i);
          tmphead(i).nshoots2 = tmphead(i).nshoots2 * bincount(i);
          tmphead(i).ch(1).nshoots = tmphead(i).ch(1).nshoots * bincount(i);
      end
      tmphead(length(bintimes)+1:end)=[];
      tmpphy=binphy;
      
      disp(['firsttime= ' datestr(tmphead(1).jdi)])
      disp(['lasttime= ' datestr(tmphead(end).jdi)])
  end
  
  % time-stamp of current file
  if (nf>1)
    if (head(end).jdf > tmphead(1).jdi)
      ['WARNING: list of files not in chronological order! file: ' list{nf}]
      tmphead(1).file
      datestr(tmphead(1).jdf)

      head(end).file
      datestr(head(end).jdf)
    end
  end

  % separate data by channel
  % struct variable 'phy' is nz:nfile
  for ch=1:tmphead(1).nch
    if (nf>1)
      
      % VERIFY: If the vector size changes during the day...
      a=tmphead(1).ch(ch).ndata;
      b=head(end).ch(ch).ndata;
      if (a > b)
        chphy(ch).data(b+1:a,:)=NaN;

        for t=1:length(head)
          head(t).ch(ch).ndata=tmphead(1).ch(ch).ndata;
        end
      end

      head=[head tmphead];
      chphy(ch).data = [chphy(ch).data tmpphy];
    else
      head=tmphead;
      chphy(ch).data = tmpphy;
    end

  end
end
clear tmpphy;
%clear tmpraw;
%