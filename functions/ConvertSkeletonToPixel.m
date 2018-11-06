function [skeleton, pos] = ConvertSkeletonToPixel(skeleton, xh, yw)
global HEAD  SHOULDER_CENTER SPINE numFrames
global SHOULDER_RIGHT ELBOW_RIGHT WRIST_RIGHT HAND_RIGHT 
global SHOULDER_LEFT  ELBOW_LEFT  WRIST_LEFT  HAND_LEFT  
X=1; Y=2; Z=3;  
WIDTH  = xh;
HEIGHT = yw;
NUI_CAMERA_SKELETON_TO_DEPTH_IMAGE_MULTIPLIER_320x240 = 285.3;

pos   = zeros(10,3, numFrames);
skeletonP = zeros(20, 3, numFrames);
skeletonP(:,X,:) = uint16( WIDTH / 2 + skeleton(:,X,:).*  (WIDTH/320.0).*  NUI_CAMERA_SKELETON_TO_DEPTH_IMAGE_MULTIPLIER_320x240 ./ skeleton(:,Z,:) + 0.5);
skeletonP(:,Y,:) = uint16( HEIGHT / 2 - skeleton(:,Y,:).* (HEIGHT/240.0).* NUI_CAMERA_SKELETON_TO_DEPTH_IMAGE_MULTIPLIER_320x240 ./ skeleton(:,Z,:) + 0.5);
skeletonP(:,Z,:) = skeleton(:,Z,:);

%% POSITIONS TO SHOW
pos(1,:,:) = skeletonP(SHOULDER_CENTER,:,:);
pos(2,:,:) = skeletonP(HEAD,:,:); 
pos(3,:,:) = skeletonP(SHOULDER_LEFT,:,:);  
pos(4,:,:) = skeletonP(ELBOW_LEFT ,:,:);  
pos(5,:,:) = skeletonP(WRIST_LEFT,:,:); 
pos(6,:,:) = skeletonP(HAND_LEFT,:,:);  
pos(7,:,:) = skeletonP(SHOULDER_RIGHT,:,:); 
pos(8,:,:) = skeletonP(ELBOW_RIGHT,:,:); 
pos(9,:,:) = skeletonP(WRIST_RIGHT,:,:);
pos(10,:,:)= skeletonP(HAND_RIGHT,:,:);
pos(11,:,:)= skeletonP(SPINE,:,:);

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