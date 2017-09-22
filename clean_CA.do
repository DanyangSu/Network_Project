/*
1 drop msa_pop_density < 4% and not in MA, remaining 76.7% of sample
2 drop institutionized sample
3 choose female samples between age 20 and 55
4 k level data for employment, house value, household income, CA are for whole population
5 k level data for college degree, welfare, single mom, race for selected female 
6 drop if number of pepole speak language less than 1000
7 drop if frequency in the data less than 500 (female sample)
8 choose language group with obs on all cities
9 income_ratio: mean income / mean monthly renter/owner cost
10 I exclude isolated language groups: Korean, German, Persian, Armenian, Hindi, Arabic, Portuguese.

*/

//read raw data
set more off
clear
cls

local dta_name "$data_dir\pums5_ca.dta"
display "`dta_name'"
qui append using "`dta_name'", keep(msapmsa serialno rgrent rownrcst ///
	rhhinc value sex race age marital gqinst rpob rspouse rownchld ragechld rhhfamtp migstate rnrlchld poverty r18undr rfaminc rpincome persons school rearning yearsch lang1 lang2 english fertil rlabor industry occup class pob hispanic income6)
keep if gqinst != 1

//pick MSAs
bysort msapmsa: gen num_msa = _N
gen num_CA = _N
gen msa_pop_density = num_msa/num_CA
drop if msapmsa > 9360 // in CA, only not in MA exists, use as default, and I group small town with population below 50,000
drop if msa_pop_density < 0.04
label define msapmsa 360 "Orange County", add
label define msapmsa 4480 "Los Angeles-Long Beach", add
label define msapmsa 5775 "Oakland", add
label define msapmsa 6780 "Riverside-San Bernardino", add
label define msapmsa 6920 "Sacramento", add
label define msapmsa 7320 "San Diego", add
label define msapmsa 7360 "San Francisco", add
label define msapmsa 7400 "San Jose", add
la var msapmsa "MSA"
tab msapmsa, sort


