clear
clc

load raw_clean
rng('shuffle') 
init_rand = 1000*randn;
[s,z,zx_sim,size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,size_i,size_j,size_k,sample_weight,pop_density,j_welfare,jkCA,X1,X2,X3] = ...
    clean_data(choice_data_t,ij_data_t,j_data,jk_data,k_data,s_data,iv_data_t,0);

%% Establish Equilibrium
B = load('t_m.txt');
est_MLE = B(:,end-3);
theta_opt = B(est_MLE==min(est_MLE),1:size_zx + size_z);
global delta_old
delta_old = [randn(size_j,2*size_k-1) zeros(size_j,1)];
MLE_est(theta_opt,s,z,zx_sim,size_k,size_i,size_j,...
    size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,0);
delta1 = delta_old(:,1:size_k);
delta0 = delta_old(:,size_k+1:end);
Y = [reshape(delta1',[],1);reshape(delta0',[],1)];
m_coef1 = (X1'*X1)\(X1'*Y);
Y_tilda1 = X1(:,2:end) * m_coef1(2:end);
delta_tilda1 = [reshape(Y_tilda1(1:size_j*size_k),size_k,size_j)' reshape(Y_tilda1(size_j*size_k+1:end),size_k,size_j)'];
iv_method = 1;
spec_CA = 0;
Z1_k = get_IV(sample_weight,flag_j_id,delta_tilda1,sum_flag_j_id,theta_opt,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welfare,pop_density,jkCA,X1(:,2:end),iv_method,spec_CA);
m_coef1_IV_k = (Z1_k'*X1)\(Z1_k'*Y);

