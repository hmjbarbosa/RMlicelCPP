function [P, times, count] = bins(minday,maxday,dt,heads,data) 

% Divide the period between minday and maxday into intervals of
% size dt minutes
ntimes=floor((maxday-minday)*1440./dt);

% Create the vector of times (start of each interval)
times=((0:ntimes-1))*dt/1440.+minday;

% Initialize variables
P(size(data,1), ntimes)=0;
count(ntimes)=0;

% Go over all profiles read and accumulate them into time-bins of
% size dt-minutes
clear list
for j=1:size(data,2)
  % to which bin should the j-th profile contribute
  idx=floor((heads(j).jdi-minday)*1440./dt)+1;
  if (idx>=1 & idx<=ntimes) 
    % how many profiles were added to this bin? 
    count(idx)=count(idx)+1;
    % accumulate the data
    P(:,idx)=P(:,idx)+data(:,j);
  end
end
% For each dt interval, divide sum / counts
for j=1:ntimes
  if (count(j)>0)
    P(:,j)=P(:,j)./count(j);
  end
end
% And set as NaN if no profile were read into that bin
P(:,count==0)=NaN;

%fim