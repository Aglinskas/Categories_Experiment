function model_fit = func_fit_RSA_model(data,model)
% model_fit = func_fit_RSA_model(data,model)
%data = tcmats;
%model = model;

%load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
%model = wikiClust.cmat;


if ndims(data) ~= 3;error('model not 3d');end
if ~iscell(model);model = {model};end
if size(model{1},1) ~= size(data,1); error('model and data size mismatch');end
nmodels = length(model);
warning('off','stats:linkage:NotEuclideanMatrix');

for m = 1:nmodels
use_model = model{m};
use_data = data;

%use_data = atanh(use_data);

drop_inds = sum(use_model,2)==0;
% Not use empty cells
    use_model(drop_inds,:) = [];
    use_model(:,drop_inds) = [];
    use_data(drop_inds,:,:) = [];
    use_data(:,drop_inds,:) = [];
    
    
for s = 1:size(data,3)
v1 = get_triu(use_model)';
    v1 = v1-mean(v1);
v2 = get_triu(use_data(:,:,s))';
    v2 = v2-mean(v2);
model_fit(s,m) = corr(v1,v2);
end
end


end