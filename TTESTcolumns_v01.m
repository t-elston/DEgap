function [tstat,df,pval,CohenD] = TTESTcolumns_v01(indata,nullVal)

% does ttests on columns of data. also returns effect size (Cohen's D)

[~,pval,~,stats]=ttest(indata,nullVal);
tstat=stats.tstat;
df = stats.df;

% subtract the null val from indata for calculating Cohen's D
SubData = indata - nullVal;

CohenD = nanmean(SubData) ./ std(SubData);


end % of function