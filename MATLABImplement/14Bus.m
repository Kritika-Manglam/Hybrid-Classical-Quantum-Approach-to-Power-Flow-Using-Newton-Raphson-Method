clear
basemva = 100;  accuracy = 0.001; accel = 1.8; maxiter = 100;


%        Bus Bus  Voltage Angle   ---Load---- -------Generator----- Static Mvar
%        No  code Mag.    Degree  MW    Mvar  MW      Mvar     Qmin Qmax    +Qc/-Ql
busdata=[1   1    1.060    0.0   0.0   0.0   232.4 -16.01      0      0         0
         2   2    1.045    0.0   21.7  12.7  40     45.41     -0.40   0.5       0
         3   2    1.01     0.0   94.2  19    0.0    25.28      0      0.4       0
         4   0      1      0.0   47.8 -3.9   0.0     0.0       0      0         0
         5   0      1      0.0   7.6   1.6   0.0     0.0       0      0         0
         6   2    1.07     0.0   11.2  7.5   0.0    13.62     -0.06   0.24      0
         7   0     1       0.0   0.0   0.0   0.0     0.0       0      0         0
         8   2    1.09     0.0   0.0   0.0   0.0    18.24     -0.06   0.24      0
         9   0      1      0.0   29.5  16.6  0.0     0.0       0      0         0.19
         10  0      1      0.0   9     5.8   0.0     0.0       0      0         0
         11  0      1      0.0   3.5   1.8   0.0     0.0       0      0         0
         12  0      1      0.0   6.1   1.6   0.0     0.0       0      0         0
         13  0      1      0.0   13.5  5.8   0.0     0.0       0      0         0
         14  0      1      0.0   14.9  8     0.0     0.0       0      0         0];
%                                                 Line code
%         Bus bus   R          X          1/2 B   = 1 for lines
%         nl  nr  p.u.        p.u.         p.u.     > 1 or < 1 tr. tap at bus nl
linedata=[1   2   0.01938     0.05917     0.0264      1;
          2   3   0.04699     0.19797     0.0219      1;
          2   4   0.05811     0.17632     0.0187      1; 
          1   5   0.05403     0.22304     0.0246      1; 
          2   5   0.05695     0.17388     0.017       1; 
          3   4   0.06701     0.17103     0.0173      1; 
          4   5   0.01335     0.04211     0.0064      1; 
          5   6     0         0.25202     0       0.932; 
          4   7     0         0.20912     0       0.978; 
          7   8     0         0.17615     0           1; 
          4   9     0         0.55618     0       0.969; 
          7   9     0         0.11001     0           1; 
          9   10   0.03181    0.0845      0           1; 
          6   11   0.09498    0.1989      0           1;
          6   12   0.12291    0.25581     0           1; 
          6   13   0.06615    0.13027     0           1; 
          9   14   0.12711    0.27038     0           1; 
          10  11   0.08205    0.19207     0           1; 
          12  13   0.22092    0.19988     0           1; 
          13  14   0.17093    0.34802     0           1];

          
          
          
                                                        
          
LFYBUS              % form the bus admittance matrix
LFNEWTON            % Load flow solution by Gauss-Seidel method
plot_result         %for plotting 
BUSOUT              % Prints the power flow solution on the screen
LINEFLOW            % Computes and displays the line flow and losses
