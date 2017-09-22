set more off
use "$data_dir\temp_clean_data", clear
replace k_single_mom = k_single_mom*100
replace k_mp_occu = k_mp_occu*100
tabout msapmsa using "$table_dir\table_loc.tex", ///
c(mean num_msa mean k_pvt mean k_employ mean k_mp_occu mean k_black mean k_chld_p mean k_single_mom mean k_welfare) ///
f(0c 2c 2c 2c 2c 2c 2c 2c) clab(Sample_Size Poverty_Level Unemployment_% Professional_% Black_% Child_Present Single_Mom_% Welfare_%) h2(nil) ///
sum rep font(9) ptotal(none) ///
style(tex) topf("$table_dir\table_loc_topf.tex") botf("$table_dir\table_loc_botf.tex") sort 


use "$data_dir\temp_clean_data_with_English", clear
gen num_kid_0 = .
replace num_kid_0 = num_kid if num_kid>0
replace welfare = welfare*100
replace single_mom = single_mom*100
replace flag_college = flag_college*100
tabout lang2 using "$table_dir\table_lang.tex", ///
c(mean freq_lang mean age mean chld_p mean flag_college mean married mean num_kid_0 mean single_mom mean eng_flu mean welfare) ///
f(0c 2c 2c 2c 2c 2c 2c 2c 2c 2c) clab(Sample_Size Age Child_Present College_% Married No._Kid(>0) Single_Mom_% English_Fluency Welfare_%) h2(nil) ///
sum rep font(9) rotate(60) ptotal(none) ///
style(tex) topf("$table_dir\table_lang_topf.tex") botf("$table_dir\table_lang_botf.tex") sort 


/*
label define msapmsa 360 "OC", modify
label define msapmsa 4480 "LA-LB", modify
label define msapmsa 5775 "Oakland", modify
label define msapmsa 6780 "Riverside-SB", modify
label define msapmsa 6920 "Sacramento", modify
label define msapmsa 7320 "SD", modify
label define msapmsa 7360 "SF", modify
label define msapmsa 7400 "SJ", modify
gen eCA = exp(CA)
tabout lang2 msapmsa using "$table_dir\table3.tex", ///
c(mean eCA) f(3c) rep font(6) sum ptotal(none) ///
style(tex) topf("$table_dir\table3_topf.tex") h3(nil) botf("$table_dir\table3_botf.tex") 


gen w100 = welfare * 100
tabout lang2 msapmsa using "$table_dir\table_pk.tex", ///
c(mean w100) f(2p) rep font(6) sum ptotal(none) ///
style(tex) topf("$table_dir\table_pk_topf.tex") h3(nil) botf("$table_dir\table_pk_botf.tex") 
*/


use "$data_dir\temp_clean_data", clear
gen num_kid_0 = .
replace num_kid_0 = num_kid if num_kid>0
replace welfare = welfare*100
replace single_mom = single_mom*100
replace flag_college = flag_college*100
replace foreign_born = foreign_born*100
gen number = 1
label var welfare "Welfare"
label define welfare 0 "No", add
label define welfare 100 "Yes", add
label values welfare welfare
tabout welfare using "$table_dir\table_w.tex", ///
c(count number mean chld_p mean flag_college mean married mean num_kid_0 mean single_mom mean eng_flu mean foreign_born) ///
f(0c 2c 2c 2c 2c 2c 2c 2c) clab(Freq. Child_Present College_% Married No._Kid(>0) Single_Mom_% English_Fluency Immigrant_%) h2(nil) ///
sum rep font(9) ptotal(none) ///
style(tex) topf("$table_dir\table_w_topf.tex") botf("$table_dir\table_w_botf.tex") sort 
