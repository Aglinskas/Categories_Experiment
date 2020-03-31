code_root = '/Users/aidasaglinskas/Desktop/TN-Semantic-Categories/';
addpath(fullfile(code_root,'Scripts'))
load(fullfile(code_root,'/Scripts/subvec.mat'))
load(fullfile(code_root,'/Scripts/mats/cat_names.mat'))
cat_names([5 18]) = []; % drop leisure and control condition
clc
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

behav.mat_rt = behav.mat_rt(3:end,:)
behav.mat_resp = behav.mat_resp(3:end,:)

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
%%
clc; disp('RT difference between living > non-living')
%[H,P,CI,STATS] = ttest(lmat(4:end),nlmat(4:end));
[H,P,CI,STATS] = ttest(lmat(1:end),nlmat(1:end));
t_statement(STATS,P);
% should be 
%t(17) = 0.62,p = 0.545
%or t(15) = 0.94,p = 0.362
%% ANOVA - RT differences between categories
%[pRT, tableRT] = anova_rm(behav.mat_rt,'off');
[pRT, tableRT] = anova_rm(behav.mat_rt(1:end,:),'off');
disp('ANOVA RT differences between categories')
F_statement(tableRT)
%F(15,225) = 3.952, p < .001
%% ANOVA - rating differences between categories
%[pResp, tableResp] = anova_rm(behav.mat_rt,'off');
[pResp, tableResp] = anova_rm(behav.mat_resp(1:end,:),'off');
disp('ANOVA response differences between categories')
F_statement(tableResp)
%F(15,225) = 15.659, p < .001
%% Make a table
behav.lbls_eng = {'Clothes','Musical Instruments','Tools','Households','Materials','Transports&Movement','Animals-Water','Animals-Insects','Animals-Domestic','Animals-Wild','Animals-Birds','Fruits&Vegetables','Foods&Drinks','Flora','Outdoors','Bodyparts'}

tt = table
tt.category = behav.lbls_eng'

%tt.RT_mean= mean(behav.mat_rt,1)'
%tt.RT_std=std(behav.mat_rt,1)'
%tt.AVG_rating = mean(behav.mat_resp,1)'
%tt.rating_STD_dev = std(behav.mat_resp,1)'

