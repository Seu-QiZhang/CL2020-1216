% This file is created by Xu Xiaoli on 23/03/2020
%It combine the same state probability together
%First row is r, second row is w, third row is d; fourth row is probability
function neatBelief=combineBelief(belief)

State=belief(1:3,:)'; %sort them into rows;
Prob=belief(4,:);

[B, ~, iA] = unique(State, 'rows');
indices     = accumarray(iA, (1:numel(iA)).', [], @(r){sort(r)});

uniqueStates=size(B,1);
StateProb=zeros(1,uniqueStates);
for i=1:size(B,1)
    rowIdx=indices{i};
    StateProb(i)=sum(Prob(rowIdx));
end
neatBelief=[B';StateProb];
