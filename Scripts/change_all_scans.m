map = [1	1
2	2
3	3
4	4
5	NaN
6	5
7	6
8	7
9	8
10	9
11	10
12	11
13	12
14	13
15	14
16	15
17	16
18 17]
%%
all_scans.sa.cond_index2 = []
for i = 1:length(all_scans.sa.cond_index)
all_scans.sa.cond_index2(i,1) = map(find(map(:,1)==all_scans.sa.cond_index(i)),2);
end
%%