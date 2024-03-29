*change the end-of-line delimiter to ';'
# delimit ;
*clear the environment;
clear all;

************************************;
*1)set up the panel;
************************************;
*30 units in 6 periods;
set obs 180;
*generate the unit identifier and time variables;
gen period=.;
gen unit=.;
*generate indep. var. income;
gen income=.;
gen price=.;
gen price_com=.;
gen mu=.;
gen gamma=.;
gen zeta_1=.;
gen zeta_2=.;
gen zeta_3=.;
gen zeta_4=.;
gen attractions=.;
gen epsilon=.;
 
*write time period and the individuals;
local j = 1;
local k = 1;
forvalues i = 1(1)180{;
	replace period = `j' if _n == `i' /*Replace period=j if obs=i */;
	replace unit = `k' if _n==`i';
	local j = `j'+1;
	/*If we reach period 6, then move to the next unit*/;
	if `j'==7{;
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

* allow mu to be time invariant and unit variant (unobserved endowments);
forvalues i=1(1)30{;
	forvalues j=2(1)6{;
		replace mu = mu[1+(`i'-1)*6] if unit==`i' & period==`j';
	};
};

* allow gamma to be unit invariant and time variant (unobserved shocks);
forvalues j=1(1)6{;
	forvalues i=2(1)30{;
		replace gamma = gamma[`j'] if unit==`i' & period==`j';
	};
};

* generate income and allow for dependence between on unit-specific effects;
replace zeta_1 = runiform();
replace income = 0.7 * mu + (1 - (0.4)^2)^(0.5)*zeta_1;

* allow for dependence between attractions and unit-specific effects;
replace zeta_4 =  runiform( );
replace attractions = 0.34 * mu + (1 - (0.5)^2)^(0.5)*zeta_1;

* generate price and allow for dependence between on time-specific effects;
replace zeta_2 = runiform();
replace price = 0.4 * gamma + (1 - (0.6)^2)^(0.4)*zeta_2;

*generate price for complemenatary neighbors;
*and allow for dependence between on time-specific effects;

replace zeta_3 = runiform();
replace price_com = 0.2 * gamma + (1 - (0.3)^2)^(0.4)*zeta_3;

*change the data to wide form;
reshape wide income price price_com attractions gamma epsilon zeta_1 zeta_2 zeta_3 zeta_4, i(unit) j(period);

************************************;
*4)create the contiguity weighting matrix W;
************************************;
matrix W = J(30, 30, .);
forvalues i = 1/30 {;
	forvalues j = 1/30 {;
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
*Sparial Durbin Model (SDM);
*y_t = (I-rho*W)^-1 (X_t*beta+theta*W*X_t + mu + gamma + epsilon);
************************************;
local rho = 0.5;
matrix beta = (0.3 \ -0.4 \ -0.2 \ 0.5);
matrix theta = (0.2 \ -0.1 \ -0.1 \ 0.3);

*generate tourism arrivals for periods 1 to 6;
forvalues t = 1/6{;
	mkmat income`t' price`t' price_com`t' attractions`t', matrix(X`t');
	mkmat mu, matrix(Mu);
	mkmat epsilon`t', matrix(Epsilon`t');
	mkmat gamma`t', matrix(Gamma`t');
	matrix Y`t' = inv(I(30) - `rho'*W)*(X`t'*beta + W*X`t'*theta + Mu + Gamma`t' + Epsilon`t');
	svmat double Y`t', name(arrival`t');
	rename arrival`t'1 arrival`t';
};

*************************;
*regression model;
*************************;

*back to long form data;
reshape long income price price_com attractions gamma epsilon zeta_1 zeta_2 zeta_3 zeta_4 arrival, i(unit) j(period);
*tell stata about the panel;
xtset unit period;
xsmle arrival income price price_com attractions, wmat(W) model(sdm) fe type(both) nsim(500) nolog;


