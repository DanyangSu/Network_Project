%% Execution specification
% clear %no clear because it will erase rank
clc
bootstrap_flag = 0; %1 random resample, 0 full data
local_machine = 1; %1 if run on my machine, 0 on cluster
method_GMM = 0;

%% Main code Starts
if bootstrap_flag == 1 && method_GMM == 1
    output_name = 'b_g.txt';
elseif bootstrap_flag == 1 && method_GMM == 0
    output_name = 'b_m.txt';
elseif bootstrap_flag == 0 && method_GMM == 1
    output_name = 't_g.txt';
elseif bootstrap_flag == 0 && method_GMM == 0
    output_name = 't_m.txt';
else
    error('Either full sample or bootstrap');
end

if local_machine == 1
    addpath('C:\Users\Fno\Dropbox\reference\utility\nlopt'); %path that contains the optimizer toolbox
    addpath('C:\Users\Fno\Dropbox\reference\utility\nlopt\matlab');
elseif local_machine == 0
    addpath('/hpchome/econ/ds293/utility/nlopt-2.4.2/octave'); %add optimizer to path
else
    error('Either local machine or cluster');
end

% run load_data
load raw_clean
init_rand = 1000*randn;
s_flag = 0; %1 calculate from resample, 0 full data. Here has to be 0, as we have very few observation on certain location-participation.
[moment_t,s,z,zx_sim,zx_sim_var,size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,size_i,size_j,size_k,sample_weight,pop_density,j_welfare,jkCA,X1,X2,X3,X4,X5] = ...
    clean_data(choice_data_t,ij_data_t,j_data,jk_data,k_data,s_data,iv_data,s_flag,bootstrap_flag);
p_condition_participate = 0; %1 if calculate conditional probability of participation given location

%% Stage one estimation
size_reg = size_z;
global delta_old;
obj = @(theta) GMM(theta,moment_t,s,z,zx_sim,zx_sim_var,size_k,size_i,size_j,...
    size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,method_GMM,p_condition_participate);
t_max = 10;
t_std = 5;
iter = 1;
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
    if method_GMM == 1
        [theta_opt_iter(:,i),f_min_iter(i),retcode_iter(i)] = nlopt_optimize(opt,theta_trial);
    else
        toi = nlopt_optimize(opt,theta_trial);
        [theta_opt_iter(:,i),f_min_iter(i),retcode_iter(i)] = nlopt_optimize(opt,toi);
    end
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
method_GMM = 1;
[~,GMM_error,condi_prob] = GMM(theta_opt,moment_t,s,z,zx_sim,zx_sim_var,size_k,size_i,size_j,...
    size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,method_GMM,p_condition_participate);

%% Stage two estimation
Y = [reshape(delta1',[],1);reshape(delta0',[],1)];
avg_marginal_multiplier = mean(condi_prob.*(1-condi_prob));

m_coef1 = (X1'*X1)\(X1'*Y);
beta_CA_welfare1 = avg_marginal_multiplier * m_coef1(2); %network
p1 = get_p(X1,Y,m_coef1);

m_coef2 = (X2'*X2)\(X2'*Y);
beta_CA_welfare2 = avg_marginal_multiplier * m_coef2(2); %network
p2 = get_p(X2,Y,m_coef2);

m_coef3 = (X3'*X3)\(X3'*Y);
beta_CA_welfare3 = avg_marginal_multiplier * m_coef3(2); %network
beta_CA3 = m_coef3(3);
p3 = get_p(X3,Y,m_coef3);

m_coef4 = (X4'*X4)\(X4'*Y);
beta_CA_welfare4 = avg_marginal_multiplier * m_coef4(2); %network
beta_CA4 = m_coef4(3);
p4 = get_p(X4,Y,m_coef4);

m_coef5 = (X5'*X5)\(X5'*Y);
beta_CA_welfare5 = avg_marginal_multiplier * m_coef5(2); %network
beta_CA5 = m_coef5(3);
beta_CA_p5 = m_coef5(4);
p5 = get_p(X5,Y,m_coef5);

%% IV estimation with Network of k simulated from model I
Y_tilda1 = m_coef1(1) + X1(:,3:end) * m_coef1(3:end);
delta_tilda1 = [reshape(Y_tilda1(1:size_j*size_k),size_k,size_j)' reshape(Y_tilda1(size_j*size_k+1:end),size_k,size_j)'];
iv_method = 1;
spec_CA = 0;
Z1_k = get_IV(sample_weight,flag_j_id,delta_tilda1,sum_flag_j_id,theta_opt,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welfare,pop_density,jkCA,X1(:,3:end),iv_method,spec_CA);
m_coef1_IV_k = (Z1_k'*X1)\(Z1_k'*Y);
beta_IV_k_welfare1 = avg_marginal_multiplier * m_coef1_IV_k(2); %network
p1iv = get_p(X1,Y,m_coef1_IV_k,Z1_k);

