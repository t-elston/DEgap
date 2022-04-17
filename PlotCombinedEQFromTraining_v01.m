function PlotCombinedEQFromTraining_v01(P_data,AllData,wPdata)

% define color scheme and plotting parameters
EQGcol = [0.415686274509804,0.239215686274510,0.603921568627451];
EQLcol = [0.792156862745098,0.698039215686275,0.839215686274510];
LW =4;
ax_LW = 1;
ax_FntSz = 12;
MkrSz = 20;

% define figure and axes
figh = figure;
set(figh,'Units','centimeters','Position',[5 5 20 15]);
set(gcf,'renderer','Painters');
%define axes
axW=.2;
axH=.3;

B_y = .65;
W_y = .2;
B_Dax    = axes('Position',[.1   B_y  axW  axH]);
B_Eax    = axes('Position',[.4   B_y  axW  axH]);
B_DxEax  = axes('Position',[.7   B_y  axW  axH]);

W_Dax    = axes('Position',[.1   W_y  axW  axH]);
W_Eax    = axes('Position',[.4   W_y  axW  axH]);
W_DxEax  = axes('Position',[.7   W_y  axW  axH]);



%---
% prepare the between-subject data for plotting
%---
B_Data = P_data.Choice;
VarNames =  B_Data.Properties.VariableNames;
Loss_ix = contains(P_data.Protocol,'loss');
NumPs = numel(Loss_ix);

% rectify the loss data 
B_Data = table2array(B_Data);
% Data(Loss_ix,:) = 1 -  Data(Loss_ix,:);
B_Data(Loss_ix,1:18) = 1 -  B_Data(Loss_ix,1:18);
B_Data(:,19:21) = abs(.5 - B_Data(:,19:21));

B_Data = array2table(B_Data);
B_Data.Properties.VariableNames = VarNames;


% fit and compared mixed effects linear models to see if there are effects of training
% and protocol on the magnitude of the DE gap
% the idea is to get a sense of where the distortion first arises
tbl = table;
tbl.Protocol = categorical(Loss_ix);
tbl.DTrainPerf = nanmean(table2array(B_Data(:,1:3)),2);
tbl.ETrainPerf = nanmean(table2array(B_Data(:,4:6)),2);
tbl.MeanTrain  = nanmean(table2array(B_Data(:,1:6)),2);
tbl.TrainDiff  = nanmean( table2array(B_Data(:,1:3)) - table2array(B_Data(:,4:6)),2);
tbl.EQperf = nanmean(table2array(B_Data(:,19:21)),2);

[DxE_x_EQ_mdl] = fitlme(tbl,'EQperf ~ 1 + MeanTrain + Protocol + MeanTrain*Protocol'); 
mdl_intercept = DxE_x_EQ_mdl.Coefficients{1,2};
TrainingBeta  = DxE_x_EQ_mdl.Coefficients{3,2};
MeanTrainBIC = DxE_x_EQ_mdl.ModelCriterion{1,2};

[DTrain_x_EQ_mdl] = fitlme(tbl,'EQperf ~ 1 + DTrainPerf + Protocol + DTrainPerf*Protocol'); 
D_mdl_intercept = DTrain_x_EQ_mdl.Coefficients{1,2};
D_TrainingBeta  = DTrain_x_EQ_mdl.Coefficients{3,2};
D_TrainBIC = DTrain_x_EQ_mdl.ModelCriterion{1,2};

[ETrain_x_EQ_mdl] = fitlme(tbl,'EQperf ~ 1 + ETrainPerf + Protocol + ETrainPerf*Protocol'); 
E_mdl_intercept = ETrain_x_EQ_mdl.Coefficients{1,2};
E_TrainingBeta  = ETrain_x_EQ_mdl.Coefficients{3,2};
E_TrainBIC = ETrain_x_EQ_mdl.ModelCriterion{1,2};

%----------------------------------
% begin plotting between-subject data

axes(B_Dax);
hold on
plot(tbl.DTrainPerf(~Loss_ix), tbl.EQperf(~Loss_ix),'.','MarkerSize',MkrSz,'color',EQGcol);
plot(tbl.DTrainPerf(Loss_ix), tbl.EQperf(Loss_ix),'.','MarkerSize',MkrSz,'color',EQLcol);
xlim([.4 1]);
ylim([0 .5]);
yticks([0 .25 .5]);
xticks([.4 .7 1]);
% plot the fit from the model
plot([xlim],[(xlim*D_TrainingBeta)+D_mdl_intercept],'k','LineWidth',2);
% legend({'Gain' 'Loss'},'FontSize',12,'Location','northwest');

ylabel('Mean EQ Bias');
xlabel('Mean Training Perf.');
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
title(['D Training; BIC = ' num2str(D_TrainBIC,3)]);

axes(B_Eax);
hold on
plot(tbl.ETrainPerf(~Loss_ix), tbl.EQperf(~Loss_ix),'.','MarkerSize',MkrSz,'color',EQGcol);
plot(tbl.ETrainPerf(Loss_ix), tbl.EQperf(Loss_ix),'.','MarkerSize',MkrSz,'color',EQLcol);
xlim([.4 1]);
ylim([0 .5]);
% plot the fit from the model
plot([xlim],[(xlim*E_TrainingBeta)+E_mdl_intercept],'k','LineWidth',2);
yticks([0 .25 .5]);
xticks([.4 .7 1]);
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
title(['E Training; BIC = ' num2str(E_TrainBIC,3)]);

