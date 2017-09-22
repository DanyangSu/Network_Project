function new_data = get_rand_data(origin_data,rand_id)  %#ok<INUSD>
    var_name = origin_data.var_name;
    size_var = length(var_name);
    for i_var = 1:size_var
        eval(sprintf('rand_vec = origin_data.%s;',var_name{i_var}));
        eval(sprintf('new_data.%s = rand_vec(rand_id);',var_name{i_var}));
    end
    new_data.var_name = var_name;
end