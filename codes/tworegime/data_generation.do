*change the end-of-line delimiter to ';'
# delimit ;
*clear the environment;
clear all;

************************************;
*1)set up the panel;
************************************;
*300 units in 20 periods;
set obs 6000;
*generate the unit identifier and time variables;
gen period=.;
gen unit=.;
*generate indep. var. income;
gen income=.;
gen price=.;
gen mu=.;
*gen gamma=.;
gen zeta_1=.;
gen zeta_2=.;
gen epsilon=.;
gen d =. ;

*write time period and the individuals;
local j = 1;
local k = 1;
forvalues i = 1(1)6000{;
	replace period = `j' if _n == `i' /*Replace period=j if obs=i */;
	replace unit = `k' if _n==`i';
	local j = `j'+1;
	/*If we reach period 20, then move to the next unit*/;
	if `j'==21{;
	local j=1;
	local k=`k'+1;
	};
};

*************************************;
*2)draw some random numbers;
*************************************;

*draw i.i.d. unit fixed effects from N(20,7);
set seed 1056;
replace mu = rnormal(100,20) if period == 1;
sum mu;

*draw i.i.d. time fixed effects from N(10,3);
*set seed 2023;
*replace gamma = rnormal(10,3) if unit == 1;
*sum gamma;

*draw i.i.d. error terms from N(0,1);
set seed 1999;
replace epsilon = rnormal();

*************************************;
*3)create the other values;
*************************************;

* allow mu to be time invariant and unit variant (unobserved endowment);
forvalues i=1(1)300{;
	forvalues j=2(1)20{;
		replace mu = mu[1+(`i'-1)*20] if unit==`i' & period==`j';
	};
};

* allow gamma to be unit invariant and time variant (unobserved common shocks);
*forvalues j=1(1)6{;
*	forvalues i=2(1)30{;
*		replace gamma = gamma[`j'] if unit==`i' & period==`j';
*	};
*};

* generate income and allow for dependence between on unit-specific effects;
replace zeta_1 = runiform(-15,15);
replace income = 0.7 * mu + (1 - (0.4)^2)^(0.5)*zeta_1;

* generate price and allow for dependence between on unit-specific effects;
replace zeta_2 = runiform(-15,15);
replace price = 0.4 * mu + (1 - (0.6)^2)^(0.4)*zeta_2;

*change the data to wide form;
reshape wide income price epsilon zeta_1 zeta_2, i(unit) j(period);

************************************;
*4)create the contiguity weighting matrix W;
*create the indicator matrix D_t;
* Assume D_t = D for simplicity;
* assume our units are in an unconnected line;
************************************;
matrix W = J(300, 300, .);
forvalues i = 1/300 {;
	forvalues j = 1/300 {;
		if `i' == `j'{;
		matrix W[`i', `j'] = 0;
		};
		else{;
			matrix W[`i', `j'] = exp(-0.002*(`i' + `j'));
		};
	};
};

*display our matrix;
matrix list W;

matrix D = J(300, 300, .);
replace d = uniform() <= 0.5;
local j = 1;
forvalues i = 1/300{;
	if `j' == `i'{;
	matrix D[`i', `j'] = d[`j'];
	};
	else{;
			matrix D[`i', `j'] = 0;
		};
	local j = `j' + 1;
};
matrix list D;

************************************;
*5)Data Generating Process;
*Two-regime parial Durbin Model (SDM) with unit fixed effects in the reduced form;
*y_t = (I-delta_1*D*W-delta_2*[I-D]*W)^-1 (X_t*b+theta*W*X_t + mu + epsilon);
************************************;
local rho = 0.3;
matrix beta = (0.6 \ -0.2);
matrix theta = (0.3 \ -0.1);

*generate tourism arrivals for periods 1 to 20;
forvalues t = 1/20{;
	mkmat income`t' price`t', matrix(X`t');
	mkmat mu, matrix(Mu);
	mkmat epsilon`t', matrix(Epsilon`t');
	*mkmat gamma`t', matrix(Gamma`t');
	matrix Y`t' = inv(I(300) - `rho'*W)*(X`t'*beta + W*X`t'*theta + Mu + Epsilon`t');
	svmat double Y`t', name(arrival`t');
	rename arrival`t'1 arrival`t';
};

*************************;
*regression model;
*************************;

*back to long form data;
reshape long income price epsilon zeta_1 zeta_2 arrival, i(unit) j(period);


*sort data for matlab input;
sort period unit;

*save data;
save simulation_data, replace;
