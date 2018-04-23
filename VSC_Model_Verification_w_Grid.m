clear all;
close all;

%% Grid parameters %%
Vs      = 120;              % AC grid voltage amplitude
f_grid  = 60;               % AC grid frequency (Hz)
omega   = 2*pi*f_grid;      % AC grid frequency (Rad/s)
R_grid  = 0.15;             % AC grid - VSC transmission line resistance (ohm)
L_grid  = 2e-3;             % AC grid - VSC transmission line inductance (H)
Vdc     = 200;              % DC grid - VSC voltage

%% VSC terminal filter %%
Ls = 12e-3;                 % Filter inductance (H)
Rs = 0.15;                  % Filter resistance (ohm)

%% PLL control parameters %%
Tr_PLL  = 5e-3;             % Time constant
wn      = 4/Tr_PLL;         % Natural frequency
zeta    = 0.7;              % Damping coefficient
Kp_pll  = (2*zeta*wn)/Vs;   % Proportional gain
Ti_pll  = (2*zeta)/wn;      % Integral time constant 

%% VSC current control parameters %%
Tr_is   = 15e-3;                                    % Time constant         
wn_i    = 4/(Tr_is);                                % Natural frequency
zeta_i  = 1.15;                                        % Damping coefficient
Ti_is   = ( 2*(zeta_i)/wn_i )-( Rs/( Ls*wn_i^2 ) ); % Integral time constant 
Kp_is   = Ls*wn_i^2*Ti_is;                          % Proportional gain
cur_sat = 50;                                       % Current saturation limit (A)

%% VSC power control parameters %%
Tr_p    = 50e-3;                                    % Time constant   
wn_p    = 4/Tr_p;                                   % Natural frequency
zeta_p  = 0.8;                                      % Damping coefficient
Ti_p    = ( 2*zeta_p/wn_p )-( Rs/(Ls*wn_p^2) );     % Integral time constant
Gain_p  = Ls*wn_p^2*Ti_p;                           % Proportional gain

%% VSC set-points %%
P_ref       = 1000;     % Active power set-point (W)
Q_ref       = 0;        % Reactive power set-point(W)

P_ref_step  = -1000;    % Active power set-point after step (W)
P_step_time = 1;        % Active power step time (s)

%% Simulink simulation %%
sim_time = 3;

avg_model = sim('Simulink Models/VSC_Model_Verification_AVG_w_Grid',...
            'SimulationMode','normal',...
            'SaveOutput','on','OutputSaveName','yout',...
            'SaveFormat', 'Dataset');

switch_model = sim('Simulink Models/VSC_Model_Verification_Switching_Devices_w_Grid',...
            'SimulationMode','normal',...
            'SaveOutput','on','OutputSaveName','yout',...
            'SaveFormat', 'Dataset');



%% Plots %%
figure(1);
plot(switch_model.S.Time, switch_model.S.Data(:,1),...
    avg_model.S.Time, avg_model.S.Data(:,1));
title('Active power');
legend('Switching Model', 'Average Model');

figure(2);
subplot(2,1,1);
plot(switch_model.pll.Time, switch_model.pll.Data(:,1),...
     avg_model.pll.Time, avg_model.pll.Data(:,1));
title('$\hat{\theta}$','Interpreter','latex');
legend('Switching Model', 'Average Model');


subplot(2,1,2);
plot(switch_model.pll.Time, switch_model.pll.Data(:,2),...
     avg_model.pll.Time, avg_model.pll.Data(:,2));
title('$\hat{\omega}$','Interpreter','latex');
legend('Switching Model', 'Average Model');

figure(3);
plot(switch_model.measurements.Time, switch_model.measurements.Data(:,1),...
    avg_model.measurements.Time, avg_model.measurements.Data(:,1)); 
title('Current at intersection');
legend('Switching Model', 'Average Model');
