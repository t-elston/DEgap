function [zz] = PlotSurveyData_v04(P_data,AllData)
% v04 references data to the frequency of experienced payoffs per stimulus

zz=[];
% EXTRACT AND SUMMARIZE DATA
Data = P_data.Survey;
Loss_ix = contains(P_data.Protocol,'loss');
NumPs = numel(Loss_ix);

% EXCLUDE PARTICIPANTS
% Exclude_ix = logical(P_data.ExcludeParticipant);
% NumPs = sum(~Exclude_ix);
% Data(Exclude_ix,:)=[];
% Loss_ix(Exclude_ix)=[];

VarNames =  Data.Properties.VariableNames;

Loss_tbl(1,:)  = nanmean(table2array(Data(Loss_ix,:)));
Loss_tbl(2,:) = nanstd(table2array(Data(Loss_ix,:))) / sqrt(sum(Loss_ix));

Loss_tbl = array2table(Loss_tbl);
Loss_tbl.Properties.VariableNames = VarNames;

Gain_tbl(1,:) = nanmean(table2array(Data(~Loss_ix,:)));
Gain_tbl(2,:) = nanstd(table2array(Data(~Loss_ix,:))) / sqrt(sum(~Loss_ix));

Gain_tbl = array2table(Gain_tbl);
Gain_tbl.Properties.VariableNames = VarNames;

% get the real payoff/loss probabilities associated with each stimulus
[D_pOut, E_pOut] = GetRealStimulus_pWin_v01(AllData);

DE_OutcomeDiffs = D_pOut - E_pOut;
DE_RatingDiffs = table2array(Data(:,1:3)) - table2array(Data(:,4:6));


ErrorScores(:,1) = Data.D1-D_pOut(:,1);
ErrorScores(:,2) = Data.D2-D_pOut(:,2);
ErrorScores(:,3) = Data.D3-D_pOut(:,3);
ErrorScores(:,4) = Data.E1-E_pOut(:,1);
ErrorScores(:,5) = Data.E2-E_pOut(:,2);
ErrorScores(:,6) = Data.E3-E_pOut(:,3);

%--------------------------------------------------------
% PAREMETERS FOR PLOTTING
DGcol = [0.121568627450980,0.470588235294118,0.705882352941177];
DLcol = [0.650980392156863,0.807843137254902,0.890196078431373];
EGcol = [0.890196078431373,0.101960784313725,0.109803921568627];
ELcol = [0.984313725490196,0.603921568627451,0.600000000000000];

LW =3;
ax_LW = 1;
ax_FntSz = 12;
MkrSz = 8;
SMkrSz = 10;
xlbls = {'20' '50' '80'};
xlims = [0 100];


% PLOT DATA
fig = figure;
set(fig, 'Position', [100 150 900 300]);
set(gcf,'renderer','Painters');
RAWax    = axes('Position',[.1   .2  .22  .65]);
ERRORax  = axes('Position',[.43   .2  .22  .65]);
OxRax    = axes('Position',[.75   .2  .22  .65]);

axes(RAWax);
hold on
plot([0 100], [0 100],'k','LineWidth',1,'LineStyle','-');
errorbar([20 50 80],table2array(Gain_tbl(1,1:3)),table2array(Gain_tbl(2,1:3)),'^','MarkerSize',MkrSz,'MarkerFaceColor',DGcol,'LineWidth',LW,'MarkerEdgeColor',DGcol,'color',DGcol);
errorbar([20 50 80],table2array(Gain_tbl(1,4:6)),table2array(Gain_tbl(2,4:6)),'^','MarkerSize',MkrSz,'MarkerFaceColor',EGcol,'LineWidth',LW,'MarkerEdgeColor',EGcol,'color',EGcol);
errorbar([20 50 80],table2array(Loss_tbl(1,1:3)),table2array(Loss_tbl(2,1:3)),'s','MarkerSize',SMkrSz,'MarkerFaceColor',DLcol,'LineWidth',LW,'MarkerEdgeColor',DLcol,'color',DLcol);
errorbar([20 50 80],table2array(Loss_tbl(1,4:6)),table2array(Loss_tbl(2,4:6)),'s','MarkerSize',SMkrSz,'MarkerFaceColor',ELcol,'LineWidth',LW,'MarkerEdgeColor',ELcol,'color',ELcol);
ylim([0 100]);
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
% legend({'unity','D - gain','E - gain','D - loss','E - loss'},'FontSize',ax_FntSz);
% legend boxoff
ylabel('Reported Probability (%)');
xticks([0 20,50,80,100]);
xlim(xlims);
xlabel('Real Gain/Loss Probability (%)');



