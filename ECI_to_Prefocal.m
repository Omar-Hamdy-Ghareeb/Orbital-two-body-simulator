function A_p = ECI_to_Prefocal(t,Omega,omega,i,A_i)
    A_p = zeros(3,length(t));
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
        A_p(:,j) = Tpi * A_i(:,j);



    end
 end