function MakeCombinedRTPlot_v01(P_data,wPdata,type)

%---
% prepare the between-subject data
%---
B_Data = P_data.(type);
VarNames =  B_Data.Properties.VariableNames;
Loss_ix = contains(P_data.Protocol,'loss');
NumPs = numel(Loss_ix);

% EXCLUDE PARTICIPANTS
% Exclude_ix = logical(P_data.ExcludeParticipant);
% NumPs = sum(~Exclude_ix);
% Data(Exclude_ix,:)=[];
% Loss_ix(Exclude_ix)=[];
% NumPs = sum(~Exclude_ix);

% Rectify the choice data for formal analysis
if contains(type,'Choice')
    B_Data = table2array(B_Data);
    B_Data(Loss_ix,1:18) = 1 -  B_Data(Loss_ix,1:18);  
    B_Data = array2table(B_Data);
    B_Data.Properties.VariableNames = VarNames;   
end


B_Loss_tbl(1,:)  = nanmean(table2array(B_Data(Loss_ix,:)));
B_Loss_tbl(2,:) = nanstd(table2array(B_Data(Loss_ix,:))) / sqrt(sum(Loss_ix));

B_Gain_tbl(1,:) = nanmean(table2array(B_Data(~Loss_ix,:)));
B_Gain_tbl(2,:) = nanstd(table2array(B_Data(~Loss_ix,:))) / sqrt(sum(~Loss_ix));


%---
% prepare the within-subject data
%---
W_Data = wPdata.(type);
% Data(wPdata.CouldExclude,:)=[];

W_LossIX = W_Data.context ==2;
W_Loss_tbl(1,:)  = nanmean(table2array(W_Data(W_LossIX,4:end)));
W_Loss_tbl(2,:) = nanstd(table2array(W_Data(W_LossIX,4:end))) / sqrt(sum(W_LossIX));

W_Gain_tbl(1,:) = nanmean(table2array(W_Data(~W_LossIX,4:end)));
W_Gain_tbl(2,:) = nanstd(table2array(W_Data(~W_LossIX,4:end))) / sqrt(sum(~W_LossIX));


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
    ylims = [0 1];
    ylbl = 'p(Optimal)';
    ChanceLineY = .5;
    eqylbl = 'p(Choose Experience)';
    
else
    ylbl = 'RT (ms)';
    ChanceLineY = NaN;
    ylims = [400 900];
    eqylbl = ylbl;
    
end


% make figure and axes

g_x = [1.5 3.5 5.5];
l_x = [2 4 6];
% PLOT DATA  - plot gain and loss on the same graphs
figh = figure;
set(figh,'Units','centimeters','Position',[5 5 20 15]);
set(gcf,'renderer','Painters');
%define axes
axW=.15;
axH=.3;

B_y = .65;
W_y = .15;
B_TRAINax = axes('Position',[.1   B_y  axW  axH]);
B_PUREax  = axes('Position',[.33   B_y  axW  axH]);
B_UNEQax  = axes('Position',[.55   B_y  axW  axH]);
B_EQax    = axes('Position',[.78   B_y  axW  axH]);

W_TRAINax = axes('Position',[.1   W_y  axW  axH]);
W_PUREax  = axes('Position',[.33   W_y  axW  axH]);
W_UNEQax  = axes('Position',[.55   W_y  axW  axH]);
W_EQax    = axes('Position',[.78   W_y  axW  axH]);


axes(B_TRAINax);
hold on
errorbar(g_x,B_Gain_tbl(1,1:3),B_Gain_tbl(2,1:3),'^','MarkerSize',MkrSz,'MarkerFaceColor',DGcol,'LineWidth',LW,'MarkerEdgeColor',DGcol,'color',DGcol);
errorbar(g_x,B_Gain_tbl(1,4:6),B_Gain_tbl(2,4:6),'^','MarkerSize',MkrSz,'MarkerFaceColor',EGcol,'LineWidth',LW,'MarkerEdgeColor',EGcol,'color',EGcol);
errorbar(l_x,B_Loss_tbl(1,1:3),B_Loss_tbl(2,1:3),'s','MarkerSize',SMkrSz,'MarkerFaceColor',DLcol,'LineWidth',LW,'MarkerEdgeColor',DLcol,'color',DLcol);
errorbar(l_x,B_Loss_tbl(1,4:6),B_Loss_tbl(2,4:6),'s','MarkerSize',SMkrSz,'MarkerFaceColor',ELcol,'LineWidth',LW,'MarkerEdgeColor',ELcol,'color',ELcol);
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

