% Determines the longest gap between inlier points in the direction of the fit line
% We use a direct comparison based sort rather than looping through all
% pairs of points. This implementation provides a quadratic speed-up
% compared to the version from the compendium which is (N^2)log(N). 
function [distance] = longest_gap(line_start, line_end, inlier_points)
    % convert to vector form
    line = line_end - line_start;
    line = line ./ norm(line);
    inlier_points = map_by_row(inlier_points, @(point) (point - line_start'));
    
    % calculate distances
    distances =  map_by_row(inlier_points, @(point) (point * line));

    % find max gap 
    distance = max(diff(sort(distances))); 
end