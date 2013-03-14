clear jd1 days hh good period
% start counting from
jd1=datenum(2011,1,1,0,0,0);
days=aero.jd-jd1+1;

% number of measurements in each day
hh=histc(days,[1:floor(max(days))+1]);
figure(1); plot(hh); title('meas. per day');

% days with a minimum number of measurements in
good=hh>10;

% cound sequency of good days
period(1)=0;
for i=2:size(good,1)
  if good(i)
    period(i)=period(i-1)+1;
  else
    if period(i-1)>7
      disp(['Days: ' num2str(period(i-1)) ' start: ' da ' end: ']);
    end
    period(i)=0;
  end
end



