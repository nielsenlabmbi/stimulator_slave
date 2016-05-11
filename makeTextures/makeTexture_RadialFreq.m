function makeTexture_Radial Freq

%make radial frequency stimuli

global  screenPTR screenNum 

global Gtxtr  

%clean up
if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end


Gtxtr = [];  


%get parameters
P = getParamStruct;


%convert stimulus size to pixel
xN=deg2pix(P.x_stimsize,'round');
yN=deg2pix(P.y_stimsize,'round');

%generate texture
xcoord=linspace(-xN/2,xN/2,xN);
ycoord=linspace(-yN/2,yN/2,yN);
[xcoord,ycoord]=meshgrid(xcoord,ycoord); 
[thetacoord,rhocoord]=cart2pol(xcoord,ycoord);

%compute modulated base radius
rMod=P.r0*(1+P.rAmp*sin(P.rFreq*thetacoord+P.phase));
rTemp=((rhocoord-rMod)/P.rSig).^2;
stim=(1-4*rTemp+4/3*rTemp.^2).*exp(-rTemp);
stim=(stim-min(stim(:)))/(max(stim(:))-min(stim(:))); %scales to 0-1
%stim=2*stim-1;

Gtxtr = Screen('MakeTexture',screenPTR, stim,[],[],2);









