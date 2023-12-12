function makeTexture(modID)

%modID: 2 letter string

global blankFlag stereoFlag

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

%no stimulus generation in blanks
if blankFlag==0 
    %run makeTexture file
    eval(mList{idx}{3});
end