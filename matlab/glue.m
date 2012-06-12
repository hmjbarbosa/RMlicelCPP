function [glued] = glue(analog, photon, header, toplot)

[nz nt] = size(analog);

%% GLUE ALL TIMES
for t=1:nt

  if exist('toplot','var')
    glued(:,t)=glue_single(analog(:,t), photon(:,t), header, toplot);
  else
    glued(:,t)=glue_single(analog(:,t), photon(:,t), header);
  end

end

%