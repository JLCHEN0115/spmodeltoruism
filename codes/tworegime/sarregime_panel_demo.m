% Demo of model with spatial and time period fixed effects and two regimes

% written by: J.Paul Elhorst 2/2007
% University of Groningen
% Department of Economics
% 9700AV Groningen
% the Netherlands
% j.p.elhorst@rug.nl
%
% REFERENCES: 
% Elhorst J.P., Fréret S. (2009) Evidence of political yardstick competition in France 
% using a two-regime spatial Durbin model with fixed effects. 
% Journal of Regional Science. Forthcoming.

% Read data
A=xlsread('simulation_data.xls');
W=xlsread('weights.xlsx');
% Row-normalize W
W=normr(W);
% Model parameters and y and x variables
N=300;
T=20;
nobs=N*T;
K=14;
y=A(:,10); % column number in the data matrix that corresponds to the dependent variable
dum=A(:,9); % column number in the data matrix that corresponds to the regime indicator
xh=A(:,[3,4]);% column numbers in the data matrix that correspond to the independent variables, no constant because it will be eliminated
% Create wx variables
for t=1:T
    t1=1+(t-1)*N;t2=t*N;
    wx(t1:t2,:)= W*xh(t1:t2,:);
end
x=[dum xh wx];
info.model=1;
results = sarregime_panel(y,x,dum,W,T,info);
fid = fopen('ols.out','wr');
prt_spreg(results,[],fid);