function [std_m, sig_m] = get_matrix(bootstrap_mat,theta_opt,flag_p)
    size_v = size(bootstrap_mat,2);
    size_iter = size(bootstrap_mat,1);
    sign_theta = theta_opt>0;
    std_m = zeros(size_v,1);
    p = zeros(size_v,1);
    if flag_p == 0 %bootstrap of value
        for i=1:size_v
            if theta_opt(i)==-999
                std_m(i) = 0;
            else
                if sign_theta(i)>0;
                    p(i) = sum(bootstrap_mat(:,i)<0)/size_iter;
                else
                    p(i) = sum(bootstrap_mat(:,i)>0)/size_iter;
                end
                std_m(i) = sqrt(var(bootstrap_mat(:,i)));
            end
        end
    elseif flag_p==1 %bootstrap of probability < 0
        for i=1:size_v
            if sign_theta(i)>0;
                p(i) = mean(bootstrap_mat(:,i));
            else
                p(i) = 1 - mean(bootstrap_mat(:,i));
            end
        end
    end
    sig_m = zeros(size_v,1);
    sig_m(p<0.05) = 10;
    sig_m(p<0.025) = 5;
    sig_m(p<0.005) = 1;
    sig_m(theta_opt==-999) = -999;
        
end
    
    