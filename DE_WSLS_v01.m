function DE_WSLS_v01(AllData)

ParticipantIDs = unique(AllData.vpNum);

for p = 1:numel(ParticipantIDs)
    
    pData = AllData(AllData.vpNum == ParticipantIDs(p),:);
    
    % which protocol was this participant in?
     LossIX(p,1) = contains(pData.version(1),'loss');
     
     % be sure that win trials are the -0 trials in the loss protocol
     % and are the +1 trials in the gain protocol 
     if LossIX(p)
         % non-zero outcome trials are the "wins".
         WinTrials = pData.rewardCode ==0;
         LoseTrials = pData.rewardCode ==1;
     else
         % non-zero outcome trials are the "wins".
         WinTrials = pData.rewardCode ==1;
         LoseTrials = pData.rewardCode == 0;

     end
    
    % let's look at just the main block "pure" trials
    MainD = contains(pData.phase,'experiment') & contains(pData.trialType,'PureDescription');
    MainE = contains(pData.phase,'experiment') & contains(pData.trialType,'PureExperience');
    
    ChoiceProbs = [pData.imageProbLeft , pData.imageProbRight];
    
    % get chosen probability of each trial
    for t = 1:size(MainD)
        
       if contains(pData.response_side(t),'right')
           ChosenProb(t,1) = pData.imageProbRight(t);
       else
           ChosenProb(t,1) = pData.imageProbLeft(t);
       end % of determining the chosen prob on this trial
               
    end % of looping through trials
    
    % loop through each possible probability and find it's win-stay
    % probability. Do this separately for description and experience
    % options. 
    
    Probs = unique(ChosenProb);
      
    for prob_ix = 1:numel(Probs)
        
        thisProb = Probs(prob_ix);
        
        % find instances where this prob was chosen in the main D and E
        % trials
        ThisProb_D_trials = MainD & (ChosenProb == thisProb);
        ThisProb_E_trials = MainE & (ChosenProb == thisProb);
        
        % find trials where this prob was present 
        MainD_ProbInTrial = find(any(ChoiceProbs==thisProb,2) & MainD);
        MainE_ProbInTrial = find(any(ChoiceProbs==thisProb,2) & MainE);
        
        % find the trial indices of the "win" trials when this prob was
        % chosen
        winD_trials = find(ThisProb_D_trials & WinTrials);
        winE_trials = find(ThisProb_E_trials & WinTrials);
        
        loseD_trials = find(ThisProb_D_trials & LoseTrials);
        loseE_trials = find(ThisProb_E_trials & LoseTrials);
        
        % find the nearest trial after each individual win trial to see
        % whether the participant picks it again
        winNextDtrials = MainD_ProbInTrial(circshift(ismember(MainD_ProbInTrial,winD_trials),1));
        winNextEtrials = MainE_ProbInTrial(circshift(ismember(MainE_ProbInTrial,winE_trials),1));
        
        loseNextDtrials = MainD_ProbInTrial(circshift(ismember(MainD_ProbInTrial,loseD_trials),1));
        loseNextEtrials = MainE_ProbInTrial(circshift(ismember(MainE_ProbInTrial,loseE_trials),1));
        
        % now look and see whether they pick this same image again after a
        % win
        D_WS(p,prob_ix) = nanmean(ChosenProb(winNextDtrials) == thisProb);
        E_WS(p,prob_ix) = nanmean(ChosenProb(winNextEtrials) == thisProb);
        
        % look and see the lose-shift 
        D_LS(p,prob_ix) = nanmean(ChosenProb(loseNextDtrials) ~= thisProb);
        E_LS(p,prob_ix) = nanmean(ChosenProb(loseNextEtrials) ~= thisProb);
       
    end % of looping through probabilities    
    
end % of cycling through participants

% get mean and confidence intervals 
[winMeanDgain,win_CI_Dgain] = GetMeanCI(D_WS(~LossIX,:),'bootstrap');
[winMeanDloss,win_CI_Dloss] = GetMeanCI(D_WS(LossIX,:),'bootstrap');