//gen k data (The weight I think is wrong, many ppl do not have housewgt because they are not head, but they should be 1 since I am not using weigth anymore...)
gen houswgt = 1
bysort serialno: gen hh_flag = _n
replace houswgt = . if hh_flag != 1
drop hh_flag
gen hvalue = .
replace hvalue = rgrent if rgrent > 0
replace hvalue = rownrcst if rownrcst > 0
gen hwt = .
replace hwt = 1 if rgrent > 0 &  houswgt == 1
replace hwt = 1 if rownrcst > 0 &  houswgt == 1
gen inc_ratio = .
replace inc_ratio = rhhinc / hvalue if hwt==1
gen pvt_cut = .
replace pvt_cut = 6451 if persons==1 
replace pvt_cut = 8303 if persons==2 & rnrlchld==0
replace pvt_cut = 8547 if persons==2 & rnrlchld==1
replace pvt_cut = 9699 if persons==3 & rnrlchld==0
replace pvt_cut = 9981 if persons==3 & rnrlchld==1
replace pvt_cut = 9990 if persons==3 & rnrlchld==2
replace pvt_cut = 12790 if persons==4 & rnrlchld==0
replace pvt_cut = 12999 if persons==4 & rnrlchld==1
replace pvt_cut = 12575 if persons==4 & rnrlchld==2
replace pvt_cut = 12619 if persons==4 & rnrlchld==3
replace pvt_cut = 15424 if persons==5 & rnrlchld==0
replace pvt_cut = 15648 if persons==5 & rnrlchld==1
replace pvt_cut = 15169 if persons==5 & rnrlchld==2
replace pvt_cut = 14798 if persons==5 & rnrlchld==3
replace pvt_cut = 14572 if persons==5 & rnrlchld==4
replace pvt_cut = 17740 if persons==6 & rnrlchld==0
replace pvt_cut = 17811 if persons==6 & rnrlchld==1
replace pvt_cut = 17444 if persons==6 & rnrlchld==2
replace pvt_cut = 17092 if persons==6 & rnrlchld==3
replace pvt_cut = 16569 if persons==6 & rnrlchld==4
replace pvt_cut = 16259 if persons==6 & rnrlchld==5
replace pvt_cut = 20412 if persons==7 & rnrlchld==0
replace pvt_cut = 20540 if persons==7 & rnrlchld==1
replace pvt_cut = 20101 if persons==7 & rnrlchld==2
replace pvt_cut = 19794 if persons==7 & rnrlchld==3
replace pvt_cut = 19224 if persons==7 & rnrlchld==4
replace pvt_cut = 18558 if persons==7 & rnrlchld==5
replace pvt_cut = 17828 if persons==7 & rnrlchld==6
replace pvt_cut = 22830 if persons==8 & rnrlchld==0
replace pvt_cut = 23031 if persons==8 & rnrlchld==1
replace pvt_cut = 22617 if persons==8 & rnrlchld==2
replace pvt_cut = 22253 if persons==8 & rnrlchld==3
replace pvt_cut = 21738 if persons==8 & rnrlchld==4
replace pvt_cut = 21084 if persons==8 & rnrlchld==5
replace pvt_cut = 20403 if persons==8 & rnrlchld==6
replace pvt_cut = 20230 if persons==8 & rnrlchld==7
replace pvt_cut = 27463 if persons>=9 & rnrlchld==0
replace pvt_cut = 27596 if persons>=9 & rnrlchld==1
replace pvt_cut = 27229 if persons>=9 & rnrlchld==2
replace pvt_cut = 26921 if persons>=9 & rnrlchld==3
replace pvt_cut = 26415 if persons>=9 & rnrlchld==4
replace pvt_cut = 25719 if persons>=9 & rnrlchld==5
replace pvt_cut = 25089 if persons>=9 & rnrlchld==6
replace pvt_cut = 24933 if persons>=9 & rnrlchld==7
replace pvt_cut = 23973 if persons>=9 & rnrlchld>=8
	
gen pvt = .
replace pvt = rhhinc/pvt_cut*100 


// this part of code can be applied to US sample
gen age_flag = 0
replace age_flag=1 if age>20 & age<55
gen HS_drop = 0
replace HS_drop = 1 if yearsch < 10
gen HS_degree = 0
replace HS_degree = 1 if yearsch == 10
gen some_college = 0
replace some_college = 1 if yearsch >=11 & yearsch<=13
gen college_more = 0
replace college_more = 1 if yearsch > 13


gen m_sp = 0
replace m_sp = 1 if rspouse == 1
gen m_sa = 0
replace m_sa = 1 if rspouse == 2
gen widow = 0
replace widow = 1 if rspouse == 3
gen divorce = 0
replace divorce = 1 if rspouse == 4
gen separated = 0
replace separated = 1 if rspouse == 5
gen never_m = 0
replace never_m = 1 if rspouse == 6
gen married = 0
replace married = 1 if m_sp == 1 | m_sa == 1
gen white = 0
replace white = 1 if race == 1
gen black = 0
replace black = 1 if race == 2
gen hisp = 1
replace hisp = 0 if hispanic==0 | hispanic==199
gen chld_p = 0 //child present flag only average over women between 15 and 55	
replace chld_p = 1 if ragechld < 4 & ragechld > 0
gen single_mom = 0
replace single_mom = 1 if ragechld > 0 & ragechld < 4 & rspouse > 1
gen eng_flu = 0
replace eng_flu = 1 if english < 3
gen foreign_born = 0
replace foreign_born = 1 if pob > 59
gen welfare = 0
replace welfare = 1 if income6 > 0
gen num_kid = fertil - 1
gen flag_college = 0
replace flag_college = 1 if yearsch > 13
// chunk ends here, need to add gender/language restriction to US sample separately 


