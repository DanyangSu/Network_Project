% obselete need revise
clear
clc
size_k = 9;
size_i = 10^5;
size_j = 8;
size_v = 4; %number of interaction individual
size_vk = 4; %number of interaction k
size_iv = 7; %number of individual variables
delta_jk = [randn(size_j,2*size_k-1) zeros(size_j,1)];

%% Generate language index
j_rand = rand(size_i,1);
j_id = ones(size_i,1);
for i=1:size_j-1
    j_flag = j_rand > i/size_j;
    j_id(j_flag) = i + 1;
end

%% Generate delta for each i
delta_i = zeros(size_i,2*size_k);
for i=1:size_j
    flag_j = j_id==i;
    delta_i(flag_j,:) = repmat(delta_jk(i,:),sum(flag_j),1);
end

%% Generate interaction variable data
k_data = rand(size_k,size_vk);
ind_k = rand(size_i,size_v) > 0.3;
inter_term = cell(size_k,1);
for k = 1:size_k  
    kpk = zeros(size_i,size_v*size_vk);
    for i = 1:size_v
        for j = 1:size_vk
            kpk(:,(i-1)*size_vk+j) = ind_k(:,i) * k_data(k,j);
        end
    end
    inter_term{k} = kpk;
end

%% Generate individual variable data
ind_v = rand(size_i,size_iv-2) > 0.4;
ind_age = rand(size_i,1);
ind_age2 = ind_age.^2;
ind_v = [ind_age ind_age2 ind_v];

%% Generate coef
gamma = randn(size_v*size_vk,1);
eta = randn(size_iv,1);

%% Generate p;
p = zeros(size_i,2*size_k);
itk = [inter_term;inter_term];
for k = 1:2*size_k
    sl = itk{k} * gamma;
    ss = (ind_v * eta);
    p(:,k) = exp(sl + ss*(k<=size_k) + delta_i(:,k));
end
p = p ./ repmat(sum(p,2),1,2*size_k);
pp = cumsum(p,2);
pp(:,end) = 1;
global test_p
test_p = p;

%% Generate decision
choice_rand = rand(size_i,1);
choice = ones(size_i,1);
choice_k = repmat(k_data(1,:),size_i,1);
kk_data = [k_data;k_data];
for i=1:2*size_k-1
    flag_choice = choice_rand > pp(:,i);
    choice(flag_choice) = i + 1;
    choice_k(flag_choice,:) = repmat(kk_data(i+1,:),sum(flag_choice),1);
end

%% Generate k moment
moment_k_t = zeros(size_v*size_vk,1);
kpk_t = zeros(size_i,size_v*size_vk);
for i=1:size_v
    for j=1:size_vk
        kpk_t(:,(i-1)*size_vk+j) = ind_k(:,i) .* choice_k(:,j);
        moment_k_t((i-1)*size_vk+j) = mean(kpk_t(:,(i-1)*size_vk+j));
    end
end
    
%% Generate ind moment
flag_p_t = choice<=size_k;
ind_v_t = ind_v;
ind_v_t(~flag_p_t,:) = 0;
moment_ind_t = mean(ind_v_t)';

%% Generate s
s = zeros(size_j,2*size_k);

for j=1:size_j
    for k=1:2*size_k
        flag_jk = j_id==j & choice==k;
        s(j,k) = sum(flag_jk) / sum(j_id==j);
    end
end


%% Run GMM
theta_t = [gamma;eta];
moment_t = [moment_k_t' moment_ind_t'];
z = ind_v;
zx_sim = inter_term;
size_z = size_iv;
size_zx = size_v * size_vk;
zx_sim_var = cell(size_zx,1);
for zx=1:size_zx
    temp_zx = zeros(size_i,size_k);
    for k=1:size_k
        zx_k = zx_sim{k};
        temp_zx(:,k) = zx_k(:,zx);
    end
    zx_sim_var{zx} = temp_zx;
end
flag_d_id = zeros(size_i,2*size_k);
for k=1:2*size_k
    flag_d_id(:,k) = choice==k;
end
method_GMM = 1;
flag_j_id = cell(size_j,1);
sum_flag_j_id = zeros(size_j,1);
for i=1:size_j
    flag_j_id{i} = j_id==i;
    sum_flag_j_id(i) = sum(flag_j_id{i});
end
d_id = cell(size_j,2*size_k);
for i=1:2*size_k
    for j=1:size_j
        d_id{j,i} = choice==i & j_id==j;
    end
end
flag_k_id = cell(size_k,1);
k_id = choice;
k_id(k_id>size_k) = k_id(k_id>size_k) - size_k;
for i=1:size_k
    flag_k_id{i} = k_id==i;
end
flag_p_id = choice<=size_k;
global count
count = 0;
global delta_old
delta_old = [randn(size_j,2*size_k-1) zeros(size_j,1)];
M_t = GMM(theta_t,moment_t,s,z,zx_sim,zx_sim_var,size_k,size_i,size_j,...
    size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,method_GMM);
theta_1 = theta_t + 0.1*randn(size_zx+size_iv,1);
M_1 = GMM(theta_1,moment_t,s,z,zx_sim,zx_sim_var,size_k,size_i,size_j,...
    size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,method_GMM);
theta_01 = theta_t + 0.01*randn(size_zx+size_iv,1);
M_01 = GMM(theta_01,moment_t,s,z,zx_sim,zx_sim_var,size_k,size_i,size_j,...
    size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,method_GMM);
fprintf('%4.5f %4.5f %4.5f\n',M_t,M_01,M_1);
fprintf('%4.5f %4.5f\n',(M_01-M_t)/M_t,(M_1-M_t)/M_t);
obj = @(theta) GMM(theta,moment_t,s,z,zx_sim,zx_sim_var,size_k,size_i,size_j,...
    size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,method_GMM);

t_max = 10;
t_std = 5;
size_reg = size_zx + size_iv;
theta_trial = t_std * reshape(randn(size_reg,1),[],1);
theta_trial(theta_trial > t_max) = t_max;
theta_trial(theta_trial < -t_max) = -t_max;
opt.algorithm = NLOPT_LN_BOBYQA;
opt.min_objective = obj;
opt.xtol_rel = 1e-7;
opt.verbose = 1;
xopt = nlopt_optimize(opt,theta_trial);












