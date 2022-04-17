function [P_data] = SummarizeParticipantData_v02(AllData)
P_data = struct;

ParticipantIDs = unique(AllData.vpNum);
P_data.ParticipantIDs = [];
P_data.Protocol = {};
P_data.ExcludeParticipant=[];
P_data.Demographics = table;
P_data.Choice = table;
P_data.RT = table;
P_data.Survey = table;


% find outlier threshold for RTs
% EXTRACT key measures
% depending on the version of matlab you are using, these variables will be
% read out of the excel file as a logical or as a string. This works both
% ways
try
    AllPickedHighProb   = double(contains(AllData.highProbSelected,'true'));
catch
    AllPickedHighProb = double(AllData.highProbSelected);
end

AllPickedExperience = double(contains(AllData.chosenImageType,'Experience'));


allRTs   = AllData.rt;
AllLvRProbDiff = AllData.imageProbLeft - AllData.imageProbRight;

% Identify individual outlier RTs    
Outlier_ix = (allRTs < 100) | (allRTs > 3000);   

allRTs(Outlier_ix) = NaN;
AllPickedHighProb(Outlier_ix) = NaN;
AllPickedExperience(Outlier_ix) = NaN;
AllLvRProbDiff(Outlier_ix) = NaN;

% figure;
% lp=0;

% cycle through each participant and get mean results
for p = 1:numel(ParticipantIDs)
    
    % depending on the version of matlab you have, the vpNum would be read
    % out as a string or a double. This works both ways.
    try
        thisP_ix = contains(AllData.vpNum,ParticipantIDs(p));
    catch
        thisP_ix = AllData.vpNum == ParticipantIDs(p);
    end
        
    thisP_data= AllData(thisP_ix,:);
    
    % save ID num
    P_data.ParticipantIDs(p,:) = ParticipantIDs(p);
    
%     % save the protocol type
%     if(contains(thisP_data.version,'loss'))
%        P_data.Protocol(p,1) = {'loss'};
%        lp_col = 'b';
%     else
%         P_data.Protocol(p,1) = {'gain'};
%         lp_col = 'r';
%     end
    
   RT=allRTs(thisP_ix);
   PickedHighProb   = AllPickedHighProb(thisP_ix);
   PickedExperience = AllPickedExperience(thisP_ix);
   LvRProbDiff = AllLvRProbDiff(thisP_ix);
    
    
%---------------------------------------
% collect some indices for grouping data
%---------------------------------------  
Train_ix = contains(thisP_data.phase,'learning');
PureD_ix = contains(thisP_data.trialType,'PureDescription');
PureE_ix = contains(thisP_data.trialType,'PureExperience');    
UE_ix    = contains(thisP_data.trialType,'UnequalMixed');      
EQ_ix    = contains(thisP_data.trialType,'EqualMixed'); 

% find cases where the experience stimuli were the high prob ones
ExpIsHighProb   = (contains(thisP_data.imageTypeLeft,'Experience') & LvRProbDiff > 0) | (contains(thisP_data.imageTypeRight,'Experience') & LvRProbDiff < 0); 

% find the choice conditions
a20_ix = thisP_data.imageProbLeft == .2 | thisP_data.imageProbRight == .2;
a50_ix = thisP_data.imageProbLeft == .5 | thisP_data.imageProbRight == .5;
a80_ix = thisP_data.imageProbLeft == .8 | thisP_data.imageProbRight == .8;

t20v20 = thisP_data.imageProbLeft == .2 & thisP_data.imageProbRight ==.2;
t50v50 = thisP_data.imageProbLeft == .5 & thisP_data.imageProbRight ==.5;
t80v80 = thisP_data.imageProbLeft == .8 & thisP_data.imageProbRight ==.8;

