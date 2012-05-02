function [glued] = glue(analog, photon, header)

[nz nt] = size(analog);

%% GLUE ALL TIMES
for t=1:nt

  glued(:,t)=glue_single(analog(:,t), photon(:,t), header);

end

%