% NOW SHOW THE ERROR SCORES
axes(ERRORax);
hold on
errorbar([20 50 80],nanmean(ErrorScores(~Loss_ix,1:3)),nanstd(ErrorScores(~Loss_ix,1:3))/sqrt(30),'^','MarkerSize',MkrSz,'MarkerFaceColor',DGcol,'LineWidth',LW,'MarkerEdgeColor',DGcol,'color',DGcol);
errorbar([20 50 80],nanmean(ErrorScores(~Loss_ix,4:6)),nanstd(ErrorScores(~Loss_ix,4:6))/sqrt(30),'^','MarkerSize',MkrSz,'MarkerFaceColor',EGcol,'LineWidth',LW,'MarkerEdgeColor',EGcol,'color',EGcol);
errorbar([20 50 80],nanmean(ErrorScores(Loss_ix,1:3)),nanstd(ErrorScores(Loss_ix,1:3))/sqrt(30),'s','MarkerSize',SMkrSz,'MarkerFaceColor',DLcol,'LineWidth',LW,'MarkerEdgeColor',DLcol,'color',DLcol);
errorbar([20 50 80],nanmean(ErrorScores(Loss_ix,4:6)),nanstd(ErrorScores(Loss_ix,4:6))/sqrt(30),'s','MarkerSize',SMkrSz,'MarkerFaceColor',ELcol,'LineWidth',LW,'MarkerEdgeColor',ELcol,'color',ELcol);
ylim([-25 20]);
xlim(xlims);
plot([0 100], [0 0],'k','LineWidth',1,'LineStyle','-');
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
ylabel({'Inferential Error ' ; '(\Delta% from True Likelihood)'});
xticks([0 20,50,80,100]);


% collect factors
DE_Factor        = [reshape(ones(NumPs,3),[],1) ; reshape(ones(NumPs,3)+1,[],1)];
ProbFactor = [ones(NumPs,1) ; ones(NumPs,1)+1 ; ones(NumPs,1)+2 ; ones(NumPs,1) ; ones(NumPs,1)+1 ; ones(NumPs,1)+2];
ProtocolFactor   = [Loss_ix ; Loss_ix ;Loss_ix ;Loss_ix ;Loss_ix ;Loss_ix];
Subject = [[1:NumPs]' ; [1:NumPs]'; [1:NumPs]'; [1:NumPs]'; [1:NumPs]'; [1:NumPs]'];
S_Y = reshape(ErrorScores,[],1);


% DO A REPEATED MEASURES ANOVA
SurveyRMData = [];
SurveyRMData(:,:,1) = (ErrorScores(:,1:3)); % description 
SurveyRMData(:,:,2) = (ErrorScores(:,4:6)); % experience
Survey_ranovatbl = simple_mixed_anova(SurveyRMData, Loss_ix, {'Prob', 'StimType'}, {'Protocol'});


% NOW RELATE THE DIFFERENCE IN EXPERIENCED OUTCOMES TO DIFFERENCES IN RATINGS
% colors
L20 = [166 206 227]/255;
G20 = [31  120 180]/255;
L50 = [178 223 138]/255;
G50 = [51  160 44] /255;
L80 = [251 154 153]/255;
G80 = [227 26  28] /255;

axes(OxRax);
hold on
xlim([-20 20]);
ylim([-80 80]);
plot(xlim,[0 0],'k');
plot([0 0],ylim,'k');

plot(DE_OutcomeDiffs(Loss_ix,1),DE_RatingDiffs(Loss_ix,1),'.','color',L20,'MarkerSize',15);
plot(DE_OutcomeDiffs(~Loss_ix,1),DE_RatingDiffs(~Loss_ix,1),'.','color',G20,'MarkerSize',15);
plot(DE_OutcomeDiffs(Loss_ix,2),DE_RatingDiffs(Loss_ix,2),'.','color',L50,'MarkerSize',15);
plot(DE_OutcomeDiffs(~Loss_ix,2),DE_RatingDiffs(~Loss_ix,2),'.','color',G50,'MarkerSize',15);
plot(DE_OutcomeDiffs(Loss_ix,3),DE_RatingDiffs(Loss_ix,3),'.','color',L80,'MarkerSize',15);
plot(DE_OutcomeDiffs(~Loss_ix,3),DE_RatingDiffs(~Loss_ix,3),'.','color',G80,'MarkerSize',15);
ylabel('D-E Rating');
xlabel('D-E Experienced Outcome');

set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);

% prepare data for a linear mixed effects model
% Fit a mixed effects model
RatingDiffs  = reshape(DE_RatingDiffs,[],1);
OutcomeDiffs = reshape(DE_OutcomeDiffs,[],1);
Subject      = [ [1:60]' ; [1:60]' ; [1:60]' ];
Protocol     = [ Loss_ix ; Loss_ix ; Loss_ix];
Prob         = [ ones(size(Loss_ix))*20 ; ones(size(Loss_ix))*50 ; ones(size(Loss_ix))*80 ];

SurbeyTbl = table(Subject, OutcomeDiffs, Prob,Protocol,RatingDiffs);
SurveyLME = fitlme(SurbeyTbl,'RatingDiffs ~ OutcomeDiffs + OutcomeDiffs:Protocol + OutcomeDiffs:Prob + (1|Subject)');




end % of function