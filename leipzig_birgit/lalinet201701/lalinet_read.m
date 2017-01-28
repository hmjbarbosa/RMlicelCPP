clear all
%addpath ../matlab
%
%%base='/server/ftproot/private/lalinet/LALINET/';
%base='/Volumes/FTPBACKUP/ftproot/private/lalinet/LALINET/'
%rangebins=4000;
%
%% Argetina
%ff_ar={};
%tmpf=dirpath([base 'Argentina/raw_original/20120911'],'a*'); ff_ar=[ff_ar,tmpf];
%[htmp1, chtmp1] = profile_read_many(ff_ar, 0, 0, 0, rangebins);
%
%ff_ar={};
%tmpf=dirpath([base 'Argentina/raw_original/20120912'],'a*'); ff_ar=[ff_ar,tmpf];
%[htmp2, chtmp2] = profile_read_many(ff_ar, 0, 0, 0, rangebins);
%
%ff_ar={};
%tmpf=dirpath([base 'Argentina/raw_original/20120913'],'a*'); ff_ar=[ff_ar,tmpf];
%[htmp3, chtmp3] = profile_read_many(ff_ar, 0, 0, 0, rangebins);
%
%ff_ar={};
%tmpf=dirpath([base 'Argentina/raw_original/20120914'],'a*'); ff_ar=[ff_ar,tmpf];
%[htmp4, chtmp4] = profile_read_many(ff_ar, 0, 0, 0, rangebins);
%
%for i=1:length(htmp1)
%  tmp=datevec(htmp1(i).jdi);
%  tmp(1)=2012; tmp(2)=9; tmp(3)=11;
%  htmp1(i).jdi=datenum(tmp);
%end
%
%for i=1:length(htmp2)
%  tmp=datevec(htmp2(i).jdi);
%  tmp(1)=2012; tmp(2)=9; tmp(3)=12;
%  htmp2(i).jdi=datenum(tmp);
%end
%head_ar=[htmp1 htmp2 htmp3 htmp4];
%chphy_ar(1).data=[chtmp1(1).data chtmp2(1).data chtmp3(1).data chtmp4(1).data];
%
%%clear htmp1 htmp2 htmp3 htmp4
%%clear chtmp1 chtmp2 chtmp3 chtmp4
%
%% Brasil_Manaus
%ff_ma={};
%tmpf=dirpath([base 'Brasil_Manaus/raw_original/10'],'RM*'); ff_ma=[ff_ma,tmpf];
%tmpf=dirpath([base 'Brasil_Manaus/raw_original/11'],'RM*'); ff_ma=[ff_ma,tmpf];
%tmpf=dirpath([base 'Brasil_Manaus/raw_original/12'],'RM*'); ff_ma=[ff_ma,tmpf];
%tmpf=dirpath([base 'Brasil_Manaus/raw_original/13'],'RM*'); ff_ma=[ff_ma,tmpf];
%tmpf=dirpath([base 'Brasil_Manaus/raw_original/14'],'RM*'); ff_ma=[ff_ma,tmpf];
%[head_ma, chphy_ma] = profile_read_many(ff_ma, 0, 0, 0, rangebins);
%for i=1:length(head_ma)
%  head_ma(i).jdi=head_ma(i).jdi+4./24; % UTC-4 but file saved as local time
%end
%
%%% Brasil_SP
%ff_sp={};
%tmpf=dirpath([base 'Brasil_SP/raw_original/201209/1009/measurement_day'],'RM*'); ff_sp=[ff_sp,tmpf];
%tmpf=dirpath([base 'Brasil_SP/raw_original/201209/1209/measurement_day'],'RM*'); ff_sp=[ff_sp,tmpf];
%tmpf=dirpath([base 'Brasil_SP/raw_original/201209/1409/measurement_day'],'RM*'); ff_sp=[ff_sp,tmpf];
%[head_sp, chphy_sp] = profile_read_many(ff_sp, 0, 0, 0, rangebins);
%
%% Chile
%ff_ch={};
%tmpf=dirpath([base 'Chile/raw_original/110912'],'/a*'); ff_ch=[ff_ch,tmpf];
%tmpf=dirpath([base 'Chile/raw_original/120912'],'/a*'); ff_ch=[ff_ch,tmpf];
%tmpf=dirpath([base 'Chile/raw_original/130912'],'/a*'); ff_ch=[ff_ch,tmpf];
%[head_ch, chphy_ch] = profile_read_many(ff_ch, 0, 0, 0, rangebins);
%for i=1:length(ff_ch)
%  [A DELIM NH]=importdata(ff_ch{i},' ',6);
%  if (isstruct(A))
%    chphy_ch(:,i)=A.data(:,1);
%    
%    head_ch(i).file=A.textdata{1};
%    S=regexp(A.textdata{2}, ' ', 'split');
%    head_ch(i).site=S{1};
%    head_ch(i).jdi=datenum([S{2} ' ' S{3}],'dd/mm/yyyy HH:MM:SS');
%    head_ch(i).jdf=datenum([S{4} ' ' S{5}],'dd/mm/yyyy HH:MM:SS');
%  else
%    disp(['possivel error. i=' num2str(i)])
%  end
%end
%
for i=1:length(head_ch)
  head_ch(i).jdi=head_ch(i).jdi+4./24; % UTC-4 but file saved as local time
end


%