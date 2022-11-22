clear
clc
% Torque Requirements for a Rectangular Propeller
% Propeller physical caratheristics
radius = 0.5; %[m] Distance from the hub to the tip ########### FIXAT
chord = [0.08 0.025]; %[m] Assumed constant chord ########### ES POT VARIAR
pitch = [14 3]; %[º] Angle between the airfoil's chord and the hub's plane ########### ES POT VARIAR
n_blades = 2;  %########### ES POT VARIAR
rpm = 4500;
omega = (rpm*2*pi)/60; %[rad/s]

% Airfoil selected - S1223-IL
Re = [50000 100000 200000 500000 1000000];

% Section calculations
g = 9.81; %[m/s^2] Gravity Acceleration
rho = 1.225; %[kg/m^3] Air Density
mu = 1.8e-5; %[Ns/m] Dynamic Viscosity


elements = 200; %Number of domain elements
pi = 3.141592;
oswald = 0.85;
motor_efficiency = 0.92;
ESC_efficiency = 0.9;

%Airfoil Data S1223-IL
Re5e4_tab = readtable('xf-s1223-il-50000-n5.csv');
Re1e5_tab = readtable('xf-s1223-il-100000-n5.csv');
Re2e5_tab = readtable('xf-s1223-il-200000-n5.csv');
Re5e5_tab = readtable('xf-s1223-il-500000-n5.csv');
Re1e6_tab = readtable('xf-s1223-il-1000000-n5.csv');

Re5e4 = table2array(Re5e4_tab);
Re1e5 = table2array(Re1e5_tab);
Re2e5 = table2array(Re2e5_tab);
Re5e5 = table2array(Re5e5_tab);
Re1e6 = table2array(Re1e6_tab);

%Profile Chords
local_chord = linspace(chord(1),chord(2), elements);
%Profile Alphas
alpha = linspace(pitch(1),pitch(2), elements);

%Aerodynamic Variables
 Lift = zeros(elements,1);
 Drag = zeros(elements,1);
 Torque = zeros(elements,1);
 Efficiency_wing = zeros(elements,1);
 Efficiency_airfoil = zeros(elements,1);

 CD = zeros(elements,1);
 CL = zeros(elements,1);
 Cl = zeros(elements,1);
 Cd = zeros(elements,1);
 Re_X= zeros(elements,1);
 
Total_Lift = 0; %[N]
Total_Drag = 0; %[N]
Total_Torque = 0; %[Nm]

dist = linspace(0,radius,elements); %[m]

