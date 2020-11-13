classdef Transmission
    properties
        rece
    end
    methods
        function comm = Transmission(...)
            if nargin == 0
                return
            end
            t = transmitter.nTs;
            Ts = single(transmitter.symbolTime);
            fc = single(transmitter.centerFreq);
            Dt = transmitter.samplingInterval;
            rfFlag = transmitter.rfFlag;
            ofdmVariant = transmitter.variant;
            link = ofdm.Channel(...);
            noisySignal = link.noisySignal;
            h = link.channelCharacterization;
            clear link;
            comm.rece = ofdm.Receiver(...);
        end
    end
end