tt.RT_mean = arrayfun(@(x) num2str(x,'%.0f'),mean(behav.mat_rt,1)'*1000,'UniformOutput',0)
tt.RT_std=arrayfun(@(x) num2str(x,'%.0f'), std(behav.mat_rt,1)'*1000 ,'UniformOutput',0)
tt.AVG_rating =arrayfun(@(x) num2str(x,'%.2f'), mean(behav.mat_resp,1)' ,'UniformOutput',0)
tt.rating_STD_dev = arrayfun(@(x) num2str(x,'%.2f'), std(behav.mat_resp,1)' ,'UniformOutput',0)
tt.rating_STD_dev = cellfun(@(x) strrep(x,'0.','.'),tt.rating_STD_dev,'UniformOutput',0);
%arrayfun(@(x) num2str(x,'%.3f'),  ,'UniformOutput',0)
clc;disp(tt)
%%

%GRAND AVERAGE
%RT
%arrayfun(@(x) num2str(x,'%.0f'),[mean(behav.mat_rt(:)) std(behav.mat_rt(:))]*1000,'UniformOutput',0)

%resp
%arrayfun(@(x) num2str(x,'%.2f'),[mean(behav.mat_resp(:)) std(behav.mat_resp(:))],'UniformOutput',0)

f=figure(1);clf;f.Color=[1 1 1];

sp = subplot(2,1,1);
mat = behav.mat_rt;
mat = mat - mean(mat,2);
m = mean(mat,1);
s = std(mat,1);
bar(m);hold on;
errorbar(m,s,'r.');hold off
xticks(1:16);xticklabels(behav.lbls_eng');xtickangle(45);
sp.FontSize=12;sp.FontWeight='bold'
box off
title('RT','fontsize',16)

sp = subplot(2,1,2);
mat = behav.mat_resp;
mat = mat - mean(mat,2);
m = mean(mat,1);
s = std(mat,1);
bar(m);hold on;
errorbar(m,s,'r.');hold off
xticks(1:16);xticklabels(behav.lbls_eng');xtickangle(45);
sp.FontSize=12;sp.FontWeight='bold'
title('Ratings','fontsize',16)
box off
%% 
figure(2);

subplot(2,2,1)
m = mean(behav.mat_rt,1);
cmat1=squareform(pdist(m'))
add_numbers_to_mat(cmat1);
xticks(1:16);yticks(1:16);
xticklabels(behav.lbls_eng);xtickangle(65)
yticklabels(behav.lbls_eng);

subplot(2,2,2)
m = mean(behav.mat_resp,1);
cmat2=squareform(pdist(m'))
add_numbers_to_mat(cmat2);
xticks(1:16);yticks(1:16);
xticklabels(behav.lbls_eng);xtickangle(65)
yticklabels(behav.lbls_eng);

sp = subplot(2,2,3)
Z = linkage(get_triu(cmat1))
[h x perm] = dendrogram(Z,'labels',behav.lbls_eng);
[h(1:end).LineWidth] = deal(3)
xtickangle(90)
sp.FontSize=12;sp.FontWeight='bold'

sp = subplot(2,2,4)
Z = linkage(get_triu(cmat2))
[h x perm] = dendrogram(Z,'labels',behav.lbls_eng);
[h(1:end).LineWidth] = deal(3)
xtickangle(90)
sp.FontSize=12;sp.FontWeight='bold'

behav.RSA_RT = cmat1;
behav.RSA_resp = cmat2;
%%
sem = [1,0.593528688647003,0.709895118392654,0.807826291679935,0.716931742128055,0.643004705223730,0.620544230298549,0.667001407308355,0.746908401511763,0.602322525746645,0.664134073193281,0.544115937047639,0.666864981126298,0.696587589734995,0.641545405990289,0.738653885240081;0.593528688647003,1,0.638421557109377,0.696947845130924,0.615876723945513,0.588257616410078,0.512342941931263,0.564564617513506,0.619150026352301,0.482188902471590,0.529942101147402,0.436583980838208,0.563500014791460,0.571222087854455,0.564794195332136,0.605454297976529;0.709895118392654,0.638421557109377,1,0.884906630721298,0.843858387442418,0.832191577229145,0.632144128864357,0.701385761070259,0.746045685098609,0.561973109667426,0.612439634296927,0.509713199120645,0.672158949324843,0.720675643324679,0.763256099856510,0.815296854776063;0.807826291679935,0.696947845130924,0.884906630721298,1,0.890126123871709,0.811182346231206,0.731286816834274,0.780416590659894,0.861510355263413,0.651052956886650,0.705798395164748,0.632453973597657,0.821594433213398,0.805207777583680,0.802481509113003,0.824324644485170;0.716931742128055,0.615876723945513,0.843858387442419,0.890126123871709,1,0.838727032903800,0.709922086836437,0.727835662274513,0.802410410966186,0.594304768843647,0.636760869293066,0.593376270635673,0.764255983609114,0.822089484077250,0.857395268857540,0.779854795109778;0.643004705223730,0.588257616410078,0.832191577229145,0.811182346231206,0.838727032903800,1,0.612462191318987,0.645998315853067,0.752453575379520,0.519036591170785,0.568875911066768,0.435898986907736,0.623833404967454,0.716712861265753,0.876179518495235,0.726219196204883;0.620544230298549,0.512342941931263,0.632144128864357,0.731286816834274,0.709922086836437,0.612462191318987,1,0.886566192706225,0.827701403212325,0.849315125374229,0.860056983008704,0.740607727800495,0.756748488881586,0.828691435497805,0.726975109350901,0.643694956635792;0.667001407308355,0.564564617513506,0.701385761070259,0.780416590659894,0.727835662274513,0.645998315853067,0.886566192706225,1,0.887616573410179,0.873155455908640,0.894716240221612,0.667742879600011,0.718289532194313,0.860706440680825,0.749221488357474,0.748772343790566;0.746908401511763,0.619150026352301,0.746045685098610,0.861510355263413,0.802410410966186,0.752453575379520,0.827701403212325,0.887616573410179,1,0.835093805101599,0.835026403886165,0.663557514601739,0.796153234437871,0.855423073158932,0.821053705698119,0.796242982084248;0.602322525746645,0.482188902471590,0.561973109667427,0.651052956886650,0.594304768843647,0.519036591170785,0.849315125374229,0.873155455908640,0.835093805101599,1,0.926267973095890,0.635074104973896,0.618751089336105,0.765949810823022,0.627661060981466,0.604016449748014;0.664134073193281,0.529942101147402,0.612439634296927,0.705798395164748,0.636760869293066,0.568875911066768,0.860056983008704,0.894716240221612,0.835026403886164,0.926267973095890,1,0.654526342984249,0.654964928027361,0.801855934338743,0.664522898150936,0.648156313804537;0.544115937047639,0.436583980838208,0.509713199120645,0.632453973597657,0.593376270635673,0.435898986907736,0.740607727800495,0.667742879600011,0.663557514601739,0.635074104973896,0.654526342984249,1,0.871589293531779,0.706021347814331,0.510219461263662,0.500587514220604;0.666864981126298,0.563500014791460,0.672158949324843,0.821594433213398,0.764255983609114,0.623833404967454,0.756748488881586,0.718289532194313,0.796153234437871,0.618751089336105,0.654964928027361,0.871589293531779,1,0.748054882078247,0.663968582153388,0.661786957079661;0.696587589734995,0.571222087854455,0.720675643324679,0.805207777583680,0.822089484077250,0.716712861265753,0.828691435497805,0.860706440680825,0.855423073158932,0.765949810823022,0.801855934338743,0.706021347814331,0.748054882078247,1,0.853241629978235,0.751440242680351;0.641545405990289,0.564794195332136,0.763256099856510,0.802481509113003,0.857395268857540,0.876179518495235,0.726975109350901,0.749221488357474,0.821053705698119,0.627661060981466,0.664522898150936,0.510219461263662,0.663968582153388,0.853241629978235,1,0.758154865573992;0.738653885240081,0.605454297976529,0.815296854776063,0.824324644485170,0.779854795109778,0.726219196204883,0.643694956635792,0.748772343790566,0.796242982084248,0.604016449748014,0.648156313804537,0.500587514220604,0.661786957079661,0.751440242680351,0.758154865573992,1];
clc;
[RHO,PVAL] = corr(get_triu(sem)',[get_triu(behav.RSA_RT)']);
txt = sprintf('r=%.2f, p=%.3f',RHO,PVAL);txt=strrep(txt,'0.','.');
disp(txt)

[RHO,PVAL] = corr(get_triu(sem)',[get_triu(behav.RSA_resp)']);
txt = sprintf('r=%.2f, p=%.3f',RHO,PVAL);txt=strrep(txt,'0.','.');
disp(txt)
%%













