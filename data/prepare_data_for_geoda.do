*change the end-of-line delimiter to ';'
# delimit ;
clear all;

* import the dBase file;
import dbase /Users/jialiangchen/Documents/spmodeltoruism/shapefiles/china_second_level_admin_shape/cities_included.dbf;

*********************************************************************;
*some cleaning work;
*********************************************************************;
rename (NL_NAME_2) (城市);
gen 城市shapefile = 城市;
replace 城市 = "北京市" if 城市shapefile == "北京|北京";
replace 城市 = "重庆市" if 城市shapefile == "重慶|重庆";
replace 城市 = "常德市" if 城市shapefile == "常德市|常德市";
replace 城市 = "长沙市" if 城市shapefile == "长沙市|長沙市";
replace 城市 = "衡阳市" if 城市shapefile == "衡阳市|衡陽市";
replace 城市 = "怀化市" if 城市shapefile == "怀化市|懷化市";
replace 城市 = "娄底市" if 城市shapefile == "娄底市|婁底市";
replace 城市 = "邵阳市" if 城市shapefile == "邵阳市|邵陽市";
replace 城市 = "湘潭市" if 城市shapefile == "湘潭市|湘潭市";
replace 城市 = "益阳市" if 城市shapefile == "益阳市|益陽市";
replace 城市 = "永州市" if 城市shapefile == "永州市|永州市";
replace 城市 = "岳阳市" if 城市shapefile == "岳阳市|岳陽市";
replace 城市 = "张家界市" if 城市shapefile == "张家界市|張家界市";
replace 城市 = "株洲市" if 城市shapefile == "株洲市|株洲市";
replace 城市 = "郴州市" if 城市shapefile == "郴州市|郴州市";
replace 城市 = "上海市" if 城市shapefile == "上海|上海";
replace 城市 = "天津市" if 城市shapefile == "天津|天津";

*remove the character "市" if the city name is ending with a "市";
replace 城市 = udsubstr(城市, 1, udstrlen(城市) - 1) if udsubstr(城市, -1, .) == "市";
*one exception;
replace 城市 = "运城" if 城市shapefile == "运城县";
merge 1:1 城市 using /Users/jialiangchen/Documents/spmodeltoruism/data/clean_data_wide.dta, generate(merge_result);
drop merge_result ID;

reshape long total_vistor total_tincome domesticarrival dometric_rev inter_arrival inter_rev CPIprecedingyear CPIbenchmark res_house_price grp_per_ceic salary pop_CEIC area_CEIC road_CEIC hotel agent A_spot railway_station, i(城市shapefile) j(year);

rename (total_vistor total_tincome domesticarrival dometric_rev inter_arrival inter_rev CPIprecedingyear CPIbenchmark res_house_price grp_per_ceic salary pop_CEIC area_CEIC road_CEIC hotel agent A_spot railway_station) (tarvl_ trev_ darvl_ drev_ iarvl_ irev_ CPIp_ CPIb_ hprice_ pgdp_ salary_ pop_ area_ road_ hotel_ agent_ Aspot_ railway_);

drop VARNAME_2;

reshape wide tarvl_ trev_ darvl_ drev_ iarvl_ irev_ CPIp_ CPIb_ hprice_ pgdp_ salary_ pop_ area_ road_ hotel_ agent_ Aspot_ railway_, i(城市shapefile) j(year);

order 城市 城市shapefile City Lat Long;

export delimited using "/Users/jialiangchen/Documents/spmodeltoruism/data/dataforgeoda.csv", replace;

export delimited using "/Users/jialiangchen/Documents/spmodeltoruism/data/dataforR.csv", replace;

*decrease our variable names length < 10;
*reshape long total_vistor total_tincome domesticarrival dometric_rev inter_arrival inter_rev CPIprecedingyear CPIbenchmark res_house_price grp_per_ceic salary pop_CEIC area_CEIC road_CEIC hotel agent A_spot railway_station, i(ID) j(year);

*rename (total_vistor total_tincome domesticarrival dometric_rev inter_arrival inter_rev CPIprecedingyear CPIbenchmark res_house_price grp_per_ceic salary pop_CEIC area_CEIC road_CEIC hotel agent A_spot railway_station) (ttvis ttin davl drev inavl inrev cpip cpib house pgdp sly pop area road htl agnt Aspt rstn );


