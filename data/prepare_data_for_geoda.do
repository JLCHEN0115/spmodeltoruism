*change the end-of-line delimiter to ';'
# delimit ;
clear all;

* import the dBase file;
import dbase /Users/jialiangchen/Documents/spmodeltoruism/shapefiles/china_second_level_admin_shape/cities_included.dbf;

*********************************************************************;
*some cleaning work;
*********************************************************************;
drop ID_0 ISO InORnot NAME_0 ID_1 NAME_1 HASC_2 CCN_2 CCA_2 VARNAME_2 layer path;
rename (NAME_2 ENGTYPE_2 NL_NAME_2) (City Admintype 城市);
gen 城市shapefile = 城市;
replace 城市 = "北京市" if City == "Beijing";
replace 城市 = "重庆市" if City == "Chongqing";

replace 城市 = "常德市" if City == "Changde";
replace 城市 = "长沙市" if City == "Changsha";
replace 城市 = "衡阳市" if City == "Hengyang";
replace 城市 = "怀化市" if City == "Huaihua";
replace 城市 = "娄底市" if City == "Loudi";
replace 城市 = "邵阳市" if City == "Shaoyang";
replace 城市 = "湘潭市" if City == "Xiangtan";
replace 城市 = "益阳市" if City == "Yiyang";
replace 城市 = "永州市" if City == "Yongzhou";
replace 城市 = "岳阳市" if City == "Yueyang";
replace 城市 = "张家界市" if City == "Zhangjiajie";
replace 城市 = "株洲市" if City == "Zhuzhou";
replace 城市 = "郴州市" if City == "Chenzhou";
replace 城市 = "上海市" if City == "Shanghai";
replace 城市 = "天津市" if City == "Tianjin";

replace ID_2 = 345 if City == "Yingkou";
*remove the character "市" if the city name is ending with a "市";
replace 城市 = udsubstr(城市, 1, udstrlen(城市) - 1) if udsubstr(城市, -1, .) == "市";
*one exception;
replace 城市 = "运城" if City == "Yuncheng";
merge 1:1 城市 using /Users/jialiangchen/Documents/spmodeltoruism/data/clean_data_wide.dta, generate(merge_result);
drop merge_result ID;

export delimited using "/Users/jialiangchen/Documents/spmodeltoruism/data/dataforgeoda.csv", replace;

*decrease our variable names length < 10;
*reshape long total_vistor total_tincome domesticarrival dometric_rev inter_arrival inter_rev CPIprecedingyear CPIbenchmark res_house_price grp_per_ceic salary pop_CEIC area_CEIC road_CEIC hotel agent A_spot railway_station, i(ID) j(year);

*rename (total_vistor total_tincome domesticarrival dometric_rev inter_arrival inter_rev CPIprecedingyear CPIbenchmark res_house_price grp_per_ceic salary pop_CEIC area_CEIC road_CEIC hotel agent A_spot railway_station) (ttvis ttin davl drev inavl inrev cpip cpib house pgdp sly pop area road htl agnt Aspt rstn );


