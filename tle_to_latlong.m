% 
% function [lon_cont, lat_cont, time_vec, r_vectors, perigee_idx, perigee_time] = tle_to_latlong(filename)
% % Read TLE from file
%     fid = fopen(filename, 'r');
%     if fid == -1
%         error('Could not open file: %s', filename);
%     end
%     sat_name = fgetl(fid);
%     tle_line1 = fgetl(fid);
%     tle_line2 = fgetl(fid);
%     fclose(fid);
% 
% % Extract orbital period
%     mean_motion = str2double(tle_line2(53:63));
%     orbital_period_seconds = (24 * 3600) / mean_motion;
% 
% % Create scenario
%     startTime = datetime('now', 'TimeZone', 'UTC');
% 
% 
%     stopTime = startTime + seconds(orbital_period_seconds * 1.1);
%     sampleTime = 60;
%     sc = satelliteScenario(startTime, stopTime, sampleTime);
%     sat = satellite(sc, filename, 'Name', strtrim(sat_name));
% 
% % Time vector
%     num_points = 500;
%     time_step = orbital_period_seconds / (num_points - 1);
%     time_vec = (0:num_points-1) * time_step;
%     time_array = startTime + seconds(time_vec);
% 
% % Preallocate
%     lat_cont = zeros(1, num_points);
%     lon_cont = zeros(1, num_points);
%     r_vectors = zeros(3, num_points); % 3D position vectors
% 
%     for i = 1:num_points
%         % Get geographic coordinates
%         [pos_geo, ~] = states(sat, time_array(i), 'CoordinateFrame', 'geographic');
%         lat_cont(i) = pos_geo(1);
%         lon_cont(i) = pos_geo(2);
% 
%         % Get inertial position vector (r vector)
%         [pos_inertial, ~] = states(sat, time_array(i), 'CoordinateFrame', 'inertial');
%         r_vectors(:, i) = pos_inertial/1000;
%     end
% 
% % Calculate perigee (minimum distance from Earth's center)
%     r_magnitudes = vecnorm(r_vectors, 2, 1); % Calculate magnitude of each position vector
%     [~, perigee_idx] = min(r_magnitudes); % Find index of minimum distance
%     perigee_time = time_vec(perigee_idx); % Time at perigee (in seconds from start)
% 
% % Display perigee information
%     fprintf('Perigee Information:\n');
%     fprintf('  Index: %d\n', perigee_idx);
%     fprintf('  Time from start: %.2f seconds (%.2f minutes)\n', perigee_time, perigee_time/60);
%     fprintf('  Distance from Earth center: %.2f km\n', r_magnitudes(perigee_idx));
%     fprintf('  Latitude: %.4f°\n', lat_cont(perigee_idx));
%     fprintf('  Longitude: %.4f°\n', lon_cont(perigee_idx));
% end

function [lon_cont, lat_cont, time_vec, r_vectors, perigee_idx, perigee_time] = tle_to_latlong(filename)
% Read TLE from file
    fid = fopen(filename, 'r');
    if fid == -1
        error('Could not open file: %s', filename);
    end
    sat_name = fgetl(fid);
    tle_line1 = fgetl(fid);
    tle_line2 = fgetl(fid);
    fclose(fid);

% Extract orbital period
    mean_motion = str2double(tle_line2(53:63));
    orbital_period_seconds = (24 * 3600) / mean_motion;

% Extract epoch from TLE line 1
    epoch_str = tle_line1(19:32); % Epoch is in columns 19-32 of line 1
    epoch_year = str2double(epoch_str(1:2));
    epoch_day = str2double(epoch_str(3:end));

% Convert TLE epoch to datetime
    % Handle year (TLE uses 2-digit years, where 57+ = 1957+, 56- = 2056-)
    if epoch_year >= 57
        full_year = 1900 + epoch_year;
    else
        full_year = 2000 + epoch_year;
    end

    % Calculate datetime from year and day of year
    startTime = datetime(full_year, 1, 1) + days(epoch_day - 1);
    startTime.TimeZone = 'UTC';

% Create a temporary TLE file with the original data
    temp_tle_file = tempname; % Create temporary filename
    fid_temp = fopen(temp_tle_file, 'w');
    if fid_temp == -1
        error('Could not create temporary TLE file');
    end
    fprintf(fid_temp, '%s\n', sat_name);
    fprintf(fid_temp, '%s\n', tle_line1);
    fprintf(fid_temp, '%s\n', tle_line2);
    fclose(fid_temp);

% Create scenario using the temporary TLE file
    stopTime = startTime + seconds(orbital_period_seconds * 1.1);
    sampleTime = 60;
    sc = satelliteScenario(startTime, stopTime, sampleTime);
    sat = satellite(sc, temp_tle_file, 'Name', strtrim(sat_name));

% Clean up temporary file
    delete(temp_tle_file);

% Time vector
    num_points = 500;
    time_step = orbital_period_seconds / (num_points - 1);
    time_vec = (0:num_points-1) * time_step;
    time_array = startTime + seconds(time_vec);

% Preallocate
    lat_cont = zeros(1, num_points);
    lon_cont = zeros(1, num_points);
    r_vectors = zeros(3, num_points); % 3D position vectors

    for i = 1:num_points
        % Get geographic coordinates
        [pos_geo, ~] = states(sat, time_array(i), 'CoordinateFrame', 'geographic');
        lat_cont(i) = pos_geo(1);
        lon_cont(i) = pos_geo(2);

        % Get inertial position vector (r vector)
        [pos_inertial, ~] = states(sat, time_array(i), 'CoordinateFrame', 'inertial');
        r_vectors(:, i) = pos_inertial/1000;
    end

% Calculate perigee (minimum distance from Earth's center)
    r_magnitudes = vecnorm(r_vectors, 2, 1); % Calculate magnitude of each position vector
    [~, perigee_idx] = min(r_magnitudes); % Find index of minimum distance
    perigee_time = time_vec(perigee_idx); % Time at perigee (in seconds from start)

% Display perigee information
    fprintf('Perigee Information:\n');
    fprintf('  Index: %d\n', perigee_idx);
    fprintf('  Time from start: %.2f seconds (%.2f minutes)\n', perigee_time, perigee_time/60);
    fprintf('  Distance from Earth center: %.2f km\n', r_magnitudes(perigee_idx));
    fprintf('  Latitude: %.4f°\n', lat_cont(perigee_idx));
    fprintf('  Longitude: %.4f°\n', lon_cont(perigee_idx));

% Display epoch information
    fprintf('\nTLE Epoch Information:\n');
    fprintf('  Epoch: %s\n', datestr(startTime, 'yyyy-mm-dd HH:MM:SS UTC'));
    fprintf('  Year: %d, Day of year: %.8f\n', full_year, epoch_day);
end