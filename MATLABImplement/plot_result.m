% Plot Results for Newton-Raphson Load Flow

% Check if variables exist
if ~exist('V_store','var') || ~exist('delta_store','var') || ~exist('mismatch_store','var')
    error('Run LFNEWTON first to generate iteration data.');
end

%% 🔹 Voltage Convergence
figure;
plot(V_store,'-o','LineWidth',2);
grid on;

xlabel('Iteration');
ylabel('Voltage Magnitude (p.u.)');
title('Voltage Convergence (Newton-Raphson)');

legend_strings = {};
for i = 1:size(V_store,2)
    legend_strings{i} = ['Bus ' num2str(i)];
end
legend(legend_strings,'Location','best');

%% 🔹 Angle Convergence
figure;
plot(delta_store * 180/pi,'-o','LineWidth',2);
grid on;

xlabel('Iteration');
ylabel('Voltage Angle (Degree)');
title('Angle Convergence');

legend(legend_strings,'Location','best');

%% 🔹 Mismatch Convergence (Log Scale)
figure;
semilogy(mismatch_store,'-o','LineWidth',2);
grid on;

xlabel('Iteration');
ylabel('Maximum Power Mismatch');
title('NR Convergence Characteristics');
