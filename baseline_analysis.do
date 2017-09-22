





//Normalize age /100 age2 /10000 
set more off
set matsize 2000
use "$data_dir\clean_data_US", clear
replace age = age/100
gen age2 = age^2
label variable age "Age/100"
label variable age2 "$\text{Age}^{2}/10000$"
label variable CA_Gwelfare "Network"
label variable mean_welfare "Mean Welfare"
label variable HS_drop "HS Dropout"
label variable HS_degree "HS Graduate"
label variable some_college "Some College"
label variable m_sa "Married, Spouse Absent"
label variable widow "Widowed"
label variable divorce "Divorced"
label variable separated "Separated"
label variable never_m "Never Married"
label variable chld_p "Child Present"
label variable single_mom "Single Mom"
label variable white "White"
label variable num_kid "No. Kid"
label variable eng_flu "English Mastery"
label variable CA "Network Strength"
label variable flag_college "College Graduate"
label variable married "Married"

egen group_id = group(j_id k_id) 
qui xi: logit welfare CA_Gwelfare CA age age2 flag_college married chld_p single_mom num_kid eng_flu i.j_id i.k_id
eststo Logit_US_CA: margin, post dydx(CA_Gwelfare CA age age2 flag_college married chld_p single_mom num_kid eng_flu)

qui xi: logit welfare CA_Gwelfare age age2 flag_college married chld_p single_mom num_kid eng_flu i.j_id i.k_id
eststo Logit_US: margin, post dydx(CA_Gwelfare age age2 flag_college married chld_p single_mom num_kid eng_flu)




use "$data_dir\temp_clean_data_with_isolate_English", clear
replace age = age/100
gen age2 = age^2
keep if lang1==1
label variable age "Age/100"
label variable age2 "$\text{Age}^{2}/10000$"
label variable CA_Gwelfare "Network"
label variable mean_welfare "Mean Welfare"
label variable HS_drop "HS Dropout"
label variable HS_degree "HS Graduate"
label variable some_college "Some College"
label variable m_sa "Married, Spouse Absent"
label variable widow "Widowed"
label variable divorce "Divorced"
label variable separated "Separated"
label variable never_m "Never Married"
label variable chld_p "Child Present"
label variable single_mom "Single Mom"
label variable white "White"
label variable num_kid "No. Kid"
label variable eng_flu "English Mastery"
label variable CA "Network Strength"
label variable flag_college "College Graduate"
label variable married "Married"

egen group_id = group(j_id k_id) 
qui xi: logit welfare CA_Gwelfare CA age age2 flag_college married chld_p single_mom num_kid eng_flu i.j_id i.k_id
eststo Logit_CA_ISO_CA: margin, post dydx(CA_Gwelfare CA age age2 flag_college married chld_p single_mom num_kid eng_flu)

qui xi: logit welfare CA_Gwelfare age age2 flag_college married chld_p single_mom num_kid eng_flu i.j_id i.k_id
eststo Logit_CA_ISO: margin, post dydx(CA_Gwelfare age age2 flag_college married chld_p single_mom num_kid eng_flu)




use "$data_dir\temp_clean_data", clear
replace age = age/100
gen age2 = age^2
label variable age "Age/100"
label variable age2 "$\text{Age}^{2}/10000$"
label variable CA_Gwelfare "Network"
label variable mean_welfare "Mean Welfare"
label variable HS_drop "HS Dropout"
label variable HS_degree "HS Graduate"
label variable some_college "Some College"
label variable m_sa "Married, Spouse Absent"
label variable widow "Widowed"
label variable divorce "Divorced"
label variable separated "Separated"
label variable never_m "Never Married"
label variable chld_p "Child Present"
label variable single_mom "Single Mom"
label variable white "White"
label variable num_kid "No. Kid"
label variable eng_flu "English Mastery"
label variable CA "Network Strength"
label variable flag_college "College Graduate"
label variable married "Married"

qui xi: logit welfare CA_Gwelfare CA age age2 flag_college married chld_p single_mom num_kid eng_flu i.j_id i.k_id
eststo Logit_CA_CA: margin, post dydx(CA_Gwelfare CA age age2 flag_college married chld_p single_mom num_kid eng_flu)

qui xi: logit welfare CA_Gwelfare age age2 flag_college married chld_p single_mom num_kid eng_flu i.j_id i.k_id
eststo Logit_CA: margin, post dydx(CA_Gwelfare age age2 flag_college married chld_p single_mom num_kid eng_flu)


esttab



