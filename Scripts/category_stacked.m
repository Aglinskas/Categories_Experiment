% Category Stacked
clear all;
load('/Users/aidasaglinskas/Desktop/roi_data_S.mat');
%% Subtract CC
cc_ind = find(strcmp(roi_data.tlbls,'control task'));
roi_data.mat = roi_data.mat - roi_data.mat(:,cc_ind,:);
    roi_data.mat(:,cc_ind,:) = [];
    roi_data.tlbls(cc_ind) = [];
%% 
roi_data.mat(:,5,:) = [];
roi_data.tlbls(5) = [];
%%
r_group = {{'IPL-L'    'IPL-R'} {'OFC-L'    'OFC-R'} {'PHG-L'    'PHG-R'}  {'RSc-L'    'RSc-R' } {'pMTG-L'    'pMTG-R'} {'Prec-M'} {'vmPFC-M'}};
    r_group_lbls = [r_group{:}];
    r_group_lbls = strrep(r_group_lbls,'-L','');
    r_group_lbls = strrep(r_group_lbls,'-R','');
    r_group_lbls = strrep(r_group_lbls,'-M','');
    r_group_lbls = unique(r_group_lbls,'stable');

    mat = roi_data.mat;
tiny_mat = [];
for r = 1:length(r_group)
   tiny_mat(r,:,:) = mean(mat(find(ismember(roi_data.rlbls,r_group{r})),:,:),1);
end
%% Bar 7

m = mean(tiny_mat,3);
m(m<0) = .00001;
for r = 1:length(r_group)
m(r,:) =m(r,:) ./ sum( m(r,:));
end

figure(1);clf
bar(m,'stacked');
ylim([0 1])
xticklabels(r_group_lbls)
legend(roi_data.tlbls,'location','bestoutside')
%%
figure(2);clf;drawnow
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Stimulation_script/winList_man3.mat');
load('/Users/aidasaglinskas/Desktop/Wiki-wordSimilarityScripts/Jwiki.mat');

finale.final_list(:,[5 18]) = [];
wiki.nouns = strrep(wiki.nouns,'-n','');
words = finale.final_list(:); % 384
words_inds = ismember(wiki.nouns,words);


wiki.dm_avg = wiki.dm_avg(words_inds,:);
wiki.nouns = wiki.nouns(words_inds);

wiki.dm_avg = log(wiki.dm_avg+1);
Y = pdist(wiki.dm_avg,'correlation');
Z = linkage(Y,'ward');


cth = 1;
dendrogram(Z,0,'labels',wiki.nouns,'colorthreshold',cth);
xtickangle(90);







 






    
    
    