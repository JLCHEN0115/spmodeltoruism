*change the end-of-line delimiter to ';'
# delimit ;
clear all;

* import data;
use "/Users/jialiangchen/Documents/spmodeltoruism/data/clean_data.dta";

* tell stata about our panel;
xtset ID year;

* Tools for spatial data analysis, uncomment to downloaod the user-written pkg;
* search sg162;

summarize Lat Lon;

* Calculate the greatest R2 distance between two points in our dataset;
* WARNING: some hard coding here;
display sqrt((18.25874  - 50.25127)^2 + ( 84.8959  - 131.1653)^2);

reshape wide total_vistor-railway_station, i(ID) j(year);
order ID City 城市 Lat Long;
* Create weight matrix called Weight, bandwidth > the longest distance;
* w_{i,j} = 1/(distance between point i and point j) for i != j;
*spatwmat, name(Weight_10) xcoord(Long) ycoord(Lat) band(0 60) standardize;
spatwmat, name(Weight_3) xcoord(Long) ycoord(Lat) band(0 3) standardize;
*spatwmat, name(Weight_bin) xcoord(Long) ycoord(Lat) band(0 3) bin;
* Moran I statistics;
*spatgsa total_vistor2015, weights(Weight_10) moran;
*spatgsa total_vistor2015, weights(Weight_3) moran;
*spatgsa total_vistor2015, weights(Weight_bin) moran;

********************************************************************************;
* pooled panel analysis
********************************************************************************;

*generate spatial lag for total arrival Wy;
forvalues t = 2011/2019{;
	mkmat total_vistor`t' , matrix(TOTAL_VISTOR`t');
	matrix LAG_TOTAL_VISTOR`t' = Weight_3*TOTAL_VISTOR`t';
	svmat double LAG_TOTAL_VISTOR`t', name(lag_total_vistor`t');
	rename lag_total_vistor`t'1 lag_total_vistor`t';
};

*generate spatial lag for population, used as IV for Wy;
forvalues t = 2011/2019{;
	mkmat pop_CEIC`t' , matrix(POP_CEIC`t');
	matrix LAG_POP_CEIC`t' = Weight_3*POP_CEIC`t';
	svmat double LAG_POP_CEIC`t', name(lag_pop_CEIC`t');
	rename lag_pop_CEIC`t'1 lag_pop_CEIC`t';
};
										  
reshape long total_vistor total_tincome domesticarrival dometric_rev inter_arrival inter_rev CPIprecedingyear CPIbenchmark res_house_price grp_per_ceic salary pop_CEIC area_CEIC road_CEIC hotel agent A_spot railway_station lag_total_vistor lag_pop_CEIC, i(ID) j(year);

xtivreg total_vistor (lag_total_vistor CPIbenchmark = lag_pop_CEIC res_house_price) salary pop_CEIC road_CEIC hotel A_spot;

;
