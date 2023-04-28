% INPUT: 
% pos_x is position of neeto in x-axis of global frame
% pos_x is position of neeto in y-axis of global frame
% pos_angle is angle of neeto in global frame (reading counter-clockwise)
% sensor_d is the distance reading from the lidar sensor 
% sensor_a is the angle reading from the lidar sensor (reading
% counter-clockwise)
%
% RETURNS:
% gframe_x is the object detected in the x-axis of global frame
% grame_y is the object detected in the y-axis of global frame
function [gframe_x, gframe_y] = neeto_to_global(pos_x, pos_y, pos_angle, sensor_d, sensor_a)
    SENSOR_OFFSET = 0.1; % offset of lidar sensor from the center of the neeto
    translate_matrix = [1 0 -pos_x; 0 1 -pos_y; 0 0 1];
    rotate_maxtrix = [cos(pos_angle), -sin(pos_angle), 0; sin(pos_angle), cos(pos_angle), 0; 0, 0, 1]; 
    translate_sensor_offset = [1 0 -SENSOR_OFFSET; 0 1 0; 0 0 1];
    neeto_frame_position = [sensor_d .* cos(sensor_a); sensor_d .* sin(sensor_a); ones([1, length(sensor_d)])];
    gframe = translate_matrix * rotate_maxtrix * translate_sensor_offset * neeto_frame_position;
    gframe_x = gframe(1, :); 
    gframe_y = gframe(2, :); 
end