function [glued a b] = glue(anSignal, anChannel, pcSignal, pcChannel, toplot)

[nz nt] = size(anSignal);

%% GLUE ALL TIMES
for t=1:nt
  if exist('toplot','var')
    disp(['t= ' num2str(t)]);
  end
  if exist('toplot','var')
    [glued(:,t) a(t) b(t)]=glue_single(anSignal(:,t), anChannel, ...
                           pcSignal(:,t), pcChannel, toplot);
  else
    [glued(:,t) a(t) b(t)]=glue_single(anSignal(:,t), anChannel, ...
                           pcSignal(:,t), pcChannel);
  end
end

%