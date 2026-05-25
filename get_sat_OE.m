function out = get_sat_OE(Omega_epoch,omega_epoch,i,ecc,a,M_epoch,epoch_time,t_final,dt)  
    mu = 398600;
    Re = 6378 ;
    j2 = 1.08263e-3;



    i = deg2rad(i);
    omega_epoch = deg2rad(omega_epoch);
    Omega_epoch = deg2rad(Omega_epoch);
    M_epoch = deg2rad(M_epoch);
    n_rad = 2*pi*n;
    out.n_sec = n_rad/24/60/60;
    ecc = ecc*1e-7;
    p = a*(1-ecc^2);
    out.T = 2*pi/out.n_sec;




    t_epoch_tp = M_epoch/out.n_sec;
    out.tp = epoch_time - t_epoch_tp;
    n_t = (t_final-epoch_time)/dt;
    out.t = linspace(epoch_time,t_final,n_t);

    delta_t = (out.t - epoch_time)/60; % time in minutes from epoch
    

    n_sec_array = zeros(size(out.t));

    for j = 1:length(out.t)
        dt_min = delta_t(j); % minutes from epoch
        
        % First-order drag correction to mean motion
        % B* effect: dn/dt ≈ -(3/2) * B* * n^2 * (a/p0)^2
        ndot_drag = -(3/2) * out.bstar * (out.n_sec*60)^2 * (a/p)^2; % rev/day^2
        ndot_drag_sec = ndot_drag / (24*60*60); % convert to rad/s^2
        
        % Update mean motion
        n_sec_array(j) = out.n_sec + ndot_drag_sec * dt_min * 60;
    end

    E = zeros(size(out.t));
   
    for j = 1:length(out.t)
        M = n_sec_array(j)*(out.t(j)-out.tp);
        kepler = @(E_val) E_val - ecc*sin(E_val) - M;
        E(j) = fzero(kepler,M);
    end
    
    nu = 2.*atan2(sqrt(1+ecc).*sin(E/2),sqrt(1-ecc)*cos(E/2));
    r = a.*(1-ecc^2)./(1+ecc.*cos(nu));
    r_p = [r.*cos(nu); r.*sin(nu); zeros(size(out.t))];
    v_p = sqrt(mu/p)*[-sin(nu);ecc+cos(nu); zeros(size(out.t))];
    
    Omegadot = -(3/2*sqrt(mu)*j2*Re^2/(1-ecc^2)^2/a^(7/2))*cos(i);
    omegadot = -(3/2*sqrt(mu)*j2*Re^2/(1-ecc^2)^2/a^(7/2))*(5/2*sin(i)^2-2);
    Omega = Omegadot*(out.t-epoch_time) +Omega_epoch;
    omega = omegadot*(out.t-epoch_time) +omega_epoch;


    [r_i,norm_r_i] = Prefocal_to_ECI(out.t,Omega,omega,out.i,r_p);
    out.altitude = norm_r_i - Re ;
    [v_i,out.norm_v_i] = Prefocal_to_ECI(out.t,Omega,omega,out.i,v_p);

    gst = gmst_from_jd(out.t/24/60/60);
    theta = gst.theta;
    out.gst_h = gst.t; %In Hours

    r_e = ecef_from_eci(r_i,theta);
    v_e = ecef_from_eci(v_i,theta);
    out.r_e = r_e;

    out.v_e = v_e;
    


    [lambda,phi] = ground_track_from_ecef(re);
    out.lambda_deg = rad2deg(lambda);
    out.phi_deg    = rad2deg(phi);
    out.r_i = r_i;
    out.v_i = v_i;
    out.Omega = Omega;
    out.omega = omega;
 
    

    function theta = gmst_from_jd(JD)
        T = (JD - 2451545.0)/36525;
    
        theta = 280.46061837 ...
              + 360.98564736629 * (JD - 2451545.0) ...
              + 0.000387933 * T.^2 ...
              - (T.^3)/38710000;
    
        theta = deg2rad(mod(theta, 360));   % wrap to [0, 2pi)
    end
    

end