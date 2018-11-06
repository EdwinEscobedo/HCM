function ShowSkeleton(skeleton)
joints = [4, 3, 2, 3, 5, 6, 7, 3, 9,  10, 11, 1,  13, 14, 15, 1,  17, 18, 19;
     3, 2, 1, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
 
temp = skeleton(:,:,1);

Xmax = max(temp(:,1)+0.15);
Xmin = min(temp(:,1)-0.15);
Ymax = max(temp(:,2)+0.15);
Ymin = min(temp(:,2)-0.15);
Zmax = max(temp(:,3)+0.15);
Zmin = min(temp(:,3)-0.15);

clear temp;

joint = skeleton(:,:,1);
    
plot3(joint(:,1), joint(:,3), joint(:,2), 'r.', 'MarkerSize', 20);
xlabel('X');
ylabel('Z');
zlabel('Y');
set(gca,'DataAspectRatio',[1 1 1])
       
for j = 1:size(joints,2)
    point1 = joint(joints(1,j),:);
    point2 = joint(joints(2,j),:);

    switch j
        case 1
            line([point1(1),point2(1)], [point1(3),point2(3)], [point1(2),point2(2)], 'Color',[1 0 0],'LineWidth',3);
        case 5
            line([point1(1),point2(1)], [point1(3),point2(3)], [point1(2),point2(2)], 'Color',[1 1 0],'LineWidth',3);
        case 4
            line([point1(1),point2(1)], [point1(3),point2(3)], [point1(2),point2(2)], 'Color',[0 0 0],'LineWidth',3);
        case 8
            line([point1(1),point2(1)], [point1(3),point2(3)], [point1(2),point2(2)], 'Color',[0 0 0],'LineWidth',3);    
        case 6
            line([point1(1),point2(1)], [point1(3),point2(3)], [point1(2),point2(2)], 'Color',[0 1 1],'LineWidth',3);
        case 7
            line([point1(1),point2(1)], [point1(3),point2(3)], [point1(2),point2(2)], 'Color',[1 0 1],'LineWidth',3);
        case 9
            line([point1(1),point2(1)], [point1(3),point2(3)], [point1(2),point2(2)], 'Color',[1 1 0],'LineWidth',3);
        case 10
            line([point1(1),point2(1)], [point1(3),point2(3)], [point1(2),point2(2)], 'Color',[0 1 1],'LineWidth',3);
        case 11
            line([point1(1),point2(1)], [point1(3),point2(3)], [point1(2),point2(2)], 'Color',[1 0 1],'LineWidth',3);                
        otherwise
            line([point1(1),point2(1)], [point1(3),point2(3)], [point1(2),point2(2)], 'LineWidth',3);
    end
end

axis([Xmin Xmax Zmin Zmax Ymin Ymax]);
grid;
