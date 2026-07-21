function configCom_tcpNew

%configures communication with the stimulus master - new tcp commands

global CtrlCom setupDefault


CtrlCom = tcpclient(setupDefault.masterIP, 30000);
configureTerminator(CtrlCom, 126); %126 = ~
configureCallback(CtrlCom, "terminator", @MastercbNew);

fprintf('Connected to Server!\n\n');
 





