code_root = '/Users/aidasaglinskas/Desktop/TN-Semantic-Categories/';
addpath(fullfile(code_root,'Scripts'))
load(fullfile(code_root,'/Scripts/subvec.mat'))
load(fullfile(code_root,'/Scripts/mats/cat_names.mat'))
cat_names([5 18]) = []; % drop leisure and control condition
%% Get Data Into Shape
mt_fn_temp = fullfile(code_root,'/fMRI_Data/S%d/S%.2i_P1_myTrials_fixed.mat');
subvec = 1:20;
subvec([9 12]) = []; % drop subjects 9 and 12

for s = 1:length(subvec);
subID = subvec(s);
mt_fn = sprintf(mt_fn_temp,subID,subID);
myTrials = [];
load(mt_fn);

if max([myTrials.response]) > 4; error('wat');end

for c = 1:16
   inds = find(strcmp({myTrials.CatName},cat_names{c}));
   resp(s,c) = nanmean([myTrials(inds).response]);
   cell_resp{s,c} = [myTrials(inds).response];
   RT(s,c) = nanmean([myTrials(inds).RT]);
   cell_RT{s,c} = [myTrials(inds).RT];
end
end % ends subs

behav.mat_rt = RT; % Reaction time matrix 18 subs by 16 categories
behav.mat_resp = resp;
behav.lbls = cat_names;

%behav.mat_rt = behav.mat_rt(3:end,:)
%behav.mat_resp = behav.mat_resp(3:end,:)
% First three subjects have all nans in the second run

varnames = behav.lbls;
varnames = strrep(varnames,' ','_');
varnames = strrep(varnames,'&','');
varnames = strrep(varnames,'__','_');
T = array2table(behav.mat_rt,'variablenames',varnames)
%% Living non-living RT differences
living = {'animali acquatici' 'insetti & rettili' 'animali  domestici' 'animali  esotici'  'uccelli' 'frutta e vegetali' 'flora' 'cibo & bevande'};
non_living = {'vestiti' 'strumenti musicali' 'utensili' 'cose di casa' 'materiali' 'trasporto & movimento'  'parti del corpo' 'natura'};
    
% living non-living RT mat
lmat = nanmean(behav.mat_rt(:,ismember(behav.lbls,living)),2);
nlmat = nanmean(behav.mat_rt(:,ismember(behav.lbls,non_living)),2);

% living non-living Resp mat
%lmat = nanmean(behav.mat_resp(:,ismember(behav.lbls,living)),2);
%nlmat = nanmean(behav.mat_resp(:,ismember(behav.lbls,non_living)),2);

clc; disp('RT difference between living > non-living')
%[H,P,CI,STATS] = ttest(lmat(4:end),nlmat(4:end));
[H,P,CI,STATS] = ttest(lmat(1:end),nlmat(1:end));
t_statement(STATS,P);
% should be 
%t(17) = 0.62,p = 0.545
%or t(15) = 0.94,p = 0.362
%% ANOVA - RT differences between categories
%[pRT, tableRT] = anova_rm(behav.mat_rt,'off');
[pRT, tableRT] = anova_rm(behav.mat_rt(3:end,:),'off');
disp('ANOVA RT differences between categories')
F_statement(tableRT)
%F(15,225) = 3.952, p < .001
%% ANOVA - rating differences between categories
%[pResp, tableResp] = anova_rm(behav.mat_rt,'off');
[pResp, tableResp] = anova_rm(behav.mat_resp(3:end,:),'off');
disp('ANOVA response differences between categories')
F_statement(tableResp)
%F(15,225) = 15.659, p < .001







