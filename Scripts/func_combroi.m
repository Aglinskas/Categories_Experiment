function [cmats] = func_combroi(wh_rois,voxel_data)
% function [cmats] = func_combroi(wh_rois,voxel_data)
%Needs:
%voxel_data.mat_files % ROIS
%voxel_data.dt{r_ind,t,s} % Data

if nargin==0
 clc;help func_combroi;
else
if ~isfield(voxel_data,'mat_files') | ~isfield(voxel_data,'dt')
    disp(voxel_data)
    error('either mat_files or dt missing')
end

if ndims(voxel_data.dt)~=3;error('not 4 dims, please check');end

% QA
disp(sprintf('ROIs:%d,Tasks:%d,Subs:%d',size(voxel_data.dt,1),size(voxel_data.dt,2),size(voxel_data.dt,3)))


for s = 1:size(voxel_data.dt,3);
mat = [];
for r = 1:length(wh_rois);
c = [];
r_ind = find(strcmp(voxel_data.mat_files,wh_rois{r}));
for t = 1:size(voxel_data.dt,2);
dt = voxel_data.dt{r_ind,t,s};
c(:,t) = dt;
end % t loop

if isempty(mat); 
mat = c;
else
mat = [mat;c];
end % if statement
end % R loop
s_cmat = corr(mat);
cmats(:,:,s) = s_cmat;
end % ends subject loop


end