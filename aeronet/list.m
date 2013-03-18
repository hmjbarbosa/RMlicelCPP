clear day mon

fid=fopen('list_days.txt','r');
M=textscan(fid,'%f/%f/%f %f');
day(:,1)=M{1};
day(:,2)=M{2};
day(:,3)=M{3};
for i=1:size(day,1)
  day(i,4)=datenum(2000+day(i,1),day(i,2),day(i,3),12,0,0);
end
day(:,5)=day(:,4)-datenum(2011,1,1,0,0,0);
day(:,6)=M{4}/1440;
day=sortrows(day,4);
fclose(fid);

% plot
figure(1); clf; 
bar(day(21:end,4), day(21:end,6)*100);
datetick('x','yy/mm');
xlim([datenum(2011,1,1,0,0,0) datenum(2013,1,1,0,0,0)]);
L = get(gca,'XLim');                  
set(gca,'XTick',linspace(L(1),L(2),9))
ylabel('Measured hours per day [%]');
print('lidar_days.png','-dpng');

%=======================================================================

fid=fopen('list_mon.txt','r');
M=textscan(fid,'%f/%f %f');
mon(:,1)=M{1};
mon(:,2)=M{2};
%mon(:,3)=M{3};
for i=1:size(mon,1)
  mon(i,4)=datenum(2000+mon(i,1),mon(i,2),1,0,0,0);
end
mon(:,5)=mon(:,4)-datenum(2011,1,1,0,0,0);
mon(:,6)=M{3}/1440/eomday(mon(i,1),mon(i,2));
mon=sortrows(mon,4);
fclose(fid);

% plot
figure(2); clf; 
bar(mon(4:24,4), mon(4:24,6)*100);
datetick('x','yy/mm');
xlim([datenum(2011,1,1,0,0,0) datenum(2013,1,1,0,0,0)]);
ylabel('Measured hours per month [%]');
print('lidar_months.png','-dpng');
