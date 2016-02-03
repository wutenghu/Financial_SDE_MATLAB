tic;
clc;
clear;
%%
GOLD = fetch(yahoo,{'GOLD'},{'Close'},'01/01/15','01/01/16','d');
ABX_TO = fetch(yahoo,{'ABX.TO'},{'Close'},'01/01/15','01/01/16','d');

prices = [GOLD(:,2) ABX_TO(:,2)]; %construct the financial time series

close(yahoo)
%%
% load Data_GlobalIdx2
% % prices  = [Dataset.TSX Dataset.CAC Dataset.DAX ...
% %    Dataset.NIK Dataset.FTSE Dataset.SP];
% 
% prices = [Dataset.TSX Dataset.CAC];
returns =  tick2ret(prices);

%% Setup the parameters
nVariables  = size(returns,2);
expReturn   = mean(returns); % calculate the mean return
sigma       = std(returns); % calculate the standard deviations
correlation = corrcoef(returns); % calculate the correlation coefficients
t           = 0;
X           = 100*ones(nVariables,1);

%% Construct the SDE system
F = @(t,X) diag(expReturn) * X;
G = @(t,X) diag(X) * diag(sigma);

SDE = sde(F, G, 'Correlation', ...
    correlation, 'StartState', X);

%% Simulate the SDE system
nPeriods = 249*2;      % # of simulated observations
dt       =   1;      % time increment = 1 day
rng(142857,'twister')

[S,T] = simulate(SDE, nPeriods, 'DeltaTime', dt);

%% Plot the figure
plot(T, S), xlabel('Trading Day'), ylabel('Price')
title('First Path of Multi-Dimensional Market Model')
legend({'Canada' 'France' 'Germany' 'Japan' 'UK' 'US'},...
    'Location', 'Best')
%%
toc
