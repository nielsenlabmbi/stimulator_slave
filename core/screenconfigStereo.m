function screenconfigStereo

global screenPTR screenPTROff screenNum Mstate Gtxtr Masktxtr setupDefault

%screens=Screen('Screens');
%screenNum=max(screens);

%set GPU correctly if needed in case of 2 GPUs
if setupDefault.useSecondGfx==1 
    PsychTweak('UseGPUIndex',1);
    screenNum=1;
else
    screenNum=0;
end

%set stereomode- 4 means left/right images 
stereoMode = 4;


PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','FloatingPoint32BitIfPossible');
PsychImaging('AddTask','General','NormalizedHighresColorRange',1);
PsychImaging('AddTask', 'General', 'UseFastOffscreenWindows');

AssertOpenGL;
InitializeMatlabOpenGL;



screenRes = Screen('Resolution',screenNum);

%initialize pointers to textures generated in makeTexture
Gtxtr=[]; 
Masktxtr=[];

%[screenPTR,~] = PsychImaging('OpenWindow', screenNum, 0.5, stereoMode);
[screenPTR,~] = PsychImaging('OpenWindow', screenNum, 0, [], 32, 2, stereoMode);
Screen(screenPTR,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


% screenPTROff=Screen('OpenOffscreenWindow',screenPTR,[],[],[],[],8);
% Screen(screenPTROff,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

updateMonitor

pixpercmX = screenRes.width/Mstate.screenXcm;
pixpercmY = screenRes.height/Mstate.screenYcm;

syncWX = round(pixpercmX*Mstate.syncSize); %syncSize is in cm to be independent of screen distance
syncWY = round(pixpercmY*Mstate.syncSize);

Mstate.refresh_rate = 1/Screen('GetFlipInterval', screenPTR);

%SyncLoc = [0 screenRes.height-syncWY syncWX-1 screenRes.height-1]';
SyncLoc = [0 0 syncWX-1 syncWY-1]';
SyncPiece = [0 0 syncWX-1 syncWY-1]';
 
%Set the screen
wsync = Screen(screenPTR, 'MakeTexture', zeros(syncWY,syncWX),[],[],2); % "low"

Screen('SelectStereoDrawBuffer', screenPTR, 0);
Screen('DrawTexture', screenPTR, wsync,SyncPiece,SyncLoc);
Screen('SelectStereoDrawBuffer', screenPTR, 1);
Screen('DrawTexture', screenPTR, wsync,SyncPiece,SyncLoc);

Screen(screenPTR, 'Flip');


