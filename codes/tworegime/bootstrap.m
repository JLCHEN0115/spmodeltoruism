clear;
tic
% Read data
optsData = detectImportOptions('tlaged_ct_spdata_long.xlsx');
preview('tlaged_ct_spdata_long.xlsx',optsData);
optsData.SelectedVariableNames = [8:57];
A = readmatrix('tlaged_ct_spdata_long.xlsx',optsData);
% Read weighting matrices
W6nn = readmatrix('6nnmatrix.xlsx','Range','B2:JX284');
W = W6nn;
% number of units
N=283;
% time periods
T=8;
% Model parameters and y and x variables
nobs=N*T;
% how many explanatory variables, exclusing the lagged y (if any), 
% including lagged x (if any)
K=20;
% the time of bootstrap
nBootstrap = 1000;

% Initialize a matrix to store the stacked data
stackedData = zeros(N*T,size(A,2));

% Initialize a matrix to store the weights
weight = zeros(N,N);

bootCoefs = zeros(nBootstrap, 23); % Matrix to store bootstrapped coefficients


for i = 1:nBootstrap

    % Select cities randomly with replacement
    selectedCities = datasample(1:N, N, 'Replace', true);
    
    % Loop over the selected cities and stack the data by time and spatial units
    for j = 1:length(selectedCities)
    % Get the row indices corresponding to the selected city and all years
    rowIndex = (0:T-1)*N + selectedCities(j);
    
    % Extract the data for the selected city and stack it in the stackedData matrix
    stackedData((0:T-1)*N + j, :) = A(rowIndex,:);
    end

    % Extract the weight information for the selected city and plug it in the new weight matrix
    for m = 1:length(selectedCities)
       for n = 1:length(selectedCities)
           weight(m,n) = W(selectedCities(m), selectedCities(n));
       end
    end
    % row-normalization the new weighting matrix
    row_sums = sum(weight, 2);
    nonzero_rows = row_sums ~= 0;
    weight(nonzero_rows,:) = weight(nonzero_rows,:) ./ row_sums(nonzero_rows,:);

    % Perform estimation
    y=stackedData(:,1); % column number in the data matrix that corresponds to the dependent variable
    dum=stackedData(:,40); % column number in the data matrix that corresponds to the regime indicator
    xh=stackedData(:,[11,12,13,16,17,20,21,22,25,26]);% column numbers in the data matrix that correspond to the independent variables, no constant because it will be eliminated

    % Create wx variables
    for t=1:T
        t1=1+(t-1)*N;t2=t*N;
        weightx(t1:t2,:)= weight*xh(t1:t2,:);
    end
    % log transformation
    y=log(1+y); 
    xh=log(1 + xh);
    weightx=log(1 + weightx);
    x=[dum xh weightx];
    info.model=3;
    results = sarregime_panel(y,x,dum,weight,T,info);
    coefficients = [results.beta ; results.rho];
    
    % Store the estimated coefficients in the bootstrapped coefficients matrix
    bootCoefs(i,:) = coefficients;
end

% calculate the variance-covariance matrix of the bootstraped coefficients
bootCoefsCov = cov(bootCoefs);
% Extract the diagonal elements (variance)
bootCoefsVar = diag(bootCoefsCov)
% Take the sqaure root to obtain the standard errors
bootCoefsSE = sqrt(bootCoefsVar)
toc