function vetor = HCM(imgDepth,numBlock,numBins)
     subIDM = ConvertDepth2cloud(imgDepth);
     [f, c,~] = size(subIDM);
     divf1 = round(f/numBlock);
     divc1 = round(c/numBlock);
     contaX=0;
     divX = 1;
     vetor = [];
     while contaX<numBlock
        divf = divf1;
        divc = divc1;
        divY = 1;
        contaY=0; 
        dif = f-divX;
        if(dif<divf), divf = dif;   end
        
        while contaY<numBlock
            subPcloud = subIDM(divX:(divX+divf-1),divY:(divY+divc-1),:);
            X = subPcloud(:,:,1);  X = X(:);           
            Y = subPcloud(:,:,2);  Y = Y(:);           
            Z = subPcloud(:,:,3);  Z = Z(:);           
            MatN     = [X Y Z];
            r =find(isnan(MatN (:,1))&isnan(MatN (:,2))&isnan(MatN (:,3)));
            MatN(r,:)= [];
            subVetor = zeros(numBins,3);           
            center = getCenterOfPoints(MatN);
            
            if (isnan(center(1,1)) && isnan(center(1,2))&& isnan(center(1,3)))
            else
                dist = [(MatN(:,1) - center(1,1)) (MatN(:,2) - center(1,2)) (MatN(:,3) - center(1,3))] ;   
                magnitud = sqrt(dist(:,1).^2+dist(:,2).^2 + dist(:,3).^2);
                cosenos  = [dist(:,1)./magnitud dist(:,2)./magnitud dist(:,3)./magnitud];  
                %%comprobar que la suma d ecuadrados de cosenos es 1
                %compro   = cosenos(:,1).^2+cosenos(:,2).^2 + cosenos(:,3).^2;
                angulos  = acosd(cosenos);    
                [filas, ~] = size(angulos);
                 
                for inic = 1: filas
                    bin = uint8(round(angulos(inic,:).*numBins/180));
                    bin(bin==0)=1;
                    bin(bin>numBins)=numBins;
                    subVetor(bin(1,1),1)=magnitud(inic)+subVetor(bin(1,1),1);  %%X
                    subVetor(bin(1,2),2)=magnitud(inic)+subVetor(bin(1,2),2);  %%Y
                    subVetor(bin(1,3),3)=magnitud(inic)+subVetor(bin(1,3),3);  %%Z
                end 
            end
            
            vetor = [vetor; subVetor];
            divY = divY + divc;
            dif = c-divY;
            if(dif<divc), divc = dif;   end
            contaY = contaY+1;
        end
        contaX = contaX+1;
        divX = divX + divf;        
     end
     maxi = max(vetor);
     vetor = [vetor(:,1)/maxi(1,1), vetor(:,2)/maxi(1,2), vetor(:,3)/maxi(1,3)];
     vetor = [vetor(:,1);vetor(:,2);vetor(:,3)];     
     vetor = vetor';

function cloudData = ConvertDepth2cloud(depthData)
tfl = [1 1];
depthData= double(depthData);
depthData(depthData == 0) = nan;
[f, c] =size(depthData);
center = [round(f/2) round(c/2)];
constant = 570.3;
MM_PER_M = 1000;
cloudData = zeros(f,c,3);
xgrid = ones(f,1)*(1:c) + (tfl(1)-1) - center(1);
ygrid = (1:f)'*ones(1,c) + (tfl(2)-1) - center(2);
cloudData(:,:,1) = xgrid.*depthData/constant/MM_PER_M;
cloudData(:,:,2) = ygrid.*depthData/constant/MM_PER_M;
cloudData(:,:,3) = depthData/MM_PER_M;

function center = getCenterOfPoints(points)
nPoints = size(points, 1);
center = zeros(1, 3);
center(1, 1) = sum(points(:, 1)) / nPoints;
center(1, 2) = sum(points(:, 2)) / nPoints;
center(1, 3) = sum(points(:, 3)) / nPoints;