%% IV estimation with Network of k simulated from model II
Y_tilda2 = m_coef2(1) + X2(:,3:end) * m_coef2(3:end);
delta_tilda2 = [reshape(Y_tilda2(1:size_j*size_k),size_k,size_j)' reshape(Y_tilda2(size_j*size_k+1:end),size_k,size_j)'];
iv_method = 1;
spec_CA = 0;
Z2_k = get_IV(sample_weight,flag_j_id,delta_tilda2,sum_flag_j_id,theta_opt,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welfare,pop_density,jkCA,X2(:,3:end),iv_method,spec_CA);
m_coef2_IV_k = (Z2_k'*X2)\(Z2_k'*Y);
beta_IV_k_welfare2 = avg_marginal_multiplier * m_coef2_IV_k(2); %network
p2iv = get_p(X2,Y,m_coef2_IV_k,Z2_k);

%% IV estimation with Network of k simulated from model III
Y_tilda3 = m_coef3(1) + X3(:,4:end) * m_coef3(4:end);
delta_tilda3 = [reshape(Y_tilda3(1:size_j*size_k),size_k,size_j)' reshape(Y_tilda3(size_j*size_k+1:end),size_k,size_j)'];
iv_method = 1;
spec_CA = 1;
Z3_k = get_IV(sample_weight,flag_j_id,delta_tilda3,sum_flag_j_id,theta_opt,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welfare,pop_density,jkCA,X3(:,4:end),iv_method,spec_CA);
m_coef3_IV_k = (Z3_k'*X3)\(Z3_k'*Y);
beta_IV_k_welfare3 = avg_marginal_multiplier * m_coef3_IV_k(2); %network
beta_IV_k_CA3 = m_coef3_IV_k(3);
p3iv = get_p(X3,Y,m_coef3_IV_k,Z3_k);

%% IV estimation with Network of k simulated from model VI
Y_tilda4 = m_coef4(1) + X4(:,4:end) * m_coef4(4:end);
delta_tilda4 = [reshape(Y_tilda4(1:size_j*size_k),size_k,size_j)' reshape(Y_tilda4(size_j*size_k+1:end),size_k,size_j)'];
iv_method = 1;
spec_CA = 1;
Z4_k = get_IV(sample_weight,flag_j_id,delta_tilda4,sum_flag_j_id,theta_opt,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welfare,pop_density,jkCA,X4(:,4:end),iv_method,spec_CA);
m_coef4_IV_k = (Z4_k'*X4)\(Z4_k'*Y);
beta_IV_k_welfare4 = avg_marginal_multiplier * m_coef4_IV_k(2); %network
beta_IV_k_CA4 = m_coef4_IV_k(3);
p4iv = get_p(X4,Y,m_coef4_IV_k,Z4_k);

%% IV estimation with Network of k simulated from model V
Y_tilda5 = m_coef5(1) + X5(:,5:end) * m_coef5(5:end);
delta_tilda5 = [reshape(Y_tilda5(1:size_j*size_k),size_k,size_j)' reshape(Y_tilda5(size_j*size_k+1:end),size_k,size_j)'];
iv_method = 1;
spec_CA = 2;
Z5_k = get_IV(sample_weight,flag_j_id,delta_tilda5,sum_flag_j_id,theta_opt,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welfare,pop_density,jkCA,X5(:,5:end),iv_method,spec_CA);
m_coef5_IV_k = (Z5_k'*X5)\(Z5_k'*Y);
beta_IV_k_welfare5 = avg_marginal_multiplier * m_coef5_IV_k(2); %network
beta_IV_k_CA5 = m_coef5_IV_k(3);
beta_IV_k_CAp5 = m_coef5_IV_k(4);
p5iv = get_p(X5,Y,m_coef5_IV_k,Z5_k);

%% Output
if local_machine == 1
    save data_for_debug
end
est_out = [reshape(theta_opt,1,[])...
    beta_CA_welfare1 beta_CA_welfare2 beta_CA_welfare3 beta_CA3 beta_CA_welfare4...
    beta_CA4 beta_CA_welfare5 beta_CA5 beta_CA_p5 beta_IV_k_welfare1...
    beta_IV_k_welfare2 beta_IV_k_welfare3 beta_IV_k_CA3 beta_IV_k_welfare4 beta_IV_k_CA4...
    beta_IV_k_welfare5 beta_IV_k_CA5 beta_IV_k_CAp5 p1 p2...
    p3 p4 p5 p1iv p2iv...
    p3iv p4iv p5iv GMM_error retcode...
    init_rand rank];
fileID = fopen(output_name,'at');
size_out = length(est_out);
for i=1:size_out
fprintf(fileID,'%5.7f ',est_out(i));
end
fprintf(fileID,'\n');
fclose(fileID);
