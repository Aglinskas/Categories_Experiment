function model = func_made_RSA_model(mat_lbls,clust,do_plot,ttl);
% function model = func_made_RSA_model(mat_lbls,clust,ttl);

sort_mats = 0;
sz = length(mat_lbls);
e_mat = zeros(sz);
for m_ind = 1:length(clust)
inds = ismember(mat_lbls,clust{m_ind});
e_mat(inds,inds) = 1;
end
model = e_mat;

if sort_mats
ord = cellfun(@(x) find(strcmp(mat_lbls,x)),[clust{:}]);
ord = [ord find(~ismember(1:sz,ord))];
e_mat = e_mat(ord,ord); mat_lbls =mat_lbls(ord);
end

if exist('do_plot');
%f = gcf;clf
add_numbers_to_mat(e_mat,mat_lbls,'nonum');
f.Colormap = colormap('parula');
%f.CurrentAxes.XTickLabelRotation = 45;
if exist('ttl')title(ttl,'fontsize',20);end
end