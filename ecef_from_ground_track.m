function r_e = ecef_from_ground_track(long, lat, R)
    % Ensure long and lat are column vectors
    
    % Preallocate
    r_e = zeros(3, length(long));
    long = deg2rad(long);
    lat = deg2rad(lat);
    % Convert back to Cartesian coordinates (element-wise operations)
    r_e(1,:) = R * cos(lat) .* cos(long);  % x
    r_e(2,:) = R * cos(lat) .* sin(long);  % y
    r_e(3,:) = R * sin(lat);                  % z
end