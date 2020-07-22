function Latency=getARQsimu(lambda,p,N)


PackeTransmitted=(rand(1,N)>p);
PacketArrive=(rand(1,N)<lambda);

PacketAccumulated=cumsum(PacketArrive);
PacketProcessed=cumsum(PackeTransmitted);

RealTransmission=PackeTransmitted;
NoTransmission=(PacketAccumulated<PacketProcessed); %if the number of packets accumulated is less than the number of processing capability, no real transmission in that time slot. 
while any(NoTransmission)
    idx=find(NoTransmission==1,1,'first');
    RealTransmission(idx)=0;
    PacketProcessed=cumsum(RealTransmission);
    NoTransmission=(PacketAccumulated<PacketProcessed);
end

ProcessTime=find(RealTransmission==1);%By the end of the time slot , the packet is delivered to the receiver side
ArriveTime=find(PacketArrive==1); %packets arrive at the begining of these time slot
Latency=mean(ProcessTime-ArriveTime(1:length(ProcessTime))+1); %only count those packets that have been processed


