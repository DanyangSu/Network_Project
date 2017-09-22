clear
load raw_clean
ij_data = ij_data_t;
choice_data = choice_data_t;
size_i = size(ij_data,1);
    age = ij_data(:,1);
    age2 = age.^2;
    age = age / max(age);
    age2 = age2 / max(age2);
    flag_child_p = ij_data(:,2); %p
    flag_college = ij_data(:,3); %c
    flag_single_mom = ij_data(:,5); %s
    num_child = ij_data(:,8);
    num_child = num_child / max(num_child);
    flag_immi = ij_data(:,9);
    flag_eng = ij_data(:,10);
    j_id = ij_data(:,12);

    net_jk = jk_data(:,1);
    k_id = choice_data(:,end);
    
    net = zeros(size_i,1);
    for i=1:max(j_id)
        for j=1:max(k_id)
            net(j_id==i&k_id==j) = net_jk((i-1)*max(k_id)+j);
        end
    end
    
    
    welfare = choice_data(:,7);
    jk_id = grp2idx(j_id*100 + k_id);
    z = [age age2 flag_college flag_child_p flag_single_mom num_child flag_immi flag_eng];
    l_j = zeros(size_i,max(j_id));
    for i=1:max(j_id)
        l_j(:,i) = i==j_id;
    end
    
        l_k = zeros(size_i,max(k_id));
    for i=1:max(k_id)
        l_k(:,i) = i==k_id;
    end
    
        l_jk = zeros(size_i,max(jk_id));
    for i=1:max(jk_id)
        l_jk(:,i) = i==jk_id;
    end
    
    
    
    x1 = [net z l_j(:,2:end) l_k];
    y = welfare;
    beta1 = (x1'*x1)\(x1'*y);
    beta1(1)
    
    x2 = [z l_jk];
    beta2 = (x2'*x2)\(x2'*y);
    y2 = beta2(9:end);
    x22 = jk_data;
    x22(:,2) = 1; %add a constant term
    beta22 = (x22'*x22)\(x22'*y2);
    beta22(1)
    
    
    
    