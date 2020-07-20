%This file is created by Xu Xiaoli on 26/04/2020
%It simulate the performance of single-action policy with approximated
%value function

%value

% N=10000;
% p=0.45;
% lambda=0.5;
% T=10;

function ExpectedDelay=getSingleAction(lambda,p,N,T)

PacketArrive=[1, (rand(1,N-1)<lambda)]; %Start from the first arriving packet
PackeTransmitted=(rand(1,N)>p); 
GenerateTime=find(PacketArrive==1);
DeliverTime=zeros(1,length(GenerateTime));%to store the deliver time for all the packets

Action=zeros(1,N); %To record the actions taken during all the N time slots
RealState=zeros(3,N); %To record the real value of waiting packet at the reciever side
w=0;
d=0;

%====At the beginning of the first time slot, always send information packet==========
State=[1,0,0]';
belief=[State; 1];
Action(1)=0; % send the first information packet
numPacket=1; %the processed packet increased by 1
if PackeTransmitted(1)>p
   DeliverTime(1)=2;% it is completely received at the beginning of the second time slot
else
   w=1;
end
TransQueue=0;
A=cell(1,N);
A{1}=belief;
value=0;
Collectvalue=zeros(1,N);
Estimated=zeros(1,N);
for i=2:N
    %There is no feedback information yet
    TransQueue=TransQueue+PacketArrive(i);
    RealState(:,i)=[TransQueue;w;d];
    if i<T+1
        %no feedback information yet
        belief=UpdateBelief2(belief,PacketArrive(i),Action(i-1),lambda,p,1); % the belief state at the beginning of the second time slot
    else
        belief=UpdateBelief2([RealState(:,i-T);1],PacketArrive(i-T+1:i),Action(i-T:i-1),lambda,p,T);
    end
    if TransQueue==0
        %no choice but sent the coded packet
        Action(i)=1;
        if PackeTransmitted(i)>p
            d=d+1;
            if d>=w-0.001
                DeliverTime((numPacket-w+1):numPacket)=i+1;%all the waiting packets are delivered
                w=0;
                d=0;
            end
        end
    else
        %We need to make decision which action to take
        belief0_arrive0=UpdateBelief2(belief,0,0,lambda,p,1);%if no packet come at next slot and take action 0
        belief0_arrive1=UpdateBelief2(belief,1,0,lambda,p,1);%if take action 0 and there willl be a packet arrival at the beginning of next time slot
        belief1_arrive0=UpdateBelief2(belief,0,1,lambda,p,1);
        belief1_arrive1=UpdateBelief2(belief,1,1,lambda,p,1);
        value0=(1-lambda)*getValueofState(belief0_arrive0,p,lambda)+lambda*getValueofState(belief0_arrive1,p,lambda);
        value1=(1-lambda)*getValueofState(belief1_arrive0,p,lambda)+lambda*getValueofState(belief1_arrive1,p,lambda);
%       value=Majorvote(belief,p,lambda);
      
   %     if value>0.5
   if value0>=value1
            %send information packet
            Action(i)=0; %send an information packet
            numPacket=numPacket+1; %the processed packet increased by 1
            TransQueue=TransQueue-1; %transmitting queue decrease by 1
            w=w+1;
            if PackeTransmitted(i)>p
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
            if PackeTransmitted(i)>p
                d=d+1;
                if d>=w-0.001
                    DeliverTime((numPacket-w+1):numPacket)=i+1;%all the waiting packets are delivered
                    w=0;
                    d=0;
                end
            end
        end
    end
    A{i}=belief;
    Collectvalue(i)=value;
    if(i<T+2)
    if(Action(i-1)==1) Estimated(i)=Estimated(i-1)-(1-p); end
    if(Action(i-1)==0) Estimated(i)=Estimated(i-1)+p; end
    else
         Estimated(i)=RealState(2,i-T)-RealState(3,i-T)+sum(1-Action(i-T:i-1))*p-sum(Action(i-T:i-1))*(1-p);
    end
    if Estimated(i)<0
        Estimated(i)=0;
    end
end

TotalDelivered=sum(DeliverTime>=1);% only count those packets that has been delivered

ExpectedDelay=mean(DeliverTime(1:TotalDelivered)-GenerateTime(1:TotalDelivered));
DeliverRatio=TotalDelivered/length(GenerateTime);
% 
