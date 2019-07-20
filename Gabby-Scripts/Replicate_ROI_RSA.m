%% Clear Eniviroment
clear all; close all;
%% Load Data
load('Files/netRSA_data3.mat');
%% Semantic model
load('Files/wikiClust16.mat');
netRSA_data.model = wikiClust.cmat;
% has to be 16x16 semantic model
%% Reshape Data
netRSA_data.rlbs = netRSA_data.rlbls;
tlbls = netRSA_data.tlbs;
    tlbls([5 18]) = [];
% Reshape Voxel Data
for r = 1:size(netRSA_data.voxel_data,1);
    rmat = [];
for s = 1:18
for c = 1:18
for b = 1:3
v = netRSA_data.voxel_data{r,c,s,b};
rmat(c,s,b,:) = v;
end
end
end
rmats{r} = rmat;
end
% Voxel Corr
cmats = [];
for r = 1:size(netRSA_data.voxel_data,1)
for s = 1:18
for b = 1:3
mat = squeeze(rmats{r}(:,s,b,:));
mat([5 18],:) = [];
mat = mat-mean(mat,1); % centering       
cmats(:,:,r,s,b) = corr(mat','rows','pairwise');
end
end
end
sum(isnan(cmats(:)))
%% Single ROI RDM

r = 1; % ROI index, check netRSA_data.rlbls

    cmat_2d = mean(mean(cmats(:,:,r,:,:),5),4);
    cmat_3d = squeeze(mean(cmats(:,:,r,:,:),5));
    func_plot_dendMat(cmat_2d,tlbls)

    [H,P,CI,STATS]  = ttest(func_fit_RSA_model(cmat_3d,netRSA_data.model));
    title({netRSA_data.rlbls{r} t_statement(STATS,P)},'fontsize',20);
