function [mapped] = map_by_row(input, map_fun)
    mapped = []; 
    for row=1:size(input, 1)
       mapped = [mapped; map_fun(input(row, :))];
    end
end