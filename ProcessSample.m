function [GLOBAL_FEATURES, LOCAL_FEATURES]= ProcessSample(kinectData,opt)   
   close all;
   %% A. FIXED PARAMETERS
   global  VAL_PORCENT numFrames  sphCoord  HR HL
   VAL_PORCENT      =  0.03; 
   
   %% A_1 BODY JOINT POSITIONS
   global HEAD  SHOULDER_CENTER HIP_CENTER SPINE 
   global SHOULDER_RIGHT ELBOW_RIGHT WRIST_RIGHT HAND_RIGHT HIP_RIGHT KNEE_RIGHT ANKLE_RIGHT FOOT_RIGHT
   global SHOULDER_LEFT  ELBOW_LEFT  WRIST_LEFT  HAND_LEFT  HIP_LEFT  KNEE_LEFT  ANKLE_LEFT  FOOT_LEFT
   HIP_CENTER       = 1;  
   SPINE            = 2;                   
   SHOULDER_CENTER  = 3;  
   HEAD             = 4;  
   SHOULDER_LEFT    = 5;  
   ELBOW_LEFT       = 6;   
   WRIST_LEFT       = 7;  
   HAND_LEFT        = 8; 
   SHOULDER_RIGHT   = 9; 
   ELBOW_RIGHT      = 10; 
   WRIST_RIGHT      = 11;
   HAND_RIGHT       = 12;  
   HIP_LEFT         = 13; 
   KNEE_LEFT        = 14; 
   ANKLE_LEFT       = 15; 
   FOOT_LEFT        = 16; 
   HIP_RIGHT        = 17;
   KNEE_RIGHT       = 18;
   ANKLE_RIGHT      = 19;
   FOOT_RIGHT       = 20;
   
   %% B. NUMBER OF FRAMES VALIDATION
   numFrames   =   size(kinectData{opt.Depth},3);
   if(numFrames<opt.NumKF)
       disp('Number of frames less than KeyFrames number indicated...');
       return;        
   end
       
   %% C. CONVERT TO SPHERICAL COORDINATES
   disp('1. CONVERT TO SPHERICAL COORDINATES');
   tic
       sphCoord = Convert2sph(kinectData{opt.Skltn}, SHOULDER_CENTER);
       [X, Y, Z]= sph2cart(sphCoord(:,1,:),sphCoord(:,2,:),sphCoord(:,3,:));
       HAND = [X,Y,Z];
       clear X Y Z;

       HR = HAND(HAND_RIGHT,:,:);  HR = reshape(HR,3,numFrames)';
       HL = HAND(HAND_LEFT ,:,:);  HL = reshape(HL,3,numFrames)';
   toc
   
   if(opt.Show)
       ShowData(kinectData,opt);      
   end   
   
   %% D. KEYFRAMES EXTRACTION
   disp('2. KEYFRAMES EXTRACTION');
   tic
        listKF = ExtractKF(HR,opt);
   toc
   if (opt.Show)
       ShowKeyframes(listKF,kinectData{opt.Depth});
   end  
  
   %% E. FEATURE EXTRACTION
   disp('3. FEATURE EXTRACTION');
   %% E1. GLOBAL FEATURE EXTRACTION
   disp('   3.1 GLOBAL FEATURE EXTRACTION');
   tic
     GLOBAL_FEATURES = ComputeGlobalFeatures(kinectData, listKF, opt);
   toc
   %% E2. LOCAL FEATURE EXTRACTION
   disp('   3.2 LOCAL FEATURE EXTRACTION');
   tic
    LOCAL_FEATURES  = ComputeLocalFeatures(kinectData{opt.Depth}, listKF, opt);
   toc
   clear HAND HR HL;
   
