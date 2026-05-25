clc;clear;close all;

load("earth.mat");

tle = "tle.txt";
nilesat_new = "nilesat_new.txt";
nilesat = "NILESAT_201.txt";
galileo = "GSAT0101_(GALILEO-PFM).txt";
mol = "mol.txt";
ISS = "ISS.txt";


filename = galileo;
Re = 6378 ;

tle_data = readsat(filename);
ti = tle_data.epoch_time;

now_time = juliandate(datetime('now', 'TimeZone', 'UTC'));
% t_final = now_time*24*60*60;
t_final = ti + 24*60*60;

dt = 50;

[lon_cont, lat_cont, time_vec,r_vec,perigee_idx, perigee_time] = tle_to_latlong(filename);
sat_tle = get_sat(filename,t_final,dt);

theta = sat_tle.theta;
lambda_deg = sat_tle.lambda_deg;
phi_deg = sat_tle.phi_deg;
r_i = sat_tle.r_i;
rp = sat_tle.r_p;
r_e = sat_tle.r_e;
norm_v_i = sat_tle.norm_v_i;
altitude = sat_tle.altitude;
solar_time = sat_tle.solartime;
nu = sat_tle.nu;
energy = sat_tle.energy;
sat_name = sat_tle.sat_name;


%% Enhanced Plots with Three Separate Figures

