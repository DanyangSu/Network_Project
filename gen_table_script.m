A = load('b_m.txt');
B = load('t_m.txt');
est_MLE = B(:,end-3);
theta_opt = B(est_MLE==min(est_MLE),:);
size_theta = 4 * 3 * 2 + 8;

%% Get First Stage Table Interaction for non-participants
size_row = 4; %k
size_col = 3; %z
size_reg_inter = size_row * size_col;
pick_id = 1:size_reg_inter;
[std_v, sig_v] = get_matrix(A(:,pick_id),theta_opt(pick_id),0);
std_m = reshape(std_v,size_row,size_col);
sig_m = reshape(sig_v,size_row,size_col);
theta_m = reshape(theta_opt(pick_id),size_row,size_col);
var_row_list = cell(size_row,1);
var_row_list{1} = 'Poverty Level';
var_row_list{2} = 'Black';
var_row_list{3} = 'Unemployment';
var_row_list{4} = 'Professional';
var_col_list = cell(size_col,1);
var_col_list{1} = 'Child Present';
var_col_list{2} = 'Single Mom';
var_col_list{3} = 'English Fluency';
permit = 'wt';
fid = fopen('E:\Dropbox\papers\network\table\table_zx_note.txt','r');
table_zx_note = fscanf(fid,'%c');
fclose(fid);
table_zx_top = '\\begin{table}[htbp]\\centering\\caption{Estimation of Coefficient on Individual Preference over Locations}\\label{tab:inter_est}\\small\\begin{tabular}';
table_zx_bot = sprintf('\\multicolumn{%.0g}{l}{* p<0.10, ** p<0.05, *** p<0.01}\n\\\\\n\\hline\n\\hline\n\\end{tabular}\n\\captionsetup{font=footnotesize, labelformat=empty, labelsep=none, margin={0in,0in}}\\caption{',size_col+1);
gen_tex_table(var_row_list,var_col_list,theta_m,std_m,sig_m,'E:\Dropbox\papers\network\table\table_zx.tex',permit,table_zx_top,table_zx_bot,table_zx_note,0);
reg_index = size_reg_inter;

%% Get First Stage Table Interaction for participants
size_row = 4; %k
size_col = 3; %z
size_reg_inter = size_row * size_col;
pick_id = reg_index + 1:reg_index + size_reg_inter;
[std_v, sig_v] = get_matrix(A(:,pick_id),theta_opt(pick_id),0);
std_m = reshape(std_v,size_row,size_col);
sig_m = reshape(sig_v,size_row,size_col);
theta_m = reshape(theta_opt(pick_id),size_row,size_col);
var_row_list = cell(size_row,1);
var_row_list{1} = 'Poverty Level';
var_row_list{2} = 'Black';
var_row_list{3} = 'Unemployment';
var_row_list{4} = 'Professional';
var_col_list = cell(size_col,1);
var_col_list{1} = 'Child Present';
var_col_list{2} = 'Single Mom';
var_col_list{3} = 'English Fluency';
permit = 'wt';
fid = fopen('E:\Dropbox\papers\network\table\table_zx1_note.txt','r');
table_zx1_note = fscanf(fid,'%c');
fclose(fid);
table_zx1_top = '\\begin{table}[htbp]\\centering\\caption{Estimation of Coefficient on Heterogeneous Effect of Geographic Characteristics}\\label{tab:inter_est1}\\small\\begin{tabular}';
table_zx1_bot = sprintf('\\multicolumn{%.0g}{l}{* p<0.10, ** p<0.05, *** p<0.01}\n\\\\\n\\hline\n\\hline\n\\end{tabular}\n\\captionsetup{font=footnotesize, labelformat=empty, labelsep=none, margin={0in,0in}}\\caption{',size_col+1);
gen_tex_table(var_row_list,var_col_list,theta_m,std_m,sig_m,'E:\Dropbox\papers\network\table\table_zx1.tex',permit,table_zx1_top,table_zx1_bot,table_zx1_note,0);
reg_index = reg_index + size_reg_inter;

%% Get First Stage Table Individual Panel
size_row = 1; %k
size_col = 4; %z
size_reg_ind1 = size_row * size_col;
pick_id = reg_index+1:reg_index+size_reg_ind1;
[std_v, sig_v] = get_matrix(A(:,pick_id),theta_opt(pick_id),0);
std_m = reshape(std_v,size_row,size_col);
sig_m = reshape(sig_v,size_row,size_col);
theta_m = reshape(theta_opt(pick_id),size_row,size_col);
var_row_list = cell(size_row,1);
var_row_list{1} = ' ';
var_col_list = cell(size_col,1);
var_col_list{1} = 'Age';
var_col_list{2} = '$\text{Age}^{2}$';
var_col_list{3} = 'College';
var_col_list{4} = 'Married';
permit = 'wt';
tableza_note = '';
tableza_top = '\\begin{table}[htbp]\\centering\\caption{Estimation of the Main Effect on Welfare Participation}\\label{tab:ind_est}\\small\\begin{tabular}';
tableza_bot = '';
gen_tex_table(var_row_list,var_col_list,theta_m,std_m,sig_m,'E:\Dropbox\papers\network\table\table_z.tex',permit,tableza_top,tableza_bot,tableza_note,0);
reg_index = reg_index + size_reg_ind1;

