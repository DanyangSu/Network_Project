function gen_tex_table(var_list,model_list,coef_matrix,std_matrix,sig_matrix,tex_file,permit,top_string,bot_string,note_string,panel_continue)
    fileID = fopen(tex_file,permit);
    size_col = length(model_list);
    size_row = length(var_list);
    fprintf(fileID,top_string);
    if panel_continue==0
        fprintf(fileID,'{');
        for i=1:size_col+1
            fprintf(fileID,'l');
        end
        fprintf(fileID,'}\n\\hline\n\\hline\n');
    else 
        fprintf(fileID,'\n');
    end
    for i=1:size_col
        fprintf(fileID,'&%s',model_list{i});
    end
    fprintf(fileID,'\\\\\n');
    fprintf(fileID,'\n\\cline{2-%.0g}\n',size_col+1);
    for i=1:size_row
        fprintf(fileID,'%s',var_list{i});
        for j=1:size_col
            if sig_matrix(i,j)==10
                fprintf(fileID,'&%5.2f*',coef_matrix(i,j));
            elseif sig_matrix(i,j)==5
                fprintf(fileID,'&%5.2f**',coef_matrix(i,j));
            elseif sig_matrix(i,j)==1
                fprintf(fileID,'&%5.2f***',coef_matrix(i,j));
            elseif sig_matrix(i,j)==0
                fprintf(fileID,'&%5.2f',coef_matrix(i,j));
            elseif sig_matrix(i,j)==999
                fprintf(fileID,'&%5.2f\\%%',coef_matrix(i,j));
            elseif sig_matrix(i,j)==-999
                fprintf(fileID,'&');
            end
        end
        fprintf(fileID,'\\\\\n');
        for j=1:size_col
            if sig_matrix(i,j)~=-999
                fprintf(fileID,'&(%5.2f)',std_matrix(i,j));
            else
                fprintf(fileID,'&');
            end
        end
        fprintf(fileID,'\\\\\n');
    end
    fprintf(fileID,'%c',bot_string);
    fprintf(fileID,'%c',note_string);
    fclose(fileID);
end