t20v50 = a20_ix & a50_ix;
t50v80 = a50_ix & a80_ix;
t20v80 = a20_ix & a80_ix;
%---------------------------------------
  
    % get RT data
    tmpRT_tbl=table;
    tmpRT_tbl.TrainD_20v50 = nanmean(RT(t20v50 & Train_ix & PureD_ix));
    tmpRT_tbl.TrainD_50v80 = nanmean(RT(t50v80 & Train_ix & PureD_ix));
    tmpRT_tbl.TrainD_20v80 = nanmean(RT(t20v80 & Train_ix & PureD_ix));
    
    tmpRT_tbl.TrainE_20v50 = nanmean(RT(t20v50 & Train_ix & PureE_ix));
    tmpRT_tbl.TrainE_50v80 = nanmean(RT(t50v80 & Train_ix & PureE_ix));
    tmpRT_tbl.TrainE_20v80 = nanmean(RT(t20v80 & Train_ix & PureE_ix));
    
    tmpRT_tbl.PureD_20v50 = nanmean(RT(t20v50 & ~Train_ix & PureD_ix));
    tmpRT_tbl.PureD_50v80 = nanmean(RT(t50v80 & ~Train_ix & PureD_ix));
    tmpRT_tbl.PureD_20v80 = nanmean(RT(t20v80 & ~Train_ix & PureD_ix));
    
    tmpRT_tbl.PureE_20v50 = nanmean(RT(t20v50 & ~Train_ix & PureE_ix));
    tmpRT_tbl.PureE_50v80 = nanmean(RT(t50v80 & ~Train_ix & PureE_ix));
    tmpRT_tbl.PureE_20v80 = nanmean(RT(t20v80 & ~Train_ix & PureE_ix));
    
    tmpRT_tbl.UE_DisHigh_20v50 = nanmean(RT(t20v50 & UE_ix & ~ExpIsHighProb));
    tmpRT_tbl.UE_DisHigh_50v80 = nanmean(RT(t50v80 & UE_ix & ~ExpIsHighProb));
    tmpRT_tbl.UE_DisHigh_20v80 = nanmean(RT(t20v80 & UE_ix & ~ExpIsHighProb));
    
    tmpRT_tbl.UE_EisHigh_20v50 = nanmean(RT(t20v50 & UE_ix & ExpIsHighProb));
    tmpRT_tbl.UE_EisHigh_50v80 = nanmean(RT(t50v80 & UE_ix & ExpIsHighProb));
    tmpRT_tbl.UE_EisHigh_20v80 = nanmean(RT(t20v80 & UE_ix & ExpIsHighProb));
    
    
    tmpRT_tbl.EQ_20v20 = nanmean(RT(t20v20 & EQ_ix));
    tmpRT_tbl.EQ_50v50 = nanmean(RT(t50v50 & EQ_ix));
    tmpRT_tbl.EQ_80v80 = nanmean(RT(t80v80 & EQ_ix));
    
    % CHOICE PATTERNS
    tmpChoice_tbl=table;
    tmpChoice_tbl.TrainD_20v50 = nanmean(PickedHighProb(t20v50 & Train_ix & PureD_ix));
    tmpChoice_tbl.TrainD_50v80 = nanmean(PickedHighProb(t50v80 & Train_ix & PureD_ix));
    tmpChoice_tbl.TrainD_20v80 = nanmean(PickedHighProb(t20v80 & Train_ix & PureD_ix));
    
    tmpChoice_tbl.TrainE_20v50 = nanmean(PickedHighProb(t20v50 & Train_ix & PureE_ix));
    tmpChoice_tbl.TrainE_50v80 = nanmean(PickedHighProb(t50v80 & Train_ix & PureE_ix));
    tmpChoice_tbl.TrainE_20v80 = nanmean(PickedHighProb(t20v80 & Train_ix & PureE_ix));
    
    tmpChoice_tbl.PureD_20v50 = nanmean(PickedHighProb(t20v50 & ~Train_ix & PureD_ix));
    tmpChoice_tbl.PureD_50v80 = nanmean(PickedHighProb(t50v80 & ~Train_ix & PureD_ix));
    tmpChoice_tbl.PureD_20v80 = nanmean(PickedHighProb(t20v80 & ~Train_ix & PureD_ix));
    
    tmpChoice_tbl.PureE_20v50 = nanmean(PickedHighProb(t20v50 & ~Train_ix & PureE_ix));
    tmpChoice_tbl.PureE_50v80 = nanmean(PickedHighProb(t50v80 & ~Train_ix & PureE_ix));
    tmpChoice_tbl.PureE_20v80 = nanmean(PickedHighProb(t20v80 & ~Train_ix & PureE_ix));
    
    tmpChoice_tbl.UE_DisHigh_20v50 = nanmean(PickedHighProb(t20v50 & UE_ix & ~ExpIsHighProb));
    tmpChoice_tbl.UE_DisHigh_50v80 = nanmean(PickedHighProb(t50v80 & UE_ix & ~ExpIsHighProb));
    tmpChoice_tbl.UE_DisHigh_20v80 = nanmean(PickedHighProb(t20v80 & UE_ix & ~ExpIsHighProb));
    
    tmpChoice_tbl.UE_EisHigh_20v50 = nanmean(PickedHighProb(t20v50 & UE_ix & ExpIsHighProb));
    tmpChoice_tbl.UE_EisHigh_50v80 = nanmean(PickedHighProb(t50v80 & UE_ix & ExpIsHighProb));
    tmpChoice_tbl.UE_EisHigh_20v80 = nanmean(PickedHighProb(t20v80 & UE_ix & ExpIsHighProb));
    
    tmpChoice_tbl.EQ_20v20 = nanmean(PickedExperience(t20v20 & EQ_ix));
    tmpChoice_tbl.EQ_50v50 = nanmean(PickedExperience(t50v50 & EQ_ix));
    tmpChoice_tbl.EQ_80v80 = nanmean(PickedExperience(t80v80 & EQ_ix));
    
    % SURVEY
    tmpSurvey = table;
    tmpSurvey.D1 = thisP_data.D1(1);
    tmpSurvey.D2 = thisP_data.D2(1);
    tmpSurvey.D3 = thisP_data.D3(1);    
    tmpSurvey.E1 = thisP_data.E1(1);
    tmpSurvey.E2 = thisP_data.E2(1);
    tmpSurvey.E3 = thisP_data.E3(1);
    
    % BASIC DEMOGRAPHICS
    tmpDemographics = table;
    tmpDemographics.Age         = thisP_data.age(1);
    tmpDemographics.IsFemale    = contains(thisP_data.gender(1),'female');
    tmpDemographics.RightHanded = contains(thisP_data.handedness(1),'right');
    
    % now put everything into the struct to be saved
    P_data.Demographics(p,:) = tmpDemographics;
    P_data.Choice(p,:)       = tmpChoice_tbl;
    P_data.RT(p,:)           = tmpRT_tbl;
    P_data.Survey(p,:)       = tmpSurvey;
    
    % check whether to potentially exclude this participant
    TrainD_all = nanmean(PickedHighProb(Train_ix & PureD_ix));
    TrainE_all = nanmean(PickedHighProb(Train_ix & PureE_ix));
    
    MainD_all = nanmean(PickedHighProb(~Train_ix & PureD_ix));
    MainE_all = nanmean(PickedHighProb(~Train_ix & PureE_ix));

    if contains(thisP_data.version,'loss')
        TrainD_all = 1 -TrainD_all;
        TrainE_all = 1 -TrainE_all;
        
        MainD_all = 1 - MainD_all;
        MainE_all = 1 - MainE_all;

    end
    
    
    P_data.ExcludeParticipant(p,1) = mean(TrainD_all) < .50 |  mean(TrainE_all) < .50;
    
%     P_data.ExcludeParticipant(p,1) = mean(MainD_all) < .50 |  mean(MainE_all) < .50;


    
end % of cycling through each participant








end % of function