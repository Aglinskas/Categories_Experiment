load('/Users/aidasaglinskas/Desktop/mats/detrend_ROI_data.mat');
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat')
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
roi_data.tlbls = tlbls;
%%
model = wikiClust.cmat;
[rcmats tcmats] = deal([]);
tlbls = roi_data.tlbls;
tlbls([5 18]) = [];
for s = 1:18
    mat = roi_data.mat(:,:,s);
    %mat = mat - mat(:,18)
    mat(:,[5 18]) = [];
    mat = mat - mean(mat,2);
 rcmats(:,:,s) = corr(mat');
 tcmats(:,:,s) = corr(mat);
end

[H,P,CI,STATS] = ttest(func_fit_RSA_model(tcmats,model));
func_plot_dendMat({mean(tcmats,3) mean(rcmats,3)},{tlbls roi_data.rlbls});
title(t_statement(STATS,P),'fontsize',20)





