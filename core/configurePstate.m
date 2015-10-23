function configurePstate(modID)

%modID: 2 letter string

%figure out which module we want
mList=moduleListSlave;
idx=0;
for i=1:length(mList)
    if strcmp(modID,mList{i}{1})
    	idx = i;
        break;
    end
end

%run config file
eval(mList{idx}{2});


