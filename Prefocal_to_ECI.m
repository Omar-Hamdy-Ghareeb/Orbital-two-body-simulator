function [A_i,norm_A_i] = Prefocal_to_ECI(t,Omega,omega,i,A_p)

    norm_A_i = zeros(size(t));
    A_i = zeros(3,length(t));
    for j = 1:length(t)
    
        T3O = [cos(Omega(j)), sin(Omega(j)), 0; ...
            -sin(Omega(j)), cos(Omega(j)), 0; ...
            0               0           1;];
        T1i = [ 1,   0,      0; ...
            0,  cos(i), sin(i);....
            0,  -sin(i), cos(i);];
    
        T3o = [cos(omega(j)), sin(omega(j)), 0; ...
            -sin(omega(j)), cos(omega(j)), 0; ...
            0               0           1;];

        Tpi = (T3o * T1i * T3O);
        Tip = Tpi.';
        A_i(:,j) = Tip * A_p(:,j);

        norm_A_i(j) = norm(A_i(:,j));

    end
 end