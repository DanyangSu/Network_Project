function Z = get_IV(sample_weight,flag_j_id,delta_iv,sum_flag_j_id,theta,zx_sim,z,size_i,size_j,size_k,size_zx,size_z,j_welf,pd,jkCA,lambda,iv_method,spec_CA)
    delta = zeros(size_i,2*size_k);
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
    for i=1:size_j
        delta(flag_j_id{i},:) = repmat(delta_iv(i,:),sum_flag_j_id(i),1); % assign delta for each i
    end
    eu = exp(u+delta); %exponential of utility
    sum_eu = repmat(sum(eu,2),1,2*size_k);
    p = eu ./ sum_eu;
    w = repmat(sample_weight,1,2*size_k);
    s_delta = zeros(size_j,2*size_k); %simulated share
    for j=1:size_j
        s_delta(j,:) = sum(p(flag_j_id{j},:).*w(flag_j_id{j},:)) / sum(sample_weight(flag_j_id{j})); %reweight, since CA is for all populations.
    end
    %% Generate second stage data
    pop_density = repmat(pd',size_j,1);
    size_jk = size_j * size_k;
    if iv_method==1 %simulate for share in k
        s_k = s_delta(:,1:size_k) + s_delta(:,size_k+1:end);
        CA = log(s_k ./ pop_density);
        j_welfare = repmat(j_welf,1,size_k);
        CA_welfare = CA .* j_welfare;
        jk_CA_welfare = [reshape(CA_welfare',[],1);reshape(CA_welfare',[],1)];
        pjk_CA_welfare = jk_CA_welfare;
        pjk_CA_welfare(size_jk+1:end) = 0;
        jk_CA = [reshape(CA',[],1);reshape(CA',[],1)];
        pjk_CA = jk_CA;
        pjk_CA(size_jk+1:end) = 0;
    elseif iv_method==2 %simulate for share in p
        s_p = sum(s_delta(:,1:size_k),2);
        jk_CA = [jkCA;jkCA];
        pjk_CA = jk_CA;
        pjk_CA(size_jk+1:end) = 0;
        j_welfare = repmat(s_p,1,size_k);
        CA_welfare = reshape(jkCA,size_k,size_j)' .* j_welfare;
        jk_CA_welfare = [reshape(CA_welfare',[],1);reshape(CA_welfare',[],1)];
        pjk_CA_welfare = jk_CA_welfare;
        pjk_CA_welfare(size_jk+1:end) = 0;
    else %simulate for share in kp
        s_k = s_delta(:,1:size_k) + s_delta(:,size_k+1:end);
        CA = log(s_k ./ pop_density);
        s_p = sum(s_delta(:,1:size_k),2);
        j_welfare = repmat(s_p,1,size_k);
        CA_welfare = CA .* j_welfare;
        jk_CA_welfare = [reshape(CA_welfare',[],1);reshape(CA_welfare',[],1)];
        pjk_CA_welfare = jk_CA_welfare;
        pjk_CA_welfare(size_jk+1:end) = 0;
        jk_CA = [reshape(CA',[],1);reshape(CA',[],1)];
        pjk_CA = jk_CA;
        pjk_CA(size_jk+1:end) = 0;
    end
    if spec_CA==0 %no CA
        Z = [pjk_CA_welfare lambda];
    elseif spec_CA==1 %same CA
        Z = [pjk_CA_welfare pjk_CA lambda];
    elseif spec_CA==2 %different CA
        Z = [pjk_CA_welfare jk_CA pjk_CA lambda];
    else
        error('must be 0, 1, or 2')
    end
end