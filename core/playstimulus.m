function playstimulus(modID)

global blankFlag stereoFlag

HideCursor

%modID: 2 letter string

%figure out which module we want
if stereoFlag==0
    mList=moduleListSlave;
else
    mList=moduleListStereo;
end

idx=0;
for i=1:length(mList)
    if strcmp(modID,mList{i}{1})
    	idx = i;
        break;
    end
end

if blankFlag==0
    %run playTexture file
    eval(mList{idx}{4});
else
    %play generic blank trial
    eval(mList{end}{4});
end
    
ShowCursor;
    