axes(B_PUREax);
hold on
errorbar(g_x,B_Gain_tbl(1,7:9),B_Gain_tbl(2,7:9),'^','MarkerSize',MkrSz,'MarkerFaceColor',DGcol,'LineWidth',LW,'MarkerEdgeColor',DGcol,'color',DGcol);
errorbar(g_x,B_Gain_tbl(1,10:12),B_Gain_tbl(2,10:12),'^','MarkerSize',MkrSz,'MarkerFaceColor',EGcol,'LineWidth',LW,'MarkerEdgeColor',EGcol,'color',EGcol);
errorbar(l_x,B_Loss_tbl(1,7:9),B_Loss_tbl(2,7:9),'s','MarkerSize',SMkrSz,'MarkerFaceColor',DLcol,'LineWidth',LW,'MarkerEdgeColor',DLcol,'color',DLcol);
errorbar(l_x,B_Loss_tbl(1,10:12),B_Loss_tbl(2,10:12),'s','MarkerSize',SMkrSz,'MarkerFaceColor',ELcol,'LineWidth',LW,'MarkerEdgeColor',ELcol,'color',ELcol);
ylim(ylims);
xlim(xlims);
xtickangle(45);
xlabel('Choice Condition')
plot([min(xlim) max(xlim)], [ChanceLineY ChanceLineY],'k','LineWidth',ax_LW,'LineStyle','-');
% B_PUREax.YAxis.Visible = 'off'; % remove y-axis
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
xticks([2 4 6]);
xticklabels(xlbls);
title('Pure');

axes(B_UNEQax);
hold on
errorbar(g_x,B_Gain_tbl(1,13:15),B_Gain_tbl(2,13:15),'^','MarkerSize',MkrSz,'MarkerFaceColor',DGcol,'LineWidth',LW,'MarkerEdgeColor',DGcol,'color',DGcol);
errorbar(g_x,B_Gain_tbl(1,16:18),B_Gain_tbl(2,16:18),'^','MarkerSize',MkrSz,'MarkerFaceColor',EGcol,'LineWidth',LW,'MarkerEdgeColor',EGcol,'color',EGcol);
errorbar(l_x,B_Loss_tbl(1,13:15),B_Loss_tbl(2,13:15),'s','MarkerSize',SMkrSz,'MarkerFaceColor',DLcol,'LineWidth',LW,'MarkerEdgeColor',DLcol,'color',DLcol);
errorbar(l_x,B_Loss_tbl(1,16:18),B_Loss_tbl(2,16:18),'s','MarkerSize',SMkrSz,'MarkerFaceColor',ELcol,'LineWidth',LW,'MarkerEdgeColor',ELcol,'color',ELcol);
ylim(ylims);
xlim(xlims);
xtickangle(45);
xlabel('Choice Condition')
plot([min(xlim) max(xlim)], [ChanceLineY ChanceLineY],'k','LineWidth',ax_LW,'LineStyle','-');
% B_UNEQax.YAxis.Visible = 'off'; % remove y-axis
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
xticks([2 4 6]);
xticklabels(xlbls);

% legend({'Gain - D is better','Gain - E is better','Loss - D is better','Loss - E is better'},'FontSize',12);
% legend boxoff
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
title('\neqDvsE');



% plot within-subject results
axes(W_TRAINax);
hold on
errorbar(g_x,W_Gain_tbl(1,1:3),W_Gain_tbl(2,1:3),'^','MarkerSize',MkrSz,'MarkerFaceColor',DGcol,'LineWidth',LW,'MarkerEdgeColor',DGcol,'color',DGcol);
errorbar(g_x,W_Gain_tbl(1,4:6),W_Gain_tbl(2,4:6),'^','MarkerSize',MkrSz,'MarkerFaceColor',EGcol,'LineWidth',LW,'MarkerEdgeColor',EGcol,'color',EGcol);
errorbar(l_x,W_Loss_tbl(1,1:3),W_Loss_tbl(2,1:3),'s','MarkerSize',SMkrSz,'MarkerFaceColor',DLcol,'LineWidth',LW,'MarkerEdgeColor',DLcol,'color',DLcol);
errorbar(l_x,W_Loss_tbl(1,4:6),W_Loss_tbl(2,4:6),'s','MarkerSize',SMkrSz,'MarkerFaceColor',ELcol,'LineWidth',LW,'MarkerEdgeColor',ELcol,'color',ELcol);
ylim(ylims);
xlim(xlims);
xtickangle(45);
xlabel('Choice Condition')
plot([min(xlim) max(xlim)], [ChanceLineY ChanceLineY],'k','LineWidth',ax_LW,'LineStyle','-');
% legend({'Gain - D','Gain - E','Loss - D','Loss - E'},'FontSize',12);
% legend boxoff
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
ylabel(ylbl);
xticks([2 4 6]);
xticklabels(xlbls);
% title('Training');

