%% Load up
load('./Scripts/mats/Jwiki.mat')
load('./Stimulation_script/winList_man3.mat')
%
wiki.nouns = strrep(wiki.nouns,'-n','');
exp_words = finale.final_list(:,1:17);
inds = ismember(wiki.nouns,exp_words(:));
    perc = sum(inds) / length(exp_words(:));
wiki.dm_avg = wiki.dm_avg(inds,:);
wiki.nouns = wiki.nouns(inds);
wiki.dm_avg = log(wiki.dm_avg+1);
clear cat_vec vecs
for c = 1:17
inds = ismember(wiki.nouns,exp_words(:,c));
    if sum(ismember(wiki.nouns,exp_words(:,c))) ~= 24; error('missing');end
cat_vec = mean(wiki.dm_avg(inds,:));
vecs(c,:) = cat_vec;
end
%% Wikipedia RDM
cmat = corr(vecs');
lbls = finale.catNames(1:17);
Y = 1-get_triu(cmat);
Z = linkage(Y,'ward');
subplot(1,2,1)
[h x perm] = dendrogram(Z,'labels',lbls);
xtickangle(45)
subplot(1,2,2)
add_numbers_to_mat(cmat(perm,perm),lbls(perm))

wikiClust.cmat = cmat;
wikiClust.lbls = lbls;

%save('wikiClust','wikiClust');
%% Psycholinguistic RDM
load('/Users/aidasaglinskas/Desktop/Wiki-wordSimilarityScripts/it_freq.mat')
load('tlbls');
tlbls = tlbls(1:17)
keep_inds = ismember({it_freq.word},finale.final_list_it(:));
it_freq = it_freq(keep_inds)
%%
%mean(ismember(finale.final_list_it(:),{it_freq.word}))
for c = 1:17
for r = 1:24
word_it = finale.final_list_it{r,c};
word_en = finale.final_list{r,c};
    
word_length_mat(c,r) = length(word_it);

ind = find(strcmp({it_freq.word},word_it));

if isempty(ind)
    word_freq_mat(c,r) = NaN;
else
    word_freq_mat(c,r) = str2num(it_freq(ind).freq);
end

end
end
word_freq_mat = log(word_freq_mat+1);
%%
%figure(3);add_numbers_to_mat(log(word_freq_mat+1))
word_freq_model = squareform(pdist(nanmean(word_freq_mat,2)));
word_length_model = squareform(pdist(nanmean(word_length_mat,2)));
%% Bar Graphs
figure(1);clf
mat = word_length_mat;

m = nanmean(mat,2)
sd = nanstd(mat,[],2)

bar(m);hold on;
errorbar(m,sd,'r.');hold off;
xticks(1:17);
xticklabels(tlbls);xtickangle(45)
%% Model and similarity
figure(1)
% word_length_model
model = word_length_model;
figure(1);clf
sp = subplot(1,2,1)

Y = get_triu(model);
Z = linkage(Y,'ward');

[h x perm] = dendrogram(Z,'labels',tlbls);
xtickangle(45)

sp = subplot(1,2,2)

add_numbers_to_mat(model,tlbls)
%%
wikiClust.word_length_model = word_length_model;
wikiClust.word_freq_model = word_freq_model;
wikiClust.lbls = tlbls;
%%
save('wikiClust.mat','wikiClust')



