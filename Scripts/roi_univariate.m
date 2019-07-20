clear;
load('all_ds26.mat');
load('rlbls');load('tlbls');
load('subvec.mat');
%r_ord = [6	11	3	10	4	12	1	8	14	15	7	2	9	5	13];
%t_ord = [11	12	8	9	10	15	13	14	1	3	4	6	17	7	16	2 5 18];
all_ds = all_ds(r_ord);
rlbls = rlbls(r_ord);
%%
for r_ind = 1:9;
    subplot(5,3,r_ind)
ds = all_ds{r_ind};
all_b = [];
for s = 1:length(subvec)
for c = 1:18;
    subID = subvec(s);
ds = all_ds{r_ind};
ds = cosmo_remove_useless_data(ds);
ds = cosmo_slice(ds,ds.sa.subID == subID);
for run_ind = 1:3
    dim = 1;
    ds.samples(ds.sa.run_ind==run_ind,:) = zscore(ds.samples(ds.sa.run_ind==run_ind,:),[],dim);
    %ds.samples(ds.sa.b_ind==run_ind,:) = zscore(ds.samples(ds.sa.b_ind==run_ind,:),[],dim);
end
ds = cosmo_slice(ds,ds.sa.cond_index == c);
mean3 = mean(ds.samples,2);
b(c,s) = mean(mean3);
end
end
%
%b = b-b(18,:);
%b = b-mean(b,1);
b = b(t_ord,:);
m = mean(b,2);
s = std(b,[],2) ./ sqrt(19);
f = figure(2);
%f.CurrentAxes.FontWeight = 'bold';
bar(m);hold on;
errorbar(m,s,'r.');hold off;
xticks(1:18);
xticklabels(tlbls(t_ord))
xtickangle(45)
title(rlbls{r_ind},'fontsize',14)
box off
end