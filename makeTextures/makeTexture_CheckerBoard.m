function makeTexture_CheckerBoard

%generate checkerboard texture

global  screenPTR screenNum 

global Gtxtr  Masktxtr   %'play' will use these

%clean up
if ~isempty(Gtxtr)
    disp(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

if ~isempty(Masktxtr)
    Screen('Close',Masktxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];  
Masktxtr=[];


%get parameters
P = getParamStruct;
screenRes = Screen('Resolution',screenNum);


%convert stimulus size to pixel
xN=deg2pix(P.x_size,'round');
yN=deg2pix(P.y_size,'round');

%convert block size to pixel);
bN = deg2pix(P.block_size,'round');

%create the masks 
mN=deg2pix(P.mask_radius,'round');
mask=makeMask(screenRes,P.x_pos,P.y_pos,xN,yN,mN,P.mask_type);

Masktxtr(1) = Screen('MakeTexture',screenPTR, mask,[],[],2);  %need to specify correct mode to allow for floating point numbers

%generate texture
rN = ceil(yN/bN);
pN = ceil(xN/bN);

black = zeros(bN);
white = ones(bN);
tile = [black white; white black];
board = repmat(tile,rN,pN);



Gtxtr(1) = Screen('MakeTexture',screenPTR, board,[],[],2);
board = mod(board+1,2);
Gtxtr(2) = Screen('MakeTexture',screenPTR, board, [],[],2);








