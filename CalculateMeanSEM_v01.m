function [means sems] = CalculateMeanSEM_v01(indata)

means=[];
sems=[];

means = nanmean(indata);
sems  = nanstd(indata) / sqrt(numel(indata(:,1)));


end % of function