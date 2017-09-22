function data_struct = my_import(data_dir,data_string,flag_header,varname) 
    delimiter_type = ',';
    if flag_header == 1
        header_line = 1;
        raw_data = importdata(sprintf('%s\\%s.csv',data_dir,data_string),delimiter_type,header_line);        
        num_var = length(raw_data.colheaders);
        for i=1:num_var
            eval(sprintf('data_struct.%s = %s;', raw_data.colheaders{i}, 'raw_data.data(:,i)'));
        end
        data_struct.var_name = raw_data.colheaders;
    else
        raw_data_mat = importdata(sprintf('%s\\%s.csv',data_dir,data_string),delimiter_type); %#ok<NASGU>
        eval(sprintf('data_struct.%s = raw_data_mat;',varname));
        data_struct.var_name = cell(1);
        data_struct.var_name{1} = varname;
    end
    
end
    
    