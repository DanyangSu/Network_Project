function [obj,prob_cond_parti] = MLE_est(theta,s,z,zx_sim,size_k,size_i,size_j,...
    size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,p_condition_participate)
% theta: parameters
% moment_t: true moment
% s: share data
% z: individual data
% zx_sim: interaction term data, grouped for location variable
% zx_sim_var: interaction term data, grouped for each variable 
% flag_j_id: language group identifier
% flag_d_id: decision identifier
% method_GMM: GMM if 1, MLE if 0
    %% Generate utility terms
    global delta_old
    delta_old(isnan(delta_old)) = 0;
    delta_old = 0.5 * delta_old; % start from relatively smaller scale
    gamma = reshape(theta(1:size_zx),[],1); % gamma is for interaction terms
    eta = reshape(theta(size_zx+1:size_zx+size_z),[],1); % eta is for individual terms
    half_size_zx = size_zx / 2;
    u_k1 = zeros(size_i,size_k);
    u_k2 = zeros(size_i,size_k);
    for i=1:size_k
        X = zx_sim{i};
        u_k1(:,i) = X(:,1:half_size_zx) * gamma(1:half_size_zx);
        u_k2(:,i) = X(:,half_size_zx+1:size_zx) * gamma(half_size_zx+1:size_zx);
    end
    u_i = z * eta;
    u = [u_k1 + u_k2 + repmat(u_i,1,size_k) u_k1]; % [participation non-participation]
    %% Find delta
    distance = 1;
    counter = 0;
    while distance > 0.001
        delta = zeros(size_i,2*size_k);
        for i=1:size_j
            delta(flag_j_id{i},:) = repmat(delta_old(i,:),sum_flag_j_id(i),1); % assign delta for each i
        end
        eu = exp(u+delta); %exponential of utility
        sum_eu = repmat(sum(eu,2),1,2*size_k);
        p = eu ./ sum_eu;
        s_delta = zeros(size_j,2*size_k); %simulated share
        for j=1:size_j
            s_delta(j,:) = sum(p(flag_j_id{j},:)) / sum_flag_j_id(j);
        end
        delta_new = delta_old + log(s) - log(s_delta);
        norm_delta_new = delta_new - repmat(delta_new(:,end),1,2*size_k); % normalize for the end
        distance = max(max(abs(norm_delta_new - delta_old)));
        delta_old = (norm_delta_new + delta_old) / 2;
        counter = counter + 1;
        if counter > 10000
            error('May not converge');
        end
    end
    L = log(sum(p.*flag_d_id,2));
    obj = -sum(L);
    if p_condition_participate==1
        pk = p(:,1:size_k) + p(:,size_k+1:end);
        flag_k_id = flag_d_id(:,1:size_k) + flag_d_id(:,size_k+1:end);
        prob_k = sum(pk.*flag_k_id,2);
        prob_d = sum(p(:,1:size_k).*flag_k_id,2); %for people who choose k, the probability of choosing welfare
        prob_cond_parti = prob_d ./ prob_k;
    else
        prob_cond_parti = [];
    end
end
        
        