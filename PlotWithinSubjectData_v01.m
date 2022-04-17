function PlotWithinSubjectData_v01(wPdata,type)



% loss condition were rectified at time of initial summarization
if contains(type,'Choice')
    ylims = [0 1];
    ylbl = 'p(Choose Best)';
    ChanceLineY = .5;
    
else
    ylbl = 'RT (ms)';
    ChanceLineY = NaN;
    ylims = [400 900];
    
end
   
Data = wPdata.(type);
% Data(wPdata.CouldExclude,:)=[];

LossIX = Data.context ==2;
Loss_tbl(1,:)  = nanmean(table2array(Data(LossIX,4:end)));
Loss_tbl(2,:) = nanstd(table2array(Data(LossIX,4:end))) / sqrt(sum(LossIX));

Gain_tbl(1,:) = nanmean(table2array(Data(~LossIX,4:end)));
Gain_tbl(2,:) = nanstd(table2array(Data(~LossIX,4:end))) / sqrt(sum(~LossIX));







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

[L_tstat,L_df,L_pval,L_cohenD] = TTESTcolumns_v01(table2array(Data(LossIX,4:6)),.5);
[G_tstat,G_df,G_pval,G_cohenD] = TTESTcolumns_v01(table2array(Data(~LossIX,4:6)),.5);

g_x = [1.5 3.5 5.5];
l_x = [2 4 6];
% PLOT DATA  - plot gain and loss on the same graphs
fig = figure;
set(fig,'Units','centimeters','Position',[10 10 20 7]);
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

%--------
% START OF ANALYSIS
%--------
nP=numel(Data.vpNum);
CondIX = [ ones(nP,1) , ones(nP,1)*2 , ones(nP,1)*3 , ones(nP,1) , ones(nP,1)*2 , ones(nP,1)*3];
TypeIX = [ ones(nP,1) , ones(nP,1) , ones(nP,1) , ones(nP,1)*-1 , ones(nP,1)*-1 , ones(nP,1)*-1];

% make some factors for the rmanova
% get the data
TrainData = reshape(table2array(Data(:,4:9)),[],1);
PureData  = reshape(table2array(Data(:,10:15)),[],1);
UEData    = reshape(table2array(Data(:,16:21)),[],1);

% make the factors
SubjectF  = repmat(Data.vpNum,numel(TrainData)/numel(Data.vpNum),1);
CondF     = reshape(CondIX,[],1);
ContextF  = repmat(Data.context,numel(TrainData)/numel(Data.vpNum),1);
StimTypeF = reshape(TypeIX,[],1);



% do the analysis for the training data
[~,TRAIN_ranovatbl] = anovan(TrainData,{CondF,SubjectF,ContextF,StimTypeF},...
 'random',2,'varnames', {'Cond','Subjects','Context','StimType'},'model','full','display','off');
% remove the random effects from the anova table
TRAIN_ranovatbl(contains(TRAIN_ranovatbl(:,1),'Subj'),:)=[];

[~,PURE_ranovatbl] = anovan(PureData,{CondF,SubjectF,ContextF,StimTypeF},...
 'random',2,'varnames', {'Cond','Subjects','Context','StimType'},'model','full','display','off');
% remove the random effects from the anova table
PURE_ranovatbl(contains(PURE_ranovatbl(:,1),'Subj'),:)=[];

[~,UE_ranovatbl] = anovan(UEData,{CondF,SubjectF,ContextF,StimTypeF},...
 'random',2,'varnames', {'Cond','Subjects','Context','BetterStim'},'model','full','display','off');
% remove the random effects from the anova table
UE_ranovatbl(contains(UE_ranovatbl(:,1),'Subj'),:)=[];


EQData    = reshape(table2array(Data(:,22:24)),[],1);
CondIX = reshape([ ones(nP,1) , ones(nP,1)*2 , ones(nP,1)*3],[],1);
ContextF  = repmat(Data.context,numel(EQData)/numel(Data.vpNum),1);
SubjectF  = repmat(Data.vpNum,numel(EQData)/numel(Data.vpNum),1);


[~,EQ_ranonvatbl] = anovan(EQData,{CondIX,ContextF,SubjectF},...
 'random',3,'varnames', {'Cond','Context','Subject'},'model','full','display','off');
EQ_ranonvatbl(contains(EQ_ranonvatbl(:,1),'Subj'),:)=[];



[~,GainsRMTbl,GainsEQstats] = anovan(EQData(ContextF==1),{CondIX(ContextF==1),SubjectF(ContextF==1)},...
 'random',2,'varnames', {'Cond','Subjects'},'display','off');

[EQgainsMultC] = multcompare(GainsEQstats,'display','off');

[~,LossRMTbl,LossEQstats] = anovan(EQData(ContextF==2),{CondIX(ContextF==2),SubjectF(ContextF==2)},...
 'random',2,'varnames', {'Cond','Subjects'},'display','off');

[EQlossMultC] = multcompare(LossEQstats,'display','off');





end % of function