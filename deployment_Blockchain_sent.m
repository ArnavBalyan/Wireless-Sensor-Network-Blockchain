close all;
clear;
clc;

%%%%%%%%%%%%%%%%%%%% Network Establishment Parameters %%%%%%%%%%%%%%%%%%%%

%%% Area of Operation %%%

% Field Dimensions in meters %
xm=100;
ym=100;
x=0; % added for better display results of the plot
y=0; % added for better display results of the plot
% Number of Nodes in the field %
n=50;
% Number of Dead Nodes in the beggining %
dead_nodes=0;
% Coordinates of the gateway (location is predetermined in this simulation) %
gatewayx=10;
gatewayy=100;

%%% Energy Values %%%
% Initial Energy of a Node (in Joules) % 
Eo=2; % units in Joules
% Energy required to run circuity (both for transmitter and receiver) %
Eelec=50*10^(-9); % units in Joules/bit
ETx=50*10^(-9); % units in Joules/bit
ERx=50*10^(-9); % units in Joules/bit
% Transmit Amplifier Types %
Eamp=100*10^(-12); % units in Joules/bit/m^2 (amount of energy spent by the amplifier to transmit the bits)
% Data Aggregation Energy %
EDA=5*10^(-9); % units in Joules/bit
% Size of data package %
k=4000; % units in bits

% total energy consumption in network
energy =0;
% Round of Operation %
rnd=10;

trans_range=25; %transmission range of each node in meters

% Current Number of operating Nodes %
operating_nodes=n;
transmissions=0;
temp_val=0;
flag1stdead=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%% End of Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%



            %%% Creation of the Wireless Sensor Network %%%

% Plotting the WSN %
for i=1:n
    
    SN(i).id=i;	% sensor's ID number
    SN(i).x=rand(1,1)*xm;	% X-axis coordinates of sensor node
    SN(i).y=rand(1,1)*ym;	% Y-axis coordinates of sensor node
    SN(i).E=Eo;     % nodes energy levels (initially set to be equal to "Eo"
    SN(i).cond=1;	% States the current condition of the node. when the node is operational its value is =1 and when dead =0
    SN(i).rop=0;	% number of rounds node was operational
    SN(i).neighbour=[];  %array of neighbour
    SN(i).cnt = 1;
    SN(i).vect=struct('Prev_Hash',{},'Timestamp',{},'Data',{},'Hash',{});
    SN(i).vect(1).Prev_Hash = 0;
    SN(i).vect(1).Timestamp = datestr(now,'mm dd, yyyy HH:MM:SS.FFF ');
    SN(i).vect(1).Data = i;
    strr = strcat(mat2str(SN(i).vect(1).Prev_Hash),mat2str(SN(i).vect(1).Timestamp),mat2str(SN(i).vect(1).Data));
    
    hasher = System.Security.Cryptography.SHA256Managed;
    hash0 = uint8(hasher.ComputeHash(uint8(strr)));
    SN(i).vect(1).Hash = dec2hex(hash0);
    
    hold on;
    figure(1)
    plot(x,y,xm,ym,SN(i).x,SN(i).y,'ob',gatewayx,gatewayy,'*r');
    title 'Wireless Sensor Network';
    xlabel '(m)';
    ylabel '(m)';
    
end

for i=1:1:(n )  % to find the neighbour node in network 
     for j=1:1:n
         dis=sqrt((SN(i).x-SN(j).x)^2 + (SN(i).y-SN(j).y)^2 );
         if(dis<=trans_range)
             SN(i).neighbour=[j SN(i).neighbour];
         end
     end
     
end



for r= 1:rnd

% transmission of message 

    for i=1:n
       if ((SN(i).cond==1) && (SN(i).E>0) )
            ETx= Eelec*k + Eamp * k * trans_range;
            SN(i).E=SN(i).E - ETx;
            energy=energy+ETx;
            %SN(i).time_stamp = generate TODO
            %SN(i).hash = generate TODO
        % Dissipation for all the neighbour nodes during reception
        
       for j= 1: length(SN(i).neighbour)
                
         
        
        if SN(SN(i).neighbour(j)).E>0 && SN(SN(i).neighbour(j)).cond==1 
            ERx=(Eelec+EDA)*k;
            energy=energy+ERx;
            SN(SN(i).neighbour(j)).E=SN(SN(i).neighbour(j)).E - ERx;
            pth = SN(i).cnt;
            for p = 1: pth
                flag = 1;
                counter = 0;
                nth  = SN(SN(i).neighbour(j)).cnt;
                for q = 1: nth
                    if SN(i).vect(p).Data == SN(SN(i).neighbour(j)).vect(q).Data
                        flag = 2;
                    end
                    
                end
                if flag == 1
                    SN(SN(i).neighbour(j)).cnt = SN(SN(i).neighbour(j)).cnt + 1;
                    SN(SN(i).neighbour(j)).vect(SN(SN(i).neighbour(j)).cnt).Prev_Hash = SN(SN(i).neighbour(j)).vect(SN(SN(i).neighbour(j)).cnt - 1).Hash;
                    SN(SN(i).neighbour(j)).vect(SN(SN(i).neighbour(j)).cnt).Timestamp = datestr(now,'mm dd, yyyy HH:MM:SS.FFF '); %SN(i).hash;
                    SN(SN(i).neighbour(j)).vect(SN(SN(i).neighbour(j)).cnt).Data = SN(i).vect(p).Data;
                    finalstr = strcat(mat2str(SN(SN(i).neighbour(j)).vect(SN(SN(i).neighbour(j)).cnt).Prev_Hash),mat2str(SN(SN(i).neighbour(j)).vect(SN(SN(i).neighbour(j)).cnt).Timestamp),mat2str(SN(SN(i).neighbour(j)).vect(SN(SN(i).neighbour(j)).cnt).Data));
                    hashObject = System.Security.Cryptography.SHA256Managed;
                    hash1 = uint8(hashObject.ComputeHash(uint8(finalstr)));
                    SN(SN(i).neighbour(j)).vect(SN(SN(i).neighbour(j)).cnt).Hash = dec2hex(hash1);
                    %SN(SN(i).neighbour(j)).cnt = SN(SN(i).neighbour(j)).cnt + 1;
                    
                end
            end
            
            
             if SN(SN(i).neighbour(j)).E<=0  % if cluster heads energy depletes with reception
                SN(SN(i).neighbour(j)).cond=0;
                dead_nodes=dead_nodes +1;
                operating_nodes = operating_nodes - 1;
             end
        end
        end
        
        
        
        
            if SN(i).E<=0       % if nodes energy depletes with transmission
            dead_nodes=dead_nodes +1;
            operating_nodes = operating_nodes - 1;
            SN(i).cond=0;
            end
        
      end
    end   

end