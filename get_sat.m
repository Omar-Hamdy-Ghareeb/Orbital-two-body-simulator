function out = get_sat(filename,t_final,dt)  
    mu = 398600;
    Re = 6378 ;
    j2 = 1.08263e-3;
    % omega_earth = 2*pi/24/60/60;
    
    fid = fopen(filename, 'r');
    line0 = fgetl(fid); % Satellite name
    line1 = fgetl(fid); % First line of TLE
    fclose(fid);

    out.sat_name = strtrim(line0);
    bstar_str = strtrim(line1(54:61));
    bstar = parse_bstar(bstar_str);

    orbit_vars = readmatrix(filename);
    epoch = orbit_vars(1,4);
      


    temp = num2cell(orbit_vars(2, 3:end-1));
    [out.i, out.Omega_epoch, out.ecc, out.omega_epoch, out.M_epoch, n] = temp{:};
    out.i = deg2rad(out.i);
    out.omega_epoch = deg2rad(out.omega_epoch);
    out.Omega_epoch = deg2rad(out.Omega_epoch);
    out.M_epoch = deg2rad(out.M_epoch);
    n_rad = 2*pi*n;
    out.n_sec = n_rad/24/60/60;
    out.ecc = out.ecc*1e-7;
    out.a = (mu/out.n_sec^2)^(1/3);
    p = out.a*(1-out.ecc^2);
    out.T = 2*pi/out.n_sec;
        
    epoch_year = num2str(epoch, '%.0f');
    epoch_year = str2double(epoch_year(1:2));
    
    if epoch_year >= 57
        epoch_year = 1900 + epoch_year;
    else
        epoch_year = 2000 + epoch_year;
    end
    
    epoch_day = num2str(epoch, '%.10f');
    epoch_day = str2double(epoch_day(3:end));
    epoch_day_int = floor(epoch_day);
    epoch_day_frac = epoch_day - epoch_day_int;
    % Return to line 48 
    epoch_date = datetime(epoch_year,1,1,0,0,0,'TimeZone','UTC') + days(epoch_day_int-1) + seconds(epoch_day_frac*86400);
    epoch_jd = juliandate(epoch_date);
    out.epoch_time = epoch_jd*24*60*60;




    t_epoch_minus_tp = out.M_epoch/out.n_sec;
    out.tp = out.epoch_time - t_epoch_minus_tp;
    N_t = (t_final-out.epoch_time)/dt;
    out.t = linspace(out.epoch_time,t_final,N_t);
    out.solartime = datetime(out.t/60/60/24,'ConvertFrom','juliandate','TimeZone','local');

    delta_t = (out.t - out.epoch_time)/60; % time in minutes from epoch
    

    n_sec_array = zeros(size(out.t));

    for j = 1:length(out.t)
        dt_min = delta_t(j); % minutes from epoch
        
        % First-order drag correction to mean motion
        % B* effect: dn/dt ≈ -(3/2) * B* * n^2 * (a/p0)^2
        ndot_drag = -(3/2) * bstar * (out.n_sec*60)^2 * (out.a/p)^2; % rev/day^2
        ndot_drag_sec = ndot_drag / (24*60*60); % convert to rad/s^2
        
        % Update mean motion
        n_sec_array(j) = out.n_sec + ndot_drag_sec * dt_min * 60;
    end

    E = zeros(size(out.t));
   
    for j = 1:length(out.t)
        M = n_sec_array(j)*(out.t(j)-out.tp);
        kepler = @(E_val) E_val - out.ecc*sin(E_val) - M;
        E(j) = fzero(kepler,M);
    end
    
    nu = 2.*atan2(sqrt(1+out.ecc).*sin(E/2),sqrt(1-out.ecc)*cos(E/2));
    r = out.a.*(1-out.ecc^2)./(1+out.ecc.*cos(nu));
    r_p = [r.*cos(nu); r.*sin(nu); zeros(size(out.t))];
    v_p = sqrt(mu/p)*[-sin(nu);out.ecc+cos(nu); zeros(size(out.t))];
    
    Omegadot = -(3/2*sqrt(mu)*j2*Re^2/(1-out.ecc^2)^2/out.a^(7/2))*cos(out.i);
    omegadot = -(3/2*sqrt(mu)*j2*Re^2/(1-out.ecc^2)^2/out.a^(7/2))*(5/2*sin(out.i)^2-2);
    Omega = Omegadot*(out.t-out.epoch_time) +out.Omega_epoch;
    omega = omegadot*(out.t-out.epoch_time) +out.omega_epoch;



    [r_i,norm_r_i] = Prefocal_to_ECI(out.t,Omega,omega,out.i,r_p);

    [v_i,out.norm_v_i] = Prefocal_to_ECI(out.t,Omega,omega,out.i,v_p);


    
    gst = gmst_from_jd(out.t/24/60/60);
    theta = gst.theta;



    r_e = ecef_from_eci(r_i,theta);
    v_e = ecef_from_eci(v_i,theta);

    



    [lambda,phi] = ground_track_from_ecef(r_e);
    

    out.sat_name;
    out.t;
    out.T;
    out.tp;
    out.epoch_time;
    out.solartime;
    out.gst_h = gst.t;
    out.bstar = bstar;
    out.lambda_deg = rad2deg(lambda);
    out.phi_deg    = rad2deg(phi);
    out.r_e = r_e;
    out.v_e = v_e;
    out.r_i = r_i;
    out.r_p = r_p;
    out.v_i = v_i;
    out.norm_v_i;
    out.altitude = norm_r_i - Re ;
    out.Omega = Omega;
    out.omega = omega;
    out.i;
    out.ecc;
    out.nu = nu;
    out.M_epoch;
    out.n_sec;
    out.a;
    out.energy = out.norm_v_i.^2./2-mu./norm_r_i;
    out.theta = theta;
 %In Hours

    % e -> ECEF frame
    % i -> ECI frame


    

    function gst = gmst_from_jd(JD)
        gst.t = JD - 2451545.0;
        T = (gst.t)/36525;
    
        gst.theta = 280.46061837 ...
              + 360.98564736629 * (JD - 2451545.0) ...
              + 0.000387933 * T.^2 ...
              - (T.^3)/38710000;
    
        gst.theta = deg2rad(mod(gst.theta, 360));   % wrap to [0, 2pi)
    end
    
    function bstar = parse_bstar(bstar_str)

            bstar_str = strtrim(bstar_str);
            
            if isempty(bstar_str) || strcmp(bstar_str, '00000-0') || strcmp(bstar_str, '00000+0')
                bstar = 0;
                return;
            end

            idx_minus = find(bstar_str == '-', 1, 'last');
            idx_plus = find(bstar_str == '+', 1, 'last');
            
            if ~isempty(idx_minus) && (isempty(idx_plus) || idx_minus > idx_plus)
                idx = idx_minus;
                exp_sign = -1;
            elseif ~isempty(idx_plus)
                idx = idx_plus;
                exp_sign = 1;
            else
                bstar = str2double(bstar_str);
                return;
            end
            
            
            mantissa_str = bstar_str(1:idx-1);
            exponent_str = bstar_str(idx+1:end);

            mantissa_str = strrep(mantissa_str, ' ', '');
            mantissa_str = strrep(mantissa_str, '+', '');
            
            mantissa = str2double(mantissa_str) / 100000; 
            exponent = exp_sign * str2double(exponent_str);
            
            bstar = mantissa * 10^exponent;
    end

end

