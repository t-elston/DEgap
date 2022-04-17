function [ww] = pExperienceVsDescribed_v01(P_data)
ww=[];

Data = P_data.Choice;
VarNames =  Data.Properties.VariableNames;
Loss_ix = contains(P_data.Protocol,'loss');
NumPs = numel(Loss_ix);

% for each participant, find their p(Experience) vs all for all instances
% where each probability level was present

Ecols = [];

for p = 1:NumPs
    
    
    
    
    
    
    
end % of cycling through participants




end % of function 