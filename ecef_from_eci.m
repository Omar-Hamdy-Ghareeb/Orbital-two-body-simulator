    function A_e = ecef_from_eci(A_i,theta)
        A_e = zeros(size(A_i));
        A_e(1,:) =  A_i(1,:).*cos(theta) + A_i(2,:).*sin(theta);
        A_e(2,:) = -A_i(1,:).*sin(theta) + A_i(2,:).*cos(theta);
        A_e(3,:) =  A_i(3,:);
    end