% Determines the longest angle gap in the circle model
function [distance] = longest_circle_gap(circle_origin, inlier_points)
    % convert to vector form
    inlier_points = map_by_row(inlier_points, @(point) (point - circle_origin'));

    % calculate angles
    angles =  map_by_row(inlier_points, @(point) (atan2(point(2),point(1))));

    % find max gap 
    distance = max(diff(sort(angles))); 
end