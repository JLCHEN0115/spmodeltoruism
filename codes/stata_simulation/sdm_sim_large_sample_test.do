*change the end-of-line delimiter to ';'
# delimit ;
*clear the environment;
clear all;

************************************;
*1)set up the panel;
************************************;
*180 units in 180 periods;
set obs 32400;
*generate the unit identifier and time variables;
gen period=.;
gen unit=.;
*generate indep. var. income;
gen income=.;
gen price=.;
gen mu=.;
gen gamma=.;
gen zeta_1=.;
gen zeta_2=.;
gen epsilon=.;
 
*write time period and the individuals;
local j = 1;
local k = 1;
forvalues i = 1(1)32400{;
	replace period = `j' if _n == `i' /*Replace period=j if obs=i */;
	replace unit = `k' if _n==`i';
	local j = `j'+1;
	/*If we reach period 180, then move to the next unit*/;
	if `j'==181{;
	local j=1;
	local k=`k'+1;
	};
};

*************************************;
*2)draw some random numbers;
*************************************;

*draw i.i.d. unit fixed effects from N(20,7);
set seed 1056;
replace mu = rnormal(20,7) if period == 1;
sum mu;

*draw i.i.d. time fixed effects from N(10,3);
set seed 2023;
replace gamma = rnormal(10,3) if unit == 1;
sum gamma;

*draw i.i.d. error terms from N(0,1);
set seed 1999;
replace epsilon = rnormal();

*************************************;
*3)create the other values;
*************************************;

* allow mu(unit fixed) to be unit invariant and time variant;
forvalues i=1(1)180{;
	forvalues j=2(1)180{;
		replace mu = mu[1+(`i'-1)*180] if unit==`i' & period==`j';
	};
};

* allow gamma(time fixed) to be time invariant and unit variant;
forvalues j=1(1)180{;
	forvalues i=2(1)180{;
		replace gamma = gamma[`j'] if unit==`i' & period==`j';
	};
};

* generate income and allow for dependence between on unit-specific effects;
replace zeta_1 = runiform();
replace income = 0.7 * mu + (1 - (0.4)^2)^(0.5)*zeta_1;

* generate price and allow for dependence between on time-specific effects;
replace zeta_2 = runiform();
replace price = 0.4 * gamma + (1 - (0.6)^2)^(0.4)*zeta_2;

*change the data to wide form;
reshape wide income price gamma epsilon zeta_1 zeta_2, i(unit) j(period);

************************************;
*4)create the contiguity weighting matrix W;
************************************;
matrix W = J(180, 180, .);
forvalues i = 1/180 {;
	forvalues j = 1/180 {;
		if abs(`i' - `j') == 1{;
			matrix W[`i', `j'] = 1;
		};
		else{;
			matrix W[`i', `j'] = 0;
		};
	};
};

*display our matrix;
matrix list W;

************************************;
*5)Data Generating Process;
*Sparial Durbin Model (SDM) in reduced form;
*y_t = (I-rho*W)^-1 (X_t*b+theta*W*X_t + mu + gamma + epsilon);
************************************;
local rho = 0.5;
matrix beta = (0.3 \ -0.4);
matrix theta = (0.2 \ -0.1);

*generate tourism arrivals for periods 1 to 180;
forvalues t = 1/180{;
	mkmat income`t' price`t', matrix(X`t');
	mkmat mu, matrix(Mu);
	mkmat epsilon`t', matrix(Epsilon`t');
	mkmat gamma`t', matrix(Gamma`t');
	matrix Y`t' = inv(I(180) - `rho'*W)*(X`t'*beta + W*X`t'*theta + Mu + Gamma`t' + Epsilon`t');
	svmat double Y`t', name(arrival`t');
	rename arrival`t'1 arrival`t';
};

*************************;
*regression model;
*************************;

*back to long form data;
reshape long income price gamma epsilon zeta_1 zeta_2 arrival, i(unit) j(period);
*tell stata about the panel;
xtset unit period;
xsmle arrival income price, wmat(W) model(sdm) fe type(both) nsim(500) nolog;





