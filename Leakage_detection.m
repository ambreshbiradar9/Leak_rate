clear all
clc
input('Stabilize the level of float in the tube and then press any key to continue');
fileID=fopen('C:\Users\Srinivas\Desktop\Experiments\SerialPortSotware\Record_leak\Leak_2021.txt','a');
I=imread('C:\Users\Srinivas\Desktop\Experiments\SerialPortSotware\OutputDisplay2.jpg');
videoplayer=vision.VideoPlayer('Name','Pressure and Leak');
position1=[210 130];
position2=[580 130];
box_color={'white'};
%% Initialization
vidDevice = imaq.VideoDevice('winvideo', 1, 'MJPG_640x480','ReturnedColorSpace', 'rgb','ROI', [90 90 380 290]); ...% Acquire input video stream
    %'ROI', [235 195 510 500], ...
    
vidInfo = imaqhwinfo(vidDevice); % Acquire input video property

hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
    'CentroidOutputPort', true, ...
    'BoundingBoxOutputPort', true', ...
    'MinimumBlobArea', 100, ...
    'MaximumBlobArea', 55000, ...
    'MaximumCount', 6);

hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
    'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
nFrame = 0; % Frame number initialization
blueThresh = 0.06; % Threshold for blue detection
%blueThresh = 0.053;
%% Processing Loop
while(nFrame < 600)
    rgbFrame = step(vidDevice); % Acquire single frame
    %%
    diffFrameBlue = imsubtract(rgbFrame(:,:,3), rgb2gray(rgbFrame)); % Get blue component of the image
    diffFrameBlue = medfilt2(diffFrameBlue, [3 3]); % Filter out the noise by using median filter
    %binFrameBlue = im2bw(diffFrameBlue, blueThresh); % Convert the image into binary image with the blue objects as white
    binFrameBlue = imbinarize(diffFrameBlue,blueThresh);
   [centroidBlue, bboxBlue] = step(hblob, binFrameBlue); % Get the centroids and bounding boxes of the blue blobs
    %centroid1 = uint16(centroidBlue); % Convert the centroids into Integer for further steps 
    centroid1 = centroidBlue;
    %%
    if length(centroid1)>=2
        text=append(num2str(centroid1(1,1)),' ',num2str(centroid1(1,2)));
        rgbFrame=insertText(rgbFrame,[centroid1(1,1)-6 centroid1(1,2)-9],text);
        %if (height(centroid1)>=2)&&(width(centroid1)>=2)
        text_1=append(num2str(centroid1(2,1)),' ',num2str(centroid1(2,2)));
        rgbFrame=insertText(rgbFrame,[centroid1(2,1)-6 centroid1(2,2)-9],text_1);
        %   if (height(centroid1)>=3)&&(width(centroid1)>=3)
        text_2=append(num2str(centroid1(3,1)),' ',num2str(centroid1(3,2)));
        rgbFrame=insertText(rgbFrame,[centroid1(3,1)-6 centroid1(3,2)-9],text_2);
        %      if (height(centroid1)>=4)&&(width(centroid1)>=4)
        text_3=append(num2str(centroid1(4,1)),' ',num2str(centroid1(4,2)));
        rgbFrame=insertText(rgbFrame,[centroid1(4,1)-6 centroid1(4,2)-9],text_3);
        %         if (height(centroid1)>=5)&&(width(centroid1)>=5)
        text_4=append(num2str(centroid1(5,1)),' ',num2str(centroid1(5,2)));
        rgbFrame=insertText(rgbFrame,[centroid1(5,1)-6 centroid1(5,2)-9],text_4);
        %            if (height(centroid1)==6)&&(width(centroid1)==6)
        text_5=append(num2str(centroid1(6,1)),' ',num2str(centroid1(6,2)));
        rgbFrame=insertText(rgbFrame,[centroid1(6,1)-6 centroid1(6,2)-9],text_5);
        %           end
        %      end
        %  end
        %end
        %end
    end
    step(hVideoIn, rgbFrame); % Output video stream
    nFrame = nFrame+1;
end

%% Sorting of the centroid coordinates
centroid_Blue=sortrows(centroidBlue);

if centroid_Blue(1,2)>centroid_Blue(2,2)
    temp1=centroid_Blue(1,1);
    temp2=centroid_Blue(1,2);
    centroid_Blue(1,1)=centroid_Blue(2,1);
    centroid_Blue(1,2)=centroid_Blue(2,2);
    centroid_Blue(2,1)=temp1;
    centroid_Blue(2,2)=temp2;
end

if centroid_Blue(3,2)>centroid_Blue(4,2)
    temp1=centroid_Blue(3,1);
    temp2=centroid_Blue(3,2);
    centroid_Blue(3,1)=centroid_Blue(4,1);
    centroid_Blue(3,2)=centroid_Blue(4,2);
    centroid_Blue(4,1)=temp1;
    centroid_Blue(4,2)=temp2;
end

