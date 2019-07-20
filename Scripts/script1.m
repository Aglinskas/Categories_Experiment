data.cmats = cmats;

% animals
%wh = {'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds'}
% tools
wh = {'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials'}
% animals & tools
%wh = {'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds' 'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials'}
% non-living
%wh = { 'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials' 'Transport' 'Outdoors' 'Bodyparts'}
% living
%wh = {'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds' 'Fruits & Veg' 'Food & Drink' 'Flora'}

% all
%wh = {'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials' 'Transport' 'Outdoors' 'Bodyparts' 'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds' 'Fruits & Veg' 'Food & Drink' 'Flora'}

data.use_tlbls = data.tlbs;
data.use_tlbls([5 18]) = [];
inds = ismember(data.use_tlbls,wh);

data.use_tlbls = data.use_tlbls(inds);
data.use_model = data.model(inds,inds);

r = 4; % %OFC
%r = 11; %pMTG
%r = 8;
cm = squeeze(mean(cmats(:,:,r,:,:),5));
cm = cm(inds,inds,:);

model_ev = func_fit_RSA_model(cm,data.use_model);
[H,P,CI,STATS] = ttest(model_ev,0,'tail','right');
func_plot_dendMat(mean(cm,3),data.use_tlbls);
title(t_statement(STATS,P),'fontsize',20)

%v1 = model_ev
%[H,P,CI,STATS] = ttest(v1,model_ev);
%[H,P,CI,STATS] = ttest(mean([v1 model_ev],2));
%t_statement(STATS,P);

% Animals vs tools 
%%
clust = {{'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds'} {'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials'}}
%clust = {{'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Flora'  'Animals-Birds' 'Fruits & Veg' 'Food & Drink'} {'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials' 'Transport' 'Outdoors' 'Bodyparts'}}
ii = find(~ismember(1:18,[5 18]));
model = func_made_RSA_model(data.tlbs(ii),clust);

add_numbers_to_mat(model,data.tlbs(ii),'nonum')
%%
mc = mean(data.cmats,5);
dt = [];
for r = 1:13
dt(:,r) = func_fit_RSA_model(squeeze(mc(:,:,r,:)),model);
end
func_plot_tbar_plot(dt,data.rlbs)

[H,P,CI,STATS] = ttest(dt(:,ismember(data.rlbs,'OFC-L')),0,'tail','right');
t_statement(STATS,P);