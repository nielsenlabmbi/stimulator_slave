function makeTexture_GA

%make closed contour stimuli for the V4 GA; generate mask in addition if
%selected
%we use an offscreen window to generate these textures so that we can
%activate anti-aliasing

global   screenPTROff screenNum Mstate




%get screen size
screenRes = Screen('Resolution',screenNum);

%get parameters set in GUI
P = getParamStruct;



folderName = [Mstate.anim '_r-' num2str(P.runNum)];


c=P.contrast/100;
fore_col = [P.fore_r P.fore_g P.fore_b];
if c==0
    fore_col=P.background;
end

if P.genNum > 0
    fullFolderName = [folderName '_g-' num2str(P.genNum)];
    load([P.stimPathSlave '/' fullFolderName '_stim.mat']);
    
    stim = stimuli{P.linNum,P.stimNum};
    cPts = [stim.cPts(:,1) -stim.cPts(:,2)];   
    cPts = movePts(cPts,stim.xPos,stim.yPos,deg2pix(stim.siz,'none'),stim.ori); 
    
    concatenatedSplines = drawSpline(cPts,200);
else
    fullFolderName = [folderName '_p'];
    load([P.stimpath '/' fullFolderName '_maskStim.mat']);
    
    if P.stimNum>length(stimuli{P.linNum})
        disp('Stimulus number exceeds the number of stimuli in that lineage.')
    end
    
    stim = stimuli{P.linNum}{P.stimNum};
    
    cPts = [stim.cPts(:,1) -stim.cPts(:,2)];
    cPts = movePts(cPts,stim.xPos,stim.yPos,deg2pix(stim.siz,'none'),stim.ori); 
    concatenatedSplines = drawSpline(cPts,200);
    
    maskwidth=screenRes.width;
    maskheight=screenRes.height;
    
    [wmat,hmat]=meshgrid(1:maskwidth,1:maskheight);
    
    mask=ones(maskheight,maskwidth,4);
    
    for i=1:3
        mask(:,:,i)=round(mask(:,:,i)*P.maskcolor);
    end
    
    masktmp=zeros(maskheight,maskwidth);
    
    for maskNum=1:3
        temp = zeros(maskheight,maskwidth);
        center = round(movePts([stim.mask{maskNum}.x -stim.mask{maskNum}.y],stim.xPos,stim.yPos,deg2pix(stim.siz,'none'),stim.ori));
        siz = stim.mask{maskNum}.s*deg2pix(stim.siz,'none');
        [~,rad]=cart2pol(wmat-center(1),hmat-center(2));
        
        innerRad = 0.8;
        slopeInd = 1:-0.005:innerRad;
        alphaVals = linspace(0,1,length(slopeInd));
        for i=1:length(slopeInd)
            temp(rad<slopeInd(i)*siz) = alphaVals(i);
        end
        
        masktmp = temp + masktmp;
    end
    masktmp(masktmp>1) = 1;
 %   save('/Users/nielsenlab/Desktop/temp.mat','masktmp');

    maskWindowCenter = round(min(concatenatedSplines) + (max(concatenatedSplines) - min(concatenatedSplines)) / 2);
    maskWindowSize = round(max(max(concatenatedSplines) - min(concatenatedSplines)));
    
    maskWindowXLims = [1:(maskWindowCenter(1) - maskWindowSize), (maskWindowCenter(1) + maskWindowSize):maskwidth];
    maskWindowYLims = [1:(maskWindowCenter(2) - maskWindowSize), (maskWindowCenter(2) + maskWindowSize):maskheight];
    
    maskWindowXLims(maskWindowXLims > maskwidth) = maskwidth;
    maskWindowYLims(maskWindowYLims > maskheight) = maskheight;
    maskWindowXLims(maskWindowXLims < 1) = 1;
    maskWindowYLims(maskWindowYLims < 1) = 1;
    
    masktmp(maskWindowYLims,:) = 1;
    masktmp(:,maskWindowXLims) = 1;

    %save('/Users/nielsenlab/Desktop/temp.mat','masktmp','maskWindowXLims','maskWindowYLims');
    
    
    masktmp=1-masktmp; %everything that is 1 in the mask will be set to the mask color
%    save('/Users/nielsenlab/Desktop/temp2.mat','masktmp');
    
    mask(:,:,4)=masktmp;
end


Screen(screenPTROff, 'FillRect', P.background);
Screen('FillPoly',screenPTROff,fore_col, concatenatedSplines);
if P.genNum < 0
    Screen('PutImage',screenPTROff,mask);
end