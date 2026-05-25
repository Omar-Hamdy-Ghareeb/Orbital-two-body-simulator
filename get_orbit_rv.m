function out = get_orbit_rv(r0,v0,t_start,t_end)
% input time in JD but converted to seconds

    mu = 398600.44188;
        j2 = 1.08263e-3;
        Re = 6378 ;

    [t_vec,r_i] = ode45(@fun,[t_start, t_end],[r0; v0]);
    r_i = r_i(:,1:3)';
    h_vec = cross(r0,v0);
    ecc_vec = cross(v0,h_vec)./mu - r0./norm(r0);

    gst = gmst_from_jd(t_vec/24/60/60);
    theta = gst.theta;
    out.gst_h = gst.t; %In Hours
    
    r_e = ecef_from_eci(r_i,theta');
    [lambda,phi]= ground_track_from_ecef(r_e);
    lambda_rv = rad2deg(lambda);
    phi_rv    = rad2deg(phi);
    ecc = norm(ecc_vec);
    h = norm(h_vec);
    a = h^2/mu/(1-ecc^2);
    n = sqrt(mu/a^3);
    i = acos(dot(h_vec,[0;0;1])/h);
    nodevec = cross([0;0;1],h_vec);
    Omega0 = acos(dot(nodevec,[1;0;0])/norm(nodevec));
    if nodevec(2) < 0  % if n_y < 0
        Omega0 = 2*pi - Omega0;
    end
    omega0 = acos(dot(nodevec,ecc_vec)/((nodevec)*norm(ecc_vec)));
    if ecc_vec(3) < 0  % if e_z < 0
        omega0 = 2*pi - omega0;
    end

     Omegadot = -(3/2*sqrt(mu)*j2*Re^2/(1-ecc^2)^2/a^(7/2))*cos(i);
     omegadot = -(3/2*sqrt(mu)*j2*Re^2/(1-ecc^2)^2/a^(7/2))*(5/2*sin(i)^2-2);
     Omega = Omegadot*(t_vec-t_start) +Omega0;
     omega = omegadot*(t_vec-t_start) +omega0;

     r_p = ECI_to_Prefocal(t_vec,Omega,omega,i,r_i);
     out.t_vec = t_vec;
     out.r_i = r_i;
     out.r_p = r_p;
     out.lambda_rv = lambda_rv;
     out.phi_rv = phi_rv;
     out.i = i; 
     out.Omega0 = Omega0;
     out.Omega = Omega;
     out.ecc_vec = ecc_vec;
     out.omega0 = omega0;
     out.omega = omega;
     out.n = n;
     out.a = a;

    function w_dot = fun(~,w)
        w_dot = [w(4);w(5);w(6);rdd45(w,1);rdd45(w,2);rdd45(w,3)];
    end

    function result = rdd45(w,elem)
        result = -mu.*w(elem)./((w(1).^2+w(2).^2+w(3).^2).^1.5);
    end
    
     function gst = gmst_from_jd(JD)
        gst.t = JD - 2451545.0;
        T = (gst.t)/36525;
    
        gst.theta = 280.46061837 ...
              + 360.98564736629 * (JD - 2451545.0) ...
              + 0.000387933 * T.^2 ...
              - (T.^3)/38710000;
    
        gst.theta = deg2rad(mod(gst.theta, 360));   % wrap to [0, 2pi)
    end

end
