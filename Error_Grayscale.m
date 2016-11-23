clc;
clear all;

[num,txt,raw]=xlsread('./../Matrix.csv'); %
[obtnum,obttxt,obtraw]=xlsread('./../Accuracy_Dataset/dbm/Obtained_deepali_recur3_base.csv');
[achnum,achtxt,achraw]=xlsread('./../Accuracy_Dataset/dbm/Achieve_deepali_recur3_base.csv');
[r,c]=size(num);
[obtr,obtc]=size(obtnum);
[achr,achc]=size(achnum);
bins=[0;0;0;0];
for i=1:obtr
    obt_pos=find(obtnum(i,:)==1);
    ach_pos=find(achnum(i,:)==1);
    if(num(ach_pos,obt_pos)==0)
        bins(1)=bins(1)+1;
    elseif(num(ach_pos,obt_pos)==1)
        bins(2)=bins(2)+1;
    elseif(num(ach_pos,obt_pos)==2)
        bins(3)=bins(3)+1;
    else
        bins(4)=bins(4)+1;
    end
end
total=bins(1)+bins(2)+bins(3)+bins(4);
figure;
bar(1,(bins(1)/total)*100,'FaceColor',[0.15 0.15 0.15]);
hold on;
bar(2,(bins(2)/total)*100,'FaceColor',[0.3 0.3 0.3 ]);
hold on;
bar(3,(bins(3)/total)*100,'FaceColor',[0.55 0.55 0.55]);
hold on;
bar(4,(bins(4)/total)*100,'FaceColor',[0.8 0.8 0.8]);
title('Bar Graph Display Distribution of testing samples');
xlabel('Error');
ylabel('Frequency %');
ylim([0 100]);
legend('Correct Identified', 'error within 1 block', 'error within 2 blocks', 'error within 3+ blocks');
Labels = {'0', '1', '2', '3+'};
set(gca, 'XTick', 1:4, 'XTickLabel', Labels);