sort msapmsa
capture program drop wt_m
program define wt_m
	gen temp_wx = `1' * `2'
	bysort msapmsa: egen sum_wx = sum(temp_wx)
	bysort msapmsa: egen sum_w = sum(`2')
	gen k_`1' = sum_wx/sum_w
	drop temp_wx sum_wx sum_w
end

gen hhwt = .
bysort serialno: replace hhwt = 1 if _n==1
wt_m pvt hhwt

tab msa_pop_density
bysort lang2: gen num_lang = _N
bysort lang2 msapmsa: gen msa_num_lang = _N
gen CA = log((msa_num_lang/num_lang)/(num_msa/num_CA))


gen p_w = 1
wt_m white p_w
wt_m black p_w
wt_m hisp p_w
replace k_black = k_black*100

gen employ = . //employ here is actually unemploy
replace employ = 1 if rlabor == 3 & age_flag == 1
replace employ = 0 if (rlabor == 1 | rlabor == 2 | rlabor == 4 | rlabor == 5) & age_flag == 1
gen p_w_employ = .
replace p_w_employ = 1 if employ~=.
wt_m employ p_w_employ
replace k_employ = k_employ*100

gen mp_occu = .
replace mp_occu = 1 if occup>=003 & occup<=199 & age_flag == 1
replace mp_occu = 0 if occup>199 & age_flag == 1
gen p_w_occu = .
replace p_w_occu = 1 if occup>0
wt_m mp_occu p_w_occu

gen keep_flag = 0
replace keep_flag = 1 if sex==1 & age_flag == 1
bysort serialno: gen num_house = _N
by serialno: egen num_sample_house = sum(keep_flag)
gen sample_weight = num_house / num_sample_house

sort lang2 msapmsa
keep if keep_flag == 1
sort msapmsa

wt_m chld_p p_w



wt_m flag_college p_w


wt_m welfare p_w
replace k_welfare = k_welfare*100


wt_m single_mom p_w


gen manufact_industry = .
replace manufact_industry = 0 if employ == 1
replace manufact_industry = 1 if employ == 1 & industry < 400 & industry > 59
wt_m manufact_industry p_w

program drop wt_m




bysort lang2: egen mean_welfare = mean(welfare)
gen CA_Gwelfare = CA*mean_welfare
replace lang2 = 999 if lang1 == 2
label values lang2 lang2
label variable lang2 "Language"
label define lang2 619 "Italian", add
label define lang2 620 "French", add
label define lang2 625 "Spanish", add
label define lang2 708 "Chinese", add
label define lang2 720 "Thai", add
label define lang2 723 "Japanese", add
label define lang2 728 "Vietnamese", add
label define lang2 742 "Tagalog", add
label define lang2 726 "Mon-Khmer", add
label define lang2 999 "English", add

//this part of code is the language restriction
drop if num_lang < 1000 //seems sensitive if I choose 10000 or 50000
bysort lang2: gen freq_lang = _N
drop if freq_lang < 500 // pick sample size large
// this chunk ends here

sort msapmsa lang2
gen id = _n
sort lang2
egen j_id = group(lang2)
sort msapmsa
egen k_id = group(msapmsa)



save "$data_dir\temp_clean_data_with_isolate_English", replace
// drop if no observation in all MSAs
sort msapmsa welfare
egen kp_id = group(msapmsa welfare)
bysort lang2 kp_id: gen nvals = _n == 1 
by lang2: replace nvals = sum(nvals)
by lang2: replace nvals = nvals[_N]
egen max_v = max(nvals)
drop if nvals < max_v
drop nvals max_v kp_id

save "$data_dir\temp_clean_data_with_English", replace
//keep only foreign speakers
keep if lang1 == 1
drop id j_id k_id //This is very important, otherwise j_id is not from 1-9
sort msapmsa lang2
gen id = _n
sort lang2
egen j_id = group(lang2)
sort msapmsa
egen k_id = group(msapmsa)
save "$data_dir\temp_clean_data", replace

