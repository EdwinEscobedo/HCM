function [listKF]= ExtractKF(HR,opt)
global numFrames
listDR  = zeros(1,numFrames);

for k=1:numFrames-1;
    x_2 = (HR(k,1) - HR(k+1,1))^2;
    y_2 = (HR(k,2) - HR(k+1,2))^2;
    z_2 = (HR(k,3) - HR(k+1,3))^2;
    dr = sqrt(x_2+ y_2 +z_2);
    listDR(k)=dr;    
end

P_MMX = diff(listDR)';
x = (1:numFrames-1)';

listKF = convhull(x,P_MMX); 

%% only to show 
CVH = listKF;
%% 
listKF = sort(listKF(2:end));
PMMX_aux=abs(P_MMX);

lst = find(PMMX_aux~=intmax);   
    
while numel(lst)~=opt.NumKF        
    minimo = intmax;           
    for i=1:numel(listKF)-1
        MinAux = min(PMMX_aux(listKF(i):listKF(i+1)-1));
        if(minimo>MinAux)
            posi = find(PMMX_aux==MinAux,1,'last');
            minimo = MinAux;
        end
    end

    PMMX_aux(posi) = intmax;
    lst = find(PMMX_aux~=intmax);
end  
listKF = [];
listKF.CVH   = CVH;
listKF.KF    = lst;
listKF.P_MMX = P_MMX;
