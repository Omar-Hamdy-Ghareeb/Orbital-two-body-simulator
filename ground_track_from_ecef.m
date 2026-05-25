    function [lambda,phi]= ground_track_from_ecef(r_e)
    
       lambda = atan2(r_e(2,:), r_e(1,:));
       phi  = atan2(r_e(3,:), sqrt(r_e(1,:).^2 + r_e(2,:).^2));

    end