function makeTexture_Img

%loads images, and scrambles if selected

global screenPTR Gtxtr loopTrial Mstate IDim

%get parameters
P = getParamStruct;

if ~P.keepinmemory
    if ~isempty(Gtxtr)
        for ii=1:length(Gtxtr)
            Screen('Close',Gtxtr(ii));
        end
    end

    Gtxtr = [];
elseif ~isempty(Gtxtr)
    return;
end



%read image
img=imread([P.imgpath '/' P.imgbase '/' P.imgbase '_' num2str(P.imgnr) '.' P.filetype]);
img=double(img);

% this hack is not required anymore because both setups are the same and
% will be for the forseeable future. 
% %%%hack: necessary to run the same code on the 2 setups
% [setup,~]=getSetup;
% if strcmp(setup,'2P') && max(img(:))>1
%     % assume that the image is 0-255 scale
%     img = img/255;
% end

img = img/255;

%turn to black/white if requested
if P.color==0
    img=mean(img,3);
end

%make output image
imgout=img;

%if selected, scramble the image by reordering blocks
if P.scramble==1
    s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*str2double(Mstate.unit)+str2double(Mstate.expt)+loopTrial);
    
    %get size of the blocks
    imgdim=size(img);
    sizeblockX=round(imgdim(1)/P.nrblocks);
    sizeblockY=round(imgdim(2)/P.nrblocks);
    
    %make sure that the blocks actually fit (may have to adjust the image size
    %a little bit)
    img=imresize(img,[sizeblockX*P.nrblocks sizeblockY*P.nrblocks]);
    
    %get start and stop pixels for every block
    blockstartX=[1:sizeblockX:imgdim(1)];
    blockstopX=blockstartX+sizeblockX-1;
    blockstopX(blockstopX>imgdim(1))=imgdim(1);
    
    blockstartY=[1:sizeblockY:imgdim(2)];
    blockstopY=blockstartY+sizeblockY-1;
    blockstopY(blockstopY>imgdim(2))=imgdim(2);
    
    %get IDs for every block
    [blockIdX,blockIdY]=meshgrid(1:P.nrblocks);
    
    %randomize block order
    randvec=randperm(s,P.nrblocks.^2);
    blockIdXrand=blockIdX(randvec);
    blockIdYrand=blockIdY(randvec);
    
    %make scrambled images
    for i=1:P.nrblocks^2
        xin(1)=blockstartX(blockIdXrand(i));
        xin(2)=blockstopX(blockIdXrand(i));
        xout(1)=blockstartX(blockIdX(i));
        xout(2)=blockstopX(blockIdX(i));
        
        yin(1)=blockstartY(blockIdYrand(i));
        yin(2)=blockstopY(blockIdYrand(i));
        yout(1)=blockstartY(blockIdY(i));
        yout(2)=blockstopY(blockIdY(i));
        
        for c=1:size(img,3)
            imgout(xout(1):xout(2),yout(1):yout(2),c)=img(xin(1):xin(2),yin(1):yin(2),c);
        end
    end
end

%c=P.contrast/100;
%imgout=imgout.*c+P.background*(1-c);


% save('/Users/NielsenLab/Desktop/temp.mat','imgout');

IDim=size(imgout);

%generate texture

if length(IDim) <= 3
    Gtxtr = Screen(screenPTR, 'MakeTexture', imgout);
else
    for ii=1:IDim(4)
        Gtxtr(ii) = Screen(screenPTR, 'MakeTexture', squeeze(imgout(:,:,1,ii)));
    end
end


