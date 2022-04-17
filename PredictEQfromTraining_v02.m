function [xx] = PredictEQfromTraining_v02(P_data,AllData)
xx=[];

Data = P_data.Choice;
VarNames =  Data.Properties.VariableNames;
Loss_ix = contains(P_data.Protocol,'loss');
NumPs = numel(Loss_ix);

% rectify the loss data 
Data = table2array(Data);
% Data(Loss_ix,:) = 1 -  Data(Loss_ix,:);
Data(Loss_ix,1:18) = 1 -  Data(Loss_ix,1:18);
Data(:,19:21) = abs(.5 - Data(:,19:21));

Data = array2table(Data);
Data.Properties.VariableNames = VarNames;

%--------------------------------------------------------
% PARAMETERS FOR PLOTTING
Dcolor  = [39 68 83 ]/255;
Ecolor  = [173 101 122 ]/255;
UEcolor = [75 112 93 ]/255;
EQcolor = [185 44 40]/255;
EQGcol = [0.415686274509804,0.239215686274510,0.603921568627451];
EQLcol = [0.792156862745098,0.698039215686275,0.839215686274510];

% colors for the training x bias plots
L20 = [166 206 227]/255;
G20 = [31  120 180]/255;
L50 = [178 223 138]/255;
G50 = [51  160 44] /255;
L80 = [251 154 153]/255;
G80 = [227 26  28] /255;

LW =4;
ax_LW = 1;
ax_FntSz = 14;
MkrSz = 30;
%--------------------------------------------------------


% fit and compared mixed effects linear models to see if there are effects of training
% and protocol on the magnitude of the DE gap
% the idea is to get a sense of where the distortion first arises
tbl = table;
tbl.Protocol = categorical(Loss_ix);
tbl.DTrainPerf = nanmean(table2array(Data(:,1:3)),2);
tbl.ETrainPerf = nanmean(table2array(Data(:,4:6)),2);
tbl.MeanTrain  = nanmean(table2array(Data(:,1:6)),2);
tbl.TrainDiff  = nanmean( table2array(Data(:,1:3)) - table2array(Data(:,4:6)),2);
tbl.EQperf = nanmean(table2array(Data(:,19:21)),2);

[DxE_x_EQ_mdl] = fitlme(tbl,'EQperf ~ 1 + MeanTrain + Protocol + MeanTrain:Protocol'); 
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


% repeat the procedure above but do it for each probability level,
% separately
% pull out training performance when each given probability level was
% present
[MeanTrainx20,EQx20Bias]  = GetTrainPerfByProb_v01(AllData,.2);
[MeanTrainx50,EQx50Bias] = GetTrainPerfByProb_v01(AllData,.5);
[MeanTrainx80,EQx80Bias] = GetTrainPerfByProb_v01(AllData,.8);
% prepare data for a linear mixed effects model
lme_tbl = table;
lme_tbl.TrainPerf = [MeanTrainx20 ; MeanTrainx50 ; MeanTrainx80];
lme_tbl.EQbias    = [EQx20Bias ; EQx50Bias ; EQx80Bias];
lme_tbl.Prob      = [ones(size(MeanTrainx20))*20 ; ones(size(MeanTrainx20))*50; ones(size(MeanTrainx20))*80];
lme_tbl.Protocol  = [categorical(Loss_ix) ; categorical(Loss_ix) ; categorical(Loss_ix)];
lme_tbl.Subject   = [[1:60]' ; [1:60]' ; [1:60]' ];

TrainXEQbias_lme = fitlme(lme_tbl,'EQbias ~ TrainPerf + Prob + Protocol + TrainPerf:Prob + TrainPerf:Protocol  + (1|Subject)');
ProbXBias_intercept = TrainXEQbias_lme.Coefficients{1,2};
ProbXBiasBeta  = TrainXEQbias_lme.Coefficients{2,2};
%----------------------------------
% begin plotting


fig = figure;
set(fig, 'Position', [100 150 700 300]);
set(gcf,'renderer','Painters');


subplot(1,3,1);
hold on
plot(tbl.DTrainPerf(~Loss_ix), tbl.EQperf(~Loss_ix),'.','MarkerSize',MkrSz,'color',EQGcol);
plot(tbl.DTrainPerf(Loss_ix), tbl.EQperf(Loss_ix),'.','MarkerSize',MkrSz,'color',EQLcol);
xlim([.4 1]);
ylim([0 .5]);
yticks([0 .25 .5]);
xticks([.4 .7 1]);
% plot the fit from the model
plot([xlim],[(xlim*D_TrainingBeta)+D_mdl_intercept],'k','LineWidth',2);
legend({'Gain' 'Loss'},'FontSize',14,'Location','northwest');

ylabel('Mean Equiprobable Bias');
xlabel('Mean Training Performance');
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);
title(['D Training; BIC = ' num2str(D_TrainBIC,3)]);

subplot(1,3,2);
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

subplot(1,3,3);
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

fig2 = figure;
set(gcf,'renderer','Painters');
set(fig2, 'Position', [100 150 400 400]);
hold on
plot(MeanTrainx20(Loss_ix),EQx20Bias(Loss_ix),'.','MarkerSize',25,'color',L20);
plot(MeanTrainx20(~Loss_ix),EQx20Bias(~Loss_ix),'.','MarkerSize',25,'color',G20);
plot(MeanTrainx50(Loss_ix),EQx50Bias(Loss_ix),'.','MarkerSize',25,'color',L50);
plot(MeanTrainx50(~Loss_ix),EQx50Bias(~Loss_ix),'.','MarkerSize',25,'color',G50);
plot(MeanTrainx80(Loss_ix),EQx80Bias(Loss_ix),'.','MarkerSize',25,'color',L80);
plot(MeanTrainx80(~Loss_ix),EQx80Bias(~Loss_ix),'.','MarkerSize',25,'color',G80);
xlim([.4 1]);
ylim([.0 .5]);
yticks([0 .25 .5]);
xticks([.4 .7 1]);
% plot the training perf fit from the model
plot([xlim],[(xlim*ProbXBiasBeta)+ProbXBias_intercept],'k','LineWidth',2)
ylabel('Mean EQ Bias');
xlabel('Mean Train Perf.');
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW);





end % of function