function GLOBAL_FEATURES = ComputeGlobalFeatures(kinectData,listKF, opt)
  global VAL_PORCENT sphCoord  HR HL  HEAD    
  global ELBOW_RIGHT WRIST_RIGHT HAND_RIGHT  ELBOW_LEFT  WRIST_LEFT  HAND_LEFT  
  
  %% A. NORMALIZE  polar angle (inclination) AND THE azimuthal angle  BY PI
  sphCoord = NormalizeSph(sphCoord(:,:,listKF.KF));
  
  %% B. VALIDATE IF EXIST MOVEMENT IN THE HANDS RIGHT AND LEFT 
  meanHL = std(sqrt(sum(HL.^2,2)));
  meanHR = std(sqrt(sum(HR.^2,2)));
  JOINTS_R = [HEAD, ELBOW_RIGHT, WRIST_RIGHT, HAND_RIGHT];
  JOINTS_L = [ELBOW_LEFT , WRIST_LEFT , HAND_LEFT ];
  
  %% C. COMPUTE GLOBAL FEATURES  
  if meanHR>VAL_PORCENT
    %% C1. COMPUTE VSI RIGHT      
    VSI = sphCoord(JOINTS_R,:,:);  

    %% C2. COMPUTE VTI RIGHT
    sphCoord2 = Convert2sph(kinectData{opt.Skltn}, HAND_RIGHT);
    sphCoord2 = NormalizeSph(sphCoord2(:,:,listKF.KF));
    VTI = sphCoord2([ELBOW_RIGHT, WRIST_RIGHT],:,:); 
       
    %% C3. COMPUTE VHC RIGHT  -- THIS WAS DEPRECIT
    %% THIS VECTOR WAS DISCARDED BY NOT IMPROVING THE PRECISION IN EXPERIMENTS     
  else
    VSI = zeros(numel(JOINTS_R), 3, opt.NumKF);
    VTI = zeros(2, 3, opt.NumKF);
  end    
  
  if meanHL>VAL_PORCENT
    %% C1. COMPUTE VSI LEFT 
    VSI = [VSI; sphCoord(JOINTS_L,:,:)]; 

    %% C2. COMPUTE VTI LEFT 
    sphCoord2 = Convert2sph(kinectData{opt.Skltn}, HAND_LEFT);
    sphCoord2 = NormalizeSph(sphCoord2(:,:,listKF.KF));
    VTI = [VTI; sphCoord2([ELBOW_LEFT, WRIST_LEFT],:,:)];
    %% C3. COMPUTE VHC RIGHT  -- THIS WAS DEPRECIT
    %% THIS VECTOR WAS DISCARDED BY NOT IMPROVING THE PRECISION IN EXPERIMENTS    
  else      
    VSI = [VSI; zeros(numel(JOINTS_L), 3, opt.NumKF)];
    VTI = [VTI; zeros(2, 3, opt.NumKF)];      
       
  end  
  VSI = VSI(:)';
  VTI = VTI(:)';
  VHC = zeros(1,2*3*opt.NumKF);
  GLOBAL_FEATURES = [VSI, VTI, VHC];
  
function LOCAL_FEATURES  = ComputeLocalFeatures(depthData, listKF, opt)
value = opt.NumBlock^2*opt.NumBins*3;
LOCAL_FEATURES = [];%zeros(opt.NumKF,value*4);
depthData = depthData(:,:,listKF.KF);

%% COMPUTE HISTOGRAMS OF CUMULATIVE MAGNITUDES
for i=1:opt.NumKF
    depthImg =depthData(:,:,i);
    LOCAL_FEATURES=[LOCAL_FEATURES, HCM(depthImg, opt.NumBlock, opt.NumBins)];    
end
  
function sphCoord = NormalizeSph(sphCoord)
%% A. NORMALIZE  polar angle (inclination) AND THE azimuthal angle  BY PI
sphCoord(:,1:2,:) = sphCoord(:,1:2,:)/pi;
%% NORMALIZE  r value by max 
sphCoord(:,3,:) = sphCoord(:,3,:)/max(max(sphCoord(:,3,:)));

function ShowData(kinectData,opt)
global VAL_PORCENT numFrames HR HL
tamano=get(0,'ScreenSize');
h= figure('position',[tamano(1)+tamano(3)/5 tamano(2)+tamano(4)/5 tamano(3)/1.5 tamano(4)/1.5]);
[~, posi] = ConvertSkeletonToPixel(kinectData{opt.Skltn }, 320, 240);       

width  = 30; 
height = 35;       

