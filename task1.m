X=imread("1.bmp"); %write here name of the file
%X=imbinarize(X,0); %uncomment this if file is in .png format and comment if it is .bmp format
[m,n]=size(X);
spur=5; 
se=[
     0 1 0;
     1 1 1;
     0 1 0;
    ];

ms=size(se);
maskS=ms(1);
clc
%% cropping 
count=0;
count2=0;
%up crop
for i=1:m
    if sum(X(i,:))~=n && count==0
        Hor1=i-1;
        count=count+1;
    end
    for j=1:n
        if sum(X(:,j))~=m && count2==0
            Ver1=j-1;
            count2=count2+1;
        end
    end
end
X_crop=true(m-Hor1,n-Ver1);
for i=1:m-Hor1
    for j=1:n-Ver1
        X_crop(i,j)=X(i+Hor1,j+Ver1);
    end
end
%---bottom crop
[mc,nc]=size(X_crop);
count3=0;
count4=0;
for i=1:mc
    if sum(X_crop(i,:))==nc && count3==0
        Hor2=i-1;
        count3=count3+1;
    end
    for j=1:nc
        if sum(X_crop(:,j))==mc && count4==0
            Ver2=j-1;
            count4=count4+1;
        end
    end
end
X_cropFin=true(Hor2,Ver2);
for i=1:Hor2
    for j=1:Ver2
        X_cropFin(i,j)=X_crop(i,j);
    end
end
%% Zero Padding
Padded=true(Hor2+maskS-1,Ver2+maskS-1);
[z,k]=size(Padded);
for i=1:Hor2+(maskS-1)/2
    for j=1:Ver2+(maskS-1)/2
        if (i>(maskS-1)/2 && j>(maskS-1)/2)
            Padded(i,j)= X_cropFin(i-(maskS-1)/2,j-(maskS-1)/2);
        end
        
    end
end

%% dialation and erosion 
Diald=true(z,k);
for i=2:z-1
    for j=2:k-1
        if Padded(i,j)==0 || Padded(i-1,j)==0 || Padded(i,j-1)==0 || ...
                Padded(i+1,j)==0 || Padded(i,j+1)==0 ||...
                 Padded(i+1,j+1)==0 || Padded(i-1,j+1)==0 || Padded(i+1,j-1)==0 || Padded(i-1,j-1)==0 %||...
                 %Padded(i+2,j)==0 || Padded(i,j+2)==0 || Padded(i-2,j)==0 || Padded(i,j-2)==0
            Diald(i,j)=0;
        end
    end
end
Eros=true(z,k);
for i=2:z-1
    for j=2:k-1
        if Diald(i,j)==0 && Diald(i-1,j)==0 && Diald(i,j-1)==0 && ...
                Diald(i+1,j)==0 && Diald(i,j+1)==0
                 %Padded(i+1,j+1)==0 || Padded(i-1,j+1)==0 || Padded(i+1,j-1)==0 || Padded(i-1,j-1)==0
            Eros(i,j)=0;
        end
    end
end
%% circle finder
cou=0;

Inner=uint8(zeros(z,k));
xx=100;
Masked=Eros-Diald;
    for i=1:z
        for j=1:k
            if (Masked(i,j)==0)
                Inner(i,j)=255;
            end
        end
    end