axes(W_PUREax);
hold on
errorbar(g_x,W_Gain_tbl(1,7:9),W_Gain_tbl(2,7:9),'^','MarkerSize',MkrSz,'MarkerFaceColor',DGcol,'LineWidth',LW,'MarkerEdgeColor',DGcol,'color',DGcol);
errorbar(g_x,W_Gain_tbl(1,10:12),W_Gain_tbl(2,10:12),'^','MarkerSize',MkrSz,'MarkerFaceColor',EGcol,'LineWidth',LW,'MarkerEdgeColor',EGcol,'color',EGcol);
errorbar(l_x,W_Loss_tbl(1,7:9),W_Loss_tbl(2,7:9),'s','MarkerSize',SMkrSz,'MarkerFaceColor',DLcol,'LineWidth',LW,'MarkerEdgeColor',DLcol,'color',DLcol);
errorbar(l_x,W_Loss_tbl(1,10:12),W_Loss_tbl(2,10:12),'s','MarkerSize',SMkrSz,'MarkerFaceColor',ELcol,'LineWidth',LW,'MarkerEdgeColor',ELcol,'color',ELcol);
ylim(ylims);
xlim(xlims);
xtickangle(45);
xlabel('Choice Condition')
plot([min(xlim) max(xlim)], [ChanceLineY ChanceLineY],'k','LineWidth',ax_LW,'LineStyle','-');
% W_PUREax.YAxis.Visible = 'off'; % remove y-axis
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
xticks([2 4 6]);
xticklabels(xlbls);
% title('Pure');

axes(W_UNEQax);
hold on
errorbar(g_x,W_Gain_tbl(1,13:15),W_Gain_tbl(2,13:15),'^','MarkerSize',MkrSz,'MarkerFaceColor',DGcol,'LineWidth',LW,'MarkerEdgeColor',DGcol,'color',DGcol);
errorbar(g_x,W_Gain_tbl(1,16:18),W_Gain_tbl(2,16:18),'^','MarkerSize',MkrSz,'MarkerFaceColor',EGcol,'LineWidth',LW,'MarkerEdgeColor',EGcol,'color',EGcol);
errorbar(l_x,W_Loss_tbl(1,13:15),W_Loss_tbl(2,13:15),'s','MarkerSize',SMkrSz,'MarkerFaceColor',DLcol,'LineWidth',LW,'MarkerEdgeColor',DLcol,'color',DLcol);
errorbar(l_x,W_Loss_tbl(1,16:18),W_Loss_tbl(2,16:18),'s','MarkerSize',SMkrSz,'MarkerFaceColor',ELcol,'LineWidth',LW,'MarkerEdgeColor',ELcol,'color',ELcol);
ylim(ylims);
xlim(xlims);
xtickangle(45);
xlabel('Choice Condition')
plot([min(xlim) max(xlim)], [ChanceLineY ChanceLineY],'k','LineWidth',ax_LW,'LineStyle','-');
% W_UNEQax.YAxis.Visible = 'off'; % remove y-axis
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
xticks([2 4 6]);
xticklabels(xlbls);

% legend({'Gain - D is better','Gain - E is better','Loss - D is better','Loss - E is better'},'FontSize',12);
% legend boxoff
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
% title('\neqDvsE');




axes(B_EQax);
hold on
errorbar(g_x,B_Gain_tbl(1,19:21),B_Gain_tbl(2,19:21),'^','MarkerSize',MkrSz,'MarkerFaceColor',EQGcol,'LineWidth',LW,'MarkerEdgeColor',EQGcol,'color',EQGcol);
errorbar(l_x,B_Loss_tbl(1,19:21),B_Loss_tbl(2,19:21),'s','MarkerSize',SMkrSz,'MarkerFaceColor',EQLcol,'LineWidth',LW,'MarkerEdgeColor',EQLcol,'color',EQLcol);
ylim(ylims);
xlim(xlims);
xtickangle(45);
plot([min(xlim) max(xlim)], [ChanceLineY ChanceLineY],'k','LineWidth',1,'LineStyle','-');
% legend({'Gain','Loss'},'FontSize',12,'Location','northwest');
xticks([2 4 6]);
xticklabels({'20v20' '50v50' '80v80'});
% ylabel(eqylbl);
xlabel('Equiprobable Condition');
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
title('=DvE');

axes(W_EQax)
hold on
errorbar(g_x,W_Gain_tbl(1,19:21),W_Gain_tbl(2,19:21),'^','MarkerSize',MkrSz,'MarkerFaceColor',EQGcol,'LineWidth',LW,'MarkerEdgeColor',EQGcol,'color',EQGcol);
errorbar(l_x,W_Loss_tbl(1,19:21),W_Loss_tbl(2,19:21),'s','MarkerSize',SMkrSz,'MarkerFaceColor',EQLcol,'LineWidth',LW,'MarkerEdgeColor',EQLcol,'color',EQLcol);
ylim(ylims);
xlim(xlims);
xtickangle(45);
plot([min(xlim) max(xlim)], [ChanceLineY ChanceLineY],'k','LineWidth',1,'LineStyle','-');
xticks([2 4 6]);
xticklabels({'20v20' '50v50' '80v80'});
% ylabel(eqylbl);
xlabel('Equiprobable Condition');
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
% title('Within Subject (Exp 2)');


end % of function