%% Counterfactual
pd = repmat(pop_density',size_j,1);
delta_t_error = Y - X1 * m_coef1_IV_k;
delta_c_error = delta_t_error;
delta_c_error(1:size_k*size_j) = delta_t_error(size_k*size_j+1:size_k*size_j*2);
delta_c_vec = X1 * m_coef1_IV_k + delta_c_error;
delta_c = [reshape(delta_c_vec(1:size_j*size_k),size_k,size_j)' reshape(delta_c_vec(size_j*size_k+1:end),size_k,size_j)'];
flag_hetgeo = 0;
[s_c, p_part_c] = get_counterfact(theta_opt,z,zx_sim,size_k,size_i,size_j,...
    size_z,size_zx,flag_j_id,sum_flag_j_id,delta_c,flag_hetgeo); %counter-factual share of each choice
s_t = s; %true share of each choice
st_t = s_t(:,1:size_k)+s_t(:,size_k+1:size_k*2); %true share of each location
st_c = s_c(:,1:size_k)+s_c(:,size_k+1:size_k*2); %counter-factual share of each location
n_t = st_t./pd; %true relative density
n_c = st_c./pd; %counter-factual relative density
n_t_norm = n_t./repmat(sum(n_t,2),1,size_k); %true relative density normalized
n_c_norm = n_c./repmat(sum(n_c,2),1,size_k); %counter-factual relative density normalized
sp_c = s_c(:,1:size_k); %counter-factual participation chance
sp_c_norm = sp_c./repmat(sum(sp_c,2),1,size_k); %counter-factual participation chance normalized
sp_t = s_t(:,1:size_k); %true participation chance
sp_t_norm = sp_t./repmat(sum(sp_t,2),1,size_k); %true participation chance normalized

sn_c = s_c(:,size_k+1:size_k*2); %counter-factual non-participation chance
sn_c_norm = sn_c./repmat(sum(sn_c,2),1,size_k); %counter-factual non-participation chance normalized
sn_t = s_t(:,size_k+1:size_k*2); %true non-participation chance
sn_t_norm = sn_t./repmat(sum(sn_t,2),1,size_k); %true non-participation chance normalized
sp_diff_perct = (sp_c - sp_t)./sp_t;
sp_diff_sign = (sp_c - sp_t)>0;
sp_rel_diff_sign = (sp_c_norm-sp_t_norm)>0;
[x_ax,y_ax]=meshgrid(1:8,1:9);
x_ax_norm = x_ax;
y_ax_norm = y_ax;
x_ax(~sp_diff_sign(:)) = [];
y_ax(~sp_diff_sign(:)) = [];
x_ax_norm(~sp_rel_diff_sign(:)) = [];
y_ax_norm(~sp_rel_diff_sign(:)) = [];

f1 = figure;
imagesc(n_t_norm)
set(gca,'Xtick',1:8,'XTickLabel',{'OC', 'LA-LB', 'Oakland', 'Riverside', 'Sacramento', 'SD', 'SF', 'SJ'})
ylabel('Language')
set(gca,'Ytick',1:9,'YTickLabel',{'Italian', 'French', 'Spanish', 'Chinese', 'Thai', 'Japanese', 'Mon-Khmer', 'Vietnamese', 'Tagalog'})
colorbar
colormap('jet')
print(f1,'CA','-dpng')

f2 = figure;
subplot(1,2,1)
imagesc(n_t_norm)
hold all
scatter(x_ax_norm,y_ax_norm,'k<')
xlabel('Location')
set(gca,'Xtick',1:8,'XTickLabel',{'OC', 'LA', 'OA', 'RI', 'SA', 'SD', 'SF', 'SJ'})
ylabel('Language')
set(gca,'Ytick',1:9,'YTickLabel',{'Ita', 'Fre', 'Spa', 'Chi', 'Tha', 'Jap', 'Mon', 'Vie', 'Tag'})
colorbar
colormap('jet')
subplot(1,2,2)
imagesc((sp_c_norm-sp_t_norm))
hold all
scatter(x_ax_norm,y_ax_norm,'k<')
xlabel('Location')
set(gca,'Xtick',1:8,'XTickLabel',{'OC', 'LA', 'OA', 'RI', 'SA', 'SD', 'SF', 'SJ'})
ylabel('Language')
set(gca,'Ytick',1:9,'YTickLabel',{'Ita', 'Fre', 'Spa', 'Chi', 'Tha', 'Jap', 'Mon', 'Vie', 'Tag'})
colorbar
colormap('jet')
print(f2,'compare.png','-dpng')

s_part = s_t(:,1:size_k);
s_part_norm = s_part./repmat(sum(s_part,2),1,size_k);
s_part_prct = s_part./st_t;
s_part_prct_norm = s_part_prct./repmat(sum(s_part_prct,2),1,size_k);
f3 = figure;
imagesc(s_part_prct_norm)
set(gca,'Xtick',1:8,'XTickLabel',{'OC', 'LA-LB', 'Oakland', 'Riverside', 'Sacramento', 'SD', 'SF', 'SJ'})
ylabel('Language')
set(gca,'Ytick',1:9,'YTickLabel',{'Italian', 'French', 'Spanish', 'Chinese', 'Thai', 'Japanese', 'Mon-Khmer', 'Vietnamese', 'Tagalog'})
colorbar
colormap('jet')
print(f3,'pcrt_p','-dpng')
sp_j_t = sum(s_part,2);
sp_j_c = sum(sp_c,2);
s_diff = sp_j_c - sp_j_t;
s_diff_pcrt = s_diff ./ sp_j_t;

% size_row = 9;
% size_col = 4;
% var_row_list = cell(size_row,1);
% var_row_list{1} = 'Italian';
% var_row_list{2} = 'French';
% var_row_list{3} = 'Spanish';
% var_row_list{4} = 'Chinese';
% var_row_list{5} = 'Thai';
% var_row_list{6} = 'Japanese';
% var_row_list{7} = 'Mon-Khmer';
% var_row_list{8} = 'Vietnamese';
% var_row_list{9} = 'Tagalog';
% var_col_list = cell(size_col,1);
% var_col_list{1} = 'On';
% var_col_list{2} = 'Off';
% var_col_list{3} = 'Diff.';
% var_col_list{4} = 'Diff. \%';
% theta = [sp_j_t sp_j_c s_diff, s_diff_pcrt] * 100;
% sig_m = 999 * ones(size(theta));
% permit = 'wt';
% fid = fopen('C:\Users\Fno\Dropbox\papers\network\table\table_count_note.txt','r');
% table_count_note = fscanf(fid,'%c');
% fclose(fid);
% table_count_top = '\\begin{table}[htbp]\\centering\\caption{Counter-factual Welfare Participation across Language Groups}\\label{tab:table_count}\\small\\begin{tabular}';
% table_count_bot = sprintf('\\multicolumn{%.0g}{l}{* p<0.10, ** p<0.05, *** p<0.01}\n\\\\\n\\hline\n\\hline\n\\end{tabular}\n\\captionsetup{font=footnotesize, labelformat=empty, labelsep=none, margin={0in,0in}}\\caption{',size_col+1);
% gen_tex_table(var_row_list,var_col_list,theta,0,sig_m,'C:\Users\Fno\Dropbox\papers\network\table\table_count.tex',permit,table_count_top,table_count_bot,table_count_note,0);
% 
% flag_hetgeo = 1;
% [~,p_part_t] = get_counterfact(theta_opt,z,zx_sim,size_k,size_i,size_j,...
%     size_z,size_zx,flag_j_id,sum_flag_j_id,delta_old,flag_hetgeo);
% 
% 
% f4 = figure;
% hist_count_t = hist(p_part_t,50);
% hist_prob_t = hist_count_t/sum(hist_count_t);
% hist_count_c = hist(p_part_c,50);
% hist_prob_c = hist_count_c/sum(hist_count_c);
% bar(0.02:0.02:1,hist_prob_t,'hist')
% axis([0 1 0 0.4])
% print(f4,'p_part','-dpng')
% 
% 
%     