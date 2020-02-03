%Preprocessing and normalizing of Axial and Bending force/Moment variation
sine1 = dsp.SineWave(0.175E3,9);
sine1.SamplesPerFrame = 9000;
A = sine1();

Norm_Ben = A; % Sinusoidal data set

%%%%%%%%%%%%%%%%%%%%%Enter the VM stress of the point of interest here%%%%%%%%%%%%%%%%%%%%%%%%%%
VM = 5.7353E5; % Ave Equivalent von-Mises from FEM model {Pa}
VM_Ben =  Norm_Ben*VM; %Fluctuation of VM stress with varying BM

plot (VM_Ben)
n = size(findpeaks(VM_Ben),1); % Number of cycles. Number of peaks equals to the number of cycles
%Definitions
SIG_a_Ben = (max(VM_Ben)-min(VM_Ben))/2; %sigma_a = range/2

SIG_m_Ben = 0; %sigma_m = mean/2

%%determination of the equivalent fully reversed stress for each mean and range
S_ut = 4.6E8;

%%determination of a and b
f= 0.9; %This is the "Fatigue Strength factor" which is almost equal to 0.9 
        %(Shiegle's book Figure 6-18. S_ut = 500 MPa = 72 kpsi)
S_e_gross = S_ut/2; % Approximately, the endurance limit is half of the S_ut (Ref: Engineering Toolbox)
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
S_e = k_a*k_b*k_c*k_d*k_e*k_f*S_e_gross;
a = (f*S_ut)^2/S_e;
b = (-1/3)*log10(f*S_ut/S_e);


N = (SIG_a_Ben/a)^(1/b);

format shortE

%%Damage calculation

   Damage =  n/N;

Damage_Percentage = Damage*100
%Remaining_Time_hrs = (10/(Damage_Percentage/100))/3600
Remaining_Time_hrs_1 = (N/n)*10/3600
