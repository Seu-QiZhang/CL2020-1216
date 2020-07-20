%This file is created by XU Xiaoli on 23/03/2020
%It gives the belief update for a known state (r,w,d)
%A known packet arrival of T steps
%A known sequence action of T steps

function belief=UpdateBelief2(belief,arrival,action,lambda,p,T)
% belief=[1,0,0,1]'; 
% %The first row is the value of r, the second row is the value of w, the
% %third row is the valueo of d, the last row is the probability of being at
% %the above state
% arrival=[1,1,0];
% action=[0 0 1];

% T=min(length(arrival),length(action)); %The number of look up steps
% arrival=arrival(1:T);
% action=action(1:T);
if T==0
    belief=belief;
else
    numStates=size(belief,2); %The total number of states
    newBelief=[];

    for i=1:numStates
        r=belief(1,i);
        w=belief(2,i);
        d=belief(3,i);
        prob=belief(4,i);
        if action(1)==0
            if w==0
                nextState=[max(0,r-1+arrival(1)),max(0,r-1+arrival(1));
                           0,1; 
                           0,0;
                           1-p,p];
            else
                nextState=[max(0,r-1+arrival(1)),max(0,r-1+arrival(1));
                           w+1,w+1; 
                           d+1,d;
                           (1-p),p];
            end
        else
            if w==0 
                nextState=[r+arrival(1);0;0;1];
            elseif d==w-1
                nextState=[r+arrival(1),r+arrival(1);
                           0,w; 
                           0,d;
                           (1-p),p];
            else
                nextState=[r+arrival(1),r+arrival(1);
                           w,w; 
                           d+1,d;
                           (1-p),p];            
            end
        end
        expandBelief=[nextState(1,:);nextState(2,:);nextState(3,:);prob*nextState(4,:)];
        newBelief=[newBelief,expandBelief];
    end
    neatBelief=combineBelief(newBelief);

    if T>1
        belief=UpdateBelief(neatBelief,arrival(2:end),action(2:end),lambda,p,T-1);
    else
        belief=neatBelief;
    end
end


