classdef Channel
    properties
        noisySignal
        channelCharacterization
    end
    methods
        function link = Channel(...)
            rfFlag = transmitter.rfFlag;
            if (rfFlag)
                transmitSig = transmitter.passBandAnalog;
            else
                transmitSig = transmitter.baseBandOfdmSig;
            end
            t = transmitter.nTs;
            Ts = transmitter.symbolTime;
            No = 10^-(sigAmp/10);
            if type == "gauss"
                [link.noisySignal,...] = addGaussianNoise(...);
            elseif type == "rayl"
                [link.noisySigna;,...] = rayleighFading(...);
            elseif type == "rice"
                [link.noisySignal,...] = ricianFading(...);
            end
        end
    end
end

%% Function to make AWGN Channel
function [noisySignal,...] = addGaussianNoise(...)
    n = length(transmitSig);
    channelChar = 1;
    noisySignal = transmitSig+sqrt(No^2/2)*(randn(1,n)+...;
end

%% Function to implement Rayleigh Fading
function [fadedSignal,...] = rayleighFading(...)
    n = length(transmitSig);
    if rfFlag
        symbCount = ceil(max(t)/Ts);
        fading = randn(1,symbCount) + 1i*randn(1,symbCount);
        channelChar = (1/sqrt(2))*repelem(fading, floor(n/symbCount));
        m = length(channelChar);
        if n ~= m
            channelChar = [channelChar repelem(channelChar(m), n - m)];
        end
    else
        channelChar = (1/sqrt(2))*(randn(1,n) + 1i*randn(1,n));
    end
    fadedSignal=transmitSig.*channelChar + ...;
end

%% Function to implement Rician Fading
function [fadedSignal,...] = ricianFading(...)
    n = length(transmitSig);
    K = 10^(speculardB/10);
    if rfFlag
        symbCount = ceil(max(t)/Ts);
        fading = randn(1,symbCount) + ...;
        channelChar = sqrt(K/(K+1)) + sqrt(1/(K+1))*(1/sqrt(2))* ...;
        m = length(channelChar);
        if n ~= m
            channelChar = [channelChar, ...)];
        end
    else
        channelChar = sqrt(K/(K+1)) + sqrt(1/(K+1))*...;
    end
    fadedSignal = transmitSig.*channelChar + sqrt(No^2/2)*...;
end
