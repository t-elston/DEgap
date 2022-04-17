% aaaDE_MainAnalysis_v02
% does the between and within subject analysis

% Thomas Elston
% telston@nurhopsi.org

%--------------
% BETWEEN-SUBJECT ANALYSIS AND PLOTTING
%--------------

% Define where the data are on your machine.
% --- MUST USE THE EXCEL FILES!
BETWEENDIR = 'C:\Users\Thomas Elston\Documents\MATLAB\Projects\DE gap\DE_data\excel files\';
WITHINDIR = 'C:\Users\Thomas Elston\Documents\MATLAB\Projects\DE gap\Within Subject\WithSubject_excelfiles\';


% Get the data for each participant from separate excel sheets one table.
[AllData] = ExtractParticipantData_v02(BETWEENDIR,'between');
[Within_AllData] = ExtractParticipantData_v02(WITHINDIR,'within');

% Loop through each file and create a summary for each participant.
[P_data] = SummarizeParticipantData_v02(AllData);
[wPdata] = SummarizeWithinData_v01(Within_AllData);

%---
% Plot and analyze the choice and RT data
%---
%*** set break points at end of each function for stats
%*** the combined plots from the paper are generated at the end
    
% Exp 1 - between-subject analysis
[Between_ChoiceFig] = PlotData_v03(P_data,'Choice');
[Between_RTFig] = PlotData_v03(P_data,'RT');
[zz] = PlotSurveyData_v04(P_data,AllData);

% Predicting participant EQ biases from training performance. 
[xx] = PredictEQfromTraining_v02(P_data,AllData);

% Win-stay, lose-shift analysis.
DE_WSLS_v01(AllData);

%---
% Exp 2 - within-subject analysis
%---
PlotWithinSubjectData_v01(wPdata,'Choice');
PlotWithinSubjectData_v01(wPdata,'RT');
[xx] = WithinSubjectPredictEQfromTraining_v01(wPdata,Within_AllData);

WithinSubject_DE_WSLS_v01(Within_AllData);


% DISTRIBUTIONAL RL
%- needs to run a few time to iron out stochasticity of the e-greedy policy
resolution = .05; % step size in the alpha+ and alpha- grid
nIters = 1000;
G_E_Q =[]; G_D_Q=[]; G_EQbias=[]; L_E_Q=[]; L_D_Q=[];  L_EQbias=[]; 
pw = PoolWaitbar(nIters, 'Doing distributional RL...');
parfor i = 1:nIters
    increment(pw);
    [BestAcc(:,i),E_BestQuantile(:,i),D_BestQuantile(:,i),GeneralEQbias(:,i)] = DE_distributionalRL_v04(AllData,P_data,resolution,.05);
    [G_E_Q(:,i) ,G_D_Q(:,i) ,G_EQbias(:,i) ,L_E_Q(:,i) ,L_D_Q(:,i) ,L_EQbias(:,i)] = WithinSubject_DE_distributionalRL_v01(Within_AllData,wPdata,resolution,.05);
end
delete(pw);

% ASSESS BETWEEN SUBJECT DATA ALONE - set break point at end for stats
PlotAndAnalyzeDistributionalRL_v01(BestAcc,E_BestQuantile,D_BestQuantile,GeneralEQbias,AllData);

% ASSESS WITHIN SUBJECT DATA ALONE - set break point at end for stats
WithinSubject_PlotAndAnalyzeDistributionalRL_v01(G_E_Q ,G_D_Q ,G_EQbias ,L_E_Q ,L_D_Q ,L_EQbias);
%--------------


%-------------------------
% make combined plots - these are what are in the paper.
%-------------------------
MakeCombinedPlot_v01(P_data,wPdata,'Choice');
MakeCombinedRTPlot_v01(P_data,wPdata,'RT');

PlotCombinedEQFromTraining_v01(P_data,AllData,wPdata);

PlotCombinedDistRL_v01(E_BestQuantile,D_BestQuantile,GeneralEQbias,AllData,...
                                G_E_Q ,G_D_Q ,G_EQbias ,L_E_Q ,L_D_Q ,L_EQbias);


% make the figure for the distributional hypothesis 
MakeDistWidth_HypothesisFig;




