%Recursive Bagging - obtaining best points
clc;
clear all;

[num,txt,raw]=xlsread('./Train1/Shweta_1.csv'); %
[r,c]=size(raw);
bssid=unique(txt(2:r,7));
for i=1:r-1
    txt{i+1,5}=num2str(num(i,4));
    if ~(isnan(num(i,1)))
        txt{i+1,2}=num2str(num(i,1));
    end
end

for i=1:size(bssid,1)
    row=find(strcmp({txt{1:r,7}},bssid(i,1)));
    %sum=zeros(31,1); %
    %freq=zeros(31,1); %
    unique_loc=unique(txt(row(1,:),2));
    unique_loc_len=length(unique_loc);
    values=zeros(length(row),1); %all values for a given bssid and given location
    medians=zeros(31,1); %
    freq=zeros(31,1); %to keep track of places with no value
    
    for j=1:unique_loc_len
        freq(str2num(cell2mat(unique_loc(j))),1)=1;
        unique_row= find(strcmp({txt{row(1,:),2}},unique_loc(j))); %find row numbers for all values for given unique location
        values_in_cell=txt(row(1,unique_row),5);
        for k=1:length(values_in_cell)
            values(k,1)=str2num(cell2mat(values_in_cell(k,1)));
        end
        values=values(1:length(values_in_cell));
        medians(str2num(cell2mat(unique_loc(j))),1)=median(values);
    end
    
    for j=2:32
        if(freq(j-1)~=0)
            bssid(i,j)={medians(j-1)};
           %bssid(i,j)={sum(j-1)/freq(j-1)};
        else
           bssid(i,j)={inf};
        end
    end
end

[testnum,testtxt,testraw]=xlsread('./Train1/Acad_14n15oct_geetali.csv'); %TESTDATA floor file with 3-4 wings each
[testr,testc]=size(testtxt);
testbssid=unique(testtxt(2:testr,7));
for i=1:testr-1
    testtxt{i+1,5}=num2str(testnum(i,4));
    if ~(isnan(testnum(i,1)))
        testtxt{i+1,2}=num2str(testnum(i,1));
    end
end

for i=1:size(testbssid,1)
    row=find(strcmp({testtxt{1:testr,7}},testbssid(i,1)));
    sum=zeros(31,1); %
    unique_loc=unique(testtxt(row(1,:),2));
    unique_loc_len=length(unique_loc);
    values=zeros(length(row),1); %all values for a given bssid and given location
    medians=zeros(31,1); %
    freq=zeros(31,1); %
    
    for j=1:unique_loc_len
        freq(str2num(cell2mat(unique_loc(j))),1)=1;
        unique_row= find(strcmp({testtxt{row(1,:),2}},unique_loc(j))); %find row numbers for all values for given unique location
        values_in_cell=testtxt(row(1,unique_row),5);
        for k=1:length(values_in_cell)
            values(k,1)=str2num(cell2mat(values_in_cell(k,1)));
        end
        values=values(1:length(values_in_cell));
        medians(str2num(cell2mat(unique_loc(j))),1)=median(values);
    end
    
    for j=2:32
        if(freq(j-1)~=0)
           %testbssid(i,j)={sum(j-1)/freq(j-1)};
           testbssid(i,j)={medians(j-1)};
        else
           testbssid(i,j)={inf};
        end
    end
end

common=intersect(bssid(:,1),testbssid(:,1));

%####
cur_prediction=0;
points=randperm(31);
points=points(1:30);

fid = fopen('Recursive_results_2.txt', 'a');
fprintf(fid, ['Recursive bagging' '\r\n\r\n']);
fclose(fid);

names={'Test_october_1n7_nearby','Test_24sep','Acad_24sep','Acad_28sep','Test_24sep','Test_28sep','Test_october_1n7_faroff','Test_october_1n7_nearby'};
for iter=1:length(names)
    
[gitnum,gittxt,gitraw]=xlsread(strcat(names{1,iter},'.csv'));
[testr,testc]=size(gittxt);
for i=1:testr-1
    gittxt{i+1,5}=num2str(gitnum(i,4));
    if ~(isnan(gitnum(i,1)))
        gittxt{i+1,2}=num2str(gitnum(i,1));
    end
end

no_of_blocks=unique(gitnum(1:testr-1,1));
breadth=length(no_of_blocks);

%#######
cur_results=zeros(breadth,31);
cur_achieve=zeros(breadth,31);

best_results=zeros(breadth,31);
best_achieve=zeros(breadth,31);

%########

%####
best_bag=randperm(31);
%best_bag=best_bag(1:pts);
for pts=30:-5:25
    %disp('Enter');
    predictions=zeros(1,31);
    old_best_bag=best_bag;
    best_bag=randperm(pts);
    %best_bag=best_bag(1:pts);
    best_prediction=0;

    
for bags=1:2
    
    cur_prediction=0;
    shuffle_array=randperm(length(old_best_bag));

points=old_best_bag(shuffle_array);
points=points(1:pts);
disp(['trying bag of size: ' num2str(pts) ': ' num2str(points)]);


len=length(intersect(bssid(:,1),testbssid(:,1)));
X=zeros(1,len);
Y=zeros(1,len);
j=1;
    for k=1:length(points)
        pos=points(k)+1;
        %disp(['Difference in value for position ' num2str(points(k))]);
        for i=1:len
            testrow=find(strcmp({testbssid{:,1}},common(i)));
            row=find(strcmp({bssid{:,1}},common(i)));
            a=cell2mat(testbssid(testrow,pos));
            b=cell2mat(bssid(row,pos));
            if(a~=inf && b~=inf)
                %diff=a-b;
                %disp(diff);
                X(j)=a;
                Y(j)=b;
                j=j+1;
            end
        end
    end
    