%----------------countering----------------
crutch=0;
a=0;
b=0;
ku=0;
for i=2:z-1
    for j=2:k-1
        
        if Inner(i,j)==0  

            pi=i;
            pj=j;
            Inner(i,j)=xx+1;
            cou=1;
            crutch=0;
            halfdetecotr=0;
            while  1%(a~=pi && b~=pj)
                if crutch==0
                    a=pi;
                    b=pj;
                    crutch=1;
                end
                ku=ku+1;
                if (a-i>2 || b-j>2) && (halfdetecotr==0)
                    halfdetecotr=1;
                end
                %1
                if (Inner(a-1,b)==0) || (halfdetecotr && Inner(a-1,b)==xx+1)
                    a=a-1;
                    
                    Inner(a,b)=xx;
                    %2
                elseif (Inner(a-1,b-1)==0) || (halfdetecotr && Inner(a-1,b-1)==xx+1)
                    a=a-1;
                    b=b-1;
                    Inner(a,b)=xx;
                    %3
                elseif (Inner(a,b-1)==0) || (halfdetecotr && Inner(a,b-1)==xx+1)
                    b=b-1;
                    Inner(a,b)=xx;
                    %4
                elseif (Inner(a+1,b-1)==0) || (halfdetecotr && Inner(a+1,b-1)==xx+1)
                    a=a+1;
                    b=b-1;
                    Inner(a,b)=xx;
                    %5
                elseif (Inner(a+1,b)==0) || (halfdetecotr && Inner(a+1,b)==xx+1)
                    a=a+1;
                    Inner(a,b)=xx;
                elseif (Inner(a+1,b+1)==0) || (halfdetecotr && Inner(a+1,b+1)==xx+1)
                    a=a+1;
                    b=b+1;
                    Inner(a,b)=xx;
                elseif (Inner(a,b+1)==0) || (halfdetecotr && Inner(a,b+1)==xx+1)
                    b=b+1;
                    Inner(a,b)=xx;
                elseif (Inner(a-1,b+1)==0) || (halfdetecotr && Inner(a-1,b+1)==xx+1)
                    a=a-1;
                    b=b+1;
                    Inner(a,b)=xx;
                end
                if (a==pi && b==pj) || ku>700
                    xx=xx+50;
                    break
                end
            end
        end
        
    end
end
% check for unneeded regions
x=100;

while 1
    number=0;
    for i=2:z-1
        for j=2:k-1
            if Inner(i,j)==x
                number=number+1;
            end
        end
    end
    x=x+50;

    if x==xx 
        break;
    end
end
    if number<5
        xx=xx-50;
    end
%% decision tree first shapes 
if xx==250
    
    disp(8);
    thisis=8;
    
end
if xx==200 || xx>300
    disp([0,4,6,9])
end
if xx==150
    disp([7,5,3,2,1])
end

%% ------Thinning
Thin=imerode(~Padded,se);
%B1

for rep=0:30
    for i=2:z-1
        for j=2:k-1
            if Thin(i,j)==1 && Thin(i-1,j-1)==0 && Thin(i-1,j)==0 && Thin(i-1,j+1)==0 &&...
                    Thin(i+1,j-1)==1 && Thin(i+1,j)==1 && Thin(i+1,j+1)==1
                    Thin(i,j)=0;

            end
            if Thin(i,j)==1 && Thin(i+1,j+1)==0 && Thin(i-1,j+1)==0 && Thin(i,j+1)==0 &&...
                    Thin(i,j-1)==1 && Thin(i+1,j-1)==1 && Thin(i-1,j-1)==1
                Thin(i,j)=0;
            end
            if Thin(i,j)==1 && Thin(i-1,j-1)==1 && Thin(i-1,j)==1 && Thin(i-1,j+1)==1 &&...
                    Thin(i+1,j-1)==0 && Thin(i+1,j)==0 && Thin(i+1,j+1)==0
                Thin(i,j)=0;
            end
            if Thin(i,j)==1 && Thin(i+1,j+1)==1 && Thin(i-1,j+1)==1 && Thin(i,j+1)==1 &&...
                    Thin(i,j-1)==0 && Thin(i+1,j-1)==0 && Thin(i-1,j-1)==0
                Thin(i,j)=0;
            end
        end
    end
    
end
%B2

