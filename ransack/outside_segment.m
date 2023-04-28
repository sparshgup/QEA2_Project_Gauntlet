% Determines if the point lies outside the segment in the horizontal
% direction
% As a simplified model, points cannot be inliers if they are not in the
% segment range
function [outside] = outside_segment(line_start, line_end, point)
    % convert to vector form
    line_end = line_end - line_start;
    point = point - line_start; 
    line = line_end ./ norm(line_end);

    % calculate y-axis location 
    y_loc_point = point' * line;
    y_loc_end_seg = line_end' * line;

    if((y_loc_point < 0) || (y_loc_point > y_loc_end_seg))
        outside = 1;
    else
        outside = 0;
    end
end