axes(B_DxEax);
hold on
plot(tbl.MeanTrain(~Loss_ix), tbl.EQperf(~Loss_ix),'.','MarkerSize',MkrSz,'color',EQGcol);
plot(tbl.MeanTrain(Loss_ix), tbl.EQperf(Loss_ix),'.','MarkerSize',MkrSz,'color',EQLcol);
xlim([.4 1]);
ylim([.0 .5]);
yticks([0 .25 .5]);
xticks([.4 .7 1]);
% plot the fit from the model
plot([xlim],[(xlim*TrainingBeta)+mdl_intercept],'k','LineWidth',2)
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
title(['DxE Training; BIC = ' num2str(MeanTrainBIC,3)]);



%-------------------------------------------------
% prepare within-subject data for plotting
%-------------------------------------------------
W_Data = wPdata.Choice;
VarNames =  W_Data.Properties.VariableNames;
W_Loss_ix = W_Data.context==2;

% rectify the loss data 
W_Data = table2array(W_Data);

W_Data(:,22:24) = abs(.5 - W_Data(:,22:24));

W_Data = array2table(W_Data);
W_Data.Properties.VariableNames = VarNames;


% fit and compared mixed effects linear models to see if there are effects of training
% and protocol on the magnitude of the DE gap
% the idea is to get a sense of where the distortion first arises
tbl = table;
tbl.Protocol = categorical(W_Loss_ix);
tbl.DTrainPerf = nanmean(table2array(W_Data(:,4:6)),2);
tbl.ETrainPerf = nanmean(table2array(W_Data(:,7:9)),2);
tbl.MeanTrain  = nanmean(table2array(W_Data(:,4:9)),2);
tbl.EQperf = nanmean(table2array(W_Data(:,22:24)),2);

[DxE_x_EQ_mdl] = fitlme(tbl,'EQperf ~ 1 + MeanTrain + Protocol + MeanTrain*Protocol'); 
mdl_intercept = DxE_x_EQ_mdl.Coefficients{1,2};
TrainingBeta  = DxE_x_EQ_mdl.Coefficients{3,2};
MeanTrainBIC = DxE_x_EQ_mdl.ModelCriterion{1,2};

[DTrain_x_EQ_mdl] = fitlme(tbl,'EQperf ~ 1 + DTrainPerf + Protocol + DTrainPerf*Protocol'); 
D_mdl_intercept = DTrain_x_EQ_mdl.Coefficients{1,2};
D_TrainingBeta  = DTrain_x_EQ_mdl.Coefficients{3,2};
D_TrainBIC = DTrain_x_EQ_mdl.ModelCriterion{1,2};

[ETrain_x_EQ_mdl] = fitlme(tbl,'EQperf ~ 1 + ETrainPerf + Protocol + ETrainPerf*Protocol'); 
E_mdl_intercept = ETrain_x_EQ_mdl.Coefficients{1,2};
E_TrainingBeta  = ETrain_x_EQ_mdl.Coefficients{3,2};
E_TrainBIC = ETrain_x_EQ_mdl.ModelCriterion{1,2};

% PLOT THE WITHIN-SUBJECT DATA
axes(W_Dax);
hold on
plot(tbl.DTrainPerf(~W_Loss_ix), tbl.EQperf(~W_Loss_ix),'.','MarkerSize',MkrSz,'color',EQGcol);
plot(tbl.DTrainPerf(W_Loss_ix), tbl.EQperf(W_Loss_ix),'.','MarkerSize',MkrSz,'color',EQLcol);
xlim([.4 1]);
ylim([0 .5]);
yticks([0 .25 .5]);
xticks([.4 .7 1]);
% plot the fit from the model
plot([xlim],[(xlim*D_TrainingBeta)+D_mdl_intercept],'k','LineWidth',2);
% legend({'Gain' 'Loss'},'FontSize',14,'Location','northwest');

ylabel('Mean EQ Bias');
xlabel('Mean Training Perf.');
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
title(['D Training; BIC = ' num2str(D_TrainBIC,3)]);

axes(W_Eax);
hold on
plot(tbl.ETrainPerf(~W_Loss_ix), tbl.EQperf(~W_Loss_ix),'.','MarkerSize',MkrSz,'color',EQGcol);
plot(tbl.ETrainPerf(W_Loss_ix), tbl.EQperf(W_Loss_ix),'.','MarkerSize',MkrSz,'color',EQLcol);
xlim([.4 1]);
ylim([0 .5]);
% plot the fit from the model
plot([xlim],[(xlim*E_TrainingBeta)+E_mdl_intercept],'k','LineWidth',2);
yticks([0 .25 .5]);
xticks([.4 .7 1]);
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
title(['E Training; BIC = ' num2str(E_TrainBIC,3)]);

axes(W_DxEax);
hold on
plot(tbl.MeanTrain(~W_Loss_ix), tbl.EQperf(~W_Loss_ix),'.','MarkerSize',MkrSz,'color',EQGcol);
plot(tbl.MeanTrain(W_Loss_ix), tbl.EQperf(W_Loss_ix),'.','MarkerSize',MkrSz,'color',EQLcol);
xlim([.4 1]);
ylim([.0 .5]);
yticks([0 .25 .5]);
xticks([.4 .7 1]);
% plot the fit from the model
plot([xlim],[(xlim*TrainingBeta)+mdl_intercept],'k','LineWidth',2)
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
title(['DxE Training; BIC = ' num2str(MeanTrainBIC,3)]);




end % of function