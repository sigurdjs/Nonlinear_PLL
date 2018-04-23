function [s1,s2] = lock_in_range(Kp,Ti,Vs,delta_theta)
    % This function calculates the lock-in range for the SRF-PLL
    % from the paramters Kp, Ti, Vs and delta_theta (the current phase
    % error). The function return a lower and upper estimate.

    S_0 = sqrt( 2*Vs*(Kp/Ti)*(1 + cos(delta_theta)));
    
    S_1 = (Vs*(2/3 - sin(delta_theta/2) - 1/3 * sin((3/2)*delta_theta)))./(cos(delta_theta/2));

    S_2 = ( Vs^2 * (6.5 - 4*log(2) ) )./( 6*sqrt( Kp*Vs/Ti )*cos( delta_theta/2 ) );

    S_2 = S_2 - ( Vs^2 * ( 8*sin( delta_theta/2 ) - 4*log( abs( sin( delta_theta/2 ) + 1) ) ) ) ./ ( 6*sqrt( Kp*Vs/Ti )*cos( delta_theta/2 ) );

    S_2 = S_2 - ( Vs^2 * ( 0.5*cos( 2*delta_theta ) + 2*cos( delta_theta ) ) )./( 6*sqrt( Kp*Vs/Ti )*cos( delta_theta/2 ) );

    S_2 = S_2 - ( Vs^2 * ( 2/3 - sin( delta_theta/2 ) - 1/3 * sin( (3/2)*delta_theta ) ).^2 ) ./ ( 4*sqrt( Kp*Vs/Ti )*( cos(delta_theta/2) ).^3 );
    s1 = S_0 + Kp*S_1;
    s2 = s1 + Kp^2*S_2;
end

