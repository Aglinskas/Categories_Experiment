%r = randi(1400,1,200);
mat = wiki.dm_avg;
mat = log(mat+1);
mat = zscore(mat,[],1);
mat = zscore(mat,[],2);
use_lbls = wiki.nouns(r);
tres = tsne(mat);
%%
f = figure(16);clf
f.Color = [1 1 1]
for row = 1:length(tres);
text(tres(row,1),tres(row,2),use_lbls(row),'fontsize',6)
end

xlim([min(tres(:,1)) max(tres(:,1))])
ylim([min(tres(:,2)) max(tres(:,2))])


saveas(f,'/Users/aidasaglinskas/Desktop/tsne.png')