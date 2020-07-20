%This file is created by Xu Xiaoli on 23/03/2020
%It generates the expected latency for the POMDP based coding
%lambda: packet arrival rate
%p: packet erasrue probability
%N: the total time slots considered
%T: the feedback delay (T=0 corresponds to instantaneous feedback)

function ExpectedDelay=getPOMDPCoding(lambda,p,N,T)
PacketArrive=[1, (rand(1,N-1)<lambda)]; %Start from the first arriving packet
GenerateTime=find(PacketArrive==1);
DeliverTime=zeros(1,length(GenerateTime));%to store the deliver time for all the packets

Action=zeros(1,N); %To record the actions taken during all the N time slots
RealState=zeros(3,N); %To record the real value of waiting packet at the reciever side
w=0;
d=0;

belief0=1; %the belief that there is no waiting packet at the receiver
threshold=0.5;
numPacket=0; %to store the total number of packets processed

TransQueue=0;% The queue at transmitter side
State=[1,0,0]';
belief=[State; 1];
for i=1:T+1
    %There is no feedback information yet
    TransQueue=TransQueue+PacketArrive(i);
    belief0=getBelief0(belief);
    if TransQueue>0 && belief0>=threshold
        Action(i)=0; %send an information packet
        numPacket=numPacket+1; %the processed packet increased by 1
        TransQueue=TransQueue-1; %transmitting queue decrease by 1
        w=w+1;
        if rand>p
            %if this packet is successfully received
           if w==1
               %This is the only waiting packet
               DeliverTime(numPacket)=i+1; %received at the beginning of the next time slot
               w=0;
           else
               d=d+1;
           end
        end
    else
        Action(i)=1;
        if rand>p
            d=d+1;
            if d>=w-0.001
                DeliverTime((numPacket-w+1):numPacket)=i+1;%all the waiting packets are delivered
                w=0;
                d=0;
            end
        end
    end
    RealState(:,i+1)=[TransQueue;w;d];
    belief=UpdateBelief2(belief,PacketArrive(i),Action(i),lambda,p,1);
end


for i=T+2:N
    TransQueue=TransQueue+PacketArrive(i);
    belief=UpdateBelief2([RealState(:,i-T);1],PacketArrive(i-T:i-1),Action(i-T:i-1),lambda,p,T);
    belief0=getBelief0(belief);
    if TransQueue>0 && belief0>=threshold
        Action(i)=0; %send an information packet
        TransQueue=TransQueue-1;
        numPacket=numPacket+1; %the processed packet increased by 1
        w=w+1;
        if rand>p
            if w==1
                DeliverTime(numPacket)=i+1;
                w=0;
            else
                d=d+1;
            end
        end
    else
        Action(i)=1;
        if rand>p
            d=d+1;
            if d>=w-0.001
                DeliverTime((numPacket-w+1):numPacket)=i+1;%all the waiting packets are delivered
                w=0;
                d=0;
            end
        end
    end
    RealState(:,i+1)=[TransQueue;w;d];
end

TotalDelivered=sum(DeliverTime>=1);% only count those packets that has been delivered

ExpectedDelay=mean(DeliverTime(1:TotalDelivered)-GenerateTime(1:TotalDelivered));


