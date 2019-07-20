%% extract_from_adjusted_cluster
% Plots contrast estimates from a cluster.
% Options:
% opts_clust.size = 
%   1 for whole cluster, (default)
%   2 for adjusted cluster (see adjust_cluster)
% opts_clust.inset:
%   0 prints clean to gcf
%   1 for clear, 
%   2 or mip inset (default);
%   3 for do nothing (clean stays hidden with handle figure(f))
%   4 for plot w/ sections (awesome shit)
%opts_clust.suppress4: using opt 4, suppress output
%cd(SPM.swd)

voxel_or_cluster = 2;
demean = 1;

Ic = 2; % which contrast to extract estimates from: F con usually
t = {    'Clothes'    'Musical ins'    'Tools'    'Household'    'Leisure'  'Materials'    'Transport' 'Animals-Water'    'Animals-Insects'    'Animals-Domestic' 'Animals-Wild'    'Animals-Birds'    'Fruits & Veg' 'Food & Drink'    'Flora' 'Outdoors'    'Bodyparts' 'control task'};
%t = {    'Clothes'    'Musical ins'    'Tools'    'Household'    ''  'Materials'    'Transport' 'Animals-Water'    'Animals-Insects'    'Animals-Domestic' 'Animals-Wild'    'Animals-Birds'    'Fruits & Veg' 'Food & Drink'    'Flora' 'Outdoors'    'Bodyparts' 'control task'};
T_leg = t; % Tasks: Are they  or t_old?
[xyzmm,i] = spm_XYZreg('NearestXYZ',...
spm_results_ui('GetCoords'),xSPM.XYZmm);
spm_results_ui('SetCoords',xSPM.XYZmm(:,i));
A = spm_clusters(xSPM.XYZ); % gets all clusters
j = find(A == A(i));

if voxel_or_cluster == 2
XYZ = xSPM.XYZ(:,j);
XYZmm = xSPM.XYZmm(:,j);
else
XYZ = xSPM.XYZ(:,i);
XYZmm = xSPM.XYZmm(:,i);
end
    
disp(['Cluster ' num2str(A(i)) '/' num2str(max(A)) ' Size ' num2str(length(XYZmm))])
%
% Average across voxels
% if opts_clust.size == 1
beta  = spm_get_data(SPM.Vbeta, XYZ);
ResMS = spm_get_data(SPM.VResMS,XYZ);
% else
% adjust_cluster
% beta  = spm_get_data(SPM.Vbeta, adj_cluster_XYZ);
% ResMS = spm_get_data(SPM.VResMS,adj_cluster_XYZ);
% end
vx = length(beta);
beta = mean(beta,2);
ResMS = mean(ResMS,2);
Bcov  = ResMS*SPM.xX.Bcov;

CI    = 1.6449;
% compute contrast of parameter estimates and 90% C.I.
%------------------------------------------------------------------
cbeta = SPM.xCon(Ic).c'*beta;
SE    = sqrt(diag(SPM.xCon(Ic).c'*Bcov*SPM.xCon(Ic).c));
CI    = CI*SE;
% Plot errorbar
%clf
f = figure(500);
%subplot(2,1,1);
if demean
    cbeta = cbeta-mean(cbeta);
end

bar(cbeta)
hold on
errorbar(cbeta,CI,'rx')

title({xSPM.title ['Cluster ' num2str(A(i)) '/' num2str(max(A)) ' Size ' num2str(vx) ' Voxels']})
xticks(1:numel(T_leg))
set(gca,'XTickLabel',T_leg)
xtickangle(45)
hold off