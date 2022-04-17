function [figh] = PlotData_v03(P_data,type)
figh=[];
%--------------------------------------------------------
% v03 begins analysis!
%--------------------------------------------------------

% EXTRACT AND SUMMARIZE DATA

Data = P_data.(type);
VarNames =  Data.Properties.VariableNames;
LossIX = contains(P_data.Protocol,'loss');
NumPs = numel(LossIX);

% EXCLUDE PARTICIPANTS
% Exclude_ix = logical(P_data.ExcludeParticipant);
% NumPs = sum(~Exclude_ix);
% Data(Exclude_ix,:)=[];
% Loss_ix(Exclude_ix)=[];
% NumPs = sum(~Exclude_ix);

% Rectify the choice data for formal analysis
if contains(type,'Choice')
    Data = table2array(Data);
    Data(LossIX,1:18) = 1 -  Data(LossIX,1:18);  
    Data = array2table(Data);
    Data.Properties.VariableNames = VarNames;   
end


Loss_tbl(1,:)  = nanmean(table2array(Data(LossIX,:)));
Loss_tbl(2,:) = nanstd(table2array(Data(LossIX,:))) / sqrt(sum(LossIX));

Gain_tbl(1,:) = nanmean(table2array(Data(~LossIX,:)));
Gain_tbl(2,:) = nanstd(table2array(Data(~LossIX,:))) / sqrt(sum(~LossIX));

%--------------------------------------------------------
% PARAMETERS FOR PLOTTING

% define color scheme
DGcol = [0.121568627450980,0.470588235294118,0.705882352941177];
DLcol = [0.650980392156863,0.807843137254902,0.890196078431373];
EGcol = [0.890196078431373,0.101960784313725,0.109803921568627];
ELcol = [0.984313725490196,0.603921568627451,0.600000000000000];

EQGcol = [0.415686274509804,0.239215686274510,0.603921568627451];
EQLcol = [0.792156862745098,0.698039215686275,0.839215686274510];

LW =2;
ax_LW = 1;
ax_FntSz = 12;
MkrSz = 8;
SMkrSz = 10;
xlbls = {'20v50' '50v80' '20v80'};
xlims = [1 6.5];

if contains(type,'Choice')
    ylims = [.2 1];
    ylbl = 'p(Optimal)';
    ChanceLineY = .5;
    eqylbl = 'p(Choose Exp)';
    
else
    ylbl = 'RT (ms)';
    ChanceLineY = NaN;
    ylims = [400 900];
    eqylbl = ylbl;

    
end

[L_tstat,L_df,L_pval,L_cohenD] = TTESTcolumns_v01(table2array(Data(LossIX,7:9)),.5);
[G_tstat,G_df,G_pval,G_cohenD] = TTESTcolumns_v01(table2array(Data(~LossIX,7:9)),.5);


g_x = [1.5 3.5 5.5];
l_x = [2 4 6];
% PLOT DATA  - plot gain and loss on the same graphs
figh = figure;
set(figh,'Units','centimeters','Position',[10 10 20 7]);
set(gcf,'renderer','Painters');
%define axes
axW=.15;
axH=.6;
TRAINax = axes('Position',[.1   .28  axW  axH]);
PUREax  = axes('Position',[.3   .28  axW  axH]);
UNEQax  = axes('Position',[.5   .28  axW  axH]);
EQax    = axes('Position',[.75  .28  axW  axH]);

axes(TRAINax);
hold on
errorbar(g_x,Gain_tbl(1,1:3),Gain_tbl(2,1:3),'^','MarkerSize',MkrSz,'MarkerFaceColor',DGcol,'LineWidth',LW,'MarkerEdgeColor',DGcol,'color',DGcol);
errorbar(g_x,Gain_tbl(1,4:6),Gain_tbl(2,4:6),'^','MarkerSize',MkrSz,'MarkerFaceColor',EGcol,'LineWidth',LW,'MarkerEdgeColor',EGcol,'color',EGcol);
errorbar(l_x,Loss_tbl(1,1:3),Loss_tbl(2,1:3),'s','MarkerSize',SMkrSz,'MarkerFaceColor',DLcol,'LineWidth',LW,'MarkerEdgeColor',DLcol,'color',DLcol);
errorbar(l_x,Loss_tbl(1,4:6),Loss_tbl(2,4:6),'s','MarkerSize',SMkrSz,'MarkerFaceColor',ELcol,'LineWidth',LW,'MarkerEdgeColor',ELcol,'color',ELcol);
ylim(ylims);
xlim(xlims);
xlabel('Choice Condition')
plot([min(xlim) max(xlim)], [ChanceLineY ChanceLineY],'k','LineWidth',ax_LW,'LineStyle','-');
% legend({'Gain - D','Gain - E','Loss - D','Loss - E'},'FontSize',12);
% legend boxoff
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
ylabel(ylbl);
xticks([2 4 6]);
xtickangle(45);
xticklabels(xlbls);
title('Training');