[winMeanEgain,win_CI_Egain] = GetMeanCI(E_WS(~LossIX,:),'bootstrap');
[winMeanEloss,win_CI_Eloss] = GetMeanCI(E_WS(LossIX,:),'bootstrap');

[loseMeanDgain,lose_CI_Dgain] = GetMeanCI(D_LS(~LossIX,:),'bootstrap');
[loseMeanDloss,lose_CI_Dloss] = GetMeanCI(D_LS(LossIX,:),'bootstrap');

[loseMeanEgain,lose_CI_Egain] = GetMeanCI(E_LS(~LossIX,:),'bootstrap');
[loseMeanEloss,lose_CI_Eloss] = GetMeanCI(E_LS(LossIX,:),'bootstrap');

% define the color scheme for plotting 
DGcol = [0.121568627450980,0.470588235294118,0.705882352941177];
DLcol = [0.650980392156863,0.807843137254902,0.890196078431373];
EGcol = [0.890196078431373,0.101960784313725,0.109803921568627];
ELcol = [0.984313725490196,0.603921568627451,0.600000000000000];

fig = figure;
set(fig,'Units','centimeters','Position',[10 10 15 7]);
set(gcf,'renderer','Painters');
axW=.25;
axH=.7;
WSax = axes('Position',[.15   .25  axW  axH]);
LSax = axes('Position',[.55   .25  axW  axH]);

axes(WSax);
hold on
errorbar(Probs,winMeanDgain,win_CI_Dgain,'color',DGcol,'LineWidth',2,'CapSize',0,'Marker','.','MarkerSize',20);
errorbar(Probs,winMeanDloss,win_CI_Dloss,'color',DLcol,'LineWidth',2,'CapSize',0,'Marker','.','MarkerSize',20);
errorbar(Probs,winMeanEgain,win_CI_Egain,'color',EGcol,'LineWidth',2,'CapSize',0,'Marker','.','MarkerSize',20);
errorbar(Probs,winMeanEloss,win_CI_Eloss,'color',ELcol,'LineWidth',2,'CapSize',0,'Marker','.','MarkerSize',20);
xlim([.1 .9]);
xticks([ 0 .2 .5 .8 1]);
yticks([0 .2 .4 .6 .8 1]);
ylim([0 1]);
ylabel('p(Win-Stay)');
xlabel('Probability');
set(gca,'LineWidth',1,'FontSize',14)
% legend({'D_{gain}','D_{loss}','E_{gain}','E_{loss}'},'FontSize',12,'NumColumns',2);

axes(LSax);
hold on
errorbar(Probs,loseMeanDgain,lose_CI_Dgain,'color',DGcol,'LineWidth',2,'CapSize',0,'Marker','.','MarkerSize',20);
errorbar(Probs,loseMeanDloss,lose_CI_Dloss,'color',DLcol,'LineWidth',2,'CapSize',0,'Marker','.','MarkerSize',20);
errorbar(Probs,loseMeanEgain,lose_CI_Egain,'color',EGcol,'LineWidth',2,'CapSize',0,'Marker','.','MarkerSize',20);
errorbar(Probs,loseMeanEloss,lose_CI_Eloss,'color',ELcol,'LineWidth',2,'CapSize',0,'Marker','.','MarkerSize',20);
xlim([.1 .9]);
xticks([ 0 .2 .5 .8 1]);
yticks([0 .2 .4 .6 .8 1]);
ylim([0 1]);
ylabel('p(Lose-Shift)');
xlabel('Probability');
set(gca,'LineWidth',1,'FontSize',14)


% do a mixed, repeated measures anova to assess any differences in win-stay
% patterns 
winData = [];
winData(:,:,1) = D_WS;
winData(:,:,2) = E_WS;
win_ranovatbl = simple_mixed_anova(winData, LossIX, {'Prob', 'StimType'}, {'Protocol'});

% DO A REPEATED MEASURES ANOVA
lossData = [];
lossData(:,:,1) = D_LS;
lossData(:,:,2) = E_LS;
loss_ranovatbl = simple_mixed_anova(lossData, LossIX, {'Prob', 'StimType'}, {'Protocol'});



end % of function