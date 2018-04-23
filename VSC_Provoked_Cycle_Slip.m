clear all;
close all;

all_sim_flag = 1;          % Set this flag to one for all simulations, 
                            % zero for only average model simulations

%% Grid parameters %%
Vs      = 120;              % AC grid voltage amplitude
f_grid  = 60;               % AC grid frequency (Hz)
omega   = 2*pi*f_grid;      % AC grid frequency (Rad/s)
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

%% Lock In Range
[lower_estimate, ~] = lock_in_range(Kp_pll, Ti_pll, Vs, 0);    % Function for calculating the lock in range estimates
omega0_step  = lower_estimate;                                              
omega0_step_time = 1;                                                       % Step time to apply frequency disturbance in the PLL

%% Simulink simulation %%
sim_time = 3;

avg_model = sim('Simulink Models/VSC_Provoked_Cycle_Slip_AVG',...
            'SimulationMode','normal',...
            'SaveOutput','on','OutputSaveName','yout',...
            'SaveFormat', 'Dataset');
        
if all_sim_flag == 1
    switch_model = sim('Simulink Models/VSC_Provoked_Cycle_Slip_Switching_Devices',...
                'SimulationMode','normal',...
                'SaveOutput','on','OutputSaveName','yout',...
                'SaveFormat', 'Dataset');
end

%% Lock In Range 2
[lower_estimate, upper_estimate] = lock_in_range(Kp_pll, Ti_pll, Vs, 0);    % Function for calculating the lock in range estimates
omega0_step  = upper_estimate;                                              
omega0_step_time = 1;                                                       % Step time to apply frequency disturbance in the PLL

%% Simulink simulation 2 %%
sim_time = 3;

avg_model_2 = sim('Simulink Models/VSC_Provoked_Cycle_Slip_AVG',...
            'SimulationMode','normal',...
            'SaveOutput','on','OutputSaveName','yout',...
            'SaveFormat', 'Dataset');
        
if all_sim_flag == 1
    switch_model_2 = sim('Simulink Models/VSC_Provoked_Cycle_Slip_Switching_Devices',...
                'SimulationMode','normal',...
                'SaveOutput','on','OutputSaveName','yout',...
                'SaveFormat', 'Dataset');
end

%% Simulink simulation 3 %%
omega0_step  = 1.5*upper_estimate;   
sim_time = 3;

avg_model_3 = sim('Simulink Models/VSC_Provoked_Cycle_Slip_AVG',...
            'SimulationMode','normal',...
            'SaveOutput','on','OutputSaveName','yout',...
            'SaveFormat', 'Dataset');
        
if all_sim_flag == 1
    switch_model_3 = sim('Simulink Models/VSC_Provoked_Cycle_Slip_Switching_Devices',...
                'SimulationMode','normal',...
                'SaveOutput','on','OutputSaveName','yout',...
                'SaveFormat', 'Dataset');
end



%% Plots %%
figure(1);
plot(avg_model.S.Time, avg_model.S.Data(:,1),...
    avg_model_2.S.Time, avg_model_2.S.Data(:,1),...
    avg_model_3.S.Time, avg_model_3.S.Data(:,1));
title('Active power average model');
legend('No cycle slip', 'One cycle slip', 'Many slips');

figure(2);
subplot(2,1,1);
plot(avg_model.pll.Time, avg_model.pll.Data(:,1),...
     avg_model_2.pll.Time, avg_model_2.pll.Data(:,1),...
     avg_model_3.pll.Time, avg_model_3.pll.Data(:,1));
title('$\hat{\theta}$ average model','Interpreter','latex');
legend('No cycle slip', 'One cycle slip', 'Many slips');


subplot(2,1,2);
plot(avg_model.pll.Time, avg_model.pll.Data(:,2),...
     avg_model_2.pll.Time, avg_model_2.pll.Data(:,2),...
     avg_model_3.pll.Time, avg_model_3.pll.Data(:,2));
title('$\hat{\omega}$ average model','Interpreter','latex');
legend('No cycle slip', 'One cycle slip', 'Many slips');


figure(3);
hold on;
% pi/2 is added to the phase error as the reference phase angle lags the
% estimated angle by 90 deg (the connected AC source is a cosine wave).

