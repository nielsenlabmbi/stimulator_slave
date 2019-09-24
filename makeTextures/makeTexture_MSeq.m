function makeTexture_MSeq

%generates noise pattern based on M sequence
%using pre-generated M sequence for a 16x 16 grid from Farran (originally
%from the Usrey lab)

global  Gseq Mstate loopTrial 

global Gtxtr

if ~isempty(Gtxtr)
    Screen('Close',Gtxtr);  %First clean up: Get rid of all textures/offscreen windows
end

Gtxtr = [];
Gseq = [];


%get parameters
P = getParamStruct;

%read M sequence - generates MSequence
load([P.seqfile '.mat']);

%reshape M sequence into 16x16xframes
Sequence=Sequence';
Gseq.Mseq=reshape(Sequence,[16 16 size(Sequence,2)]);

%incorporate starting offset (0: no shift)
Gseq.Mseq=circshift(Gseq,P.startOffset,3);

%we are not generating textures here because there are way too many - this
%will happen in drawtexture

%save sequence data
if Mstate.running
    saveLog(Gseq,P.rseed,loopTrial)  %append log file with the latest sequence
end


