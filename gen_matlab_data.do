set more off

//pick relevant variables
use "$data_dir\temp_clean_data", clear

#delimit ;
keep msapmsa k_pvt k_black k_employ k_mp_occu id j_id k_id CA CA_Gwelfare
welfare age HS_drop HS_degree some_college m_sa widow married
divorce separated never_m chld_p single_mom num_kid eng_flu lang2 flag_college
num_msa num_CA sample_weight;
#delimit cr
// normalize age/100 age2/10000 k_pvt/1000
replace age = age/100
gen age2_100 = age*age
replace k_pvt = k_pvt/1000
save "$data_dir\clean_data_CA", replace

//save k_data file
use "$data_dir\clean_data_CA", clear
gen pop_density = num_msa / num_CA
collapse (first) k_* pop_density, by(msapmsa)
drop msapmsa
save "$data_dir\k_data", replace
export delimited using "$matlab_dir\k_data", nolabel replace

//save choice_data file
use "$data_dir\clean_data_CA", clear
keep welfare age age2_100 HS_drop HS_degree some_college m_sa widow ///
married divorce separated never_m chld_p single_mom num_kid eng_flu lang2 ///
k_* id j_id flag_college
save "$data_dir\choice_data", replace
export delimited using "$matlab_dir\choice_data", nolabel replace

//save individual data file ij_data
use "$data_dir\clean_data_CA", clear
keep age age2_100 HS_drop HS_degree some_college m_sa widow ///
married divorce separated never_m chld_p single_mom num_kid eng_flu lang2 ///
id j_id flag_college
save "$data_dir\ij_data", replace
export delimited using "$matlab_dir\ij_data", nolabel replace

//save j_data file
use "$data_dir\clean_data_CA", clear
keep j_id welfare
sort j_id
collapse (mean) welfare, by(j_id)
save "$data_dir\j_data", replace
export delimited using "$matlab_dir\j_data", nolabel replace

//save jk_data (second-stage data)
use "$data_dir\clean_data_CA", clear
keep k_id j_id CA_Gwelfare CA
sort j_id k_id
collapse (first) CA_Gwelfare CA, by(j_id k_id)
save "$data_dir\temp_jk", replace

use "$data_dir\k_data", clear
qui su k_id
local num_k = r(max)
drop *
forvalues i=1(1)`num_k' {
	append using "$data_dir\j_data"
}
bysort j_id: gen k_id = _n
merge m:1 k_id using "$data_dir\k_data", keepusing(k_*)
drop _merge
merge 1:1 j_id k_id using "$data_dir\temp_jk"
drop _merge
tab j_id, gen(j)
tab k_id, gen(k)
keep CA_Gwelfare CA j* k* 
drop j1 k1 k_pvt k_black k_employ k_mp_occu k_id j_id
save "$data_dir\jk_data", replace
export delimited using "$matlab_dir\jk_data", nolabel replace

//save s_data
use "$data_dir\clean_data_CA", clear
qui su k_id
local k=r(max)
gen d_id = k_id //decision id
replace d_id = k_id + `k' if welfare==0 //welfare, no welfare
keep j_id d_id
gen headcount = 1
sort j_id d_id
collapse (sum) headcount, by(j_id d_id)
bysort j_id: egen total_j_count = sum(headcount)
gen s = headcount / total_j_count
keep j_id d_id s
sort j_id d_id
reshape wide s, i(j_id) j(d_id)
drop j_id
save "$data_dir\s_data", replace
export delimited using "$matlab_dir\s_data", novarnames nolabel replace

//save weight_data or iv use
use "$data_dir\clean_data_CA", clear
keep sample_weight
save "$data_dir\iv_data", replace
export delimited using "$matlab_dir\iv_data", nolabel replace

