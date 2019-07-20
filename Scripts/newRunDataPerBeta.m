clear 
masks_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/';
mask_fls = dir([masks_dir '*.nii']);
mask_fls = {mask_fls.name}';
%masks = cellfun(@(x) fullfile(masks_dir,x),mask_fls,'UniformOutput',0);
%%

%OutData = func_extract_RSA(masks_dir,mask_fls);


masks_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/test/';
mask_fls = 'roi.nii'
OutData = func_extract_RSA(masks_dir,mask_fls);

%save('/Users/aidasaglinskas/Desktop/OutData.mat','OutData')
%% Make cmats
load('/Users/aidasaglinskas/Desktop/OutData.mat');
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat');
tlbls([5 18]) = [];
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat');
cmats = []
for r = 1:length(OutData.voxel_data)
    rdata = OutData.voxel_data{r};
    % dt_leg: 'SUB|CAT|BETA|VOXELS'
    rdata = rdata - rdata(:,18,:,:);
    rdata(:,[5 18],:,:) = [];
for s = 1:size(rdata,1)
for b = 1:size(rdata,3)
    dt = squeeze(rdata(s,:,b,:))';
    dt = dt - mean(dt,2); % centers data
    cmats(:,:,r,s,b) = corr(dt);
end
end
end
%% Show ROI RDM
model  = wikiClust.cmat;
r = 1;
rcmat = squeeze(mean(cmats(:,:,r,:,:),5));

model_ev = func_fit_RSA_model(rcmat,model);
[H,P,CI,STATS] = ttest(model_ev);

f = figure(1);
ttl = {OutData.rlbls{r} ['model fit: ' t_statement(STATS,P)]}

func_plot_dendMat(mean(rcmat,3),tlbls)
title(ttl,'fontsize',20)

%ofn = ['/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/' OutData.rlbls{r} '.jpg']
%saveas(f,ofn)
%% Model fit bar graph

dt = []
for r = 1:7
for b = 1:3
%size(cmats) CxCxRxSxB
tinyC = squeeze(cmats(:,:,r,:,b));
dt(:,r,b) = func_fit_RSA_model(tinyC,model);
end
end

clf;func_plot_tbar_plot(mean(dt,3),OutData.rlbls)

[H,P,CI,STATS] = ttest(mean(dt,3));
t_statement(STATS,P)
%% Net RSA
% dt_leg: 'SUB|CAT|BETA|VOXELS'

% Reshape
panData = [];
for r = 1:7;
rmat = OutData.voxel_data{r};
for s = 1:size(rmat,1);
for c = 1:size(rmat,1);
for b = 1:size(rmat,3);
panData(r,c,s,b) = mean(squeeze(rmat(s,c,b,:)));
end
end
end
end
    
%% NetRSA 3beta
[tcmats rcmats] = deal([])
for s = 1:size(panData,3)
for b = 1:size(panData,4)

mat = panData(:,:,s,b);

mat = mat - mat(:,18);
mat(:,[5 18]) = [];
mat = mat - mean(mat,2);

tcmats(:,:,s,b) = corr(mat);
rcmats(:,:,s,b) = corr(mat');
end
end

tcmat_2d = mean(mean(tcmats,4),3);
rcmat_2d = mean(mean(rcmats,4),3);
func_plot_dendMat({tcmat_2d rcmat_2d},{wikiClust.lbls OutData.rlbls})

tcmat_3d = mean(tcmats,4);

model_ev = func_fit_RSA_model(tcmat_3d,model);
[H,P,CI,STATS] = ttest(model_ev);

subplot(2,2,2);
title(t_statement(STATS,P));
%% NetRSA 
%panData(r,c,s,b)
dat = mean(panData,4);
[tcmats rcmats] = deal([])
for s = 1:18
    
mat = dat(:,:,s);
mat = mat - mat(:,18);
mat(:,[5 18]) = [];
%mat = mat - mean(mat,2);

tcmats(:,:,s) = corr(mat);
rcmats(:,:,s) = corr(mat');   
end

func_plot_dendMat({mean(tcmats,3) mean(rcmats,3)},{wikiClust.lbls OutData.rlbls})

model_ev = func_fit_RSA_model(tcmats,model);
[H,P,CI,STATS] = ttest(model_ev);

subplot(2,2,2);
title(t_statement(STATS,P));
%%