axes(PUREax);
hold on
errorbar(g_x,Gain_tbl(1,7:9),Gain_tbl(2,7:9),'^','MarkerSize',MkrSz,'MarkerFaceColor',DGcol,'LineWidth',LW,'MarkerEdgeColor',DGcol,'color',DGcol);
errorbar(g_x,Gain_tbl(1,10:12),Gain_tbl(2,10:12),'^','MarkerSize',MkrSz,'MarkerFaceColor',EGcol,'LineWidth',LW,'MarkerEdgeColor',EGcol,'color',EGcol);
errorbar(l_x,Loss_tbl(1,7:9),Loss_tbl(2,7:9),'s','MarkerSize',SMkrSz,'MarkerFaceColor',DLcol,'LineWidth',LW,'MarkerEdgeColor',DLcol,'color',DLcol);
errorbar(l_x,Loss_tbl(1,10:12),Loss_tbl(2,10:12),'s','MarkerSize',SMkrSz,'MarkerFaceColor',ELcol,'LineWidth',LW,'MarkerEdgeColor',ELcol,'color',ELcol);
ylim(ylims);
xlim(xlims);
plot([min(xlim) max(xlim)], [ChanceLineY ChanceLineY],'k','LineWidth',ax_LW,'LineStyle','-');
PUREax.YAxis.Visible = 'off'; % remove y-axis
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
xticks([2 4 6]);
xtickangle(45);
xticklabels(xlbls);
title('Pure');

axes(UNEQax);
hold on
errorbar(g_x,Gain_tbl(1,13:15),Gain_tbl(2,13:15),'^','MarkerSize',MkrSz,'MarkerFaceColor',DGcol,'LineWidth',LW,'MarkerEdgeColor',DGcol,'color',DGcol);
errorbar(g_x,Gain_tbl(1,16:18),Gain_tbl(2,16:18),'^','MarkerSize',MkrSz,'MarkerFaceColor',EGcol,'LineWidth',LW,'MarkerEdgeColor',EGcol,'color',EGcol);
errorbar(l_x,Loss_tbl(1,13:15),Loss_tbl(2,13:15),'s','MarkerSize',SMkrSz,'MarkerFaceColor',DLcol,'LineWidth',LW,'MarkerEdgeColor',DLcol,'color',DLcol);
errorbar(l_x,Loss_tbl(1,16:18),Loss_tbl(2,16:18),'s','MarkerSize',SMkrSz,'MarkerFaceColor',ELcol,'LineWidth',LW,'MarkerEdgeColor',ELcol,'color',ELcol);
ylim(ylims);
xlim(xlims);
plot([min(xlim) max(xlim)], [ChanceLineY ChanceLineY],'k','LineWidth',ax_LW,'LineStyle','-');
UNEQax.YAxis.Visible = 'off'; % remove y-axis
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
xticks([2 4 6]);
xtickangle(45);
xticklabels(xlbls);

% legend({'Gain - D is better','Gain - E is better','Loss - D is better','Loss - E is better'},'FontSize',12);
% legend boxoff
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
title('\neqDvsE');

