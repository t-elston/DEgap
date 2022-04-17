function [MeanTrainxProb,EQxProbBias] = GetTrainPerfByProb_v01(AllData,ProbOfInterest)

ParticipantIDs = unique(AllData.vpNum);

for p = 1:numel(ParticipantIDs)
    
    thisPdata = AllData(AllData.vpNum == ParticipantIDs(p),:);
    pPickedHighProb = double(thisPdata.highProbSelected);
    pPickedExperience = double(contains(thisPdata.chosenImageType,'Experience'));
    
    % find the training trials
    Train_trials = contains(thisPdata.phase,'learning');
    
    % find the equiprobable trials
    EQ_trials = contains(thisPdata.trialType,'EqualMixed');
    
    % find trials which contained the ProbOfInterest 
    POI_Trials = thisPdata.imageProbLeft == ProbOfInterest | thisPdata.imageProbRight == ProbOfInterest;

    Train_POI_trials = Train_trials & POI_Trials;
    EQ_POI_trials    = EQ_trials & POI_Trials;
    
    % get performance and EQ bias
    if contains(thisPdata.version,'loss')
        MeanTrainxProb(p,1) = 1 - nanmean(pPickedHighProb(Train_POI_trials));
%         EQxProbBias(p,1)    = 1 - nanmean(pPickedExperience(EQ_POI_trials));
    else
        MeanTrainxProb(p,1) = nanmean(thisPdata.highProbSelected(Train_POI_trials));
%         EQxProbBias(p,1)    = nanmean(pPickedExperience(EQ_POI_trials));
    end
    
     EQxProbBias(p,1)    = abs(.5 - nanmean(pPickedExperience(EQ_POI_trials)));

        
end % of cycling through each participant



end % of function