estout Logit_CA Logit_CA_ISO Logit_US using "$table_dir\table_benchmark.tex",style(tex) cells(b(star fmt(3)) se(par fmt(3))) stats(N, fmt(%9.0g)) ///
mlabels("CA" "CA with Excluded" "US") ///
keep(CA_Gwelfare age age2 flag_college married chld_p single_mom num_kid eng_flu) starlevels(* 0.10 ** 0.05 *** 0.01) ///
topfile("$table_dir\table_benchmark_topf.tex") label bottomfile("$table_dir\table_benchmark_botf.tex") eqlabels(none) type legend replace margin

estout Logit_CA_CA Logit_CA_ISO_CA Logit_US_CA using "$table_dir\table_benchmark_CA.tex",style(tex) cells(b(star fmt(3)) se(par fmt(3))) stats(N, fmt(%9.0g)) ///
mlabels("CA" "CA with Excluded" "US") ///
keep(CA_Gwelfare CA age age2 flag_college married chld_p single_mom num_kid eng_flu) starlevels(* 0.10 ** 0.05 *** 0.01) ///
topfile("$table_dir\table_benchmark_CA_topf.tex") label bottomfile("$table_dir\table_benchmark_CA_botf.tex") eqlabels(none) type legend replace margin


/*
qui xi: logit welfare CA_Gwelfare age age2 chld_p flag_college single_mom num_kid foreign_born eng_flu i.j_id i.k_id
margin, dydx(CA_Gwelfare age age2 chld_p flag_college single_mom num_kid foreign_born eng_flu) post
eststo logit_reg_CA

use "$data_dir\temp_clean_data_with_isolate_English", clear
//drop English
keep if lang1 == 1 
gen age2 = age^2
egen max_age2 = max(age2)
egen max_age = max(age)
egen max_kid = max(num_kid)
replace age = age / 100
replace age2 = age2 / 1000
replace num_kid = num_kid / 10
label variable age "Age"
label variable age2 "Age Square"
label variable CA_Gwelfare "Network"
label variable chld_p "Child Present"
label variable flag_college "College"
label variable single_mom "Single Mom"
label variable white "White"
label variable num_kid "No. Kid"
label variable foreign_born "Immigrant"
label variable eng_flu "English Mastery"

//qui xi: reg welfare CA_Gwelfare age age2 chld_p flag_college single_mom white num_kid foreign_born eng_flu i.j_id i.k_id
//eststo ols_reg_CA_iso
qui xi: logit welfare CA_Gwelfare age age2 chld_p flag_college single_mom num_kid foreign_born eng_flu i.j_id i.k_id
margin, dydx(CA_Gwelfare age age2 chld_p flag_college single_mom num_kid foreign_born eng_flu) post
eststo logit_reg_CA_iso


use "$data_dir\clean_data_US", clear
gen age2 = age^2
egen max_age2 = max(age2)
egen max_age = max(age)
egen max_kid = max(num_kid)
replace age = age / 100
replace age2 = age2 / 1000
replace num_kid = num_kid / 10
label variable age "Age"
label variable age2 "Age Square"
label variable CA_Gwelfare "Network"
label variable chld_p "Child Present"
label variable flag_college "College"
label variable single_mom "Single Mom"
label variable white "White"
label variable num_kid "No. Kid"
label variable foreign_born "Immigrant"
label variable eng_flu "English Mastery"
//qui xi: reg welfare CA_Gwelfare age age2 chld_p flag_college single_mom white num_kid foreign_born eng_flu i.j_id i.k_id
//eststo ols_reg_US
qui xi: logit welfare CA_Gwelfare age age2 chld_p flag_college single_mom num_kid foreign_born eng_flu i.j_id i.k_id
margin, dydx(CA_Gwelfare age age2 chld_p flag_college single_mom num_kid foreign_born eng_flu) post
eststo logit_reg_US
estout ols_reg_CA logit_reg_CA logit_reg_CA_iso logit_reg_US using "$table_dir\table4.tex",style(tex) cells(b(star fmt(3)) se(fmt(3))) stats(r2 N, fmt(%9.3f %9.0g) labels(R-squared)) ///
mlabels("OLS-CA" "Logit-CA" "Logit-CA All Language" "Logit-US") ///
keep(CA_Gwelfare age age2 chld_p flag_college single_mom num_kid foreign_born eng_flu) starlevels(* 0.10 ** 0.05 *** 0.01) ///
topfile("$table_dir\table4_topf.tex") label bottomfile("$table_dir\table4_botf.tex") eqlabels(none) type legend replace
*/

