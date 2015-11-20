function makeTexture(modID)

%modID: 2 letter string

global blankFlag

%figure out which module we want
mList=moduleListSlave;
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