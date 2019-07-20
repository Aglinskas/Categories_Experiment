function str = t_statement(STATS,P)

for i = 1:size(STATS.tstat,2)

str = sprintf('t(%d) = %.2f,p = %.3f',STATS.df(i),STATS.tstat(i),P(i));
if P(i) < .001;str(end-8:end) = 'p < 0.001';end % APA style
disp(str);
    
end


end