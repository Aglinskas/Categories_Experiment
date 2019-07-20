function res = func_plot_dendMat(mats,lbls);
% func_plot_dendMat(mats,lbls)
% can be a cell of a matrix
%

if length(mats)~=length(lbls); error('number of mats doesnt match num of labels');end

res = [];

cc = 0;
if iscell(mats);
    numMats = length(mats);
    mats = mats;
else
    numMats = 1;
    mats = {mats};
    lbls = {lbls};
end

for i = 1:numMats;
cc = cc+1;;

sp = subplot(numMats,2,cc);
%figure(cc);sp = subplot(1,1,1);

%mats{i} = atanh(mats{i});

Y = 1-get_triu(mats{i});
Z = linkage(Y,'ward');
[h x perm] = dendrogram(Z,0,'labels',lbls{i});

sp.FontSize = 14;
sp.FontWeight = 'bold';

ord = perm;
res.ord{i} = ord;
[h(1:end).LineWidth] = deal(2);
xtickangle(45);

cc = cc+1;
sp = subplot(numMats,2,cc);

if length(mats{i}) < 10
    add_numbers_to_mat(mats{i}(ord,ord),lbls{i}(ord));
else
add_numbers_to_mat(mats{i}(ord,ord),lbls{i}(ord),'nonum');
end


xtickangle(45)
sp.CLim = [min(get_triu(mats{i})) max(get_triu(mats{i}))];
end
end