for rep=1:30
    for i=2:z-1
        for j=2:k-1
            
            if Thin(i,j)==1 && Thin(i+1,j+1)==0 && Thin(i-1,j+1)==0 && Thin(i,j+1)==0 &&...
                    Thin(i,j-1)==1 && Thin(i-1,j-1)==1 %&& Thin(i+1,j-1)==1
                Thin(i,j)=0;
            end
            
            if Thin(i,j)==1 && Thin(i+1,j+1)==1  && Thin(i,j+1)==1 &&... && Thin(i-1,j+1)==1
                    Thin(i,j-1)==0 && Thin(i+1,j-1)==0 && Thin(i-1,j-1)==0
                Thin(i,j)=0;
            end
            if Thin(i,j)==1  && Thin(i-1,j)==1 && Thin(i,j-1)==1 &&...&& Thin(i-1,j-1)==1
                    Thin(i+1,j+1)==0 && Thin(i,j+1)==0 && Thin(i+1,j)==0
                Thin(i,j)=0;
            end
            if Thin(i,j)==1 && Thin(i-1,j-1)==0 && Thin(i-1,j)==0 && Thin(i,j-1)==0 &&...
                    Thin(i,j+1)==1 && Thin(i+1,j)==1 %Thin(i+1,j+1)==1 && 
                Thin(i,j)=0;
            end
        end
    end
end
%sprung

for rep=1:spur
    for i=2:z-1
        for j=2:k-1         
            if Thin(i,j)==1 && Thin(i-1,j-1)==0 && Thin(i-1,j)==0 && Thin(i-1,j+1)==0 &&...
                    Thin(i,j-1)==0 && Thin(i,j+1)==0 && Thin(i+1,j-1)==0
                Thin(i,j)=0;
            end
            if Thin(i,j)==1 && Thin(i-1,j-1)==0 && Thin(i-1,j)==0 && Thin(i+1,j)==0 &&...
                    Thin(i,j-1)==0 && Thin(i+1,j+1)==0 && Thin(i+1,j-1)==0
                Thin(i,j)=0;
            end
            if Thin(i,j)==1 && Thin(i+1,j)==0 && Thin(i+1,j+1)==0 && Thin(i-1,j+1)==0 &&...
                    Thin(i,j-1)==0 && Thin(i,j+1)==0 && Thin(i+1,j-1)==0
                Thin(i,j)=0;
            end
            if Thin(i,j)==1 && Thin(i-1,j-1)==0 && Thin(i-1,j)==0 && Thin(i-1,j+1)==0 &&...
                    Thin(i,j+1)==0 && Thin(i+1,j)==0 && Thin(i+1,j+1)==0
                Thin(i,j)=0;
            end
        end
    end
end
% spur 2 
for rep=1:spur
    for i=2:z-1
        for j=2:k-1         
            if Thin(i,j)==1 && Thin(i-1,j-1)==0 && Thin(i-1,j)==0 && Thin(i-1,j+1)==0 &&...
                    Thin(i,j-1)==0 && Thin(i,j+1)==0 && Thin(i+1,j+1)==0
                Thin(i,j)=0;
            end
            if Thin(i,j)==1 && Thin(i-1,j+1)==0 && Thin(i-1,j)==0 && Thin(i-1,j+1)==0 &&...
                    Thin(i,j+1)==0 && Thin(i+1,j)==0 && Thin(i+1,j+1)==0
                Thin(i,j)=0;
            end
            if Thin(i,j)==1 && Thin(i+1,j)==0 && Thin(i+1,j+1)==0 && Thin(i-1,j-1)==0 &&...
                    Thin(i,j-1)==0 && Thin(i,j+1)==0 && Thin(i+1,j-1)==0
                Thin(i,j)=0;
            end
            if Thin(i,j)==1 && Thin(i-1,j-1)==0 && Thin(i-1,j)==0 && Thin(i-1,j+1)==0 &&...
                    Thin(i,j+1)==0 && Thin(i+1,j)==0 && Thin(i-1,j+1)==0
                Thin(i,j)=0;
            end
        end
    end
end
%------------------ remove leftovers
%B1

