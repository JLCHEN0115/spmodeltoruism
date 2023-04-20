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
optsData = detectImportOptions('tlaged_ct_spdata_long.xlsx');
preview('tlaged_ct_spdata_long.xlsx',optsData);
optsData.SelectedVariableNames = [8:57];
A = readmatrix('tlaged_ct_spdata_long.xlsx',optsData);
% Read weighting matrices
% W4nn = readmatrix('4nnmatrix.xlsx','Range','B2:JX284');
% W5nn = readmatrix('5nnmatrix.xlsx','Range','B2:JX284');
 W6nn = readmatrix('6nnmatrix.xlsx','Range','B2:JX284');

W = W6nn;

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
dum=A(:,40); % column number in the data matrix that corresponds to the regime indicator
xh=A(:,[11,12,13,16,17,20,21,22,25,26]);% column numbers in the data matrix that correspond to the independent variables, no constant because it will be eliminated
% Create wx variables
for t=1:T
    t1=1+(t-1)*N;t2=t*N;
    Wx(t1:t2,:)= W*xh(t1:t2,:);
end
% log transformation
y=log(1+y); 
xh=log(1 + xh);
Wx=log(1 + Wx);
x=[dum xh Wx];
info.model=3;
results = sarregime_panel(y,x,dum,W,T,info);
vnames=char('total arrivals','dum','GDPpc','salary','population','third industry','investment','taxi','hotel','5A spots','green land','average expense','lagGDPpc','lagslry','lagpop','lagteri','laginvest','lagtaxi','laghotel','lagspot5A','laggrnld','lagavexp');
prt_spreg(results,vnames,1);

% results for the restricted model
% x2 = [xh W3nnx];
% results2 = sar_panel_FE(y,x2,W3nn,T,info);
% vnames2 = char('total arrivals','GDPpc','salary','population','third industry','investment','taxi','hotel','5A spots','green land','average expense','lagGDPpc','lagslry','lagpop','lagteri','laginvest','lagtaxi','laghotel','lagspot5A','laggrnld','lagavexp');
% prt_sp(results2,vnames2,1);
% convert the structure to a table
% T = struct2table(results,"AsArray",true);
% T = rows2vars(T);
% writetable(T, 'results.xlsx')
