% find the minimum distance between point and line
% inputs are in the form of [x_n; y_n]
% output is a scalar value
function [distance] = project_point(line_start, line_end, point)
    % convert to vector
    line = line_end - line_start;
    point = point - line_start;
    
    % make segment a unit vector
    line = line ./ norm(line);
    
    % find perpendicular unit vector
    line_perp = [line(2), -1*line(1)];
    
    % find the distance 
    distance = abs(line_perp * point);
end