function myTrials = get_exp3_myTrials
%load('./finalStim.mat')
%save('/Users/aidasaglinskas/Desktop/winList.mat','finale')
%trans_cats_to_it
load('./winList_man3.mat')
%save('/Users/aidasaglinskas/Desktop/winList_man3.mat','finale')
%finale = add_wordCC(finale);
myTrials = struct;
stimList = lower(finale.final_list_it);
CatNames = lower(finale.catNames);
numCats = size(stimList,2);
numItems = size(stimList,1);
numItemsPerBlock = 8;
numBlocks = numCats*numItems / numItemsPerBlock;
    if ~[numBlocks==round(numBlocks)]; error('something wrong ''numBlocks~=round(numBlocks)''');end
% Get Into MyTrials
    l = 0;
for c_ind = 1:numCats
for i_ind  = 1:numItems
    l = l+1;
myTrials(l).StimName = stimList{i_ind,c_ind};
myTrials(l).StimName_eng = lower(finale.final_list{i_ind,c_ind});
myTrials(l).CatName = CatNames{c_ind};
myTrials(l).CatInd = c_ind;
end
end
myTrials(1).response = [];
myTrials(1).RT = [];
[myTrials(1:216).fmri_run] = deal(1);
[myTrials(217:end).fmri_run] = deal(2);
ch = [length(unique([myTrials([myTrials.fmri_run]==1).CatInd]))==0 length(unique([myTrials([myTrials.fmri_run]==2).CatInd]))==0];
%% Find Block Order
iter = 0;
v_sum = 1;
spacing = 3;
while ~[v_sum == 0] & ~all(ch);
    iter = iter+1;
block_order = 1:numBlocks;
block_order = Shuffle(block_order);
v1 = [arrayfun(@(x) abs(block_order(x)-block_order(x+1))<spacing,1:length(block_order)-1) 0];
v2 = [0 arrayfun(@(x) abs(block_order(x-1)-block_order(x))<spacing,2:length(block_order))];
v = sum([v1;v2]);
v_sum = sum(v);
end
%% Add block numbers
l = 0;
for b_ind = block_order
for i_ind = 1:numItemsPerBlock
    l = l+1;
    myTrials(l).BlockInd = b_ind;
end
end
% myTrials(1).response = [];
% myTrials(1).RT = [];
% [myTrials(1:216).fmri_run] = deal(1);
% [myTrials(217:end).fmri_run] = deal(2);
% ch = [length(unique([myTrials([myTrials.fmri_run]==1).CatInd]))==0 length(unique([myTrials([myTrials.fmri_run]==2).CatInd]))==0];
[~,index] = sortrows([myTrials.BlockInd].'); myTrials = myTrials(index); clear index;
%% Control Task Repeats
control_task = [18];
for i = 1:max([myTrials.BlockInd])
    inds = find([myTrials.BlockInd] == i);
    if ismember(myTrials(inds(1)).CatInd,control_task)
       shuf = Shuffle(inds(2:end));
       pick = shuf(1:randi([1 3],1));
       [myTrials(pick-1).StimName] = deal(myTrials(pick).StimName);
    end
end