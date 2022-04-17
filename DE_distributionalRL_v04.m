function [BestAcc,E_BestQuantile,D_BestQuantile,GeneralEQbias] = DE_distributionalRL_v04(AllData,P_data,resolution,epsilon)
xx=[];

ParticipantIDs = unique(AllData.vpNum);

for p = 1:numel(ParticipantIDs)
    
    thisPdata = AllData(AllData.vpNum == ParticipantIDs(p),:);
    
    if contains(thisPdata.version(1),'loss')
        pContext(p,1) = -1;
    else
        pContext(p,1) = 1;
    end
    
    nTrials = numel(thisPdata.rt);
    
    % find out what was actually chosen on each trial
    for t = 1:nTrials
        
        if contains(thisPdata.response_side(t),'right')
            ChosenProb(t,1)   = thisPdata.imageProbRight(t);
            UnChosenProb(t,1) = thisPdata.imageProbLeft(t);
            
            if contains(thisPdata.imageTypeLeft(t),'Description')
                UnChosenType(t,1) = 1;
            else
                UnChosenType(t,1) = 2;
            end
            
        else
            ChosenProb(t,1)   = thisPdata.imageProbLeft(t);
            UnChosenProb(t,1) = thisPdata.imageProbRight(t);
            
            if contains(thisPdata.imageTypeRight(t),'Description')
                UnChosenType(t,1) = 1;
            else
                UnChosenType(t,1) = 2;
            end
            
            
        end % of determining the chosen prob on this trial
       
       % keep track of the choice type in a way that's easy to index with
       % the Q table
       if contains(thisPdata.chosenImageType(t),'Description')
        ChosenType(t,1) = 1;
       else
        ChosenType(t,1) = 2; 
       end
       
       
    end % of looping through trials
    
    
    % recode the Chosen and UnChosen Probs so that it's easier to index
    % the Qtable later
    ChosenProb(ChosenProb==.2) = 1; UnChosenProb(UnChosenProb==.2) = 1;
    ChosenProb(ChosenProb==.5) = 2; UnChosenProb(UnChosenProb==.5) = 2;
    ChosenProb(ChosenProb==.8) = 3; UnChosenProb(UnChosenProb==.8) = 3;
    
    HumanChoice = ChosenType*10 + ChosenProb;
    
    EQ_ix  = contains(thisPdata.trialType,'EqualMixed');    
    p20_ix = thisPdata.imageProbLeft == .2;
    p50_ix = thisPdata.imageProbLeft == .5;
    p80_ix = thisPdata.imageProbLeft == .8;
    pickedExp = contains(thisPdata.chosenImageType,'Experience');
    
    % make sure the rewards are context specific 
    R = thisPdata.rewardCode * pContext(p,1);

    % initialize the Q table
    Qtbl = zeros(2,3) +.5;
    
    
    % do parameter sweep over + and - alphas with a .01 resolution
    ctr=0;
    for posAlpha = resolution:resolution:1
        
        for negAlpha = resolution:resolution:1
            ctr = ctr+1;
                    
            distQuantile(ctr,1) = posAlpha / (posAlpha + negAlpha);
            
            % now cycle through the individual trials
            for t = 2:nTrials
                
                % was this trial likely to elicit a positive or negative
                % PE?

                if  (R(t) - Qtbl(ChosenType(t-1),ChosenProb(t-1))) > 0
                    a = posAlpha;
                else
                    a = negAlpha;
                end
                               
                trialoptions = [(ChosenType(t)*10 + ChosenProb(t)) , (UnChosenType(t)*10 + UnChosenProb(t))];
                trialvalues  = [Qtbl(ChosenType(t),ChosenProb(t)) , Qtbl(UnChosenType(t),UnChosenProb(t))];
                
                % use an e-greedy policy             
                if diff(trialvalues) > epsilon
                    [BestVal,BestIX] = max(trialvalues);
                    Qchoice(t,1) = trialoptions(BestIX);
                else
                   Qchoice(t,1) = trialoptions(randi(2));
                end
                    
               
                     
                % update the table based on what the person did
                Qtbl(ChosenType(t),ChosenProb(t)) = Qtbl(ChosenType(t-1),ChosenProb(t-1)) + a*(R(t) - Qtbl(ChosenType(t-1),ChosenProb(t-1)));


                
                
            end % of cycling through trials
            
            % how accurate was this quantile?
            Acc(ctr,1) = sum(Qchoice(EQ_ix) == HumanChoice(EQ_ix))/numel(Qchoice(EQ_ix));
            EAcc(ctr,1) = sum(Qchoice(pickedExp & EQ_ix) == HumanChoice(pickedExp & EQ_ix))/numel(Qchoice(pickedExp & EQ_ix));
            DAcc(ctr,1) = sum(Qchoice(~pickedExp & EQ_ix) == HumanChoice(~pickedExp & EQ_ix))/numel(Qchoice(~pickedExp & EQ_ix));


            
 
            
        end % of cycyling through negative alphas
        
    end % of cycling through positive alphas
    
    %which quantile was most accurate for this participant?
    [BestAcc(p,1),quantIX] = max(Acc);
    BestQuantile(p,1) = distQuantile(quantIX);
    
   [E_BestAcc(p,1),E_quantIX] = max(EAcc);
    E_BestQuantile(p,1) = distQuantile(E_quantIX);
    
   [D_BestAcc(p,1),D_quantIX] = max(DAcc);
    D_BestQuantile(p,1) = distQuantile(D_quantIX);
    
    
    % what was the general equiprobable bias across all EQ conditions?
    GeneralEQbias(p,1) = mean(pickedExp(EQ_ix));

    

  
end % of cycling through participants

BestQuants = [E_BestQuantile - D_BestQuantile];

% option to exclude bad participants - can comment this out
% BestQuantile(logical(P_data.ExcludeParticipant))=[];
% BestAcc(logical(P_data.ExcludeParticipant))=[];
% GeneralEQbias(logical(P_data.ExcludeParticipant))=[];
% pContext(logical(P_data.ExcludeParticipant))=[];
% BestQuants(logical(P_data.ExcludeParticipant))=[];






end % of function 