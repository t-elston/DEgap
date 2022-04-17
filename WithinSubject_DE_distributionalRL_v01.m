function [G_E_Q,G_D_Q,G_EQbias,L_E_Q,L_D_Q,L_EQbias] = WithinSubject_DE_distributionalRL_v01(Within_AllData,wPdata,resolution,epsilon)
xx=[];

% should we exclude poor subjects?
% Within_AllData = RemovePoorSubjects_v01(wPdata,Within_AllData);


ParticipantIDs = unique(Within_AllData.vpNum);

for p = 1:numel(ParticipantIDs)
    
    thisPdata = Within_AllData(Within_AllData.vpNum == ParticipantIDs(p),:);
    
    % get the gain and loss trials
    GainData = thisPdata(contains(thisPdata.type,'gain'),:);
    LossData = thisPdata(contains(thisPdata.type,'loss'),:);
    LossData.rewardCode = LossData.rewardCode*-1;
    
    [G_E_Q(p,1),G_D_Q(p,1),G_EQbias(p,1)] = WithinSubjectDistRL_InnerLoop(GainData,resolution,epsilon);
    [L_E_Q(p,1),L_D_Q(p,1),L_EQbias(p,1)] = WithinSubjectDistRL_InnerLoop(LossData,resolution,epsilon);

  
end % of cycling through participants






end % of function 