
%for i=1:ncrop
%  tt(i)=heads_crop(i).jdi;   
%end
%yy=(tt-datenum(2011,1,1,0,0,0));     

nslot=(jdf-jdi)*1440/5+1;
data(1:2000,1:nslot)=NaN;
yy=((1:nslot)-1)*5/1440+jdi-datenum(2011,1,1,0,0,0);

for i=1:ncrop
  j=floor((heads_crop(i).jdi-jdi)*1440/5+0.5)+1;
  data(:,j)=chphy(6).rcs(1:2000,i);
end

gplot2(data,[0:1.e7:1.5e9],yy,zh(1:2000,1)/1e3)

%