function [] = move_many(R, sensors, vels)
    cur_angle = pi/4; 
    last_point = R(1, :); 
    for i=2:size(R,1)
        next_point = R(i,:); 
        [next_angle, ~] = move_point(cur_angle, last_point, next_point, sensors, vels); 
        last_point = next_point;
        cur_angle = next_angle;
    end
end