s=scatter(X,Y);
s.LineWidth = 0.6;
s.MarkerEdgeColor = 'b';
s.MarkerFaceColor = [0 0.5 0.5];
xlabel('Geetali phone RSSI');
ylabel('Shweta phone RSSI');
title('Distribution of RSSI points for Calibration');
P = polyfit(X,Y,1);
yfit = P(1)*X+P(2);
hold on;
plot(X,yfit,'r-.');

slope=P(1); %Of the found equation
intercept=P(2); %Of the found equation



for outer=1:breadth %Each floor block wise iteration
    block_no=no_of_blocks(outer);
    start=min(find(gitnum(:,1)==block_no))+1;
    stop=max(find(gitnum(:,1)==block_no))+1;
    gitbssid=unique(gittxt(start:stop,7));
    dis=zeros(1,1);
    for i=1:size(gitbssid,1)
        row=find(strcmp({gittxt{1:testr,7}},gitbssid(i,1)));        
        unique_loc=unique(gittxt(row(1,:),2));
        unique_loc_len=length(unique_loc);
        values=zeros(length(row),1); %all values for a given bssid and given location
        medians=zeros(31,1); %
        freq=zeros(31,1); %
        
        for j=1:unique_loc_len
            freq(str2num(cell2mat(unique_loc(j))),1)=1;
            unique_row= find(strcmp({gittxt{row(1,:),2}},unique_loc(j))); %find row numbers for all values for given unique location
            values_in_cell=gittxt(row(1,unique_row),5);
            for k=1:length(values_in_cell)
                values(k,1)=str2num(cell2mat(values_in_cell(k,1)));
            end
            values=values(1:length(values_in_cell));
            medians(str2num(cell2mat(unique_loc(j))),1)=median(values);
        end
        for j=2:32 %TESTDATA
            if(freq(j-1)~=0)
                gitbssid(i,j)={P(1)*medians(j-1)+P(2)}; %With median
            else
                 gitbssid(i,j)={inf};
            end
        end
    end

        pos=-1;
        k=1;
        for i=1:size(gitbssid,1)
            mini=10000;
            pos=-1;
            for j=2:32 %
                row=find(strcmp({gitbssid{i,1}},bssid(:,1)));
                if(length(row)~=0)
                    a=cell2mat(bssid(row,j));
                    b=cell2mat(gitbssid(i,no_of_blocks(outer)+1));
                    if(a~=inf && b~=inf)
                        if(abs(a-b)<mini)
                            mini=abs(a-b);
                            pos=j-1;
                        end
                    end
                end
            end
            if(pos~=-1)
                dis(k)=pos;
                k=k+1;
            end
        end
        if(length(dis~=0))
            %disp(['Floor/Wing Wing wise prediction is ' num2str(mode(dis))]);
        else
            disp('Location not found');
        end
        if(length(dis)~=0)
            add=zeros(1,31);
            add(block_no)=1;
            toadd = add;
            %######
            cur_achieve(outer,:)=add;
            %#####

            add=zeros(1,31);
            add(mode(dis))=1;
            toadd = add;            
            %######
            cur_results(outer,:)=add;
            %######
        end
        
        %###########
        if mode(dis)==block_no
            %disp('Enter 2');
            cur_prediction=cur_prediction+1;
        end
        %###########
        
        end
    %##############
    fid = fopen('Recursive_results_2.txt', 'a');
    fprintf(fid, ['accuracy predicted for bag' num2str(bags) ' of size' num2str(pts) ': ' num2str(cur_prediction) '\r\n']);
    fclose(fid);
    disp(['accuracy predicted for bag' num2str(bags) ' of size' num2str(pts) ': ' num2str(cur_prediction) ]);
    if(cur_prediction>best_prediction)
        best_prediction=cur_prediction;
        best_bag=points;
        best_results=cur_results;
        best_achieve=cur_achieve;
    end
    %#########
end
end
    %######
    fid = fopen('Recursive_results_2.txt', 'a');
    fprintf(fid, ['best bag' ' of size' num2str(pts) ': ' num2str(best_bag) 'with accuacy:' num2str(best_prediction) '\r\n\r\n\r\n']);
    fclose(fid);
    disp(['best bag' ' of size' num2str(pts) ': ' num2str(best_bag) 'with accuacy:' num2str(best_prediction) ]);
    achieve_filename=strcat('Achieve_downsample_',num2str(pts),'.csv');
    dlmwrite (achieve_filename, best_achieve, '-append' );
    obtained_filename=strcat('Obtained_downsample_',num2str(pts),'.csv');
    dlmwrite (obtained_filename, best_results, '-append' );
    %######

end
disp('groundfloorcdxcounter 1 ; groundfloorglassroom 2 ; groundfloorlobby 3 ; groundfloorclassroomlobby 4 ; firstfloorA 5 ; firstfloorB 6 ; firstfloorlobby 7');
disp('firstfloorclassroomlobby 8 ; secondfloorA 9 ; secondfloorB 10 ; secondfloorlobby 11 ; secondfloorclassroomlobby 12 ; thirdfloorA 13 ; thirdfloorB 14');
disp('thirdfloorlobby 15 ; fourthfloorA 16 ; fourthfloorB 17 ; fourthfloorlobby 18 ; fifthfloorA 19 ; fifthfloorB 20 ; fifthfloorlobby 21');
disp('C01 22 ; C02 23 ; C03 24 ; C11 25 ; C12 26 ; C13 27 ; C21 28 ; C22 29 ; C23 30 ; C24 31');
