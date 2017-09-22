function [s_delta, p_part] = get_counterfact(theta,z,zx_sim,size_k,size_i,size_j,...
    size_z,size_zx,flag_j_id,sum_flag_j_id,delta_c,flag_hetgeo)
    %% Generate utility terms
    gamma = reshape(theta(1:size_zx),[],1); % gamma is for interaction terms
    eta = reshape(theta(size_zx+1:size_zx+size_z),[],1); % eta is for individual terms
    half_size_zx = size_zx / 2;
    u_k1 = zeros(size_i,size_k);
    u_k2 = zeros(size_i,size_k);
    for i=1:size_k
        X = zx_sim{i};
        u_k1(:,i) = X(:,1:half_size_zx) * gamma(1:half_size_zx);
        if flag_hetgeo==1
            u_k2(:,i) = X(:,half_size_zx+1:size_zx) * gamma(half_size_zx+1:size_zx);
        end
    end
    u_i = z * eta;
    u = [u_k1 + u_k2 + repmat(u_i,1,size_k) u_k1]; % [participation non-participation]
    %% Find delta
    delta = zeros(size_i,2*size_k);
    for i=1:size_j
        delta(flag_j_id{i},:) = repmat(delta_c(i,:),sum_flag_j_id(i),1); % assign delta for each i
    end
    eu = exp(u+delta); %exponential of utility
    sum_eu = repmat(sum(eu,2),1,2*size_k);
    p = eu ./ sum_eu;
    s_delta = zeros(size_j,2*size_k); %simulated share
    for j=1:size_j
        s_delta(j,:) = sum(p(flag_j_id{j},:)) / sum_flag_j_id(j);
    end
    p_part = sum(p(:,1:size_k),2);
end
        
        