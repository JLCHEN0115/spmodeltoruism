% Demo of model with spatial and time period fixed effects and two regimes

% written by: J.Paul Elhorst 2/2007
% University of Groningen
% Department of Economics
% 9700AV Groningen
% the Netherlands
% j.p.elhorst@rug.nl
%
% REFERENCES: 
% Elhorst J.P., Fr�ret S. (2009) Evidence of political yardstick competition in France 
% using a two-regime spatial Durbin model with fixed effects. 
% Journal of Regional Science. Forthcoming.

% Read data
A=xlsread('ct_spdata_long.xlsx');

W4nn = readmatrix('4nnmatrix.xlsx','Range','B2:JX284');
% Row-normalize W
W4nn=normr(W4nn);

% Model parameters and y and x variables
% number of units
N=283;
% time periods
T=9;
nobs=N*T;
% how many explanatory variables, exclusing the lagged y (if any), 
% including lagged x (if any)
K=14;

y=A(:,1); % column number in the data matrix that corresponds to the dependent variable
dum=A(:,32); % column number in the data matrix that corresponds to the regime indicator
xh=A(:,[11, 12, 13, 17, 20, 21, 22]);% column numbers in the data matrix that correspond to the independent variables, no constant because it will be eliminated
% Create wx variables
for t=1:T
    t1=1+(t-1)*N;t2=t*N;
    w4nnx(t1:t2,:)= W4nn*xh(t1:t2,:);
end
x=[dum xh w4nnx];
info.model=3;
results = sarregime_panel(y,x,dum,W4nn,T,info);
vnames=char('total arrivals','dum','GDPp','salary','population','investment','taxi','hotel','spot5A','lagGDPp','lagslry','lagpopulation','laginvestment','lagtaxi','laghotel','lagspot5A');
prt_spreg(results,vnames,1);