%%
%Preprocessing and normalizing of Axial and Bending force/Moment variation
load('InitialData.mat');
A = Tim_1_Axi_2_Ben_3;% Time, Axial, and Bending in the columns respectively
Norm_Ben = A(1:8940,3);%/abs(max(A(1:8940,3))); % The Bending moment CAN BE made to be oscillating about 1 and -1.
                        %But the FEM analysis is for 1 N m so need not to do here

%%%%%%%%%%%%%%%%%%%%%Enter the VM stress of the point of interest here%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = 'Enter the maximum von Mises stress of the point of interest here? You can enter 5.7353E5 Pa as it is already found from the FEM Model for 1 N load: ';
VM = input (prompt); % Ave Equivalent von-mises from FEM model {Pa}
VM_Ben =  Norm_Ben*VM; %Fluctuation of VM stress with varying BM
%%
%Apply rainflow counting
C_Ben = rainflow(VM_Ben);
TT_Ben = array2table(C_Ben,'VariableNames',{'Count','Range','Mean','Start','End'});
rainflow(VM_Ben)

%%
%Definitions
SIG_a_Ben = 1/2*C_Ben(:,2); %sigma_a = range/2

SIG_m_Ben = 1/2*C_Ben(:,3); %sigma_m = mean/2
S_ut = 4.6E8; % material Property

%%
% determination of a and b
f= 0.9; %This is the "Fatigue Strength factor" which is almost equal to 0.9 
        %(Shiegle's book Figure 6-18. S_ut = 500 MPa = 72 kpsi)
S_e_raw = S_ut/2; % Approximately, the endurance limit is half of the S_ut (Ref: Engineering Toolbox)
a1 = 1.58;%(Table 6.2 Shiegley's)
b1 = -0.085;
d= 88.9;% diameter in mm
d_e = 0.37*d; %effective size of a round corresponding to a nonrotating solid or hollow round. (Equation 6-24)
k_a = a1*S_ut^b1; %Equation 6-19
k_b = 1.51*d_e^(-0.157); % Equation 6-20
k_c = 1;% because only bending
k_d = 1; % Because S_T/S_RT is almost 1 according to table 6-4
k_e = 1; % Reliability factor (This is an assumed value from Table 6-5)
k_f = 1; % Miscelaneous

S_e = k_a*k_b*k_c*k_d*k_e*k_f*S_e_raw;

a = (f*S_ut)^2/S_e;
b = (-1/3)*log10(f*S_ut/S_e);

%%
% determination of the equivalent fully reversed stress for each mean and
% range

S_f = []; % equivalent fully reversed stress. Here the Gerber Criteria is used.
for i = 1:size(SIG_a_Ben,1)
    if SIG_m_Ben(i,1) > 0
        S_f = [S_f; SIG_a_Ben(i,1)/(1-(SIG_m_Ben (i,1)/S_ut)^2)];
    else
        S_f = [S_f; S_e];
    end
end
 

%%
N =[];
for i = 1:size(S_f,1)
    N = [N; (S_f(i,1)/a)^(1/b)]; % Equation 6-16
end

format shortE

%%
% Damage calculation

Damage = [];
for i =1:size(N,1)
   Damage =  [Damage; C_Ben(i,1)./N(i,1)]; 
end

Damage_Percentage = sum(Damage)*100
Remaining_Time_hrs = (10/(Damage_Percentage/100))/3600