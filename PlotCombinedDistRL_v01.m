function PlotCombinedDistRL_v01(E_BestQuantile,D_BestQuantile,GeneralEQbias,AllData,...
                                G_E_Q ,G_D_Q ,G_EQbias ,L_E_Q ,L_D_Q ,L_EQbias)
                            
 % define figure and axes
figh = figure;
set(figh,'Units','centimeters','Position',[5 5 20 15]);
set(gcf,'renderer','Painters');
B_QUANTax = axes('Position',[.1  .6  .25  .3]);
B_CORRax  = axes('Position',[.5  .6  .25  .3]);

W_QUANTax = axes('Position',[.1  .1  .25  .3]);
W_CORRax  = axes('Position',[.5  .1  .25  .3]);

quantylim = [.3 .65];

% define color scheme
EQGcol = [0.415686274509804,0.239215686274510,0.603921568627451];
EQLcol = [0.792156862745098,0.698039215686275,0.839215686274510];

DGcol = [0.121568627450980,0.470588235294118,0.705882352941177];
DLcol = [0.650980392156863,0.807843137254902,0.890196078431373];
EGcol = [0.890196078431373,0.101960784313725,0.109803921568627];
ELcol = [0.984313725490196,0.603921568627451,0.600000000000000];

%---
% prepare the between-subject data
%---
ParticipantIDs = unique(AllData.vpNum);

for p = 1:numel(ParticipantIDs)
    
    thisPdata = AllData(AllData.vpNum == ParticipantIDs(p),:);
    
    if contains(thisPdata.version(1),'loss')
        pContext(p,1) = -1;
    else
        pContext(p,1) = 1;
    end
end

E_BestQuantile = mean(E_BestQuantile,2);
D_BestQuantile = mean(D_BestQuantile,2);
GeneralEQbias  = mean(GeneralEQbias,2);

[GE_quant_mean,GE_quant_CI] = GetMeanCI(E_BestQuantile(pContext==1),'sem');
[LE_quant_mean,LE_quant_CI] = GetMeanCI(E_BestQuantile(pContext==-1),'sem');

[GD_quant_mean,GD_quant_CI] = GetMeanCI(D_BestQuantile(pContext==1),'sem');
[LD_quant_mean,LD_quant_CI] = GetMeanCI(D_BestQuantile(pContext==-1),'sem');

%---
% PLOT BETWEEN-SUBJECT RESULTS
%---
axes(B_QUANTax);
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
ylim(quantylim);
set(gca,'LineWidth',1,'FontSize',12);

% set up for a glme
quantTbl = table;
quantTbl.quantiles = [E_BestQuantile ; D_BestQuantile];
quantTbl.Type      = ([ones(size(E_BestQuantile)) ; ones(size(E_BestQuantile))*-1]);
quantTbl.context   = categorical([pContext ; pContext]);
quantTbl.subject   = [ [1:60]' ; [1:60]'];
quantMdl = fitglme(quantTbl,'quantiles ~ Type*context + (1|subject)');


axes(B_CORRax);
hold on
plot(E_BestQuantile(pContext==1) - D_BestQuantile(pContext==1), GeneralEQbias(pContext==1),'.','MarkerSize',20,'color',EQGcol)
plot(E_BestQuantile(pContext==-1) - D_BestQuantile(pContext==-1), GeneralEQbias(pContext==-1),'.','MarkerSize',20,'color',EQLcol)
% xlim([-1 1]);
xlabel('Optimism (E-D Quantile)');
ylabel('Overall p(Choose Exp)');
set(gca,'LineWidth',1,'FontSize',12);

% formally assess the data with a GLM
tbl = table;
tbl.Quantile = E_BestQuantile - D_BestQuantile;
tbl.Bias     = GeneralEQbias;
tbl.Context  = categorical(pContext);

mdl = fitglm(tbl,'Bias ~ Quantile');
plot(xlim,mdl.Coefficients.Estimate(2)*xlim+mdl.Coefficients.Estimate(1),'k','LineWidth',1);

%---
% PREPARE THE WITHIN-SUBJECT DATA
%---

G_E_BestQuantile = mean(G_E_Q,2);
G_D_BestQuantile = mean(G_D_Q,2);
G_GeneralEQbias  = mean(G_EQbias,2);

L_E_BestQuantile = mean(L_E_Q,2);
L_D_BestQuantile = mean(L_D_Q,2);
L_GeneralEQbias  = mean(L_EQbias,2);

[GE_quant_mean,GE_quant_CI] = GetMeanCI(G_E_BestQuantile,'sem');
[LE_quant_mean,LE_quant_CI] = GetMeanCI(L_E_BestQuantile,'sem');

[GD_quant_mean,GD_quant_CI] = GetMeanCI(G_D_BestQuantile,'sem');
[LD_quant_mean,LD_quant_CI] = GetMeanCI(L_D_BestQuantile,'sem');

axes(W_QUANTax);
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
ylim([min(quantylim) max(quantylim)-.1]);
set(gca,'LineWidth',1,'FontSize',12);

% set up for a glme
quantTbl = table;
quantTbl.quantiles = [G_E_BestQuantile ; G_D_BestQuantile ; L_E_BestQuantile ; L_D_BestQuantile];
quantTbl.Type      = categorical([ones(size(G_E_BestQuantile)) ; ones(size(G_E_BestQuantile))*-1 ; ones(size(G_E_BestQuantile)) ; ones(size(G_E_BestQuantile))*-1]);
quantTbl.context   = categorical([ones(size(G_E_BestQuantile)) ; ones(size(G_E_BestQuantile)) ; zeros(size(G_E_BestQuantile)) ; zeros(size(G_E_BestQuantile))]);
quantTbl.subject   = [ [1:numel(G_E_BestQuantile)]' ; [1:numel(G_E_BestQuantile)]' ; [1:numel(G_E_BestQuantile)]' ; [1:numel(G_E_BestQuantile)]'];
quantMdl = fitglme(quantTbl,'quantiles ~ Type*context + (1|subject)');

axes(W_CORRax);
hold on
plot(G_E_BestQuantile - G_D_BestQuantile, G_GeneralEQbias,'.','MarkerSize',20,'color',EQGcol)
plot(L_E_BestQuantile - L_D_BestQuantile, L_GeneralEQbias,'.','MarkerSize',20,'color',EQLcol)
% xlim([-1 1]);
xlabel('Optimism (E-D Quantile)');
ylabel('Overall p(Choose Exp)');
set(gca,'LineWidth',1,'FontSize',12);

% formally assess the data with a GLM
tbl = table;
tbl.Quantile = [G_E_BestQuantile ; G_D_BestQuantile] - [L_E_BestQuantile;L_D_BestQuantile];
tbl.Bias     = [G_GeneralEQbias ; L_GeneralEQbias];
tbl.Context  = categorical([ones(size(G_GeneralEQbias)) ; ones(size(G_GeneralEQbias))*-1]);

mdl = fitglm(tbl,'Bias ~ Quantile:Context');
plot(xlim,mdl.Coefficients.Estimate(2)*xlim+mdl.Coefficients.Estimate(1),'k','LineWidth',1);

                            
                            
                            
                            
end % of function