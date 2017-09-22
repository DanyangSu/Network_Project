clear
data_dir = 'E:\Dropbox\papers\network\matlab_code';
choice_data_t = my_import(data_dir,'choice_data',1,[]);
ij_data_t = my_import(data_dir,'ij_data',1,[]);
k_data = my_import(data_dir,'k_data',1,[]);
j_data = my_import(data_dir,'j_data',1,[]);
jk_data = my_import(data_dir,'jk_data',1,[]);
s_data = my_import(data_dir,'s_data',0,'share_mat');
iv_data_t = my_import(data_dir,'iv_data',1,[]);
clear data_dir

save raw_clean
