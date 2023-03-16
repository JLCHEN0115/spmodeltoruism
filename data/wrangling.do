*change the end-of-line delimiter to ';'
# delimit ;

********************************************************************************;
*Data wrangling for X's;
********************************************************************************;
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;
*Arrivals in 10 thousands in databse_ZL, in thousands in other files;
*Revenue in 100 million yuan in databse_ZL, in milliions in other files;
*Not corrected yet;
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;
*clear the environment;
clear all;
*input data;
import excel "/Users/jialiangchen/Documents/spmodeltoruism/data/database_ZL.xlsx", sheet("Sheet1") cellrange(A2:AT2567) firstrow;

drop Prov ID CPI housingpriceRMBm2 BusinessVolume_Telecommunicatio-gdp_ceic ind-taxi AK-railway_length railway_number-baidu;
rename (L CPIbenchmark2011 CPIprecedingyear100) (res_house_price CPIbenchmark CPIprecedingyear);

*The old ID is missing unit 64 and 67;
gen id_correct=.;
local j = 1;
local k = 1;
forvalues i = 1(1)2565{;
	replace id_correct = `k' if _n==`i';
	local j = `j'+1;
	if `j'==10{;
	local j=1;
	local k=`k'+1;
	};
};

*Simao is nolonger a city;
forvalues i = 2269(1)2277{;
	replace Name = "普洱"  if _n==`i';
	replace City = "Puer"  if _n==`i';
};


reshape wide total_vistor total_tincome CPIprecedingyear CPIbenchmark res_house_price grp_per_ceic salary pop_CEIC area_CEIC road_CEIC hotel agent A_spot railway_station, i(id_correct) j(year);

*drop city Bijie(245) and Tongren(246);
drop if City == "Bijie" | City == "Tongren";
*renew our ID;
generate ID = _n;
drop id_correct;
order ID Name City;

save "/Users/jialiangchen/Documents/spmodeltoruism/data/clean_database_ZL.dta", replace;

********************************************************************************;
*Data wrangling for domestic tourist arrivals;
********************************************************************************;

*clear the environment;
clear all;
*input data;
import excel "/Users/jialiangchen/Documents/spmodeltoruism/data/tourism_data_of_prefecture_level_cities_in_China.xlsx", sheet("入境旅游人数") firstrow;
*drop missing values;
drop in 286/291;
*drop Qitaihe(64) and Suihua(67);
drop if id == 64 | id == 67;
*renew our ID;
generate ID = _n;
drop id;
order ID;
*drop variables we will not use;
drop city 指标 区域 频率 单位 数据来源 状态 SR码 K L M N O P Q AA;
*rename our variables;
rename (次国家 R S T U V W X Y Z) (City domesticarrival2011 domesticarrival2012 domesticarrival2013 domesticarrival2014 domesticarrival2015 domesticarrival2016 domesticarrival2017 domesticarrival2018 domesticarrival2019);

save "/Users/jialiangchen/Documents/spmodeltoruism/data/domesticarrival.dta", replace;

********************************************************************************;
*Data wrangling for intervational tourist arrivals;
********************************************************************************;

*clear the environment;
clear all;
*input data;
import excel "/Users/jialiangchen/Documents/spmodeltoruism/data/tourism_data_of_prefecture_level_cities_in_China.xlsx", sheet("国内旅游人数") firstrow;

*drop Qitaihe(64) and Suihua(67);
drop if id == 64 | id == 67;
*renew our ID;
generate ID = _n;
drop id;
order ID;
*drop variables we will not use;
drop city 指标 区域 频率 单位 数据来源 状态 SR码 K L M N O P Q A*;
*rename our variables;
rename (次国家 R S T U V W X Y Z) (City inter_arrival2011 inter_arrival2012 inter_arrival2013 inter_arrival2014 inter_arrival2015 inter_arrival2016 inter_arrival2017 inter_arrival2018 inter_arrival2019);

save "/Users/jialiangchen/Documents/spmodeltoruism/data/internationalarrival.dta", replace;

********************************************************************************;
*Data wrangling for domestic tourism revenue;
********************************************************************************;

*clear the environment;
clear all;
*input data;
import excel "/Users/jialiangchen/Documents/spmodeltoruism/data/tourism_data_of_prefecture_level_cities_in_China.xlsx", sheet("国内旅游收入") firstrow;

*drop Qitaihe(64) and Suihua(67);
drop if id == 64 | id == 67;
*renew our ID;
generate ID = _n;
drop id;
order ID;
*drop variables we will not use;
drop city 指标 区域 频率 单位 数据来源 状态 SR码 K L M N O P Q A*;
*rename our variables;
rename (次国家 R S T U V W X Y Z) (City dometric_rev2011 dometric_rev2012 dometric_rev2013 dometric_rev2014 dometric_rev2015 dometric_rev2016 dometric_rev2017 dometric_rev2018 dometric_rev2019);

save "/Users/jialiangchen/Documents/spmodeltoruism/data/domstic_revenue.dta", replace;

********************************************************************************;
*Data wrangling for international tourism revenue;
********************************************************************************;

*clear the environment;
clear all;
*input data;
import excel "/Users/jialiangchen/Documents/spmodeltoruism/data/tourism_data_of_prefecture_level_cities_in_China.xlsx", sheet("旅游外汇收入") firstrow;

*drop Qitaihe(64) and Suihua(67);
drop if id == 64 | id == 67;
*renew our ID;
generate ID = _n;
drop id;
order ID;
*drop variables we will not use;
drop city 指标 区域 频率 单位 数据来源 状态 SR码 K L M N O P Q A*;
*rename our variables;
rename (次国家 R S T U V W X Y Z) (City inter_rev2011 inter_rev2012 inter_rev2013 inter_rev2014 inter_rev2015 inter_rev2016 inter_rev2017 inter_rev2018 inter_rev2019);

save "/Users/jialiangchen/Documents/spmodeltoruism/data/international_revenue.dta", replace;

********************************************************************************;
*Data wrangling for lat and long data;
********************************************************************************;
*clear the environment;
clear all;
*input data;
import excel "/Users/jialiangchen/Documents/spmodeltoruism/data/city_latlong.xlsx", sheet("Sheet3") firstrow;
*delete the character “市” at the end of each city name;
replace 城市 = udsubstr(城市, 1, udstrlen(城市) - 1);
drop if 城市 == "七台河" | 城市 == "绥化" | 城市 =="莱芜";

save "/Users/jialiangchen/Documents/spmodeltoruism/data/city_lat_long.dta", replace;