for rep=0:30
    for i=2:z-1
        for j=2:k-1
            if Thin(i,j)==1 && Thin(i-1,j-1)==0 && Thin(i-1,j)==0 && Thin(i-1,j+1)==0 &&...
                    Thin(i+1,j-1)==1 && Thin(i+1,j)==1 && Thin(i+1,j+1)==1
                    Thin(i,j)=0;

            end
            if Thin(i,j)==1 && Thin(i+1,j+1)==0 && Thin(i-1,j+1)==0 && Thin(i,j+1)==0 &&...
                    Thin(i,j-1)==1 && Thin(i+1,j-1)==1 && Thin(i-1,j-1)==1
                Thin(i,j)=0;
            end
            if Thin(i,j)==1 && Thin(i-1,j-1)==1 && Thin(i-1,j)==1 && Thin(i-1,j+1)==1 &&...
                    Thin(i+1,j-1)==0 && Thin(i+1,j)==0 && Thin(i+1,j+1)==0
                Thin(i,j)=0;
            end
            if Thin(i,j)==1 && Thin(i+1,j+1)==1 && Thin(i-1,j+1)==1 && Thin(i,j+1)==1 &&...
                    Thin(i,j-1)==0 && Thin(i+1,j-1)==0 && Thin(i-1,j-1)==0
                Thin(i,j)=0;
            end
        end
    end
    
end
%B2

for rep=1:30
    for i=2:z-1
        for j=2:k-1
            
            if Thin(i,j)==1 && Thin(i+1,j+1)==0 && Thin(i-1,j+1)==0 && Thin(i,j+1)==0 &&...
                    Thin(i,j-1)==1 && Thin(i-1,j-1)==1 %&& Thin(i+1,j-1)==1
                Thin(i,j)=0;
            end
            
            if Thin(i,j)==1 && Thin(i+1,j+1)==1  && Thin(i,j+1)==1 &&... && Thin(i-1,j+1)==1
                    Thin(i,j-1)==0 && Thin(i+1,j-1)==0 && Thin(i-1,j-1)==0
                Thin(i,j)=0;
            end
            if Thin(i,j)==1  && Thin(i-1,j)==1 && Thin(i,j-1)==1 &&...&& Thin(i-1,j-1)==1
                    Thin(i+1,j+1)==0 && Thin(i,j+1)==0 && Thin(i+1,j)==0
                Thin(i,j)=0;
            end
            if Thin(i,j)==1 && Thin(i-1,j-1)==0 && Thin(i-1,j)==0 && Thin(i,j-1)==0 &&...
                    Thin(i,j+1)==1 && Thin(i+1,j)==1 %Thin(i+1,j+1)==1 && 
                Thin(i,j)=0;
            end
        end
    end
end
Hop=imdilate(Thin,se);
Hop=imerode(Hop,se);
Thin=bwskel(~Padded);

%%   endpoint counter and detect some
[tm,tn]=size(Thin);
Checker=uint8(zeros(tm,tn));
endpoint=0;
endloci=0;
endlocj=0;
fi=0;
fj=0;
first=0;
for i=2:tm-1
    for j=2:tn-1
        if Thin(i,j)==1 && Thin(i-1,j-1)==0 && Thin(i-1,j)==0 && Thin(i-1,j+1)==0 &&...
                Thin(i,j-1)==0 && Thin(i,j+1)==0
            Checker(i,j)=255;
            endloci=i;
            endlocj=j;
            endpoint=endpoint+1;
            if first==0
                fi=i;
                fj=j;
                first=1;
            end
        elseif Thin(i,j)==1 && Thin(i,j-1)==0 && Thin(i,j+1)==0 &&...
                Thin(i+1,j-1)==0 && Thin(i+1,j)==0 && Thin(i+1,j+1)==0
            endpoint=endpoint+1;
            Checker(i,j)=255;
            endloci=i;
            endlocj=j;
            if first==0
                fi=i;
                fj=j;
                first=1;
            end
        elseif Thin(i,j)==1 && Thin(i-1,j)==0 && Thin(i+1,j)==0 &&...
                Thin(i-1,j-1)==0 && Thin(i,j-1)==0 && Thin(i+1,j-1)==0
            endpoint=endpoint+1;
            Checker(i,j)=255;
            endloci=i;
            endlocj=j;
            if first==0
                fi=i;
                fj=j;
                first=1;
            end
        
        elseif Thin(i,j)==1 && Thin(i-1,j)==0 && Thin(i+1,j)==0 &&...
                Thin(i-1,j+1)==0 && Thin(i,j+1)==0 && Thin(i+1,j+1)==0
            endpoint=endpoint+1;
            Checker(i,j)=255;
            endloci=i;
            endlocj=j;
            if first==0
                fi=i;
                fj=j;
                first=1;
            end
        end
    end
