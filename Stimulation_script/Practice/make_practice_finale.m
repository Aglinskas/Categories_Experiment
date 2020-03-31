load('transFinalJuly2nd.mat')
pick_cats = [1 4 11];
select = 5;
for i = 1:length(pick_cats)
    all_stim = stim.stim( ~cellfun(@isempty,stim.stim(:,pick_cats(i))),pick_cats(i));
    all_stim_it = trans_final(ismember(trans_final(:,1),all_stim),2);
    free_stim = all_stim_it(~ismember(all_stim_it,finale.final_list_it(:,pick_cats(i))));
    use_stim(:,i) = free_stim(1:select);
end

finale.final_list_it = use_stim;
finale.final_list = use_stim;
finale.catNames = finale.catNames(pick_cats);
save('practice_finale','finale')