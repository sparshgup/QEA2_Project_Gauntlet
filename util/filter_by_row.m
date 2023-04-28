function [filtered] = filter_by_row(input, filter_fun)
    filtered = []; 
    for row=1:size(input, 1)
        if(filter_fun(input(row,:)))
            filtered = [filtered; input(row, :)];
        end
    end
end