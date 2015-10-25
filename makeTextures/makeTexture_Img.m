function makeTexture_Img

%loads images, and scrambles if selected

global screenPTR Gtxtr loopTrial Mstate 

if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];


%get parameters
P = getParamStruct;


%read image
img=imread(['/' P.imgpath '/' P.imgbase num2str(P.imgnr) '.tif']);
img=double(img);

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

c=P.contrast/100;
imgout=imgout.*c+P.background*(1-c);

%IDim=size(imgout);

%generate texture
Gtxtr = Screen(screenPTR, 'MakeTexture', imgout);


