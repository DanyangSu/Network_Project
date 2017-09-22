function [s,z,zx_sim,size_z,size_zx,flag_j_id,sum_flag_j_id,flag_d_id,size_i,size_j,size_k,sample_weight,pop_density,j_welfare,jkCA,X1,X2,X3]...
    = clean_data(choice_data_t,ij_data_t,j_data,jk_data,k_data,s_data,iv_data_t,rand_flag)
% variables to be normalized: age, age2, num_child, k_* from k_data and
% k_* from choice_data

    size_j = length(j_data.j_id);
    size_k = length(k_data.k_id);
    size_i = length(ij_data_t.age);
    i_id = (1:size_i);
    no_all_loc = true; %resample until see observations in all places
    if rand_flag == 1
        while no_all_loc
            rand_i_id = zeros(size_i,1);
            i_index = 1;
            for loop_j=1:size_j %resample by language group
                j_flag = ij_data_t.j_id == loop_j;
                i_id_j = i_id(j_flag);
                rand_i_id(i_index:i_index+length(i_id_j)-1) = randsample(i_id_j,length(i_id_j),1);
                i_index = i_index + length(i_id_j);
            end
            ij_data = get_rand_data(ij_data_t,rand_i_id); 
            choice_data = get_rand_data(choice_data_t,rand_i_id);
            iv_data = get_rand_data(iv_data_t,rand_i_id);
            sample_weight = iv_data.sample_weight;
            flag_jk_sample = zeros(size_j,size_k);
            for j=1:size_j
                for k=1:size_k
                    flag_jk_sample(j,k) = sum(choice_data.j_id==j & choice_data.k_id==k) > 0;
                end
            end   
            no_all_loc = sum(sum(flag_jk_sample)) < size_k*size_j;
        end
    else
        ij_data = ij_data_t;
        choice_data = choice_data_t;
        iv_data = iv_data_t;
        sample_weight = iv_data.sample_weight;
    end


    %% individual data z
    
    z = [ij_data.age ij_data.age2_100 ij_data.flag_college ij_data.married ...
        ij_data.chld_p ij_data.single_mom ij_data.num_kid ij_data.eng_flu];
    size_z = size(z,2);


    %% simulated interaction data zx_sim
    size_k_var = 4;
    size_i_var = 4;
    k_var_name = cell(size_k_var,1);
    k_var_name{1} = 'k_pvt';
    k_var_name{2} = 'k_black';
    k_var_name{3} = 'k_employ';
    k_var_name{4} = 'k_mp_occu';
    i_var_name = cell(size_i_var,1);
    i_var_name{1} = 'chld_p';
    i_var_name{2} = 'single_mom';
    i_var_name{3} = 'eng_flu';
    i_var_name{4} = 'flag_college';
    
%     i_var_j_mean = zeros(size_i_var,size_j); %contain mean for each language group
%     ij_mean_mat = zeros(size_i,size_i_var);
%     for j=1:size_j
%         flag_ij = ij_data.j_id==j;
%         for i=1:size_i_var
%             eval(sprintf('i_var_j_mean(i,j) = mean(ij_data.%s(flag_ij));',i_var_name{i}));
%             ij_mean_mat(flag_ij,i) = i_var_j_mean(i,j);
%         end
%     end

    size_zx = size_k_var *size_i_var * 2; %number of interaction terms, * 2 is for welfare and non-welfare
    zx_sim = cell(size_k,1);
    for k = 1:size_k
        temp_data = zeros(size_i,size_zx/2);
        for i_iter = 1:size_i_var
            for k_iter = 1:size_k_var
                eval(sprintf('temp_data(:,(i_iter-1)*size_k_var+k_iter) = ij_data.%s * k_data.%s(%d);',i_var_name{i_iter},k_var_name{k_iter},k));
            end
        end
        zx_sim{k} = [temp_data temp_data];
    end
    
    %% Generate choice data
    choice_k_id = choice_data.k_id;
    choice_p_id = choice_data.welfare;
    choice_np_id = 1 - choice_p_id;
    flag_d_index = choice_k_id + size_k * choice_np_id;
    flag_d_id = zeros(size_i,2*size_k);
    for k=1:2*size_k
        flag_d_id(:,k) = flag_d_index==k;
    end
    
    %% Generate second stage data
    size_jk = size_j * size_k;
    j_mat = zeros(size_j*size_k,size_j-1);
    k_mat = zeros(size_j*size_k,size_k-1);
    for i = 1:size_j-1
        eval(sprintf('j_mat(:,%d) = jk_data.j%d;',i,i+1));
    end
    for i = 1:size_k-1
        eval(sprintf('k_mat(:,%d) = jk_data.k%d;',i,i+1));
    end
    jk_mat = [j_mat k_mat];
    jk = [jk_mat;jk_mat];
    jk_CA_welfare = [jk_data.CA_Gwelfare;jk_data.CA_Gwelfare];
    pjk_CA_welfare = jk_CA_welfare;
    pjk_CA_welfare(size_jk+1:end) = 0;
    jk_CA = [jk_data.CA;jk_data.CA];
    pjk_CA = jk_CA;
    pjk_CA(size_jk+1:end) = 0;
    lambda_jk = [ones(size_jk*2,1) jk];
    lambda_jkp = lambda_jk;
    lambda_jkp(size_jk+1:end,:) = 0;
    
    
    pop_density = k_data.pop_density;
    j_welfare = j_data.welfare;
    jkCA = jk_data.CA;

    X1 = [pjk_CA_welfare lambda_jk lambda_jkp];
    X2 = [pjk_CA_welfare pjk_CA lambda_jk lambda_jkp];
    X3 = [pjk_CA_welfare jk_CA pjk_CA lambda_jk lambda_jkp];
    

    %% Generate share data s, lang indicator flag_j_id, deci flag_k_id
    flag_j_id = cell(size_j,1);
    sum_flag_j_id = zeros(size_j,1);
    for i=1:size_j
        flag_j_id{i} = ij_data.j_id==i;
        sum_flag_j_id(i) = sum(flag_j_id{i});
    end  
    s = s_data.share_mat;
end
