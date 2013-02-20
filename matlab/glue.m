function [glued] = glue(anSignal, anChannel, pcSignal, pcChannel, toplot)

[nz nt] = size(anSignal);

%% GLUE ALL TIMES
for t=1:nt
  if exist('toplot','var')
    glued(:,t)=glue_single(anSignal(:,t), anChannel, ...
                           pcSignal(:,t), pcChannel, toplot);
  else
    glued(:,t)=glue_single(anSignal(:,t), anChannel, ...
                           pcSignal(:,t), pcChannel);
  end
end

%