figure(3)
subplot(2,2,1)
g=plot(alt(qq:ww),log(sigin(qq:ww,1)),'o',alt(qq:ww),fval(qq:ww,1),'r');
title('signal')
ay=get(gca,'ylim');
if ~isnan(base(1)) 
  line([alt(base(1)) alt(base(1))],ay,'color','red'); 
  idx=base(t)-2*FIT_SLOPE_NPT-1;
  clear yy yy1 yy2;
  yy=(linear(idx,t)+slope(idx,t)*alt(qq:ww));
  yy1=(linear(idx,t)+slope(idx,t)*alt(qq:ww)+BASE_BG_SNR*relerr(idx,t));
  yy2=(linear(idx,t)+slope(idx,t)*alt(qq:ww)-BASE_BG_SNR*relerr(idx,t));
  hold on;
  plot(alt(qq:ww),yy,'b-',alt(qq:ww),yy1,'b--',alt(qq:ww),yy2,'b--');
  hold off;
end
if ~isnan(peak(1)) line([alt(peak(1)) alt(peak(1))],ay,'color','green'); end
if ~isnan(top(1) ) line([alt(top(1))  alt(top(1)) ],ay,'color','black'); end
grid on

subplot(2,2,2)
plot(alt(qq:ww), slope(qq:ww,1),'o-');
title('angular coeff')
ay=get(gca,'ylim');
if ~isnan(base(1)) line([alt(base(1)) alt(base(1))],ay,'color','red'); end
if ~isnan(peak(1)) line([alt(peak(1)) alt(peak(1))],ay,'color','green'); end
if ~isnan(top(1) ) line([alt(top(1))  alt(top(1)) ],ay,'color','black'); end
grid on

subplot(2,2,3)
plot(alt(qq:ww),linear(qq:ww,1));
title('linear coeff')
ay=get(gca,'ylim');
if ~isnan(base(1)) line([alt(base(1)) alt(base(1))],ay,'color','red'); end
if ~isnan(peak(1)) line([alt(peak(1)) alt(peak(1))],ay,'color','green'); end
if ~isnan(top(1) ) line([alt(top(1))  alt(top(1)) ],ay,'color','black'); end
grid on

subplot(2,2,4)
plot(alt(qq:ww) ,relerr(qq:ww,1));
title('S')
ay=get(gca,'ylim');
if ~isnan(base(1)) line([alt(base(1)) alt(base(1))],ay,'color','red'); end
if ~isnan(peak(1)) line([alt(peak(1)) alt(peak(1))],ay,'color','green'); end
if ~isnan(top(1) ) line([alt(top(1))  alt(top(1)) ],ay,'color','black'); end
grid on

key = waitforbuttonpress;
