%% Living Non Living
clust = {}
clust{1} = {    'Clothes'
    'Musical ins'
    'Tools'
    'Household'
    'Materials'
    'Transport'
    'Outdoors'
    }

clust{2} = {    'Animals-Water'
    'Animals-Insects'
    'Animals-Domestic'
    'Animals-Wild'
    'Animals-Birds'
    'Fruits & Veg'
    'Food & Drink'
    }
model = func_made_RSA_model(tlbls,clust)
%% tools / animals 
clust = {}
clust{1} = {    'Clothes'
    'Musical ins'
    'Tools'
    'Household'}

clust{2} = {'Animals-Insects'
    'Animals-Domestic'
    'Animals-Wild'
    'Animals-Birds'}
model = func_made_RSA_model(tlbls,clust)
%% Places vs Tools
clust{1} = {
    'Tools'
    'Household'}

clust{2} = {'Transport'
    'Outdoors'}

model = func_made_RSA_model(tlbls,clust)