clear
basemva = 100;  accuracy = 0.001; accel = 1.8; maxiter = 100;


%        Bus Bus  Voltage Angle   ---Load---- -------Generator----- Static Mvar
%        No  code Mag.    Degree  MW    Mvar  MW  Mvar Qmin Qmax    +Qc/-Ql
busdata=[1   1    1.06    0.0     0.0   0.0   0.0  0.0   0   0       0
         2   0    1.0     0.0     20.0  10.0  40.0 30.0  30  30      0
         3   0    1.0     0.0     45.0  15.0  0.0  0.0   0   0       0
         4   0    1.0     0.0     40.0   5.0  0.0  0.0   0   0       0                        
         5   0    1.0     0.0     60.0  10.0  0.0  0.0   0   0       0 ];

%                                        Line code
%         Bus bus   R      X     1/2 B   = 1 for lines
%         nl  nr  p.u.   p.u.   p.u.     > 1 or < 1 tr. tap at bus nl
linedata=[1   2   0.02   0.06   0.03            1
          1   3   0.08   0.24   0.025           1
          2   3   0.06   0.18   0.02            1
          2   4   0.06   0.18   0.02            1
          2   5   0.04   0.12   0.015           1
          3   4   0.01   0.03   0.01            1
          4   5   0.08   0.24   0.025           1];

LFYBUS              % form the bus admittance matrix
LFGAUSS            % Load flow solution by Gauss-Seidel method
plot_result         %for plotting 
BUSOUT              % Prints the power flow solution on the screen
LINEFLOW            % Computes and displays the line flow and losses
