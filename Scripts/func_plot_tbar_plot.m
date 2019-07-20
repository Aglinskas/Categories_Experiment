function [hb he] = func_plot_tbar_plot(dt,lbls,bonf)
% func_plot_tbar_plot(dt,lbls,bonf)

if ~exist('bonf');bonf = 0;end

m = mean(dt);
se = std(dt) ./ sqrt(size(dt,1));
%se = std(dt);

if bonf
    alpha = .05 / size(dt,2);
else 
    alpha = .05;
end

[H,P,CI,STATS] = ttest(dt,0,'tail','right','alpha',alpha);
%%
hb = bar(m);hold on;
hb.LineWidth = 1;
hb.BarWidth = .8;
%errorbar(1:length(m),m,m-se_pos,m-se_neg,'r.')
he = errorbar(m,se,'r.');
arrayfun(@(x)text(x-.1,0,'*','fontsize',30),find(H));

xticks(1:length(m));
xticklabels(lbls);
xtickangle(45);
hold off
%%
f = gcf;
f.Color = [1 1 1];
f.CurrentAxes.Box = 'off';
end