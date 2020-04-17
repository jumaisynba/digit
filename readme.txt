If the tested image format is .bmp, then just put it's name in quotes
as shown below
X=imread("5.bmp"); %write here name of the file
else if the tested image is not .bmp format but it is .png or similar,
then uncomment second line. 
%X=imbinarize(X,0); %uncomment this if file is in .png format and comment if it is .bmp format
Thus, as all preparations are done, the code is ready to run. 


Result will be written in the command line
