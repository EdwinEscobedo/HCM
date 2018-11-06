function [sphCoord]  = Convert2sph(skeletonData, NEW_ORIGIN)
numFrames=size(skeletonData,3);
%% 1. NORMALIZAMOS CON CENTRO DEL PECHO COMO NUEVO ORIGEN 
origin_fixed   = repmat(skeletonData(NEW_ORIGIN,:,1),20,1);
sphCoord  = zeros(20,3,numFrames);
%% 2. CONVERTIMOS LOS DATOS
for i=1:numFrames
   Aux = skeletonData(:,:,i) - origin_fixed;
   [az,el,r] = cart2sph(Aux(:,1),Aux(:,2),Aux(:,3));   
   sphCoord(:,:,i)= [az,el,r];
end


