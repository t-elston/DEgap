function [MeanTrainxProb,EQxProbBias,ContextF,SubjectID] = GetTrainPerfByProbWithinSubject_v01(AllData,ProbOfInterest)

ParticipantIDs = unique(AllData.vpNum);

ctr = 0;
for p = 1:numel(ParticipantIDs)
    
        pData = AllData(AllData.vpNum == ParticipantIDs(p),:);
    
    for c = 1:2
        clear pData2;
         ctr = ctr+1;
        
        if c ==1 % look at gain context
            pData2 = pData(contains(pData.type,'gain'),:);               
        end
        
        if c ==2
            pData2 = pData(contains(pData.type,'loss'),:);    
        end
        
        
    
    pPickedHighProb = double(pData2.highProbSelected);
    pPickedExperience = double(contains(pData2.chosenImageType,'Experience'));
    
    % find the training trials
    Train_trials = contains(pData2.phase,'learning');
    
    % find the equiprobable trials
    EQ_trials = contains(pData2.trialType,'EqualMixed');
    
    % find trials which contained the ProbOfInterest 
    POI_Trials = pData2.imageProbLeft == ProbOfInterest | pData2.imageProbRight == ProbOfInterest;

    Train_POI_trials = Train_trials & POI_Trials;
    EQ_POI_trials    = EQ_trials & POI_Trials;
    
    % get performance and EQ bias
    if c ==2
        MeanTrainxProb(ctr,1) = 1 - nanmean(pPickedHighProb(Train_POI_trials));
    else
        MeanTrainxProb(ctr,1) = nanmean(pData2.highProbSelected(Train_POI_trials));
    end
     
     EQxProbBias(ctr,1)    = abs(.5 - nanmean(pPickedExperience(EQ_POI_trials)));

          
     ContextF(ctr,1) = c;
     SubjectID(ctr,1) = p;

   
    end % of cycling through contexts
    
end % of cycling through each participant



end % of function