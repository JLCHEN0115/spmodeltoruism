*change the end-of-line delimiter to ';'
# delimit ;
clear all;
********************************************************************************;
*Merge our datasets;
********************************************************************************;
use clean_database_ZL.dta, clear;

*add domestic arrivals into the data, mathing on id;
merge 1:1 ID using  domesticarrival.dta, generate(mresult_do_arr);

*add domestic revelues into the data, mathing on id;
merge 1:1 ID using   domstic_revenue.dta,  generate(mresult_do_rev);

*add international arrivals into the data, mathing on id;
merge 1:1 ID using  internationalarrival.dta, generate(mresult_in_arr);

*add domestic revelues into the data, mathing on id;
merge 1:1 ID using   international_revenue.dta,  generate(mresult_in_rev);

*drop merge result indicators;
drop mresult_do_arr mresult_do_rev mresult_in_arr mresult_in_rev;

rename Name 城市;
replace 城市 = "襄阳" if 城市 == "襄樊";
replace City = "Xiangyang" if City == "Xiangfan";
*add international arrivals into the data, mathing on id;
merge 1:1 城市 using city_lat_long.dta, generate(mresult_location);
drop mresult_location;
order ID 城市 City Lat Long;
*save wide form data;
save "/Users/jialiangchen/Documents/spmodeltoruism/data/clean_data_wide.dta", replace;

*go to the long form;
reshape long total_vistor total_tincome domesticarrival dometric_rev inter_arrival inter_rev CPIprecedingyear CPIbenchmark res_house_price grp_per_ceic salary pop_CEIC area_CEIC road_CEIC hotel agent A_spot railway_station, i(ID) j(year);

*arrivals in thousands, revenues in millions;
replace total_vistor = total_vistor*10;
replace total_tincome = total_tincome*100;

*reordering;
order ID year 城市 City Lat Long total_vistor total_tincome  domesticarrival dometric_rev inter_arrival inter_rev;

*save and output to excel;
save "/Users/jialiangchen/Documents/spmodeltoruism/data/clean_data.dta", replace;
export excel using "/Users/jialiangchen/Documents/spmodeltoruism/data/clean_data.xls", sheetreplace firstrow(variables);
