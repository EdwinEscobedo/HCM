close all;clear;clc;
addpath('functions/')

% SELECT A SAMPLE AS: data/sample 1
folder_name = uigetdir(pwd,'Select a Sample Directory');
if ~isequal(folder_name,0)
   disp(['User selected ', folder_name]);
   depth_Name  = dir (fullfile(folder_name , '*depth.mat'));
   skltn_Name  = dir (fullfile(folder_name , '*skeleton.mat'));
   depth_data  = load(fullfile(folder_name, depth_Name.name));
   skltn_data  = load(fullfile(folder_name, skltn_Name.name));
   
   %% PARAMETER CONFIGURATION
   opt.NumKF     = 10;  %% KEYFRAMES NUMBER
   opt.Show      =  1;  %% 1=show data 
   opt.NumBins   =  8;  %% BINS NUMBER
   opt.NumBlock  =  5;  %% SUBREGIONS NUMBER
   opt.Depth     =  1;
   opt.Skltn     =  2;
   
   %% COMBINED DATA   
   kinectData{opt.Depth} = depth_data.d_depth;
   kinectData{opt.Skltn} = skltn_data.d_skel;
   %% REALLOCATE SKELETON DATA WITH DISTRIBUTION OF THE KINECT JOINTS V1
   kinectData{opt.Skltn}(1,:,:) = skltn_data.d_skel(4,:,:);
   kinectData{opt.Skltn}(3,:,:) = skltn_data.d_skel(2,:,:);
   kinectData{opt.Skltn}(4,:,:) = skltn_data.d_skel(1,:,:);
   kinectData{opt.Skltn}(2,:,:) = skltn_data.d_skel(3,:,:);
   %% EXTRACT FEATURES
   [GLOBAL_FEATURES, LOCAL_FEATURES] = ProcessSample(kinectData,opt);   
   figure;
   subplot(1,2,1)
   area(LOCAL_FEATURES)
   title('LOCAL FEATURES')
   subplot(1,2,2)
   area(GLOBAL_FEATURES)
   title('GLOBAL FEATURES')
else
   msgbox('Operation cancelled','CANCELLED');
   return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           DISTRIBUTION OF THE KINECT JOINTS V1              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                             %
%                        +   HEAD                             %
%                        *                                    %
%     SHOULDER_LEFT      *        SHOULDER_RIGHT              %
%                 + **** + *****+ *                           %
%               *  SHOULDER CENTER  *                         %
%             *          *           *                        %
% ELBOW_LEFT +           *            + ELBOW_RIGHT           %
%           *            *              *                     %
%           *            *               *                    %
%           *            *                *                   %
%WRIST_LEFT +            *                  + WRIST_RIGHT     %
%           *            *                  *                 %
% HAND_LEFT +            *                 + HAND_RIGHT       %
%                        + SPINE                              %
%                        *                                    % 
%                        *                                    %
%                        + HIP_CENTER                         %
%                      *   *                                  %
%                    *       *                                %
%      HIP_LEFT    +           +  HIP_RIGHT                   %
%                 *             *                             %
%                 *             *                             %
%                 *             *                             %
%                 *             *                             %
%                 *             *                             %
%                 *             *                             %
%      KNEE_LEFT  +             +  KNEE_RIGHT                 %
%                 *             *                             %
%                 *             *                             %
%                 *             *                             %
%                 +             +  ANKLE_RIGHT                %
%                 *              *                            %
%                *                *                           %
%    FOOT_LEFT  +                  +   FOOT_RIGHT             %
%                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
