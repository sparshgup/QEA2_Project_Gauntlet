% moves between two points by first rotating and then moving in a straight line
function [target_angle, cord2] = move_point(cur_angle, cord1, cord2, sensors, vels)
    MAX_SPEED_ROTATE = 0.02;
    MAX_SPEED_MOVE = 0.1;
    WHEEL_BASE = 0.245; 

    % rotate to angle 
    target_angle = atan((cord2(2)-cord1(2)) / (cord2(1) - cord1(1)));
    if(cord2(1) < cord1(1))
        target_angle = target_angle + pi;
    end
    omega_vel = (MAX_SPEED_ROTATE * 2) / WHEEL_BASE;
    rotation_time = abs(cur_angle - target_angle) / omega_vel;

    tic; 
    while(toc < rotation_time)
        global encoders; 
        global glob_time;
        encoders = [encoders; toc(glob_time) sensors.encoders];
        if(target_angle > cur_angle) 
           vels.lrWheelVelocitiesInMetersPerSecond = [-1*MAX_SPEED_ROTATE, MAX_SPEED_ROTATE];
        else
            vels.lrWheelVelocitiesInMetersPerSecond = [MAX_SPEED_ROTATE, -1*MAX_SPEED_ROTATE];
        end
    end

    % move!!
    target_distance = sqrt(((cord1(1) - cord2(1)) .^ 2) + ((cord1(2) - cord2(2)) .^ 2));
    drive_time = target_distance / MAX_SPEED_MOVE;
    tic; 
    while(toc < drive_time)
        vels.lrWheelVelocitiesInMetersPerSecond = [MAX_SPEED_MOVE, MAX_SPEED_MOVE];
    end

    vels.lrWheelVelocitiesInMetersPerSecond = [0, 0];
end