function [D_pOut, E_pOut] = GetRealStimulus_pWin_v01(AllData)


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
     else
         % non-zero outcome trials are the "wins".
         WinTrials = pData.rewardCode ==1;
     end
    
    % find the trials where the descriptive image was chosen
    PickedD = contains(pData.chosenImageType,'Description');
    
    % get chosen probability of each trial
    for t = 1:size(PickedD)
        
       if contains(pData.response_side(t),'right')
           ChosenProb(t,1) = pData.imageProbRight(t);
       else
           ChosenProb(t,1) = pData.imageProbLeft(t);
       end % of determining the chosen prob on this trial
               
    end % of looping through trials
    
    % loop through each prob and see how often gain/loss happened when it was
    % chosen
    
    Probs = unique(ChosenProb);
      
    for prob_ix = 1:numel(Probs)
        
        thisProb = Probs(prob_ix);
        
        D_thisProb_trials = PickedD & ChosenProb == thisProb;
        E_thisProb_trials = ~PickedD & ChosenProb == thisProb;
        
        D_pOut(p,prob_ix) = nanmean(pData.rewardCode(D_thisProb_trials))*100;
        E_pOut(p,prob_ix) = nanmean(pData.rewardCode(E_thisProb_trials))*100;
     
    end
     
    
     
     
end % of looping through participants


end % of function