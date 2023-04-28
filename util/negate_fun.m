% returns a wrapper function that is the negation of the input function
function [negate_fun_res] = negate_fun(in_fun)
    negate_fun_res = @(input) (~in_fun(input));
end