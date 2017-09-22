/* This is the master file */

clear
set more off
global script_dir "E:\Dropbox\papers\network\stata_code\iter3"
global data_dir "E:\data\PUMS_1990\5pct"
global table_dir "E:\Dropbox\papers\network\table"
global matlab_dir "E:\Dropbox\papers\network\matlab_code"

capture log close
log using "$script_dir\CA", replace

do "$script_dir\clean_CA"
do "$script_dir\sum_table"
do "$script_dir\clean_US"
do "$script_dir\baseline_analysis"
do "$script_dir\gen_matlab_data"


log close

