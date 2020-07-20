%The file is created by Xu Xiaoli on 27/04/2020
%It estimate the value of belief
function value=getValueofState(belief,p,lambda)
%this approximation does not use lambda, we may improve the value
%approximation with lambda
%value=-(r+w)*(w-d)/(1-p)-(r+1)*r/(2*(1-p));
r_vec=belief(1,:);
w_vec=belief(2,:);
d_vec=belief(3,:);
prob=belief(4,:);

%value_vec=-(r_vec+w_vec).*(w_vec-d_vec)/(1-p-lambda)-(r_vec+1).*r_vec/(2*(1-p-lambda));
value_vec=-(r_vec.*(r_vec+1)/2/(1-lambda)+(r_vec+w_vec).*(w_vec-d_vec));

%value_vec=-((r_vec+(w_vec-d_vec)/(1-p)*lambda).*(r_vec+1+(w_vec-d_vec)/(1-p)*lambda)/2/(1-lambda)/(1-p)+(lambda/(1-p)*(w_vec-d_vec).*(w_vec-d_vec+1)/2+(r_vec+w_vec).*(w_vec-d_vec))/(1-p));
value=value_vec*prob';