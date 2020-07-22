%This file is created by Xu Xiaoli on 16/04/2020 
%This file simulate the performance of greedy coding, where the information
%packet are sent immidiately when it is generated and coded packets are
%sent during the free slots. 

%The channel is busy all the time
%This scheme will not use feedback information
function simuLatency=getGreedyCoding(lambda,p,N)
PackeTransmitted=(rand(1,N)>p); %record the channel status in the time slots
PacketArrive=(rand(1,N)<lambda); %record the packet arrival 
GenerateTime=find(PacketArrive==1);
DeliverTime=zeros(1,length(GenerateTime));%to store the deliver time for all the packets
TotalPackets=sum(PacketArrive);

infoPacket=0; 
degree=0;
for i=1:(TotalPackets-1)
    infoPacket=infoPacket+1;
    ChannelStatus=PackeTransmitted(GenerateTime(i):(GenerateTime(i+1)-1));
    tmp=degree+cumsum(ChannelStatus);
    degree=tmp(end);
    if degree>=infoPacket
        %can decode all the previous information packet
        decodingTime=find(tmp==infoPacket,1,'first');%The instance when all the packets are decoded
        DeliverTime(i-infoPacket+1:i)=GenerateTime(i)+decodingTime;%since decoding only happen at the end of the time slot, no need to subtract 1
        infoPacket=0;% back to one information packet
        degree=0;
    end
end

%=========See whether the remaining packes can be decoded by the remaining
%time slots of total N time slots
undecoded=infoPacket+1;%total packet remains undecoded
ChannelStatus=PackeTransmitted(GenerateTime(end):N);
tmp=degree+cumsum(ChannelStatus);
degree=tmp(end);
if degree>=undecoded
    decodingTime=find(tmp==undecoded,1,'first');
    DeliverTime(TotalPackets-undecoded+1:end)=GenerateTime(end)+decodingTime;
    undecoded=0;
end

Delivered=TotalPackets-undecoded; %the total number of packets that have been delivered
simuLatency=mean(DeliverTime(1:Delivered)-GenerateTime(1:Delivered));
DeliverRatio=Delivered/TotalPackets;

anaLatency=lambda*p/(1-lambda-p)^2+(1-lambda)/(1-lambda-p);
