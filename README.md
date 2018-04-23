# Nonlinear_PLL

To run simulations and verify results the matlab script files in the folder should
be used. All simulink models are automatically called from the scripts. The fold-
ers Simulink Models and Functions should be added to the matlab path for the
programs to execute correctly. Below follows a short description of each program:

- __VSC_Model_Verification.m__
  This program verify that the converter works as expected. First a step of 1000
  W is set as the power controller reference, then at time t = 1 the reference is
  set to -1000 W. The converter is connected directly to an AC voltage source.
  
- __VSC_Model_Verification_w_Grid.m__
  This program verify that the converter works as expected when a grid trans-
  mission line is added between the voltage/current measurements and the AC
  voltage source. The power steps are the same as the previous program.

- __VSC_Provoked_Cycle_Slip.m__
  This program show how the converter behave when cycle slipping is provoked
  from within the PLL. The estimated frequency disturbance to move to PLL
  out of phase lock is added to the PLL output frequency. Three disturbances
  are added, one where the PLL maintain lock, one where the PLL slips exactly
  one cycle and the last disturbance result in many slips. The converter is
  connected directly to an AC voltage source.
  
- __VSC_Provoked_Cycle_Slip_w_Grid.m__
  Exactly the same as the previous program except that the grid transmission
  line is added.

- __VSC_Phase_Shift_w_Grid.m__
  A phase shift is invoked in the AC voltage source. The converter is connected
  to a grid transmission line. The inductance in the line is increased to represent
  a weak grid. The average model is stopped prematurely due to divergence of
  the solution.
  
- __VSC_Phase_Shift_w_Grid.m__
  A step of 1400 W is applied to the active power controller reference at time
  t = 0. This time the converter is connected to a weak grid. Due to divergence
  of the average model only the switching device model is used.
