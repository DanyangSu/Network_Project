/*
1 drop msa_pop_density < 4% and not in MA
2 drop institutionized sample
3 choose female samples between age 20 and 55 
4 drop if number of pepole speak language less than 1000
5 drop if frequency in the data less than 500 (female sample)
6 income_ratio: mean income / mean monthly renter/owner cost

*/

//read raw data
set more off
clear
capture program drop process
program define process

	local ST=upper("`1'")
	local dta_name "$data_dir\pums5_`1'.dta"
	qui append using "`dta_name'", keep(msapmsa serialno rgrent rownrcst ///
		rhhinc value sex race age marital gqinst rpob rspouse rownchld ragechld rhhfamtp rnrlchld poverty r18undr rfaminc rpincome persons school rearning yearsch lang1 lang2 english fertil rlabor industry occup class pob hispanic income6)
	keep if gqinst != 1
end
process al
process ak
process az
process ar
process ca
process co
process ct
process de
process dc
process fl
process ga
process hi 
process id
process il
process in
process ia
process ks 
process ky
process la
process me
process md
process ma
process mi
process mn 
process ms
process mo
process mt
process ne
process nv
process nh
process nj
process nm
process ny
process nc
process nd
process oh
process ok
process or
process pa
process ri
process sc
process sd
process tn 
process tx
process ut
process vt
process va
process wa
process wv
process wi
process wy

bysort lang2: gen num_lang = _N
bysort lang2 msapmsa: gen msa_num_lang = _N
bysort msapmsa: gen num_msa = _N
gen num_CA = _N
gen CA = log((msa_num_lang/num_lang)/(num_msa/num_CA))



// this part of code can be applied to US sample
gen age_flag = 0
replace age_flag = 1 if age>20 & age<55
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
gen foreign_born = 0
replace foreign_born = 1 if pob > 59
gen eng_flu = 0
replace eng_flu = 1 if english < 3
gen welfare = 0
replace welfare = 1 if income6 > 0
gen num_kid = fertil - 1
gen flag_college = 0
replace flag_college = 1 if yearsch > 13
// chunk ends here, need to add gender/language restriction to US sample separately 



keep if sex==1 & age_flag == 1


//keep only foreign speakers
keep if lang1 == 1

//this part of code is the language restriction
drop if num_lang < 1000 //seems sensitive if I choose 10000 or 50000
bysort lang2: gen freq_lang = _N
drop if freq_lang < 500 // pick sample size large
// this chunk ends here



bysort msapmsa: egen max_welfare = max(welfare)
drop if max_welfare == 0

bysort lang2: egen mean_welfare = mean(welfare)
gen CA_Gwelfare = CA*mean_welfare

sort msapmsa lang2
gen id = _n
sort lang2
egen j_id = group(lang2)
sort msapmsa
egen k_id = group(msapmsa)

save "$data_dir\clean_data_US", replace