axes(EQax);
hold on
errorbar(g_x,Gain_tbl(1,19:21),Gain_tbl(2,19:21),'^','MarkerSize',MkrSz,'MarkerFaceColor',EQGcol,'LineWidth',LW,'MarkerEdgeColor',EQGcol,'color',EQGcol);
errorbar(l_x,Loss_tbl(1,19:21),Loss_tbl(2,19:21),'s','MarkerSize',SMkrSz,'MarkerFaceColor',EQLcol,'LineWidth',LW,'MarkerEdgeColor',EQLcol,'color',EQLcol);
ylim(ylims);
xlim(xlims);
plot([min(xlim) max(xlim)], [ChanceLineY ChanceLineY],'k','LineWidth',1,'LineStyle','-');
% legend({'Gain','Loss'},'FontSize',12);
% legend boxoff
xticks([2 4 6]);
xticklabels({'20v20' '50v50' '80v80'});
xtickangle(45);
ylabel(eqylbl);
xlabel('Equiprobable Condition');
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
title('=DvsE');
%--------------------------------------------------------
%                   START OF ANALYSIS
%--------------------------------------------------------
% MIXED REPEATED MEASURES ANOVA
% TRAINING
TrainRMData = [];
TrainRMData(:,:,1) = table2array(Data(:,1:3)); % description stimuli
TrainRMData(:,:,2) = table2array(Data(:,4:6)); % experience stimuli
TRAIN_ranovatbl = simple_mixed_anova(TrainRMData, LossIX, {'Cond', 'StimType'}, {'Context'});


% PURE TRIALS
PureRMData = [];
PureRMData(:,:,1) = table2array(Data(:,7:9)); % description 
PureRMData(:,:,2) = table2array(Data(:,10:12)); % experience
PURE_ranovatbl = simple_mixed_anova(PureRMData, LossIX, {'Cond', 'StimType'}, {'Context'});
 
 
% UNEQUAL DvE
UE_DvE_RMData = [];
UE_DvE_RMData(:,:,1) = table2array(Data(:,13:15)); % description is better
UE_DvE_RMData(:,:,2) = table2array(Data(:,16:18)); % experience is better
UE_DvE_ranovatbl = simple_mixed_anova(UE_DvE_RMData, LossIX, {'Cond', 'StimType'}, {'Context'});
 
% EQUAL DvE
EQ_DvE_RMData = [];
EQ_DvE_RMData(:,:,1) = table2array(Data(:,19:21)); % p(Choose Experience)
EQ_DvE_ranovatbl = simple_mixed_anova(EQ_DvE_RMData, LossIX, {'Cond'}, {'Context'});

if contains(type,'Choice')
% ASSESS THE =DvE WITH A REPEATED MEASURES MODEL WITH TRAINING PERFORMANCE AS A COVARIATE 
TrainPerf        = nanmean(table2array(Data(:,1:6)),2);
rm_tbl          = table;
rm_tbl.EQ20     = abs(EQ_DvE_RMData(:,1) - .5);
rm_tbl.EQ50     = abs(EQ_DvE_RMData(:,2) - .5);
rm_tbl.EQ80     = abs(EQ_DvE_RMData(:,3) - .5);
rm_tbl.TrainPerf= TrainPerf;
rm_tbl.Context = categorical(LossIX);

EQ_DvE_mdl_withTrainingCovariate = fitrm(rm_tbl,'EQ20-EQ80 ~ Context+TrainPerf','WithinDesign',[20 50 80]);
EQ_DvE_withCovariate_ranovatbl = ranova(EQ_DvE_mdl_withTrainingCovariate);
end


% rmANOVAs for each protocol
EQ_gainData = table2array(Data(~LossIX,19:21));
EQ_lossData = table2array(Data(LossIX,19:21));

% format data for 1 way rmanova
rmEQGainData = reshape(EQ_gainData,[],1);
rmEQLossData = reshape(EQ_lossData,[],1);
s = 1:30; % subject factor
c(1:30,1) = 1; c(1:30,2) = 2; c(1:30,3) = 3;

SubjectF = [s';s';s'];
CondF = reshape(c,[],1);

[~,GainsRMTbl,GainsEQstats] = anovan(rmEQGainData,{CondF,SubjectF},...
 'random',2,'varnames', {'Cond','Subjects'},'display','off');

[EQgainsMultC] = multcompare(GainsEQstats,'display','off');

[~,LossRMTbl,LossEQstats] = anovan(rmEQLossData,{CondF,SubjectF},...
 'random',2,'varnames', {'Cond','Subjects'},'display','off');

[EQlossMultC] = multcompare(LossEQstats,'display','off');




end % of function