for i = 1:elements
    
    %Local Reynolds
    x = radius*i/elements; % Central position of the element
    Re_X(i,1) =(rho*omega*x*local_chord(i))/mu;
   
    
    if Re_X(i,1) <= Re(1) %%Re<50000 ######################
       
     for j = 1:size(Re5e4)-1
      if Re5e4(j+1,1)>alpha(i) && Re5e4(j,1)<=alpha(i)
      Cl2 = Re5e4(j,2);   
      Cd2 = Re5e4(j,3);     
      end 
     end
     
     Cl1 = 0;
     Cd1 = 0;
     
     Cl(i,1) = Interpol(0,Cl1,Re(1),Cl2,Re_X(i,1));
     Cd(i,1) = Interpol(0,Cd1,Re(1),Cd2,Re_X(i,1));
     
    elseif  Re_X(i,1)>Re(1) && Re_X(i,1)<=Re(2) %% 50000<Re<100000  ######################
       
     for j = 1:size(Re5e4)-1
      if Re5e4(j+1,1)>alpha(i) && Re5e4(j,1)<=alpha(i)
      Cl1 = Re5e4(j,2);   
      Cd1 = Re5e4(j,3);     
      end 
     end
     
     for j = 1:size(Re1e5)-1
      if Re1e5(j+1,1)>alpha(i) && Re1e5(j,1)<=alpha(i)
      Cl2 = Re1e5(j,2);   
      Cd2 = Re1e5(j,3);     
      end 
     end
        
    Cl(i,1) = Interpol(Re(1),Cl1,Re(2),Cl2,Re_X(i,1));
    Cd(i,1) = Interpol(Re(1),Cd1,Re(2),Cd2,Re_X(i,1)); 
     
    elseif  Re_X(i,1)>Re(2) && Re_X(i,1)<=Re(3)   %% 100000<Re<200000  ######################
      
     for j = 1:size(Re1e5)-1
      if Re1e5(j+1,1)>alpha(i) && Re1e5(j,1)<=alpha(i)
      Cl1 = Re1e5(j,2);   
      Cd1 = Re1e5(j,3);     
      end 
     end
     
     for j = 1:size(Re2e5)-1
      if Re2e5(j+1,1)>alpha(i) && Re2e5(j,1)<=alpha(i)
      Cl2 = Re2e5(j,2);   
      Cd2 = Re2e5(j,3);     
      end 
     end
    
    Cl(i,1) = Interpol(Re(2),Cl1,Re(3),Cl2,Re_X(i,1));
    Cd(i,1) = Interpol(Re(2),Cd1,Re(3),Cd2,Re_X(i,1)); 
        
    elseif  Re_X(i,1)>Re(3) && Re_X(i,1)<=Re(4)   %% 200000<Re<500000  ######################
        
     for j = 1:size(Re2e5)-1
      if Re2e5(j+1,1)>alpha(i) && Re2e5(j,1)<=alpha(i)
      Cl1 = Re2e5(j,2);   
      Cd1 = Re2e5(j,3);     
      end 
     end
     
     for j = 1:size(Re5e5)-1  
      if Re5e5(j+1,1)>alpha(i) && Re5e5(j,1)<=alpha(i)
      Cl2 = Re5e5(j,2);   
      Cd2 = Re5e5(j,3);    
      end 
     end
     
    Cl(i,1) = Interpol(Re(3),Cl1,Re(4),Cl2,Re_X(i,1));
    Cd(i,1) = Interpol(Re(3),Cd1,Re(4),Cd2,Re_X(i,1)); 
     
      elseif  Re_X(i,1)>Re(4) && Re_X(i,1)<=Re(5)   %% 500000<Re<1000000  ######################
        
     for j = 1:size(Re5e5)-1  
      if Re5e5(j+1,1)>alpha(i) && Re5e5(j,1)<=alpha(i)
      Cl1 = Re5e5(j,2);   
      Cd1 = Re5e5(j,3);     
      end 
     end
     
     for j = 1:size(Re1e6)-1  
      if Re1e6(j+1,1)>alpha(i) && Re1e6(j,1)<=alpha(i)
      Cl2 = Re1e6(j,2);   
      Cd2 = Re1e6(j,3);     
      end 
     end
        
    Cl(i,1) = Interpol(Re(4),Cl1,Re(5),Cl2,Re_X(i,1));
    Cd(i,1) = Interpol(Re(4),Cd1,Re(5),Cd2,Re_X(i,1)); 
     
    elseif  Re_X(i,1)>Re(5)  %% Re<1000000  ######################
        
     for j = 1:size(Re1e6)-1  
      if Re1e6(j+1,1)>alpha(i) && Re1e6(j,1)<=alpha(i)
      Cl1 = Re1e6(j,2);   
      Cd1 = Re1e6(j,3);     
      end 
      
     Cl2 = 0;
     Cd2 = 0;
     end
     
      Cl(i,1) = Interpol(3e6,Cl2,Re(5),Cl1,Re_X(i,1));
      Cd(i,1) = Interpol(3e6,Cd2,Re(5),Cd1,Re_X(i,1)); 
      
    else 
    end
    
  
 
    %AR (induced drag assumed constant along the wing)
    if i<elements
    AR = (radius)^2/(0.5*(chord(1)+chord(2))*radius); %Whole Wing AR with trapezoidal area
    S = 0.5*(local_chord(i)+local_chord(i+1))*(radius/elements); %[m^2] Element Surface Trapezoidal
    else
    end
    
    %Coeficients de la pala completa
    CL(i,1) = Cl(i,1);
    CD(i,1) = Cd(i,1) + CL(i,1)^2/(AR*pi*oswald) ;
    
    
    %Lift i drag
    Lift(i,1) = 0.5*rho*S*(omega*x)^2*CL(i,1);
    Drag(i,1) = 0.5*rho*S*(omega*x)^2*CD(i,1);
    Torque(i,1) = 0.5*rho*S*(omega*x)^2*CD(i,1)*x;
    Efficiency_wing(i,1) = CL(i,1)/CD(i,1);
    Efficiency_airfoil(i,1) = Cl(i,1)/Cd(i,1);
    
    Total_Lift = Total_Lift + Lift(i,1) ;
    Total_Drag = Total_Drag +  Drag(i,1) ;
    Total_Torque = Total_Torque +  Torque(i,1);
    
end



% Double Bladed Propeller
Total_Lift = n_blades*Total_Lift; %[N]
Total_Drag = n_blades*Total_Drag; %[N]
Total_Torque = n_blades*Total_Torque; %[Nm]

% Units Adaptation
THRUST = (Total_Lift/g); %[kgf]
MECHANICAL_POWER = Total_Torque*omega/1000; %[kW]
ELECTRICAL_POWER = MECHANICAL_POWER/(motor_efficiency*ESC_efficiency);
TP_RATIO = THRUST/ELECTRICAL_POWER;%[kgf/kW]




%% PLot 1
figure
title('CL and CD distributions');
%Cl
yyaxis left
plot(dist*100,CL);

xlabel('Blade distance from root (cm)');
ylabel('CL');
hold on

%Cd
yyaxis right
plot(dist*100,CD);
ylabel('CD');
hold off


figure
title('Lift and Drag distributions');
%Lift
yyaxis left
plot(dist*100,Lift);

xlabel('Blade distance from root (cm)');
ylabel('Lift (N)');
hold on

%Drag
yyaxis right
plot(dist*100,Drag);
ylabel('Drag (N)');

hold off


%Torque
figure
title('Torque distribution');
plot(dist*100,Torque);
ylabel('Torque (Nm)');
xlabel('Blade distance from root (cm)');

% %% Plot 2
% figure
% plot(rpm,TP_RATIO);
% xlabel('Rotational Speed (RPM)');
% ylabel('Thrust/Power Ratio (kgf/kW)');



%% X8 Configuration
n_motors = 8;
X8_loses = 0.8;
TOTAL_THRUST = THRUST*n_motors*X8_loses;
TOTAL_POWER = ELECTRICAL_POWER*n_motors;