for i = 1:numFrames
    subplot(2,3,1);    
    set(gca,'xtick',[])
    set(gca,'ytick',[]) 
    cla(h)
    imgDepth  = kinectData{opt.Depth}(:,:,i);
    imagesc(imgDepth); 

    hold on
    pos = posi(:,:,i);
    plot([pos(1,1) pos(2,1)],[pos(1,2),pos(2,2)]  ,'-r', 'linewidth',3);
    plot([pos(1,1) pos(3,1)],[pos(1,2),pos(3,2)]  ,'-k', 'linewidth',3);
    plot([pos(1,1) pos(7,1)],[pos(1,2),pos(7,2)]  ,'-k', 'linewidth',3);
    plot([pos(3,1) pos(4,1)],[pos(3,2),pos(4,2)]  ,'-y', 'linewidth',3);
    plot([pos(4,1) pos(5,1)],[pos(4,2),pos(5,2)]  ,'-c', 'linewidth',3);
    plot([pos(5,1) pos(6,1)],[pos(5,2),pos(6,2)]  ,'-m', 'linewidth',3);
    plot([pos(7,1) pos(8,1)],[pos(7,2),pos(8,2)]  ,'-y', 'linewidth',3);
    plot([pos(8,1) pos(9,1)],[pos(8,2),pos(9,2)]  ,'-c', 'linewidth',3);
    plot([pos(9,1) pos(10,1)],[pos(9,2),pos(10,2)],'-m', 'linewidth',3);
    plot(pos(1:10,1) ,pos(1:10,2),'r.','MarkerSize', 20);

    yCenter = posi(10,2,i); 
    xCenter = posi(10,1,i);       
    xLeft = xCenter - width/2;
    yBottom = yCenter - height/2;
    Xmin = min(posi(:,1,i));
    Xmax = max(posi(:,1,i));
    Ymin = min(posi(:,2,i));
    Ymax = max(posi(:,2,i));
    Xmin = Xmin-(Xmax-Xmin)*VAL_PORCENT;
    Xmax = Xmax+(Xmax-Xmin)*VAL_PORCENT;
    Ymin = Ymin-(Ymax-Ymin)*VAL_PORCENT;
    Ymax = Ymax+(Ymax-Ymin)*VAL_PORCENT;

    if(Xmin<0)   ,Xmin=0;end
    if(Xmax>240) ,Xmax=240;end
    if(Ymin<0)   ,Ymin=0;end
    if(Ymax>320) ,Ymax=320;end

    rectangle('Position', [xLeft, yBottom, width, height], 'EdgeColor', 'b', 'LineWidth', 4);
    rectangle('Position', [Xmin, Ymin, (Xmax-Xmin), (Ymax-Ymin)], 'EdgeColor', 'r', 'LineWidth', 4);                
    title('DEPTH DATA')
    subplot(2,3,2)    
    cla(h)
    ShowSkeleton(kinectData{opt.Skltn}(:,:,i));        
    title('SKELETON DATA') 
    subplot(2,3,3)
    view([139 17.2]);
    axis([-1 1 -1 1 -1 1])
    hold on
    scatter3(HR(i,1),HR(i,2),HR(i,3),...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',[0 .75 .75])               

    if i<numFrames               
        Vectarrow(HR(i,:),HR(i+1,:),'b');
    end
    title('HAND RIGHT MOVEMENT') 
    subplot(2,3,4)
    view([139 17.2]);
    axis([-1 1 -1 1 -1 1])

    hold on
    scatter3(HL(i,1),HL(i,2),HL(i,3),...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',[1 .0 .0])
     if i<numFrames               
        Vectarrow(HL(i,:),HL(i+1,:),'r');
     end
    title('HAND LEFT MOVEMENT')  
    drawnow;      
end   

subplot(2,3,5)     
meanHR = std(sqrt(sum(HR.^2,2)));
meanHL = std(sqrt(sum(HL.^2,2)));
bar([meanHR meanHL]);
title('STANDART DEVIATION') 
clear imgDepth  X Y Z pos   

function ShowKeyframes(listKF, dataImage)
figure;
x = 1:numel(listKF.P_MMX);
plot(x',listKF.P_MMX, '.'); 
hold on, plot(x(listKF.CVH), listKF.P_MMX(listKF.CVH), '-b'), hold on
plot(listKF.P_MMX);

scatter(x(listKF.KF),listKF.P_MMX(listKF.KF),...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor',[0 .75 .75])
title('KEYPOINTS')
F1=figure();
imgList = dataImage(:,:,listKF.KF);
for i=1:numel(listKF.KF);
   img = imgList(:,:,i);
   if(size(img,1)==480)
    img = imresize(img, [240 320]);
   end
   subplot(3,4,i); 
   imagesc(img)
   set(gca,'xtick',[])
   set(gca,'ytick',[])    
end

annotation(F1,'textbox',...
    [0.346428571428571 0.932333334539619 0.334821419125157 0.0642857130794299],...
    'String',{'KEYFRAMES EXTRACTED'},...
    'LineStyle','none',...
    'FontWeight','bold');