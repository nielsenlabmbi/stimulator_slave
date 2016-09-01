function mask=makeMask(screenRes,x_pos,y_pos,xsizeN,ysizeN,maskradiusN,mask_type,varargin)

%compute stimulus mask - one large aperture only
%these masks are screen size to allow correct cropping of rotated stimuli
%1 outside of stimulus, 0 where stimulus should appear
%we're generating a mask with screen size rather than stimulus size because
%it makes the generation independent of size (and faster)

%parameters:
%screenRes: screen height and width
%x_pos, y_pos: position in pixel
%xsizeN, ysizeN: size in pixel
%maskradiusN: radius in pixel
%mask_type: gauss, disc or non
%varargin: mask_color (0.5 default)

if isempty(varargin)
    background=0.5;
else
    background=varargin{1};
end


xdom=[1:screenRes.width]-x_pos;
ydom=[1:screenRes.height]-y_pos;
[xdom,ydom] = meshgrid(xdom,ydom); %this results in a matrix of dimension height x width
r = sqrt(xdom.^2 + ydom.^2);


if strcmp(mask_type,'gauss')
    maskT = 1-exp((-r.^2)/(2*maskradiusN^2));
elseif strcmp(mask_type,'disc') %disc is the default
    maskT =1-(r<=maskradiusN);
else
    xran(1) = max(x_pos-floor(xsizeN/2)+1,1);  
    xran(2) = min(x_pos+ceil(xsizeN/2),screenRes.width);
    yran(1) = max(y_pos-floor(ysizeN/2)+1,1);  
    yran(2) = min(y_pos+ceil(ysizeN/2),screenRes.height);
    maskT=ones(size(r));
    maskT(yran(1):yran(2),xran(1):xran(2))=0;
end

mask = background*ones(screenRes.height,screenRes.width,2);
mask(:,:,2) = maskT;
