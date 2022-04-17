function wPdata = SummarizeWithinData_v01(Within_AllData)

wPdata = struct;
ParticipantIDs = unique(Within_AllData.vpNum);

wPdata.CouldExclude=[];
wPdata.Demographics = table;
wPdata.Choice = table;
wPdata.RT = table;

% Identify and remove individual outlier RTs    
Outlier_ix = (Within_AllData.rt < 100) | (Within_AllData.rt > 3000); 
Within_AllData(Outlier_ix,:)=[];

% now cycle through each participant and extract data of interest

for p = 1:numel(ParticipantIDs)
    
    thisPdata = Within_AllData(Within_AllData.vpNum == ParticipantIDs(p),:);
    
    % find out the order this participant experienced gain and loss
    % conditions
    
    if contains(thisPdata.type(1),'loss')
        order = 2;
    else
        order = 1;
    end
    
    
    % get demographic info
    tmpDemographics = table;
    tmpDemographics.vpNum       = p;
    tmpDemographics.pID         = ParticipantIDs(p);
    tmpDemographics.Age         = nanmean(thisPdata.age);
    tmpDemographics.IsFemale    = any(contains(thisPdata.gender,'female'));
    tmpDemographics.RightHanded = any(contains(thisPdata.handedness,'right'));
    tmpDemographics.Order       = order;
    
    % make some useful indices
    Train_ix = contains(thisPdata.phase,'learning');
    PureD_ix = contains(thisPdata.trialType,'PureDescription');
    PureE_ix = contains(thisPdata.trialType,'PureExperience');
    UE_ix    = contains(thisPdata.trialType,'UnequalMixed');
    EQ_ix    = contains(thisPdata.trialType,'EqualMixed');
    
    GainIX  = contains(thisPdata.type,'gain');
    LossIX  = contains(thisPdata.type,'loss');
    
    a20_ix    = thisPdata.imageProbLeft == .2 | thisPdata.imageProbRight == .2;
    a50_ix    = thisPdata.imageProbLeft == .5 | thisPdata.imageProbRight == .5;
    a80_ix    = thisPdata.imageProbLeft == .8 | thisPdata.imageProbRight == .8;
    
    % find each choice condition
    t20v50 = a20_ix & a50_ix;
    t50v80 = a50_ix & a80_ix;
    t20v80 = a20_ix & a80_ix;
    t20v20 = thisPdata.imageProbLeft == .2 & thisPdata.imageProbRight == .2;
    t50v50 = thisPdata.imageProbLeft == .5 & thisPdata.imageProbRight == .5;
    t80v80 = thisPdata.imageProbLeft == .8 & thisPdata.imageProbRight == .8;

    % pull out response data
    PickedExperience = contains(thisPdata.chosenImageType,'Experience');
    PickedHighProb  = thisPdata.highProbSelected;
    RT        = thisPdata.rt;
    LvRProbDiff = thisPdata.imageProbLeft - thisPdata.imageProbRight;
    % find cases where the experience stimuli were the high prob ones
    ExpIsHighProb   = (contains(thisPdata.imageTypeLeft,'Experience') & LvRProbDiff > 0) | (contains(thisPdata.imageTypeRight,'Experience') & LvRProbDiff < 0); 
    
    % get choice results
    tmpChoice_tbl=table;
    tmpRT_tbl=table;
    
    condarray = [GainIX , LossIX];
    for c = 1:size(condarray,2)
        
        if c ==2
           PickedHighProb = PickedHighProb ==0;
        end
        
        tmpChoice_tbl.vpNum(c,1) = p;
        tmpChoice_tbl.order(c,1) = order;     
        tmpChoice_tbl.context(c,1) = c;
        
        tmpChoice_tbl.TrainD_20v50(c,1) = nanmean(PickedHighProb(t20v50 & Train_ix & PureD_ix & condarray(:,c)));
        tmpChoice_tbl.TrainD_50v80(c,1) = nanmean(PickedHighProb(t50v80 & Train_ix & PureD_ix & condarray(:,c)));
        tmpChoice_tbl.TrainD_20v80(c,1) = nanmean(PickedHighProb(t20v80 & Train_ix & PureD_ix & condarray(:,c)));
        
        tmpChoice_tbl.TrainE_20v50(c,1) = nanmean(PickedHighProb(t20v50 & Train_ix & PureE_ix & condarray(:,c)));
        tmpChoice_tbl.TrainE_50v80(c,1) = nanmean(PickedHighProb(t50v80 & Train_ix & PureE_ix & condarray(:,c)));
        tmpChoice_tbl.TrainE_20v80(c,1) = nanmean(PickedHighProb(t20v80 & Train_ix & PureE_ix & condarray(:,c)));
        
        tmpChoice_tbl.PureD_20v50(c,1) = nanmean(PickedHighProb(t20v50 & ~Train_ix & PureD_ix & condarray(:,c)));
        tmpChoice_tbl.PureD_50v80(c,1) = nanmean(PickedHighProb(t50v80 & ~Train_ix & PureD_ix & condarray(:,c)));
        tmpChoice_tbl.PureD_20v80(c,1) = nanmean(PickedHighProb(t20v80 & ~Train_ix & PureD_ix & condarray(:,c)));
        
        tmpChoice_tbl.PureE_20v50(c,1) = nanmean(PickedHighProb(t20v50 & ~Train_ix & PureE_ix & condarray(:,c)));
        tmpChoice_tbl.PureE_50v80(c,1) = nanmean(PickedHighProb(t50v80 & ~Train_ix & PureE_ix & condarray(:,c)));
        tmpChoice_tbl.PureE_20v80(c,1) = nanmean(PickedHighProb(t20v80 & ~Train_ix & PureE_ix & condarray(:,c)));
        
        tmpChoice_tbl.UE_DisHigh_20v50(c,1) = nanmean(PickedHighProb(t20v50 & UE_ix & ~ExpIsHighProb & condarray(:,c)));
        tmpChoice_tbl.UE_DisHigh_50v80(c,1) = nanmean(PickedHighProb(t50v80 & UE_ix & ~ExpIsHighProb & condarray(:,c)));
        tmpChoice_tbl.UE_DisHigh_20v80(c,1) = nanmean(PickedHighProb(t20v80 & UE_ix & ~ExpIsHighProb & condarray(:,c)));
        
        tmpChoice_tbl.UE_EisHigh_20v50(c,1) = nanmean(PickedHighProb(t20v50 & UE_ix & ExpIsHighProb & condarray(:,c)));
        tmpChoice_tbl.UE_EisHigh_50v80(c,1) = nanmean(PickedHighProb(t50v80 & UE_ix & ExpIsHighProb & condarray(:,c)));
        tmpChoice_tbl.UE_EisHigh_20v80(c,1) = nanmean(PickedHighProb(t20v80 & UE_ix & ExpIsHighProb & condarray(:,c)));
        
        tmpChoice_tbl.EQ_20v20(c,1) = nanmean(PickedExperience(t20v20 & EQ_ix & condarray(:,c)));
        tmpChoice_tbl.EQ_50v50(c,1) = nanmean(PickedExperience(t50v50 & EQ_ix & condarray(:,c)));
        tmpChoice_tbl.EQ_80v80(c,1) = nanmean(PickedExperience(t80v80 & EQ_ix & condarray(:,c)));
        
        
        % now pull out the RT data
        tmpRT_tbl.vpNum(c,1) = p;
        tmpRT_tbl.order(c,1) = order;
        tmpRT_tbl.context(c,1) = c;
        tmpRT_tbl.TrainD_20v50(c,1) = nanmean(RT(t20v50 & Train_ix & PureD_ix & condarray(:,c)));
        tmpRT_tbl.TrainD_50v80(c,1) = nanmean(RT(t50v80 & Train_ix & PureD_ix & condarray(:,c)));
        tmpRT_tbl.TrainD_20v80(c,1) = nanmean(RT(t20v80 & Train_ix & PureD_ix & condarray(:,c)));
        
        tmpRT_tbl.TrainE_20v50(c,1) = nanmean(RT(t20v50 & Train_ix & PureE_ix & condarray(:,c)));
        tmpRT_tbl.TrainE_50v80(c,1) = nanmean(RT(t50v80 & Train_ix & PureE_ix & condarray(:,c)));
        tmpRT_tbl.TrainE_20v80(c,1) = nanmean(RT(t20v80 & Train_ix & PureE_ix & condarray(:,c)));
        
        tmpRT_tbl.PureD_20v50(c,1) = nanmean(RT(t20v50 & ~Train_ix & PureD_ix & condarray(:,c)));
        tmpRT_tbl.PureD_50v80(c,1) = nanmean(RT(t50v80 & ~Train_ix & PureD_ix & condarray(:,c)));
        tmpRT_tbl.PureD_20v80(c,1) = nanmean(RT(t20v80 & ~Train_ix & PureD_ix & condarray(:,c)));
        
        tmpRT_tbl.PureE_20v50(c,1) = nanmean(RT(t20v50 & ~Train_ix & PureE_ix & condarray(:,c)));
        tmpRT_tbl.PureE_50v80(c,1) = nanmean(RT(t50v80 & ~Train_ix & PureE_ix & condarray(:,c)));
        tmpRT_tbl.PureE_20v80(c,1) = nanmean(RT(t20v80 & ~Train_ix & PureE_ix & condarray(:,c)));
        
        tmpRT_tbl.UE_DisHigh_20v50(c,1) = nanmean(RT(t20v50 & UE_ix & ~ExpIsHighProb & condarray(:,c)));
        tmpRT_tbl.UE_DisHigh_50v80(c,1) = nanmean(RT(t50v80 & UE_ix & ~ExpIsHighProb & condarray(:,c)));
        tmpRT_tbl.UE_DisHigh_20v80(c,1) = nanmean(RT(t20v80 & UE_ix & ~ExpIsHighProb & condarray(:,c)));
        
        tmpRT_tbl.UE_EisHigh_20v50(c,1) = nanmean(RT(t20v50 & UE_ix & ExpIsHighProb & condarray(:,c)));
        tmpRT_tbl.UE_EisHigh_50v80(c,1) = nanmean(RT(t50v80 & UE_ix & ExpIsHighProb & condarray(:,c)));
        tmpRT_tbl.UE_EisHigh_20v80(c,1) = nanmean(RT(t20v80 & UE_ix & ExpIsHighProb & condarray(:,c)));
        
        
        tmpRT_tbl.EQ_20v20(c,1) = nanmean(RT(t20v20 & EQ_ix & condarray(:,c)));
        tmpRT_tbl.EQ_50v50(c,1) = nanmean(RT(t50v50 & EQ_ix & condarray(:,c)));
        tmpRT_tbl.EQ_80v80(c,1) = nanmean(RT(t80v80 & EQ_ix & condarray(:,c)));
        
        % check whether to potentially exclude this participant
        TrainD_all = nanmean(PickedHighProb(Train_ix & PureD_ix & condarray(:,c)));
        TrainE_all = nanmean(PickedHighProb(Train_ix & PureE_ix & condarray(:,c)));
        ExcludeParticipant(c,1) = TrainD_all < .50 |  TrainE_all < .50;
        
  

        
        
    end % of cycling through gain and loss
    
        if any(ExcludeParticipant)
            ExcludeParticipant = logical([ 1; 1]);
        end
        
        tmpDemographics.CouldExclude = ExcludeParticipant(1);
        
   % now put everything into the struct to be saved
    wPdata.Demographics(p,:) = tmpDemographics;
    wPdata.CouldExclude      = [wPdata.CouldExclude  ; ExcludeParticipant];
    wPdata.Choice            = [wPdata.Choice ; tmpChoice_tbl];
    wPdata.RT                = [wPdata.RT  ; tmpRT_tbl];
          
end % of cycling through participants


wPdata.CouldExclude = logical(wPdata.CouldExclude );


end % of function 