size_row = 1; %k
size_col = 4; %z
size_reg_ind2 = size_row * size_col;
pick_id = reg_index+1:reg_index+size_reg_ind2;
[std_v, sig_v] = get_matrix(A(:,pick_id),theta_opt(pick_id),0);
std_m = reshape(std_v,size_row,size_col);
sig_m = reshape(sig_v,size_row,size_col);
theta_m = reshape(theta_opt(pick_id),size_row,size_col);
var_row_list = cell(size_row,1);
var_row_list{1} = ' ';
var_col_list = cell(size_col,1);
var_col_list{1} = 'Child Present';
var_col_list{2} = 'Single Mom';
var_col_list{3} = 'Number of kids';
var_col_list{4} = 'English Fluency';
permit = 'at';
fid = fopen('E:\Dropbox\papers\network\table\table_z_note.txt','r');
tablezb_note = fscanf(fid,'%c');
fclose(fid);
tablezb_top = '\n\\\\';
tablezb_bot = sprintf('\\multicolumn{%.0g}{l}{* p<0.10, ** p<0.05, *** p<0.01}\n\\\\\n\\hline\n\\hline\n\\end{tabular}\n\\captionsetup{font=footnotesize, labelformat=empty, labelsep=none, margin={0in,0in}}\\caption{',size_col+1);
gen_tex_table(var_row_list,var_col_list,theta_m,std_m,sig_m,'E:\Dropbox\papers\network\table\table_z.tex',permit,tablezb_top,tablezb_bot,tablezb_note,1);
reg_index = reg_index + size_reg_ind2;

%% Get Second Stage Table
size_row = 3;
size_col = 3;
second_reg = -999 * ones(size_row*size_col,1);
second_reg(1) = theta_opt(reg_index+1);
second_reg(2) = theta_opt(reg_index+2);
second_reg(3) = theta_opt(reg_index+4);
second_reg(4) = theta_opt(reg_index+7);
second_reg(5) = theta_opt(reg_index+8);
second_reg(6) = theta_opt(reg_index+10);
second_reg(7) = theta_opt(reg_index+13);
second_reg(8) = theta_opt(reg_index+14);
second_reg(9) = theta_opt(reg_index+16);


second_A = zeros(size(A,1),size_row*size_col);
second_A(:,1) = A(:,reg_index+1);
second_A(:,2) = A(:,reg_index+2);
second_A(:,3) = A(:,reg_index+4);
second_A(:,4) = A(:,reg_index+7);
second_A(:,5) = A(:,reg_index+8);
second_A(:,6) = A(:,reg_index+10);
second_A(:,7) = A(:,reg_index+13);
second_A(:,8) = A(:,reg_index+14);
second_A(:,9) = A(:,reg_index+16);
[std_v, sig_v] = get_matrix(second_A,second_reg,0);
std_m = reshape(std_v,size_col,size_row)';
sig_m = reshape(sig_v,size_col,size_row)';
theta_m = reshape(second_reg,size_col,size_row)';
var_row_list = cell(size_row,1);
var_row_list{1} = 'Network: OLS';
var_row_list{2} = 'Network: IV (Network)';
var_row_list{3} = 'Network: IV (Network and Welfare)';
var_col_list = cell(size_col,1);
var_col_list{1} = '(I)';
var_col_list{2} = '(II)';
var_col_list{3} = '(III)';
permit = 'wt';
fid = fopen('E:\Dropbox\papers\network\table\table_2nd_note.txt','r');
table_2nd_note = fscanf(fid,'%c');
fclose(fid);
table_2nd_top = '\\begin{table}[htbp]\\centering\\caption{Estimation of Average Marginal Effect of Network}\\label{tab:2nd_est}\\small\\begin{tabular}';
table_2nd_bot = sprintf('\\\\\nCA & No & Yes & Yes \\\\\n CA on Welfare & No & No & Yes \\\\\n\\multicolumn{%.0g}{l}{* p<0.10, ** p<0.05, *** p<0.01}\n\\\\\n\\hline\n\\hline\n\\end{tabular}\n\\captionsetup{font=footnotesize, labelformat=empty, labelsep=none, margin={0in,0in}}\\caption{',size_col+1);
gen_tex_table(var_row_list,var_col_list,theta_m,std_m,sig_m,'E:\Dropbox\papers\network\table\table_2nd.tex',permit,table_2nd_top,table_2nd_bot,table_2nd_note,0);


