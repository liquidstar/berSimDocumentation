clc;clear;
%% Interface instance
CLI = Interface();
% Interface() properties
bitCount = CLI.bitCount;
rfFlag = CLI.rfFlag;
Ts = CLI.Ts;
fc = CLI.fc;
KdB = CLI.KdB;
%channelType = CLI.channelType;
channelType = ["gauss", "rayl", "rice"];
variant = CLI.variant;
sigAmp = 0:1:30;

%% Simulation of Communication
dataSource = ofdm.DataSource(...);
transmitter = ofdm.Transmitter(...);
% Evaluator: Gets PAPR from transmitter
commCount = length(sigAmp);
% Channel and reception for different SNRs
for j = 1:length(channelType)
    eval = ofdm.Evaluator(transmitter);
    for i = 1:commCount
        comm = ofdm.Transmission(...);
        CLI.showStatus(...);
        eval = eval.getBer(...);
        clear comm;
    end
% BER plot and show PAPR
    CLI.showReport(eval, sigAmp);
end
