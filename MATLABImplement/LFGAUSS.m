%   Power flow solution by Gauss-Seidel method

Vm=0; delta=0; yload=0; deltad =0;
nbus = length(busdata(:,1));

for k=1:nbus
n=busdata(k,1);
kb(n)=busdata(k,2); Vm(n)=busdata(k,3); delta(n)=busdata(k, 4);
Pd(n)=busdata(k,5); Qd(n)=busdata(k,6); Pg(n)=busdata(k,7); Qg(n)=busdata(k,8);
Qmin(n)=busdata(k,9); Qmax(n)=busdata(k,10);
Qsh(n)=busdata(k,11);

    if Vm(n) <= 0
        Vm(n) = 1.0; V(n) = 1 + j*0;
    else
        delta(n) = pi/180*delta(n);
        V(n) = Vm(n)*(cos(delta(n)) + j*sin(delta(n)));
        P(n)=(Pg(n)-Pd(n))/basemva;
        Q(n)=(Qg(n)-Qd(n)+ Qsh(n))/basemva;
        S(n) = P(n) + j*Q(n);
    end
    DV(n)=0;
end

num = 0; AcurBus = 0; converge = 1;
Vc = zeros(nbus,1)+j*zeros(nbus,1);

% Default parameters
if ~exist('accel','var'), accel = 1.3; end
if ~exist('accuracy','var'), accuracy = 0.001; end
if ~exist('basemva','var'), basemva = 100; end
if ~exist('maxiter','var'), maxiter = 100; end

iter=0;
maxerror=10;

% ✅ Storage variables
V_store=[];
delta_store=[];
mismatch_store=[];

while maxerror >= accuracy && iter <= maxiter

    iter=iter+1;

    for n = 1:nbus
        
        YV = 0 + j*0;
        
        for L = 1:nbr
            if nl(L) == n
                k=nr(L);
                YV = YV + Ybus(n,k)*V(k);
            elseif nr(L) == n
                k=nl(L);
                YV = YV + Ybus(n,k)*V(k);
            end
        end

        Sc = conj(V(n))*(Ybus(n,n)*V(n) + YV);
        Sc = conj(Sc);

        DP(n) = P(n) - real(Sc);
        DQ(n) = Q(n) - imag(Sc);

        if kb(n) == 1
            S(n) =Sc; 
            P(n) = real(Sc); 
            Q(n) = imag(Sc); 
            DP(n) =0; 
            DQ(n)=0;
            Vc(n) = V(n);

        elseif kb(n) == 2
            Q(n) = imag(Sc); 
            S(n) = P(n) + j*Q(n);
        end

        if kb(n) ~= 1
            Vc(n) = (conj(S(n))/conj(V(n)) - YV )/ Ybus(n,n);
        end

        if kb(n) == 0
            V(n) = V(n) + accel*(Vc(n)-V(n));

        elseif kb(n) == 2
            VcI = imag(Vc(n));
            VcR = sqrt(Vm(n)^2 - VcI^2);
            Vc(n) = VcR + j*VcI;
            V(n) = V(n) + accel*(Vc(n) -V(n));
        end

    end

    maxerror = max([abs(DP), abs(DQ)]);

    % ✅ STORE VALUES FOR PLOTTING
    Vm_temp = abs(V);
    delta_temp = angle(V);

    V_store(iter,:) = Vm_temp;
    delta_store(iter,:) = delta_temp;
    mismatch_store(iter) = maxerror;

    if iter == maxiter && maxerror > accuracy
        fprintf('\nWARNING: Iterative solution did not converged after ')
        fprintf('%g', iter), fprintf(' iterations.\n\n')
        converge = 0;
    end

end

% Status
if converge ~= 1
    tech='ITERATIVE SOLUTION DID NOT CONVERGE';
else
    tech='Power Flow Solution by Gauss-Seidel Method';
end

% Final values
k=0;
for n = 1:nbus
    Vm(n) = abs(V(n)); 
    deltad(n) = angle(V(n))*180/pi;

    if kb(n) == 1
        S(n)=P(n)+j*Q(n);
        Pg(n) = P(n)*basemva + Pd(n);
        Qg(n) = Q(n)*basemva + Qd(n) - Qsh(n);
        k=k+1;
        Pgg(k)=Pg(n);

    elseif kb(n) ==2
        k=k+1;
        Pgg(k)=Pg(n);
        S(n)=P(n)+j*Q(n);
        Qg(n) = Q(n)*basemva + Qd(n) - Qsh(n);
    end

    yload(n) = (Pd(n)- j*Qd(n)+j*Qsh(n))/(basemva*Vm(n)^2);
end

% Totals
Pgt = sum(Pg);  
Qgt = sum(Qg); 
Pdt = sum(Pd); 
Qdt = sum(Qd); 
Qsht = sum(Qsh);

% Update busdata
busdata(:,3)=Vm'; 
busdata(:,4)=deltad';

% ✅ Send to workspace (same as NR)
assignin('base','V_store',V_store);
assignin('base','delta_store',delta_store);
assignin('base','mismatch_store',mismatch_store);

clear AcurBus DP DQ DV L Sc Vc VcI VcR YV converge delta