end

[z,k]=size(Padded);

if (endpoint==0 && xx==200)
    disp(0);
    thisis=0;
elseif (endpoint>=2 && xx==200) && endloci>z/2 && endlocj>k/2
    disp(4);
    thisis=4;
elseif (xx==200 || xx>300) 
    disp([6,9]);
    if fi<round(z/4)
        disp(6);
        thisis=6;
    elseif(endloci>round(z/4)) 
        disp(9);
        thisis=9;
    end
end
%% stragith lines checker
Border=Eros-Diald;
count=zeros();
a=2;
b=2;
cc=0;
bottomlines=1;
for i=2:z-1
    for j=2:k-1
        if (Border(i,j)==1 && cc==0)
            pi=i;
            pj=j;
            cc=1;
            crutch=0;
            while 1
                if crutch==0
                    a=pi;
                    b=pj;
                    crutch=1;
                    c=1;
                end
                Border(a,b)=0;
                if Border(a-1,b)==1
                    a=a-1;
                    if count(c)~=2
                        c=c+1;
                        count(c)=2;
                    end
                elseif Border(a-1,b+1)==1
                    a=a-1;
                    b=b+1;
                    if count(c)~=1
                        c=c+1;
                        count(c)=1;
                    end
                elseif Border(a,b+1)==1
                    b=b+1;
                    %if count(c)~=0
                        c=c+1;
                        count(c)=0;
                        
                   % end
                elseif Border(a+1,b+1)==1
                    a=a+1;
                    b=b+1;
                    if count(c)~=7
                        c=c+1;
                        count(c)=7;
                    end
                elseif Border(a+1,b)==1
                    a=a+1;
                    if count(c)~=6
                        c=c+1;
                        count(c)=6;
                    end
                elseif Border(a+1,b-1)==1
                    a=a+1;
                    b=b-1;
                    if count(c)~=5
                        c=c+1;
                        count(c)=5;
                    end
                elseif Border(a,b-1)==1
                    b=b-1;
                    if count(c)~=4
                        c=c+1;
                        count(c)=4;
                    end
                    if a==z-1
                        bottomlines=bottomlines+1;
                    end
                elseif Border(a-1,b-1)==1
                    a=a-1;
                    b=b-1;
                    if count(c)~=3
                        c=c+1;
                        count(c)=3;
                    end
                else
                    break;
                end

            end
        end
        
    end
end
numberOfupperLines=0;
another=0;
for c=1:c(end)
    if count(c)~=0
        another=1;
    end
    if count(c)==0 && another==0
        numberOfupperLines=numberOfupperLines+1;
    end
end


Border=Eros-Diald;
[m,n]=size(Border);

if (xx==150 && bottomlines>((n-2)/2.5) && numberOfupperLines>((n-2)/2.5) && bottomlines<n/1.5 && (fi>m/2 || fj<n/2))
    disp(3);
    thisis=3;
elseif (xx==150 && bottomlines>n/2 && fi<m/2 && fj<n/2)
    disp(2);
    thisis=2;
elseif(xx==150 && numberOfupperLines>n/2)
    disp([7,5]);
    if (fi<m/2 && fj>n/2) && endpoint>=2 && numberOfupperLines~=n-2
        disp(5);
        thisis=5;
    elseif numberOfupperLines==n-2  || (fi<m/2 && fj<n/2)
        disp(7);
        thisis=7;
    end
elseif xx==150
    disp(1);
    thisis=1;
end
subplot(1,4,1);
imshow(X); title("original");
subplot(1,4,2);
imshow(Masked); title("edge detection");
subplot(1,4,3);
imshow(Inner); title("Region splitted");
subplot(1,4,4);
imshow(Thin); title("Thin and result is "+thisis);

disp("The image contains digit "+ thisis)
    
    