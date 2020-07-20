%This file is created by XU XIaoli on 27/04/2020
%It compares the latency performance of various coding schemes for
%different delays

clc;
clear;
close all;

T_vec=0:5:30;
N=10000;
lambda=0.5;
p=0.4;
iter=10;
ARQ_ana=(1-lambda)./(1-p-lambda);
Greedy_ana=lambda*p./(1-lambda-p).^2+(1-lambda)./(1-lambda-p);
Thre_simu=zeros(1,length(T_vec));
Thre_simu_Modified=zeros(1,length(T_vec));
SA_simu=zeros(1,length(T_vec));
ARQ_delay=zeros(1,length(T_vec));



Queue_std_SA=zeros(1,length(T_vec));
Queue_CI_SA=zeros(2,length(T_vec));
Queue_std_Thre=zeros(1,length(T_vec));
Queue_CI_Thre=zeros(2,length(T_vec));
Queue_std_Thre_Modified=zeros(1,length(T_vec));
Queue_CI_Thre_Modified=zeros(2,length(T_vec));
Queue_std_ARQ=zeros(1,length(T_vec));
Queue_CI_ARQ=zeros(2,length(T_vec));


for i=1:length(T_vec)
    T=T_vec(i);
    i
    Thre_simuj= zeros(1,iter);
    SA_simuj=zeros(1,iter);
    ARQ_delayj=zeros(1,iter);
    Thre_simu_Modifiedj= zeros(1,iter);
    for j=1:iter
        j
        SA_simuj(j)=getSingleAction(lambda,p,N,T);
        Thre_simuj(j)=getThresholdCoding(lambda,p,N,T);
        ARQ_delayj(j)=getARQDelay(lambda,p,N,T);     
        Thre_simu_Modifiedj(j)=getThresholdCodingModified(lambda,p,N,T);
    end
    Thre_simu(i)=  mean(Thre_simuj);
    SA_simu(i)=mean( SA_simuj);
    ARQ_delay(i)=mean( ARQ_delayj);
    Thre_simu_Modified(i)=mean( Thre_simu_Modifiedj);
    
    Queue_std_SA(i)=std(SA_simuj);
    Queue_SEM_SA=Queue_std_SA(i)/sqrt(iter);
    Queue_ts_SA=tinv([0.025 0.095],iter-1);
    Queue_CI_SA(:,i)=Queue_std_SA(i)+Queue_ts_SA*Queue_SEM_SA;
    
    Queue_std_Thre(i)=std(Thre_simuj);
    Queue_SEM_Thre=Queue_std_Thre(i)/sqrt(iter);
    Queue_tsThre=tinv([0.025 0.095],iter-1);
    Queue_CI_Thre(:,i)=Queue_std_Thre(i)+Queue_tsThre*Queue_SEM_Thre;
    
    Queue_std_Thre_Modified(i)=std(Thre_simu_Modifiedj);
    Queue_SEM_Thre_Modified=Queue_std_Thre_Modified(i)/sqrt(iter);
    Queue_tsThre_Modified=tinv([0.025 0.095],iter-1);
    Queue_CI_Thre_Modified(:,i)=Queue_std_Thre_Modified(i)+Queue_tsThre_Modified*Queue_SEM_Thre_Modified;
    
    Queue_std_ARQ(i)=std(ARQ_delayj);
    Queue_SEM_ARQ=Queue_std_ARQ(i)/sqrt(iter);
    Queue_ts_ARQ=tinv([0.025 0.095],iter-1);
    Queue_CI_ARQ(:,i)=Queue_std_ARQ(i)+Queue_ts_ARQ*Queue_SEM_ARQ;

end


figure;
errorbar(T_vec,Thre_simu,Queue_CI_Thre(1,:),Queue_CI_Thre(2,:),'rs-','MarkerFaceColor','r','LineWidth',1);
hold on;
grid on;
errorbar(T_vec,Thre_simu_Modified,Queue_CI_Thre_Modified(1,:),Queue_CI_Thre_Modified(2,:),'bd-','MarkerFaceColor','b','LineWidth',1);
errorbar(T_vec,SA_simu,Queue_CI_SA(1,:),Queue_CI_SA(2,:),'m+-','MarkerFaceColor','m','LineWidth',1);
errorbar(T_vec,ARQ_delay,Queue_CI_ARQ(1,:),Queue_CI_ARQ(2,:),'cd-','MarkerFaceColor','c','LineWidth',1);
plot(T_vec,Greedy_ana*ones(1,length(T_vec)),'k+-');
hold off;
title(['p=',num2str(p)]);
xlabel('Feedback delay');
ylabel('End-to-end latency');
legend('Delayed ARQ','Greedy Coding');
ylim([0,30]);

legend('Threhold Coding','Threhold-Modified','Single-Action','Delayed ARQ','Greedy Coding');
% filename=['ZQ_20Results_N',num2str(N),'_T',num2str(T),'.mat'];
% save(filename);
