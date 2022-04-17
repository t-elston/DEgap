function WithinSubject_DE_WSLS_v01(AllData)

ParticipantIDs = unique(AllData.vpNum);

ctr = 0;
for p = 1:numel(ParticipantIDs)
    
    pData = AllData(AllData.vpNum == ParticipantIDs(p),:);
    
    % go through each context, gain first
    for c = 1:2
        ctr = ctr+1;
        
        if c ==1 % look at gain context
            pData2 = pData(contains(pData.type,'gain'),:);
            
            % non-zero outcome trials are the "wins".
            WinTrials = pData2.rewardCode ==1;
            LoseTrials = pData2.rewardCode == 0;
            
        end
        
        if c ==2
            pData2 = pData(contains(pData.type,'loss'),:);
            
            % zero outcome trials are the "wins".
            WinTrials = pData2.rewardCode ==0;
            LoseTrials = pData2.rewardCode ==1;
            
        end
        
        
        % let's look at just the main block "pure" trials
        MainD = contains(pData2.phase,'experiment') & contains(pData2.trialType,'PureDescription');
        MainE = contains(pData2.phase,'experiment') & contains(pData2.trialType,'PureExperience');
        
        ChoiceProbs = [pData2.imageProbLeft , pData2.imageProbRight];
        
        % get chosen probability of each trial
        for t = 1:size(MainD)
            
            if contains(pData2.response_side(t),'right')
                ChosenProb(t,1) = pData2.imageProbRight(t);
            else
                ChosenProb(t,1) = pData2.imageProbLeft(t);
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
            
            
            D_WS(ctr,prob_ix) = nanmean(ChosenProb(winNextDtrials) == thisProb);
            E_WS(ctr,prob_ix) = nanmean(ChosenProb(winNextEtrials) == thisProb);
            
            % look and see the lose-shift
            D_LS(ctr,prob_ix) = nanmean(ChosenProb(loseNextDtrials) ~= thisProb);
            E_LS(ctr,prob_ix) = nanmean(ChosenProb(loseNextEtrials) ~= thisProb);
            
            SubjectID(ctr,prob_ix) = p;
            Context(ctr,prob_ix)   = c;
            ProbFactor(ctr,prob_ix) = prob_ix;
            DStimFactor(ctr,prob_ix) = 1;
            EStimFactor(ctr,prob_ix) = 2;

            
        end % of looping through probabilities
        
    end % of cycling through contexts
    
end % of cycling through participants
    


% get mean and confidence intervals 
[winMeanDgain,win_CI_Dgain] = GetMeanCI(D_WS(Context(:,1) ==1,:),'bootstrap');
[winMeanDloss,win_CI_Dloss] = GetMeanCI(D_WS(Context(:,1) ==2,:),'bootstrap');

[winMeanEgain,win_CI_Egain] = GetMeanCI(E_WS(Context(:,1) ==1,:),'bootstrap');
[winMeanEloss,win_CI_Eloss] = GetMeanCI(E_WS(Context(:,1) ==2,:),'bootstrap');

[loseMeanDgain,lose_CI_Dgain] = GetMeanCI(D_LS(Context(:,1) ==1,:),'bootstrap');
[loseMeanDloss,lose_CI_Dloss] = GetMeanCI(D_LS(Context(:,1) ==2,:),'bootstrap');

[loseMeanEgain,lose_CI_Egain] = GetMeanCI(E_LS(Context(:,1) ==1,:),'bootstrap');
[loseMeanEloss,lose_CI_Eloss] = GetMeanCI(E_LS(Context(:,1) ==2,:),'bootstrap');

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
yticks([0 .2 .4 .6 .8 1]);

xticks([ 0 .2 .5 .8 1]);
ylim([0 1]);
ylabel('p(Lose-Shift)');
xlabel('Probability');
set(gca,'LineWidth',1,'FontSize',14)


% repeated measures anova to assess any differences in WS and LS patterns 

allWSdata      = [reshape(D_WS,[],1) ; reshape(E_WS,[],1)];
allLSdata      = [reshape(D_LS,[],1) ; reshape(E_LS,[],1)];
ContextFactor  = [reshape(Context,[],1) ; reshape(Context,[],1) ];
SubjectFactor  = [reshape(SubjectID,[],1) ; reshape(SubjectID,[],1) ];
StimTypeFactor = [reshape(DStimFactor,[],1) ; reshape(EStimFactor,[],1) ];
ProbFactor     = [reshape(ProbFactor,[],1) ; reshape(ProbFactor,[],1) ];

[~,WSanovatbl] = anovan(allWSdata,{ContextFactor,StimTypeFactor,ProbFactor,SubjectFactor},'VarNames',...
          {'Context','StimType','Prob','Subject'},'random',4,'model','interaction','display','off');
WSanovatbl(contains(WSanovatbl(:,1),'Subj'),:)=[];

[~,LSanovatbl] = anovan(allLSdata,{ContextFactor,StimTypeFactor,ProbFactor,SubjectFactor},'VarNames',...
          {'Context','StimType','Prob','Subject'},'random',4,'model','interaction','display','off');
LSanovatbl(contains(LSanovatbl(:,1),'Subj'),:)=[];





end % of function