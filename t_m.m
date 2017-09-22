%% Execution specification
% clear %no clear because it will erase rank
try 
    display(rank_id);
    local_machine = 0;
catch
    bootstrap_flag = 0; %1 random resample, 0 full data
    rank_id = 1;
    local_machine = 1;
end
if bootstrap_flag == 0
    save_data = 1;
else 
    save_data = 0;
end
%% Main code Starts
if bootstrap_flag == 1
    output_name = 'b_m.txt';
elseif bootstrap_flag == 0
    output_name = 't_m.txt';
else
    error('Either full sample or bootstrap');
end

if local_machine == 1
    addpath('E:\Dropbox\reference\utility\nlopt'); %path that contains the optimizer toolbox
    addpath('E:\Dropbox\reference\utility\nlopt\matlab');
    rank_id = 1;
elseif local_machine == 0
    pause on
    pause(rank_id) %rank is from linux command
    addpath('/hpchome/econ/ds293/utility/nlopt-2.4.2/octave'); %add optimizer to path
else
    error('Either local machine or cluster');
end

% run load_data
load raw_clean
rng('shuffle') 
init_rand = 1000*randn;
[s,z,zx_sim,size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,size_i,size_j,size_k,sample_weight,pop_density,j_welfare,jkCA,X1,X2,X3] = ...
    clean_data(choice_data_t,ij_data_t,j_data,jk_data,k_data,s_data,iv_data_t,bootstrap_flag);
p_condition_participate = 0; %1 if calculate conditional probability of participation given location

%% Stage one estimation
size_reg = size_z + size_zx;
global delta_old;
obj = @(theta) MLE_est(theta,s,z,zx_sim,size_k,size_i,size_j,...
    size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,p_condition_participate);
t_max = 10;
t_std = 5;
iter = 5;
theta_opt_iter = zeros(size_reg,iter);
f_min_iter = zeros(iter,1);
retcode_iter = zeros(iter,1);
iter_id = 1:iter;
for i=1:iter
    delta_old = [randn(size_j,2*size_k-1) zeros(size_j,1)];
    theta_trial = t_std * reshape(randn(size_reg,1),[],1);
    theta_trial(theta_trial > t_max) = t_max;
    theta_trial(theta_trial < -t_max) = -t_max;
    opt.algorithm = NLOPT_LN_BOBYQA;
    opt.min_objective = obj;
    opt.xtol_rel = 1e-7;
    if local_machine == 1
        opt.verbose = 1;
    end
    toi = nlopt_optimize(opt,theta_trial);
    opt.xtol_rel = 1e-9;
    [theta_opt_iter(:,i),f_min_iter(i),retcode_iter(i)] = nlopt_optimize(opt,toi);
end
if max(retcode_iter==1)>0
    pick_flag = f_min_iter==min(f_min_iter) & retcode_iter==1; %success with minimum f
else
    pick_flag = f_min_iter==min(f_min_iter);
end
pick_id = iter_id(pick_flag);
retcode = retcode_iter(pick_id);
theta_opt = theta_opt_iter(:,pick_id);
delta1 = delta_old(:,1:size_k);
delta0 = delta_old(:,size_k+1:end);
p_condition_participate = 1; 
[~,condi_prob] = MLE_est(theta_opt,s,z,zx_sim,size_k,size_i,size_j,...
    size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,p_condition_participate);

%% Stage two estimation
Y = [reshape(delta1',[],1);reshape(delta0',[],1)];
avg_marginal_multiplier = mean(condi_prob.*(1-condi_prob));

m_coef1 = (X1'*X1)\(X1'*Y);
beta_CA_welfare1 = avg_marginal_multiplier * m_coef1(1); %network

m_coef2 = (X2'*X2)\(X2'*Y);
beta_CA_welfare2 = avg_marginal_multiplier * m_coef2(1); %network
beta_pCA2 = avg_marginal_multiplier * m_coef2(2);

m_coef3 = (X3'*X3)\(X3'*Y);
beta_CA_welfare3 = avg_marginal_multiplier * m_coef3(1); %network
beta_CA3 = m_coef3(2);
beta_pCA3 = avg_marginal_multiplier * m_coef3(3);

%% IV estimation with Network of k simulated from model I
Y_tilda1 = X1(:,2:end) * m_coef1(2:end);
delta_tilda1 = [reshape(Y_tilda1(1:size_j*size_k),size_k,size_j)' reshape(Y_tilda1(size_j*size_k+1:end),size_k,size_j)'];
iv_method = 1;
spec_CA = 0;
Z1_k = get_IV(sample_weight,flag_j_id,delta_tilda1,sum_flag_j_id,theta_opt,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welfare,pop_density,jkCA,X1(:,2:end),iv_method,spec_CA);
m_coef1_IV_k = (Z1_k'*X1)\(Z1_k'*Y);
beta_IV_k_welfare1 = avg_marginal_multiplier * m_coef1_IV_k(1); %network

