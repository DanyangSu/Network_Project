clear
set more off
cd E:\data\PUMS_1990\5pct

capture program drop process
program define process

local ST=upper("`1'")

local dta_name "pums5_`1'.dta"

append using `dta_name', keep(gqinst pwgt1 msapmsa income6 age sex yearsch rspouse rownchld r18undr fertil english race lang1 lang2 ragechld pob)

keep if msapmsa < 9997

end
/*
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
*/
process ca
program drop process

gen num_US = _N
bysort msapmsa: gen num_msa = _N

keep if lang1 == 1
keep if gqinst != 1

//drop if lang2 == 625
bysort lang2: gen num_lang = _N
drop if num_lang < 1000 //seems sensitive if I choose 10000 or 50000
keep if age <= 55 & age >=15
keep if sex == 1

gen white = 0
replace white = 1 if race == 1
gen black = 0
replace black = 1 if race == 2

gen chinese = 0
replace chinese = 1 if lang2 == 708
gen japanese = 0
replace japanese = 1 if lang2 == 723
gen french = 0
replace french = 1 if lang2 == 620
gen spanish = 0
replace spanish = 1 if lang2 == 625
gen portuguese = 0
replace portuguese = 1 if lang2 == 629
gen polish = 0
replace polish = 1 if lang2 == 645
gen korean = 0
replace korean = 1 if lang2 == 724
gen vietnamese = 0
replace vietnamese = 1 if lang2 == 728
gen tagalog = 0
replace tagalog = 1 if lang2 == 742
gen german = 0
replace german = 1 if lang2 == 607
gen italian = 0
replace italian = 1 if lang2 == 619


gen welfare = 0
replace welfare = 1 if income6 > 0
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
gen separate = 0
replace separate = 1 if rspouse == 5
gen never_m = 0
replace never_m = 1 if rspouse == 6

gen chld_p = 0
replace chld_p = 1 if ragechld>0 & ragechld<4
gen num_kid = fertil - 1
gen foreign_born = 0
replace foreign_born = 1 if pob > 59
gen eng_flu = 0
replace eng_flu = 1 if english < 3
gen single_mom = 0
replace single_mom = 1 if ragechld>0 & ragechld<4 & rspouse > 1
bysort lang2: egen mean_welfare = mean(welfare)
bysort lang2 msapmsa: gen msa_num_lang = _N
gen CA = log((msa_num_lang/num_lang)/(num_msa/num_US))
gen age2_100 = age^2/100
gen CA_Gwelfare = CA*mean_welfare
bysort lang2 msapmsa: egen msa_welfare = mean(welfare)
gen CA_Lwelfare = CA*msa_welfare

qui reg welfare CA_Gwelfare CA HS_drop HS_degree some_college single_mom chld_p num_kid m_sa widow divorce separate never_m age age2_100 white black i.msapmsa i.lang2
est store global
qui reg welfare CA_Lwelfare CA HS_drop HS_degree some_college single_mom chld_p num_kid m_sa widow divorce separate never_m age age2_100 white black i.msapmsa i.lang2
est store local
qui reg welfare CA_Gwelfare CA_Lwelfare CA HS_drop HS_degree some_college single_mom chld_p num_kid m_sa widow divorce separate never_m age age2_100 white black i.msapmsa i.lang2
est store both
qui reg welfare CA_Gwelfare CA_Lwelfare CA HS_drop HS_degree some_college single_mom chld_p num_kid age age2_100 white black i.msapmsa i.lang2
est store simple
est table global local both simple, keep(CA_Gwelfare CA_Lwelfare CA HS_drop HS_degree some_college single_mom chld_p num_kid m_sa widow divorce separate never_m age age2_100 white black) b se

