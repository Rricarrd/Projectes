clear
clc
% Torque Requirements for a Rectangular Propeller
% Propeller physical caratheristics
radius = 0.5; %[m] Distance from the hub to the tip ########### FIXAT
chord = [0.08 0.025]; %[m] Assumed constant chord ########### ES POT VARIAR
pitch = [14 3]; %[º] Angle between the airfoil's chord and the hub's plane ########### ES POT VARIAR
n_blades = 2;  %########### ES POT VARIAR


% Airfoil selected - S1223-IL
Re = [50000 100000 200000 500000 1000000];

% Section calculations
g = 9.81; %[m/s^2] Gravity Acceleration
rho = 1.225; %[kg/m^3] Air Density
mu = 1.8e-5; %[Ns/m] Dynamic Viscosity


elements = 100; %Number of domain elements
pi = 3.141592;
oswald = 0.85;
motor_efficiency = 0.9;
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


%Profile Alphas
alpha = linspace(pitch(1),pitch(2), elements);


%Aerodynamic Variables
 Lift = zeros(elements,1);
 Drag = zeros(elements,1);
 Torque = zeros(elements,1);
 Efficiency_wing = zeros(elements,1);
 Efficiency_airfoil = zeros(elements,1);

 S = zeros(elements+1,1);
 CD = zeros(elements,1);
 CL = zeros(elements,1);
 Cl = zeros(elements,1);
 Cd = zeros(elements,1);
 Re_X= zeros(elements,1);
 
Total_Lift = zeros(elements,1); %[N]
Total_Drag = zeros(elements,1); %[N]
Total_Torque = zeros(elements,1); %[Nm]

THRUST= zeros(elements,1); %[kgf]
MECHANICAL_POWER = zeros(elements,1); %[kW]
ELECTRICAL_POWER = zeros(elements,1);
TP_RATIO = zeros(elements,1);%[kgf/kW]


rpm = 4500;
omega = (rpm*2*pi)/60; %[rad/s]

chord_end = linspace(0.04,0.01,elements);

for k = 1:elements

%Profile Chords
local_chord = linspace(chord(1),chord_end(1,k), elements+1);

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
    AR = (radius)^2/(0.5*(chord(1)+chord_end(1,k))*radius); %Whole Wing AR with trapezoidal area
    S(i,1) = 0.5*(local_chord(i)+local_chord(i+1))*(radius/elements); %[m^2] Element Surface Trapezoidal
   
    
    %Coeficients de la pala completa
    CL(i,1) = Cl(i,1);
    CD(i,1) = Cd(i,1) + CL(i,1)^2/(AR*pi*oswald) ;
    
    
    %Lift i drag
    Lift(i,1) = 0.5*rho*S(i,1)*(omega*x)^2*CL(i,1);
    Drag(i,1) = 0.5*rho*S(i)*(omega*x)^2*CD(i,1);
    Torque(i,1) = 0.5*rho*S(i)*(omega*x)^2*CD(i,1)*x;
    Efficiency_wing(i,1) = CL(i,1)/CD(i,1);
    Efficiency_airfoil(i,1) = Cl(i,1)/Cd(i,1);
    
    Total_Lift(k,1) = Total_Lift(k,1) + Lift(i,1) ;
    Total_Drag(k,1) = Total_Drag(k,1) +  Drag(i,1) ;
    Total_Torque(k,1) = Total_Torque(k,1) +  Torque(i,1);
    
end



% Double Bladed Propeller
Total_Lift(k,1) = n_blades*Total_Lift(k,1); %[N]
Total_Drag(k,1) = n_blades*Total_Drag(k,1); %[N]
Total_Torque(k,1) = n_blades*Total_Torque(k,1); %[Nm]

% Units Adaptation
THRUST(k,1) = (Total_Lift(k,1)/g); %[kgf]
MECHANICAL_POWER(k,1) = Total_Torque(k,1)*omega/1000; %[kW]
ELECTRICAL_POWER(k,1) = MECHANICAL_POWER(k,1)/(motor_efficiency*ESC_efficiency);
TP_RATIO(k,1) = THRUST(k,1)/ELECTRICAL_POWER(k,1);%[kgf/kW]


end

%% PLot 1
figure

%Thrust
yyaxis left
plot(chord_end,THRUST);

xlabel('Wing End Chord (m)');
ylabel('Thrust (kgf)');
hold on

%Electrical Power
yyaxis right
plot(chord_end,ELECTRICAL_POWER);
ylabel('Electrical Power (kW)');
hold off


%% Plot 2
figure
plot(chord_end,TP_RATIO);
xlabel('Wing End Chord (m)');
ylabel('Thrust/Power Ratio (kgf/kW)');
