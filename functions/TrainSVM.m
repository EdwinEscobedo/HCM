function [model accuracy cm] = TrainSVM(trainData,trainLabel,testData,testLabel)
% function TrainSVM()
% % % % TrainSVM (treino, opt)
% % % % treino = porcentaje para entrenar y testar
% % % % opt = 1 -> solo global por defecto
% % % % opt = 2 -> solo local
% % % % opt = 3 -> las dos combinadas EN LA PARTE DE SIFT
% % % % opt = 4 -> las dos combinadas EN LA PARTE DE HISTOGRAMAS
%     clc;clear all;

    
    disp('----------------- Train the SVM in one-vs-rest (OVR) mode');
%     tic
%     bestcv = 0;bestg = 0;
%     for log2c = 0:0.1:1,
%       for log2g = 0:0.1:1,
%         disp('--- PARA: ');   
%         cmd = ['-q -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
%         cv = get_cv_ac(trainLabel, trainData, cmd, 3);
%         if (cv >= bestcv),
%            bestcv = cv;
%            bestg = log2g;
           bestc = 0.5; bestg = 0.6;
%         end
%         fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
%       end
%     end
%      

     model = svmtrain(trainLabel,trainData, '-t 0 -c 33 -b 1');
    % model = load('model-001.mat');
    % model = model.model;
%     toc

    disp('------------------ Classify samples using OVR model');
% % %     tic
    % #######################
    % Classify samples using OVR model
    % #######################
    
%     testLabel = testLabel(1,:);
%     testData  = testData(1,:);
    [predict_label, accuracy, dec_values] = svmpredict(testLabel, testData, model,'-b 1');
%     predict_label
    
%     fprintf('Accuracy TESTE = %g%%\n', accuracy * 100);
% % %     toc
    
% % %  disp(' ... ........... RESULTADOS teste---');
%  contT = 0;
%  pred_cl = predict_label;
 numclass=size(unique(testLabel),1);
 
 [cm,~] = confusionmat(testLabel, predict_label);   
 
  tot = sum(cm,2); tot = repmat(tot,1,numclass);
  cm = cm./tot;
%  plotconfusion(testLabel,predict_label)

%  
%  for i=1:numclass
% % % %     disp([' ... ........... numero  ' int2str(i)]);
%     num   = sum(testLabel == i);
%     r     = testLabel==i;
%     cont  = sum(predict_label(r)==i);
%    
%     cm(i,:)= cm(i,:)/num;
% %     MatConfu(i,i) = num2;
% %     s =size(subMat,1);
%     
% %     if abs(num2 - s)>0
% %         MatConfu(subMat,i) = 1; 
% %     end
%     
% %     if(num2) = 
%     porc= cont*100/num;
% %     isnan()
%     contT = contT +porc;
%  end
%   
% % % %  disp([' ... ........... total teste:  ']);
%  contT = contT/size(unique(testLabel),1);

% [cm,order] = confusionmat(testLabel,predict_label);
% cm
%         
%     disp('--- Aplicando Random Forest..');
%     tic
%     TreeObject = TreeBagger(20,trainData,trainLabel,'method','classification','NVarToSample','all');
% 
%     [YFIT,scores] = predict(TreeObject,testData)
%     
%     toc 
    
end