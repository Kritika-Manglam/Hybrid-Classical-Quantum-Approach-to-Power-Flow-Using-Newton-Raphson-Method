clear
basemva = 100;  accuracy = 0.001; accel = 1.8; maxiter = 100;


%        Bus Bus  Voltage Angle   ---Load---- -------Generator----- Static Mvar
%        No  code Mag.    Degree  MW    Mvar  MW  Mvar Qmin Qmax    +Qc/-Ql
busdata=[1   1    1.05    0.0     0.0   0.0   0.0  0.0   0   0       0
         2   0    1.0     0.0     190   250   0.0  0.0   0   0       0
         3   2    1.04    0.0     0.0   0.0   380  0.0   0   0       0];

%                                        Line code
%         Bus bus   R      X     1/2 B   = 1 for lines
%         nl  nr  p.u.   p.u.   p.u.     > 1 or < 1 tr. tap at bus nl
linedata=[1   2   0.02   0.04     0            1
          1   3   0.01   0.03     0            1
          2   3   0.0125   0.025  0            1];

LFYBUS                          % form the bus admittance matrix
LFNEWTON                         % Load flow solution by Gauss-Seidel method
plot_result                     % for plotting
BUSOUT                          % Prints the power flow solution on the screen
LINEFLOW                        % Computes and displays the line flow and losses
