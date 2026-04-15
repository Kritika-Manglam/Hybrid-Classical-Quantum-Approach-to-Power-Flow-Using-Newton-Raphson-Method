%   Power flow solution by Newton-Raphson method

ns=0; ng=0;
nbus = length(busdata(:,1));

% Initialize
for k=1:nbus
    n=busdata(k,1);
    kb(n)=busdata(k,2);
    Vm(n)=busdata(k,3);
    delta(n)=busdata(k,4);
    Pd(n)=busdata(k,5);
    Qd(n)=busdata(k,6);
    Pg(n)=busdata(k,7);
    Qg(n)=busdata(k,8);
    Qmin(n)=busdata(k,9);
    Qmax(n)=busdata(k,10);
    Qsh(n)=busdata(k,11);

    delta(n)=pi/180*delta(n);
    V(n)=Vm(n)*(cos(delta(n))+1j*sin(delta(n)));

    P(n)=(Pg(n)-Pd(n))/basemva;
    Q(n)=(Qg(n)-Qd(n)+Qsh(n))/basemva;
end

% Count buses
for k=1:nbus
    if kb(k)==1, ns=ns+1; end
    if kb(k)==2, ng=ng+1; end
    ngs(k)=ng;
    nss(k)=ns;
end

Ym=abs(Ybus); 
t=angle(Ybus);

m=2*nbus-ng-2*ns;

maxerror=1; 
iter=0; 
converge=1;

% ✅ Storage for plotting
V_store=[];
delta_store=[];
mismatch_store=[];

% Iteration
while maxerror >= accuracy && iter <= maxiter

    iter = iter + 1;
    A=zeros(m,m); 
    DC=zeros(m,1);

    for n=1:nbus
        nn=n-nss(n);
        lm=nbus+n-ngs(n)-nss(n)-ns;

        J11=0; J22=0; J33=0; J44=0;

        for i=1:nbr
            if nl(i)==n || nr(i)==n
                if nl(i)==n, l=nr(i); else, l=nl(i); end

                J11=J11+Vm(n)*Vm(l)*Ym(n,l)*sin(t(n,l)-delta(n)+delta(l));
                J33=J33+Vm(n)*Vm(l)*Ym(n,l)*cos(t(n,l)-delta(n)+delta(l));

                if kb(n)~=1
                    J22=J22+Vm(l)*Ym(n,l)*cos(t(n,l)-delta(n)+delta(l));
                    J44=J44+Vm(l)*Ym(n,l)*sin(t(n,l)-delta(n)+delta(l));
                end

                if kb(n)~=1 && kb(l)~=1
                    lk=nbus+l-ngs(l)-nss(l)-ns;
                    ll=l-nss(l);

                    A(nn,ll)=-Vm(n)*Vm(l)*Ym(n,l)*sin(t(n,l)-delta(n)+delta(l));

                    if kb(l)==0
                        A(nn,lk)=Vm(n)*Ym(n,l)*cos(t(n,l)-delta(n)+delta(l));
                    end
                    if kb(n)==0
                        A(lm,ll)=-Vm(n)*Vm(l)*Ym(n,l)*cos(t(n,l)-delta(n)+delta(l));
                    end
                    if kb(n)==0 && kb(l)==0
                        A(lm,lk)=-Vm(n)*Ym(n,l)*sin(t(n,l)-delta(n)+delta(l));
                    end
                end
            end
        end

        Pk = Vm(n)^2*Ym(n,n)*cos(t(n,n)) + J33;
        Qk = -Vm(n)^2*Ym(n,n)*sin(t(n,n)) - J11;

        if kb(n)==1
            P(n)=Pk; Q(n)=Qk;
        end

        if kb(n)==2
            Q(n)=Qk;
        end

        if kb(n)~=1
            A(nn,nn)=J11;
            DC(nn)=P(n)-Pk;
        end

        if kb(n)==0
            A(nn,lm)=2*Vm(n)*Ym(n,n)*cos(t(n,n))+J22;
            A(lm,nn)=J33;
            A(lm,lm)=-2*Vm(n)*Ym(n,n)*sin(t(n,n))-J44;
            DC(lm)=Q(n)-Qk;
        end
    end

    DX = A\DC;

    for n=1:nbus
        nn=n-nss(n);
        lm=nbus+n-ngs(n)-nss(n)-ns;

        if kb(n)~=1
            delta(n)=delta(n)+DX(nn);
        end
        if kb(n)==0
            Vm(n)=Vm(n)+DX(lm);
        end
    end

    maxerror=max(abs(DC));

    % ✅ Store for plotting
    V_store(iter,:)=Vm;
    delta_store(iter,:)=delta;
    mismatch_store(iter)=maxerror;

end

% Status message
if converge~=1
    tech='ITERATIVE SOLUTION DID NOT CONVERGE';
else
    tech='Power Flow Solution by Newton-Raphson Method';
end

% Final values
V = Vm.*cos(delta)+1j*Vm.*sin(delta);
deltad = delta*180/pi;

% Generator & load update
for n=1:nbus
    S(n)=P(n)+1j*Q(n);
    Pg(n)=P(n)*basemva + Pd(n);
    Qg(n)=Q(n)*basemva + Qd(n) - Qsh(n);
    yload(n)=(Pd(n)-1j*Qd(n)+1j*Qsh(n))/(basemva*Vm(n)^2);
end

% Update busdata
busdata(:,3)=Vm';
busdata(:,4)=deltad';

% Totals
Pgt=sum(Pg); 
Qgt=sum(Qg); 
Pdt=sum(Pd); 
Qdt=sum(Qd); 
Qsht=sum(Qsh);

% Send data for plotting
assignin('base','V_store',V_store);
assignin('base','delta_store',delta_store);
assignin('base','mismatch_store',mismatch_store);