plot(avg_model.pll.data(:,1) - avg_model.pll.data(:,3) + pi/2, avg_model.pll.Data(:,2) - omega,...
    avg_model_2.pll.data(:,1) - avg_model_2.pll.data(:,3) + pi/2, avg_model_2.pll.Data(:,2) - omega,...
    avg_model_3.pll.data(:,1) - avg_model_3.pll.data(:,3) + pi/2, avg_model_3.pll.Data(:,2) - omega);
scatter(avg_model.pll.data(1,1) - avg_model.pll.data(1,3) + pi/2,avg_model.pll.Data(1,2) - omega, 50, 'g', 'filled');
scatter(avg_model.pll.data(end,1) - avg_model.pll.data(end,3) + pi/2,avg_model.pll.Data(end,2) - omega,50, 'r', 'filled','d');
scatter(avg_model_2.pll.data(end,1) - avg_model_2.pll.data(end,3) + pi/2,avg_model_2.pll.Data(end,2) - omega,50, 'r', 'filled','d');
scatter(avg_model_3.pll.data(end,1) - avg_model_3.pll.data(end,3) + pi/2,avg_model_3.pll.Data(end,2) - omega,50, 'r', 'filled','d');
hold off;
ylabel('omega error');
xlabel('theta error');
title('Phase Plot average model');
legend('No cycle slip', 'One cycle slip', 'Many slips');


if all_sim_flag == 1
    figure(4);
    plot(switch_model.S.Time, switch_model.S.Data(:,1),...
        switch_model_2.S.Time, switch_model_2.S.Data(:,1),...
        switch_model_3.S.Time, switch_model_3.S.Data(:,1));
    title('Active power switch model');
    legend('No cycle slip', 'One cycle slip', 'Many slips');
    
    figure(5);
    subplot(2,1,1);
    plot(switch_model.pll.Time, switch_model.pll.Data(:,1),...
        switch_model_2.pll.Time, switch_model_2.pll.Data(:,1),...
        switch_model_3.pll.Time, switch_model_3.pll.Data(:,1));
    title('$\hat{\theta}$ switch model','Interpreter','latex');
    legend('No cycle slip', 'One cycle slip', 'Many slips');
    
    
    subplot(2,1,2);
    plot(switch_model.pll.Time, switch_model.pll.Data(:,2),...
        switch_model_2.pll.Time, switch_model_2.pll.Data(:,2),...
        switch_model_3.pll.Time, switch_model_3.pll.Data(:,2));
    title('$\hat{\omega}$ switch model','Interpreter','latex');
    legend('No cycle slip', 'One cycle slip', 'Many slips');
    
    figure(6);
    hold on;
    % pi/2 is added to the phase error as the reference phase angle lags the
    % estimated angle by 90 deg (the connected AC source is a cosine wave).
    
    plot(switch_model.pll.data(:,1) - switch_model.pll.data(:,3) + pi/2, switch_model.pll.Data(:,2) - omega,...
        switch_model_2.pll.data(:,1) - switch_model_2.pll.data(:,3) + pi/2, switch_model_2.pll.Data(:,2) - omega,...
        switch_model_3.pll.data(:,1) - switch_model_3.pll.data(:,3) + pi/2, switch_model_3.pll.Data(:,2) - omega);
    scatter(switch_model.pll.data(1,1) - switch_model.pll.data(1,3) + pi/2,switch_model.pll.Data(1,2) - omega, 50, 'g', 'filled');
    scatter(switch_model.pll.data(end,1) - switch_model.pll.data(end,3) + pi/2,switch_model.pll.Data(end,2) - omega,50, 'r', 'filled','d');
    scatter(switch_model_2.pll.data(end,1) - switch_model_2.pll.data(end,3) + pi/2,switch_model_2.pll.Data(end,2) - omega,50, 'r', 'filled','d');
    scatter(switch_model_3.pll.data(end,1) - switch_model_3.pll.data(end,3) + pi/2,switch_model_3.pll.Data(end,2) - omega,50, 'r', 'filled','d');
    hold off;
    ylabel('omega error');
    xlabel('theta error');
    title('Phase Plot switch model');
    legend('No cycle slip', 'One cycle slip', 'Many slips');
end
