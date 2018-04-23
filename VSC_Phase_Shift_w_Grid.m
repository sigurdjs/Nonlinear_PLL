clear all;
close all;

%% Grid parameters %%
Vs      = 120;              % AC grid voltage amplitude
f_grid  = 60;               % AC grid frequency (Hz)
omega   = 2*pi*f_grid;      % AC grid frequency (Rad/s)
R_grid  = 0.15;             % AC grid - VSC transmission line resistance (ohm)
L_grid  = 8e-3;             % AC grid - VSC transmission line inductance (H)
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

%% Phase shift
phase_shift = pi/2;         % Magnitude of phase shift
phase_shift_time = 1;     % Time-step to apply phase shift 

%% Simulink simulation %%
sim_time = 1.022;

avg_model = sim('Simulink Models/VSC_Phase_Shift_AVG_w_Grid',...
            'SimulationMode','normal',...
            'SaveOutput','on','OutputSaveName','yout',...
            'SaveFormat', 'Dataset');
        
% L_grid is increased a bit to ensure cycle slip with switching model
L_grid  = 9e-3;
sim_time = 1.2;
switch_model = sim('Simulink Models/VSC_Phase_Shift_Switching_Devices_w_Grid',...
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
subplot(1,2,1);
hold on;
% pi/2 is added to the phase error as the reference phase angle lags the
% estimated angle by 90 deg (the connected AC source is a cosine wave).

plot(avg_model.pll.data(:,1) - avg_model.pll.data(:,3) + pi/2, avg_model.pll.Data(:,2) - omega);
scatter(avg_model.pll.data(1,1) - avg_model.pll.data(1,3) + pi/2,avg_model.pll.Data(1,2) - omega, 50, 'g', 'filled');
scatter(avg_model.pll.data(end,1) - avg_model.pll.data(end,3) + pi/2,avg_model.pll.Data(end,2) - omega,50, 'r', 'filled','d');
hold off;
ylabel('omega error');
xlabel('theta error');
title('Phase Plot average model');
[~, upper_estimate] = lock_in_range(Kp_pll, Ti_pll, Vs, 0);
annotation('textbox',[.15 .85 .4 .05], 'String',sprintf('Lock-in range: %i', round(upper_estimate) ),'EdgeColor','none');

subplot(1,2,2);
hold on;
% pi/2 is added to the phase error as the reference phase angle lags the
% estimated angle by 90 deg (the connected AC source is a cosine wave).

% Only the transient period from right before (t = 0.99) and after is used
% in the phase plot. Initially the PLL is synced and we exclude
% oscillations around zero from plotting.
plot(switch_model.pll.data(99990:end,1) - switch_model.pll.data(99990:end,3) + pi/2, switch_model.pll.Data(99990:end,2) - omega);
scatter(switch_model.pll.data(99990,1) - switch_model.pll.data(99990,3) + pi/2,switch_model.pll.Data(99990,2) - omega, 50, 'g', 'filled');
scatter(switch_model.pll.data(end,1) - switch_model.pll.data(end,3) + pi/2,switch_model.pll.Data(end,2) - omega,50, 'r', 'filled','d');
hold off;
ylabel('omega error');
xlabel('theta error');
title('Phase Plot switch model');
annotation('textbox',[.65 .15 .4 .05], 'String',sprintf('Lock-in range: %i', round(upper_estimate) ),'EdgeColor','none');



