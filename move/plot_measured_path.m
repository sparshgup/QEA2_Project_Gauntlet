global encoders;

% clean encoders values
encoder_data_clean = []; 
for i=2:size(encoders)
    if(encoders(i,2) ~= encoders(i-1,2))
        encoder_data_clean = [encoder_data_clean; encoders(i,:)];
    end
end
% differentiate 
measured_vl_data = diff(encoder_data_clean(:,2)) ./ diff(encoder_data_clean(:,1));
measured_vr_data = diff(encoder_data_clean(:,3)) ./ diff(encoder_data_clean(:,1));


measured_v = (measured_vl_data + measured_vr_data) / 2; 
measured_w = (measured_vr_data - measured_vl_data) / 0.245; 

measured_theta = [pi/4];
for i=1:size(measured_w)
    delta_t = encoder_data_clean(i+1,1) - encoder_data_clean(i,1);
    measured_theta = [measured_theta; measured_theta(end) + measured_w(i)*delta_t];
end

measured_r = [-0.8400 -0.9300]; 
for i=1:size(measured_v)
    delta_t = encoder_data_clean(i+1,1) - encoder_data_clean(i,1);
    next_x = measured_r(end, 1) + measured_v(i)*cos(measured_theta(i))*delta_t;
    next_y = measured_r(end, 2) + measured_v(i)*sin(measured_theta(i))*delta_t;
    measured_r = [measured_r; next_x next_y];
end

hold on;
plt = plot(measured_r(:,1), measured_r(:,2), '--', 'Color', 'white');
legend("Contour Plot", "Theoretical Path", "Measured Encoder Path");