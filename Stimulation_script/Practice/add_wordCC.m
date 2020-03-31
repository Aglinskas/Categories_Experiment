function finale = add_wordCC(finale)
how_many = 1;
final_list = finale.final_list_it;
load('./IT_func_trans.mat');
drop_words = {'the'};
ft(find(ismember(ft(:,1),drop_words)),:) = [];
ft_use = ft;
cc = {};
%final_list = finale.final_list_it
final_list_wlength = cellfun(@length,final_list);
c = 0;
match = 0;
while ~isempty(match)
    c = c+1;
inp = final_list_wlength(:,randi(size(final_list,2)));
for i = 1:size(final_list,1)
%inp = cellfun(@length,final_list(:,3));
%inp = final_list_wlength(:,c)
%match = find([ft_use{:,4}]'==inp(i));
match = find(abs([ft_use{:,4}]'-inp(i)) < 1);
if isempty(match);cc(:,end) = [];break;end
match_ind = match(1);
word = ft_use{match_ind,1};
cc{i,c} = word;
ft_use(match_ind,:) = [];
end
end
cc;
%
plt = 0;
if plt
alpha_level = .01;
allL = [final_list cc];
allL_wlength = cellfun(@length,allL);
tmat = [];
for r = 1:size(allL,2)
for c = 1:size(allL,2)
    [H,P,CI,STATS] = ttest2(allL_wlength(:,r),allL_wlength(:,c),'alpha',alpha_level);
    tmat(r,c) = H;
end
end
figure(1);clf;
imagesc(tmat);
end

%cc = add_wordCC(finale)


finale.final_list_it = [finale.final_list_it cc(:,1:how_many)];
finale.final_list = [finale.final_list cc(:,1:how_many)];
finale.catNames = [finale.catNames;repmat({'Control Task'},1,how_many)'];

%sz = size(finale.final_list_it,1);
%rp = round(sz / 6);
%s = Shuffle(2:sz)
%cc(s(1:rp),:) = cc(s(1:rp)-1,:) 
%[finale.final_list_it cc(:,1:how_many)] 


