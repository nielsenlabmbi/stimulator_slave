function configureDisplay

clear all, close all

Priority(5);  %Make sure priority is set to "real-time"  

% priorityLevel=MaxPriority(w);
% Priority(priorityLevel);

mList=moduleListSlave;
configurePstate(mList{1}{1}) %Use grater as the default when opening
configureMstate

configCom;

configSync;

configShutter;

screenconfig;