%% IV estimation with Network of k simulated from model II
Y_tilda2 = X2(:,3:end) * m_coef2(3:end);
delta_tilda2 = [reshape(Y_tilda2(1:size_j*size_k),size_k,size_j)' reshape(Y_tilda2(size_j*size_k+1:end),size_k,size_j)'];
iv_method = 1;
spec_CA = 1;
Z2_k = get_IV(sample_weight,flag_j_id,delta_tilda2,sum_flag_j_id,theta_opt,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welfare,pop_density,jkCA,X2(:,2:end),iv_method,spec_CA);
m_coef2_IV_k = (Z2_k'*X2)\(Z2_k'*Y);
beta_IV_k_welfare2 = avg_marginal_multiplier * m_coef2_IV_k(1); %network
beta_IV_k_pCA2 = avg_marginal_multiplier * m_coef2_IV_k(2);

%% IV estimation with Network of k simulated from model III
Y_tilda3 = X3(:,3:end) * m_coef3(3:end);
delta_tilda3 = [reshape(Y_tilda3(1:size_j*size_k),size_k,size_j)' reshape(Y_tilda3(size_j*size_k+1:end),size_k,size_j)'];
iv_method = 1;
spec_CA = 2;
Z3_k = get_IV(sample_weight,flag_j_id,delta_tilda3,sum_flag_j_id,theta_opt,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welfare,pop_density,jkCA,X3(:,3:end),iv_method,spec_CA);
m_coef3_IV_k = (Z3_k'*X3)\(Z3_k'*Y);
beta_IV_k_welfare3 = avg_marginal_multiplier * m_coef3_IV_k(1); %network
beta_IV_k_CA3 = m_coef3_IV_k(2);
beta_IV_k_pCA3 = avg_marginal_multiplier * m_coef3_IV_k(3);


%% IV estimation with Network of kp simulated from model I
Y_tilda1 = X1(:,2:end) * m_coef1(2:end);
delta_tilda1 = [reshape(Y_tilda1(1:size_j*size_k),size_k,size_j)' reshape(Y_tilda1(size_j*size_k+1:end),size_k,size_j)'];
iv_method = 3;
spec_CA = 0;
Z1_k = get_IV(sample_weight,flag_j_id,delta_tilda1,sum_flag_j_id,theta_opt,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welfare,pop_density,jkCA,X1(:,2:end),iv_method,spec_CA);
m_coef1_IV_k = (Z1_k'*X1)\(Z1_k'*Y);
beta_IV_kp_welfare1 = avg_marginal_multiplier * m_coef1_IV_k(1); %network

%% IV estimation with Network of kp simulated from model II
Y_tilda2 = X2(:,3:end) * m_coef2(3:end);
delta_tilda2 = [reshape(Y_tilda2(1:size_j*size_k),size_k,size_j)' reshape(Y_tilda2(size_j*size_k+1:end),size_k,size_j)'];
iv_method = 3;
spec_CA = 1;
Z2_k = get_IV(sample_weight,flag_j_id,delta_tilda2,sum_flag_j_id,theta_opt,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welfare,pop_density,jkCA,X2(:,2:end),iv_method,spec_CA);
m_coef2_IV_k = (Z2_k'*X2)\(Z2_k'*Y);
beta_IV_kp_welfare2 = avg_marginal_multiplier * m_coef2_IV_k(1); %network
beta_IV_kp_pCA2 = avg_marginal_multiplier * m_coef2_IV_k(2);

%% IV estimation with Network of kp simulated from model III
Y_tilda3 = X3(:,3:end) * m_coef3(3:end);
delta_tilda3 = [reshape(Y_tilda3(1:size_j*size_k),size_k,size_j)' reshape(Y_tilda3(size_j*size_k+1:end),size_k,size_j)'];
iv_method = 3;
spec_CA = 2;
Z3_k = get_IV(sample_weight,flag_j_id,delta_tilda3,sum_flag_j_id,theta_opt,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welfare,pop_density,jkCA,X3(:,3:end),iv_method,spec_CA);
m_coef3_IV_k = (Z3_k'*X3)\(Z3_k'*Y);
beta_IV_kp_welfare3 = avg_marginal_multiplier * m_coef3_IV_k(1); %network
beta_IV_kp_CA3 = m_coef3_IV_k(2);
beta_IV_kp_pCA3 = avg_marginal_multiplier * m_coef3_IV_k(3);

%% Output
est_out = [reshape(theta_opt,1,[])...
    beta_CA_welfare1 beta_CA_welfare2 beta_pCA2 beta_CA_welfare3... %33 34 36
    beta_CA3 beta_pCA3...
    beta_IV_k_welfare1 beta_IV_k_welfare2 beta_IV_k_pCA2 beta_IV_k_welfare3 beta_IV_k_CA3... %39 40 42
    beta_IV_k_pCA3...                                     
    beta_IV_kp_welfare1 beta_IV_kp_welfare2 beta_IV_kp_pCA2 beta_IV_kp_welfare3 beta_IV_kp_CA3... %45 46 48
    beta_IV_kp_pCA3...
    min(f_min_iter) retcode...
    init_rand rank_id];
fileID = fopen(output_name,'at');
size_out = length(est_out);
for i=1:size_out
fprintf(fileID,'%5.7f ',est_out(i));
end
fprintf(fileID,'\n');
fclose(fileID);
if save_data == 1
    save data_for_debug
end
