%#ok<*AGROW> 
function [pos_x, pos_y] = get_map()
    angle_matrix = linspace(0,2*pi,360);
    angle_matrix = transpose(table2array(readtable('../data/angles.csv')));
    
    offsets = [
        -0.83, 0.80, 2.5*pi()/180;
        -0.6, 0.87, 2.5*pi()/180;
        0, 0, 0;
        -0.385, -0.05, 1*pi()/180;
        -0.793, -0.07, 1*pi()/180;
        -1.07, -0.07, 1*pi()/180;
        0.91, 0.95, 2*pi()/180;
        0.96, 0, 1*pi()/180;
        0.98, -0.75, 1*pi()/180;
        0, -0.79, 1*pi()/180;
        -0.71, -0.83, 1*pi()/180;
        -1.13, 0.76, 162*pi()/180;
        -0.74, 0.83, 97.5*pi()/180;
    ];
    
    pos_x = [];
    pos_y = []; 
    
    for i=1:size(offsets, 1)
        [x_, y_] = neeto_to_global(offsets(i,1), offsets(i,2), offsets(i,3), load(append("../data/scan", int2str(i), ".csv")), angle_matrix);
        % if you want to visualize all the different layers, you can use:
        % pos_x = [pos_x; x_]
        % pos_y = [pos_y; y_];
        % and feeding that into scatter will use different colors for each row
        pos_x = [pos_x; x_']; 
        pos_y = [pos_y; y_'];
    end
end