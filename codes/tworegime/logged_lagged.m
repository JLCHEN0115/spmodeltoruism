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
clear

% Read data
optsData = detectImportOptions('tlaged_logged_ct_spdata_long.xlsx');
preview('tlaged_logged_ct_spdata_long.xlsx',optsData);
optsData.SelectedVariableNames = [7:62];
A = readmatrix('tlaged_logged_ct_spdata_long.xlsx',optsData);
% Read weighting matrices
% W3nn = readmatrix('3nnmatrix.xlsx','Range','B2:JX284');
% W4nn = readmatrix('4nnmatrix.xlsx','Range','B2:JX284');
% W5nn = readmatrix('5nnmatrix.xlsx','Range','B2:JX284');
% W6nn = readmatrix('6nnmatrix.xlsx','Range','B2:JX284');
% Wcont = readmatrix('contmatrix.xlsx','Range','B2:JX284');
% Wd100nb = readmatrix('d100nbmatrix.xlsx','Range','B2:JX284');
 Wd150nb = readmatrix('d150nbmatrix.xlsx','Range','B2:JX284');
% Wd200nb = readmatrix('d200nbmatrix.xlsx','Range','B2:JX284');

% Row-normalize W
Wd150nb=normr(Wd150nb);


% Model parameters and y and x variables
% number of units
N=283;
% time periods
T=8;
nobs=N*T;
% how many explanatory variables, exclusing the lagged y (if any), 
% including lagged x (if any)
K=20;

y=A(:,1); % column number in the data matrix that corresponds to the dependent variable
dum=A(:,53); % column number in the data matrix that corresponds to the regime indicator
xh=A(:,[11,12,13,16,17,20,21,22,25,26]);% column numbers in the data matrix that correspond to the independent variables, no constant because it will be eliminated
% Create wx variables
for t=1:T
    t1=1+(t-1)*N;t2=t*N;
    Wd150nbx(t1:t2,:)= Wd150nb*xh(t1:t2,:);
end
x=[dum xh Wd150nbx];
info.model=3;
results = sarregime_panel(y,x,dum,Wd150nb,T,info);
vnames=char('total arrivals','dum','GDPpc','salary','population','third industry','investment','taxi','hotel','5A spots','green land','average expense','lagGDPpc','lagslry','lagpop','lagteri','laginvest','lagtaxi','laghotel','lagspot5A','laggrnld','lagavexp');
prt_spreg(results,vnames,1);