if centroid_Blue(5,2)>centroid_Blue(6,2)
    temp1=centroid_Blue(5,1);
    temp2=centroid_Blue(5,2);
    centroid_Blue(5,1)=centroid_Blue(6,1);
    centroid_Blue(5,2)=centroid_Blue(6,2);
    centroid_Blue(6,1)=temp1;
    centroid_Blue(6,2)=temp2;
end

%% Insert
Large_lev1=150; % LEft most 500 ml
Large_lev2=500;

Medium_lev1=70; % Middle one 250 ml
Medium_lev2=250; 

Small_lev1=40; % Right most 100 ml
Small_lev2=100; 
%% Calibrate the leak value
Large_konst=(Large_lev2-Large_lev1)/sqrt(((centroid_Blue(1,1)-centroid_Blue(2,1))^2)+((centroid_Blue(1,2)-centroid_Blue(2,2))^2));
Medium_konst=(Medium_lev2-Medium_lev1)/sqrt(((centroid_Blue(3,1)-centroid_Blue(4,1))^2)+((centroid_Blue(3,2)-centroid_Blue(4,2))^2));
Small_konst=(Small_lev2-Small_lev1)/sqrt(((centroid_Blue(5,1)-centroid_Blue(6,1))^2)+((centroid_Blue(5,2)-centroid_Blue(6,2))^2));
%% blob for red
hblob1 = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
    'CentroidOutputPort', true, ...
    'BoundingBoxOutputPort', true', ...
    'MinimumBlobArea', 300, ...
    'MaximumBlobArea', 55000, ...
    'MaximumCount', 3);
redThresh = 0.06; %
%% Check
num=0;
Pressure=xlsread('C:\Users\Srinivas\Desktop\Experiments\SerialPortSotware\Control.xls','Sheet1','D5');
Leak=0;
while(num~=1)%&&(nFrame<800)
    rgbFrame = step(vidDevice); % Acquire single frame
    %rgbFrame = flipdim(rgbFrame,2); % obtain the mirror image for displaying
    diffFrame = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame)); % Get red component of the image
    diffFrame = medfilt2(diffFrame, [3 3]); % Filter out the noise by using median filter
    binFrame = imbinarize(diffFrame,redThresh); % Convert the image into binary image with the red objects as white
    %binFrame = im2bw(diffFrame,redThresh);
    [centroid, bbox] = step(hblob1, binFrame); % Get the centroids and bounding boxes of the blobs
    centroid3f=centroid;
    centroid3 = uint16(centroid); % Convert the centroids into Integer for further steps
    centroid_red=sortrows(centroid3f);
    if length(centroid_red)>=2
        Large_leakread=Large_lev1+Large_konst*sqrt(((centroid_red(1,1)-centroid_Blue(1,1))^2)+((centroid_red(1,2)-centroid_Blue(1,2))^2));
        textr_1=append(num2str(centroid_red(1,1)),' ',num2str(centroid_red(1,2)));
        rgbFrame = insertText(rgbFrame,[centroid_red(1,1) centroid_red(1,2)],textr_1);%num2str(Large_leakread));
        Medium_leakread=Medium_lev1+Medium_konst*sqrt(((centroid_red(2,1)-centroid_Blue(3,1))^2)+((centroid_red(2,2)-centroid_Blue(3,2))^2));
        textr_2=append(num2str(centroid_red(2,1)),' ',num2str(centroid_red(2,2)));
        rgbFrame = insertText(rgbFrame,[centroid_red(2,1) centroid_red(2,2)],textr_2);%num2str(Medium_leakread));
        Small_leakread=Small_lev1+Small_konst*sqrt(((centroid_red(3,1)-centroid_Blue(5,1))^2)+((centroid_red(3,2)-centroid_Blue(5,2))^2));
        textr_3=append(num2str(centroid_red(3,1)),' ',num2str(centroid_red(3,2)));
        rgbFrame = insertText(rgbFrame,[centroid_red(3,1) centroid_red(3,2)],textr_3);%num2str(Small_leakread));
    end
    %imshow(binFrame);
    %vidIn = step(htextins, vidIn, uint8(length(bbox(:,1)))); % Count the number of blobs
    step(hVideoIn, rgbFrame); % Output video stream

    nFrame = nFrame+1;
    if rem(nFrame,100)==0
        D=xlsread('C:\Users\Srinivas\Desktop\Experiments\SerialPortSotware\Control.xls','Sheet1','D5:F5');
        Pressure=D(1);
        num=D(2);
        Leak=D(3);
    end
    
    %% Display Data
    RaGaBa=insertText(I,position1,Pressure,'FontSize',45,'TextColor','black','BoxColor', box_color);
  %I commented this just check  %RaGaBa=insertText(RaGaBa,position2,leakread,'FontSize',45,'TextColor','black','BoxColor', box_color);
    %step(videoplayer,RaGaBa)
    
    %% Save Data
    fprintf(fileID,'%f\t%f\t%f\t%f\t%f\n',[now-693960 Pressure Large_leakread Medium_leakread Small_leakread]);
end

%Clearing Memory
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);
clc;
