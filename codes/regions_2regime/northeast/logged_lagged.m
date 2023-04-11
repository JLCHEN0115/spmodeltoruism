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
optsData = detectImportOptions('northeast_tlaged_logged_ct_spdata_long.xlsx');
preview('northeast_tlaged_logged_ct_spdata_long.xlsx',optsData);
optsData.SelectedVariableNames = [7:45];
A = readmatrix('northeast_tlaged_logged_ct_spdata_long.xlsx',optsData);
% Read weighting matrices
Wd200nb = readmatrix('nematrixd200nb.xlsx','Range','B2:AG33');

% Row-normalize W
Wd200nb=normr(Wd200nb);

% Model parameters and y and x variables
% number of units
N=32;
% time periods
T=8;
nobs=N*T;
% how many explanatory variables, exclusing the lagged y (if any), 
% including lagged x (if any)
K=20;

y=A(:,1); % column number in the data matrix that corresponds to the dependent variable
dum=A(:,36); % column number in the data matrix that corresponds to the regime indicator
xh=A(:,[11,12,13,16,17,20,21,22,25,26]);% column numbers in the data matrix that correspond to the independent variables, no constant because it will be eliminated
% Create wx variables
for t=1:T
    t1=1+(t-1)*N;t2=t*N;
    Wd200nbx(t1:t2,:)= Wd200nb*xh(t1:t2,:);
end
x=[dum xh Wd200nbx];
info.model=3;
results = sarregime_panel(y,x,dum,Wd200nb,T,info);
vnames=char('total arrivals','dum','GDPpc','salary','population','third industry','investment','taxi','hotel','5A spots','green land','average expense','lagGDPpc','lagslry','lagpop','lagteri','laginvest','lagtaxi','laghotel','lagspot5A','laggrnld','lagavexp');
prt_spreg(results,vnames,1);


