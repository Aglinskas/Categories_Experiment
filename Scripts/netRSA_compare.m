loadMR
%%
voxel_data = struct;
voxel_data.mat_files = netRSA_data.rlbs;
voxel_data.dt = netRSA_data.voxel_data;

vx_new = [];
vx = netRSA_data.voxel_data;
%vx(:,[5],:,:) = [];
for r = 1:size(vx,1)
for t = 1:size(vx,2)
for s = 1:size(vx,3)
tiny = [];
for run_ind = 1:size(vx,4)
tiny(run_ind,:) = vx{r,t,s,run_ind};
tiny(run_ind,:) = vx{r,t,s,run_ind} - vx{r,18,s,run_ind};
%tiny(run_ind,:) = vx{r,t,s,run_ind} - mean(vx{r,t,s,run_ind});
    
end
%tiny = tiny - mean(tiny);
vx_new{r,t,s} = mean(tiny);
end
end
end

vx_new(:,[5 18],:) = []
voxel_data.dt = vx_new;
[cmats] = func_combroi(voxel_data.mat_files,voxel_data);
cmats_vx = cmats;

data = cmats; 
model  = netRSA_data.model;
model_fit_vx = func_fit_RSA_model(data,model);

figure(1);clf;
func_plot_tbar_plot([model_fit_vx netRSA_fit],{'vx' 'netRSA'});


[H,P,CI,STATS] = ttest(model_fit_vx,netRSA_fit);
t_statement(STATS,P)
%% NetRSA

addpath('/Users/aidasaglinskas/Google Drive/Aidas/Data_words/Scripts/fMRI-person-knowledge-names/')
for r = 1:size(vx,1)
for s = 1:size(vx,3)
tiny = [];
for run_ind = 1:size(vx,4)
tiny(run_ind,:) = netRSA_data.mat(r,:,s,run_ind);
tiny(run_ind,:) = netRSA_data.mat(r,:,s,run_ind) - netRSA_data.mat(r,18,s,run_ind)
mat_new(r,:,s,run_ind) = tiny(run_ind,:);
end
end
end

use_mat = mean(mat_new,4);
use_mat(:,[5 18],:) = [];
cmats = func_make_cmat(use_mat);
cmats_netRSA = cmats;
netRSA_fit = func_fit_RSA_model(cmats{2},model)
%%
cmats = [];
model_fit = [];
for i = 1:length(voxel_data.mat_files)
[c] = func_combroi(voxel_data.mat_files(i),voxel_data);
model_fit(:,i) = func_fit_RSA_model(c,model);
cmats(:,:,:,i) = c;
end

model_fit2 = func_fit_RSA_model(mean(cmats,4),model);

figure(1);clf;
func_plot_tbar_plot([model_fit_vx netRSA_fit mean(model_fit,2) model_fit2],{'vx' 'netRSA' 'avgROIfit' 'avgRDMfit'});

ttest(netRSA_fit,mean(model_fit,2))
%%

%[H,P,CI,STATS] = ttest(netRSA_fit,model_fit_vx);
[H,P,CI,STATS] = ttest(netRSA_fit,mean(model_fit,2));
[H,P,CI,STATS] = ttest(netRSA_fit);
t_statement(STATS,P);
%%

dt = [];
for s = 1:size(cmats_vx,3);
dt(s) = corr(squareform(1-cmats_vx(:,:,s))',squareform(1-cmats_netRSA{2}(:,:,s))');
end


[H,P,CI,STATS] = ttest(dt);
t_statement(STATS,P);



