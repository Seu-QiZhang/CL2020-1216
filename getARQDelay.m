%This file is created by Xu Xiaoli on 2020/04/14
%It generate the ana and simu results for ARQ in the presence of delayed
%feedback

%BusySlot: the ratio of busy slot
%Delievered: the ratio of delievered packet
% N=10000;
% p=0.45;
% lambda=0.5;
% T=20;
function simuLatency=getARQDelay(lambda,p,N,T)
PackeTransmitted=(rand(1,N)>p); %record the channel status in the time slots
PacketArrive=(rand(1,N)<lambda); %record the packet arrival 

PacketArriveTS=find(PacketArrive==1);%The time slot with new packet arrival
PacketIndexAllTS=zeros(1,N);%the store which packet is sent on each time slot
DelieverStatus=ones(1,length(PacketArriveTS));%Those packet that are not properly received till the end of simulation
PacketDelivereTS=zeros(1,length(PacketArriveTS));%to store the time slot when the packet is delievered

for i=1:length(PacketArriveTS)  
    %Transmit at the first free TS after its arrival
    selectedTS=find(PacketIndexAllTS(PacketArriveTS(i):end)==0,1,'first')+PacketArriveTS(i)-1;
    PacketIndexAllTS(selectedTS)=i; %this time slot is used for sending ith packet
    if isempty(selectedTS)
       DelieverStatus(i)=0;
       continue; %If the selectedTS is greater than the range we consider, this packet is not going to be received properly
    end
    while PackeTransmitted(selectedTS)==0
        %if the packet is erased, schedule the retransmission
        %Retransmission should have priority than the new packet for minimizing the in-order deliver delay
        RetransmissionStart=selectedTS+T;%the time slot to get feedback
        %find the first free time slot after receiving the feedback
        selectedTS=find(PacketIndexAllTS(RetransmissionStart:end)==0,1,'first')+RetransmissionStart-1;
        if isempty(selectedTS)
            DelieverStatus(i)=0;
            break; %If the selectedTS is greater than the range we consider, this packet is not going to be received properly
        end
        PacketIndexAllTS(selectedTS)=i;        
    end 
    if DelieverStatus(i)==1
        PacketDelivereTS(i)=selectedTS+1;%by the end of selectedTS, the packet can be delivered successfully
    end
end
InOrderDelieverTS=PacketDelivereTS;
for i=2:length(PacketDelivereTS)
    if InOrderDelieverTS(i)<InOrderDelieverTS(i-1)
        InOrderDelieverTS(i)=InOrderDelieverTS(i-1);
    end
end

Indx=find(DelieverStatus==1);
simuLatency=mean(InOrderDelieverTS(Indx)-PacketArriveTS(Indx));

anaLatency=lambda*p/((1-p)*(1-p-lambda))+(p*T+1)/(1-p);
Delievered=sum(DelieverStatus)/length(DelieverStatus); 
BusySlot=sum(PacketIndexAllTS~=0)/N;
