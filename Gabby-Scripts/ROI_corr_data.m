%netRSA_add_corr
clear all;
load('Files/netRSA_data3.mat')

netRSA_data.mat(:,[5 18],:,:) = [];
netRSA_data.voxel_data(:,[5 18],:,:) = [];
netRSA_data.tlbs([5 18]) = [];
%% ROI-cmats
nrois = size(netRSA_data.mat,1);
nsubs = size(netRSA_data.mat,3);
nconds = size(netRSA_data.mat,2);
%%
r = 1;
for r = 1:nrois
nvox = length(netRSA_data.voxel_data{r,1,1,1});
rmat = reshape([netRSA_data.voxel_data{r,:,:,:}],[16,18,3,nvox]);
rmat = squeeze(mean(rmat,3));


for s = 1:nsubs
%for o = 1:3;
   CondbyVoxel = squeeze(rmat(:,s,:));
   %CondbyVoxel = CondbyVoxel - mean(CondbyVoxel,1);
   rmcats(r,:,:,s) = corr(CondbyVoxel');
   
%end
end
end
%%
%rmcats = mean(rmcats,5);
corrData.rcmats = rmcats;
corrData.legend = 'ROI|Cond1|Cond2|Subject';
corrData.rlbls = netRSA_data.rlbls;
corrData.tlbls = netRSA_data.tlbs;

save('Files/corrData.mat','corrData')