% Set default interpreter to LaTeX for math fonts
set(groot, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');

% Get screen size for centering
screenSize = get(0, 'ScreenSize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);

% Define colors for consistency
color_orbit = [0.85, 0.33, 0.10];  % Red-orange
color_ground = 'r';  % red
color_matlab = [0.47, 0.67, 0.19];  % Green
color_earth = [0.3, 0.6, 0.9];      % Light blue

% Create Earth sphere data (used multiple times)
[xs, ys, zs] = sphere(100);
xsr = xs * Re;
ysr = ys * Re;
zsr = zs * Re;

% Calculate specific orbital energy (kinetic + potential)


%% Figure 1: Orbital Views in Multiple Frames
figWidth1 = 1600;
figHeight1 = 600;
figX1 = (screenWidth - figWidth1) / 2;
figY1 = (screenHeight - figHeight1) / 2;

figure('Position', [figX1, figY1, figWidth1, figHeight1])

% ECEF Frame
subplot(1, 3, 1)
earth_ecef = ecef_from_ground_track(long, lat.', Re);
projection_ecef = ecef_from_ground_track(lambda_deg, phi_deg, Re);

hold on
h1 = plot3(r_e(1,:), r_e(2,:), r_e(3,:), 'LineWidth', 2, 'Color', color_orbit);
h2 = plot3(earth_ecef(1,:), earth_ecef(2,:), earth_ecef(3,:), '.', ...
    'MarkerSize', 8, 'Color', color_ground);
h4 = plot3(r_e(1,1), r_e(2,1), r_e(3,1), 'o', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
h5 = plot3(r_e(1,end), r_e(2,end), r_e(3,end), 'o', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);

h3 = plot3(projection_ecef(1,:), projection_ecef(2,:), projection_ecef(3,:), '.', ...
    'MarkerSize', 8, 'Color', color_matlab);
surf(xsr, ysr, zsr, 'EdgeColor', 'none', 'FaceColor', color_earth, 'FaceAlpha', 0.6)
grid on
axis equal
xlabel('$X$ (km)', 'FontSize', 12)
ylabel('$Y$ (km)', 'FontSize', 12)
zlabel('$Z$ (km)', 'FontSize', 12)
title('ECEF Frame', 'FontSize', 14, 'FontWeight', 'bold')
legend([h1, h2, h3, h4,h5], {'Satellite Orbit', 'Ground Track (Earth)', ...
    'Ground Track (Projection)', 'Epoch Position','Position at t_final'}, 'Location', 'best', 'FontSize', 10)
view(3)
hold off

% ECI Frame
subplot(1, 3, 2)
hold on
h1 = plot3(r_i(1,:), r_i(2,:), r_i(3,:), 'LineWidth', 2, 'Color', color_orbit);
h3 = plot3(r_i(1,1), r_i(2,1), r_i(3,1), 'o', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
h4 = plot3(r_i(1,end), r_i(2,end), r_i(3,end), 'o', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
h5 = plot3(r_vec(1,perigee_idx), r_vec(2,perigee_idx), r_vec(3,perigee_idx), ...
    's', 'MarkerSize', 12, 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
surf(xsr, ysr, zsr, 'EdgeColor', 'none', 'FaceColor', color_earth, 'FaceAlpha', 0.6)
grid on
axis equal
xlabel('$X$ (km)', 'FontSize', 12)
ylabel('$Y$ (km)', 'FontSize', 12)
zlabel('$Z$ (km)', 'FontSize', 12)
title('ECI Frame', 'FontSize', 14, 'FontWeight', 'bold')
legend([h1, h3,h4, h5], {'Orbit (Computed)', ...
    'Epoch (Computed)','Position at t_final' ,'Perigee'}, 'Location', 'best', 'FontSize', 10)
view(3)
hold off

% Perifocal Frame
subplot(1, 3, 3)
hold on
if exist('rp', 'var')
    % Plot orbit in perifocal frame
    h1 = plot(rp(1,:), rp(2,:), 'LineWidth', 2, 'Color', color_orbit);
    h2 = plot(rp(1,1), rp(2,1), 'o', 'MarkerSize', 10, ...
        'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    h3 = plot(rp(1,perigee_idx), rp(2,perigee_idx), 's', 'MarkerSize', 12, ...
        'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    h4 = plot(rp(1,end), rp(2,end), 's', 'MarkerSize', 12, ...
        'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    % Draw coordinate axes
    max_r = max(sqrt(sum(rp.^2, 1))) * 1.1;
    plot([0 max_r], [0 0], 'k--', 'LineWidth', 1)
    plot([0 0], [-max_r max_r], 'k--', 'LineWidth', 1)
    % Draw focus (Earth center)
    plot(0, 0, 'o', 'MarkerSize', 8, 'MarkerFaceColor', color_earth, ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1.5)
    legend([h1, h2, h3,h4], {'Orbit', 'Epoch', 'Perigee', 'Position at t_final'}, 'Location', 'best', 'FontSize', 10)
else
    text(0.5, 0.5, 'rp vector not available', 'HorizontalAlignment', 'center', ...
        'FontSize', 12)
end
grid on
axis equal
xlabel('$\hat{p}$ (km)', 'FontSize', 12)
ylabel('$\hat{q}$ (km)', 'FontSize', 12)
title('Perifocal Frame', 'FontSize', 14, 'FontWeight', 'bold')
hold off

sgtitle("Orbital Views in Multiple Reference Frames of sat: "+sat_name, 'FontSize', 16, 'FontWeight', 'bold')

%% Figure 2: Ground Track Visualizations
figWidth2 = 1400;
figHeight2 = 600;
figX2 = (screenWidth - figWidth2) / 2;
figY2 = (screenHeight - figHeight2) / 2;

figure('Position', [figX2, figY2, figWidth2, figHeight2])

% Ground track colored by velocity
subplot(2, 1, 1)
hold on
plot(long, lat, '.', 'Color', [0.7 0.7 0.7], 'MarkerSize', 4)
plot(lon_cont, lat_cont, '.', 'Color', color_matlab, 'MarkerSize', 4)
scatter(lambda_deg, phi_deg, 20, norm_v_i, 'filled')
plot(lambda_deg(end),phi_deg(end),'s', 'MarkerSize', 7, ...
        'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5)
cb1 = colorbar;
ylabel(cb1, "|v| (km/s)", 'FontSize', 11)
colormap(gca, 'spring')
grid on
xlabel('Longitude (deg)', 'FontSize', 12)
ylabel('Latitude (deg)', 'FontSize', 12)
title('Ground Track Colored by Velocity', 'FontSize', 14, 'FontWeight', 'bold')
legend('Earth Reference', 'MATLAB Toolbox', 'Satellite Orbit','Position at t_final', ...
    'Location', 'best', 'FontSize', 10)
xlim([-180 180])
ylim([-90 90])
hold off

% Ground track colored by altitude
subplot(2, 1, 2)
hold on
plot(long, lat, '.', 'Color', [0.7 0.7 0.7], 'MarkerSize', 4)
plot(lon_cont, lat_cont, '.', 'Color', color_matlab, 'MarkerSize', 4)
scatter(lambda_deg, phi_deg, 20, altitude, 'filled')
plot(lambda_deg(end),phi_deg(end),'s', 'MarkerSize', 7, ...
        'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5)
cb2 = colorbar;
ylabel(cb2, "h (km)", 'FontSize', 11)
colormap(gca, 'parula')
grid on
xlabel('Longitude (deg)', 'FontSize', 12)
ylabel('Latitude (deg)', 'FontSize', 12)
title('Ground Track Colored by Altitude', 'FontSize', 14, 'FontWeight', 'bold')
legend('Earth Reference', 'MATLAB Toolbox', 'Satellite Orbit','Position at t_final', ...
    'Location', 'best', 'FontSize', 10)
xlim([-180 180])
ylim([-90 90])
hold off

sgtitle("Ground Track Analysis of sat: " + sat_name, 'FontSize', 16, 'FontWeight', 'bold')

%% Figure 3: Orbital Parameters vs Time
figWidth3 = 1400;
figHeight3 = 900;
figX3 = (screenWidth - figWidth3) / 2;
figY3 = (screenHeight - figHeight3) / 2;

figure('Position', [figX3, figY3, figWidth3, figHeight3])

% Altitude vs Time
subplot(3, 1, 1)
plot(solar_time, altitude, 'LineWidth', 2, 'Color', color_orbit)
grid on
xlabel('Solar Time', 'FontSize', 12)
ylabel('$h$ (km)', 'FontSize', 12)
title('Altitude vs Time', 'FontSize', 13, 'FontWeight', 'bold')
xlim([min(solar_time) max(solar_time)])

% Velocity vs Time
subplot(3, 1, 2)
plot(solar_time, norm_v_i, 'LineWidth', 2, 'Color', color_ground)
grid on
xlabel('Solar Time', 'FontSize', 12)
ylabel('$|\mathbf{v}|$ (km/s)', 'FontSize', 12)
title('Velocity Magnitude vs Time', 'FontSize', 13, 'FontWeight', 'bold')
xlim([min(solar_time) max(solar_time)])

% True Anomaly vs Time
subplot(3, 1, 3)
plot(solar_time, nu, 'LineWidth', 2, 'Color', color_matlab)
grid on
xlabel('Solar Time', 'FontSize', 12)
ylabel('$\nu$ (deg)', 'FontSize', 12)
title('True Anomaly vs Time', 'FontSize', 13, 'FontWeight', 'bold')
xlim([min(solar_time) max(solar_time)])
sgtitle("Orbital Parameters vs Time of sat: "+sat_name, 'FontSize', 16, 'FontWeight', 'bold')

% Reset interpreter to default after plotting (optional)
set(groot, 'defaultTextInterpreter', 'remove');
set(groot, 'defaultAxesTickLabelInterpreter', 'remove');
set(groot, 'defaultLegendInterpreter', 'remove');

function out = readsat(filename)
    
    mu = 398600;
  
    sat_name = filename;
    orbit_vars = readmatrix(filename);
    epoch = orbit_vars(1,4);
    temp = num2cell(orbit_vars(2, 3:end-1));
    [i, Omega_epoch, ecc, omega_epoch, M_epoch, n] = temp{:};
    i = deg2rad(i);
    omega_epoch = deg2rad(omega_epoch);
    Omega_epoch = deg2rad(Omega_epoch);
    M_epoch = deg2rad(M_epoch);
    n_rad = 2*pi*n;
    n_sec = n_rad/24/60/60;
    ecc = ecc*1e-7;
    a = (mu/n_sec^2)^(1/3);
    T = 2*pi/n_sec;
        
    epoch_year = num2str(epoch, '%.0f');
    epoch_year = str2double(epoch_year(1:2));
    
    if epoch_year >= 57
        epoch_year = 1900 + epoch_year;
    else
        epoch_year = 2000 + epoch_year;
    end
    
    epoch_day = num2str(epoch, '%.10f');
    epoch_day = str2double(epoch_day(3:end));
    %% New part
    epoch_day_int = floor(epoch_day);
    epoch_day_frac = epoch_day - epoch_day_int;
    epoch_date = datetime(epoch_year,1,1,0,0,0,'TimeZone','UTC') + days(epoch_day_int-1) + seconds(epoch_day_frac*86400);
    epoch_jd = juliandate(epoch_date);
    out.epoch_time = epoch_jd*24*60*60;
    
    
    %% end of new part
    % epoch_time = (epoch_year*365+epoch_day-1)*24*60*60;

end
