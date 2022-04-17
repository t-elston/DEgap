function PlotAndAnalyzeDistributionalRL_v01(BestAcc,E_BestQuantile,D_BestQuantile,GeneralEQbias,AllData)

ParticipantIDs = unique(AllData.vpNum);

for p = 1:numel(ParticipantIDs)
    
    thisPdata = AllData(AllData.vpNum == ParticipantIDs(p),:);
    
    if contains(thisPdata.version(1),'loss')
        pContext(p,1) = -1;
    else
        pContext(p,1) = 1;
    end
end

BestAcc        = mean(BestAcc,2);
E_BestQuantile = mean(E_BestQuantile,2);
D_BestQuantile = mean(D_BestQuantile,2);
GeneralEQbias  = mean(GeneralEQbias,2);


EQGcol = [0.415686274509804,0.239215686274510,0.603921568627451];
EQLcol = [0.792156862745098,0.698039215686275,0.839215686274510];

DGcol = [0.121568627450980,0.470588235294118,0.705882352941177];
DLcol = [0.650980392156863,0.807843137254902,0.890196078431373];
EGcol = [0.890196078431373,0.101960784313725,0.109803921568627];
ELcol = [0.984313725490196,0.603921568627451,0.600000000000000];

[G_acc_mean,G_acc_CI] = GetMeanCI(BestAcc(pContext==1),'sem');
[L_acc_mean,L_acc_CI] = GetMeanCI(BestAcc(pContext==-1),'sem');



[GE_quant_mean,GE_quant_CI] = GetMeanCI(E_BestQuantile(pContext==1),'sem');
[LE_quant_mean,LE_quant_CI] = GetMeanCI(E_BestQuantile(pContext==-1),'sem');

[GD_quant_mean,GD_quant_CI] = GetMeanCI(D_BestQuantile(pContext==1),'sem');
[LD_quant_mean,LD_quant_CI] = GetMeanCI(D_BestQuantile(pContext==-1),'sem');

   
fig = figure;
set(fig, 'Position', [100 150 800 300]);
set(gcf,'renderer','Painters');
ACCax   = axes('Position',[.08  .2  .15  .7]);
QUANTax = axes('Position',[.31  .2  .25  .7]);
CORRax  = axes('Position',[.65  .2  .25  .7]);


% axes(ACCax);
% hold on
% bar(1,G_acc_mean,'FaceColor',EQGcol);
% bar(2,L_acc_mean,'FaceColor',EQLcol);
% errorbar([1],[G_acc_mean],[G_acc_CI],'k','Marker','.','CapSize',0,'MarkerSize',17,'LineWidth',3);
% errorbar([2],[L_acc_mean],[L_acc_CI],'k','Marker','.','CapSize',0,'MarkerSize',17,'LineWidth',3);
% 
% plot(xlim,[.5 .5],'k','LineWidth',1,'LineStyle','--');
% xlim([.4 2.6]);
% xticks([1 2]);
% xticklabels({'Gain','Loss'});
% 
% xlabel('Context');
% ylabel('RL Model Acc (%)');
% ylim([.2 .65]);
% set(gca,'LineWidth',1,'FontSize',12);


axes(QUANTax);
hold on
bar(1,GE_quant_mean,'FaceColor',EGcol);
bar(2,GD_quant_mean,'FaceColor',DGcol);
bar(3,LE_quant_mean,'FaceColor',ELcol);
bar(4,LD_quant_mean,'FaceColor',DLcol);
errorbar([1],[GE_quant_mean],[GE_quant_CI],'k','Marker','.','CapSize',0,'MarkerSize',17,'LineWidth',3);
errorbar([2],[GD_quant_mean],[GD_quant_CI],'k','Marker','.','CapSize',0,'MarkerSize',17,'LineWidth',3);
errorbar([3],[LE_quant_mean],[LE_quant_CI],'k','Marker','.','CapSize',0,'MarkerSize',17,'LineWidth',3);
errorbar([4],[LD_quant_mean],[LD_quant_CI],'k','Marker','.','CapSize',0,'MarkerSize',17,'LineWidth',3);
% legend({'E_{gain}','D_{gain}','E_{loss}','D_{loss}'},'NumColumns',2)
xlabel('Stimulus x Condition');
xlim([.4 4.6]);
xticks([1 2 3 4]);
xticklabels({'E_{gain}','D_{gain}','E_{loss}','D_{loss}'});
ylabel('Best Model Quantile');
ylim([.2 .65]);
set(gca,'LineWidth',1,'FontSize',12);

% set up for a glme
quantTbl = table;
quantTbl.quantiles = [E_BestQuantile ; D_BestQuantile];
quantTbl.Type      = ([ones(size(E_BestQuantile)) ; ones(size(E_BestQuantile))*-1]);
quantTbl.context   = categorical([pContext ; pContext]);
quantTbl.subject   = [ [1:60]' ; [1:60]'];
quantMdl = fitglme(quantTbl,'quantiles ~ Type*context + (1|subject)');


axes(CORRax);
hold on
plot(E_BestQuantile(pContext==1) - D_BestQuantile(pContext==1), GeneralEQbias(pContext==1),'.','MarkerSize',20,'color',EQGcol)
plot(E_BestQuantile(pContext==-1) - D_BestQuantile(pContext==-1), GeneralEQbias(pContext==-1),'.','MarkerSize',20,'color',EQLcol)
% xlim([-1 1]);
xlabel('Optimism (E-D Quantile)');
ylabel('General EQ bias');
set(gca,'LineWidth',1,'FontSize',12);

% formally assess the data with a GLM
tbl = table;
tbl.Quantile = E_BestQuantile - D_BestQuantile;
tbl.Bias     = GeneralEQbias;
tbl.Context  = categorical(pContext);

mdl = fitglm(tbl,'Bias ~ Quantile:Context');
plot(xlim,mdl.Coefficients.Estimate(2)*xlim+mdl.Coefficients.Estimate(1),'k','LineWidth',1);
