cmat_3d = cmat_3d_netRSA;
data.model;
mcmats = mean(cmats,5);

tlbls = data.tlbs;
tlbls([5 18]) = [];
nl = {'Clothes' 'Musical ins' 'Tools' 'Household'  'Materials' 'Transport' 'Outdoors' 'Bodyparts'};
l = {'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds' 'Fruits & Veg' 'Food & Drink' 'Flora'};
%l = {'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds'};
%nl = {'Clothes' 'Musical ins' 'Tools' 'Household'  'Materials'};
%%
clc
tail = 'right';
inds1 = find(ismember(tlbls,l));
inds2 = find(ismember(tlbls,nl));
model_ev1 = func_fit_RSA_model(cmat_3d(inds1,inds1,:),data.model(inds1,inds1));
model_ev2 = func_fit_RSA_model(cmat_3d(inds2,inds2,:),data.model(inds2,inds2));
[H,P,CI,STATS] = ttest(model_ev1,0,'tail',tail);t_statement(STATS,P);
[H,P,CI,STATS] = ttest(model_ev2,0,'tail',tail);t_statement(STATS,P);
[H,P,CI,STATS] = ttest(mean([model_ev1 model_ev2],2),0,'tail',tail);t_statement(STATS,P);
%%
clc;
r_ind = find(ismember(data.rlbs,'PHG-L'));
model_ev1 = func_fit_RSA_model(squeeze(mcmats(inds1,inds1,r_ind,:)),data.model(inds1,inds1));
model_ev2 = func_fit_RSA_model(squeeze(mcmats(inds2,inds2,r_ind,:)),data.model(inds2,inds2));
[H,P,CI,STATS] = ttest(model_ev1,0,'tail',tail);t_statement(STATS,P);
[H,P,CI,STATS] = ttest(model_ev2,0,'tail',tail);t_statement(STATS,P);
[H,P,CI,STATS] = ttest(mean([model_ev1 model_ev2],2),0,'tail',tail);t_statement(STATS,P);

