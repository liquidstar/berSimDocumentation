classdef Transmitter
    % All transmitter operations
    properties
        rfFlag
        baseBandOfdmSig
        centerFreq
        passBandAnalog
        nTs
        symbolTime
        variant
        samplingInterval
    end
    methods
        function trans = Transmitter(...)
            trans.rfFlag = rf;
            trans.symbolTime = Ts;
            trans.centerFreq = fc;
            trans.variant = ofdmVariant;
            trans.samplingInterval = 0.49*(fc)^-1;
            % Convert bit stream into symbol stream
            serBauds = mapBits(...);
            % Serial -- parallel according to variant
            parBauds = makeParallel(...);
            binData = binBauds(...);
            trans.baseBandOfdmSig = ofdmMux(...);
            if (trans.rfFlag)
                [baseBandAnalogI, ...] = dac(...);
                % Upscale frequency to RF
                trans.passBandAnalog = freqUpScale(...);
            end
        end    
    end
end

%% S - P Conversion
function parBauds = makeParallel(serBauds,ofdmVariant)
    ofdmVariant = ofdmVariant.subCarriers;
    dataSubs = sum(ofdmVariant(:) == 'd');
    if (mod(length(serBauds),dataSubs) ~= 0)
        serBauds = [serBauds, ...];
    end
    parBauds = reshape(serBauds, dataSubs, []);
end

%% BPSK Modulation
 function bauds = mapBits(bitArray)
    % BPSK Modulation
    bauds = 2*bitArray - 1;
 end

%% Map symbols to IFFT bins
 function bins = binBauds(baudMatrix, ofdmVariant)
    ofdmVariant = ofdmVariant.subCarriers;
    [~, symbCount] = size(baudMatrix);
    % Total subcarriers x number of OFDM symbols
    bins = int8(zeros(length(ofdmVariant),symbCount));
    j = 1;
    for i=1:length(ofdmVariant)
        if ofdmVariant(i) == 'v'
            bins(i,:) = zeros(1,symbCount);
        elseif ofdmVariant(i) == 'd'
            bins(i,:) = baudMatrix(j,:);
            j = j + 1;
        elseif ofdmVariant(i) == 'p'
            bins(i,:) = ones(1,symbCount);
        end     
    end
 end

%% Operate on binned symbols, give baseband signal
 function serOfdmSig = ofdmMux(binData, ofdmVariant)
    cp = ofdmVariant.cycPrefix/100;
    gi = ofdmVariant.guardInt/100;
    binData = binData';
    [symbCount, ofdmSize] = size(binData);
    symbLength = ofdmSize+floor(cp*ofSiz)+floor(gi*ofSiz);
    cycData = (zeros(symbCount,symbLength));
    prefixStart = ofdmSize-floor(cp*ofdmSize)+1;
    guardSize = floor(gi*ofdmSize);
    for i = 1:symbCount
        % ifft per symbol
        ifftData = ifft(binData(i,:));
        % cyclic prefix and guard-interval
        cycData(i,:) = [ifftData, ... ];
    end
    serOfdmSig = reshape(cycData', 1, []);
 end

%% Digital to analog conversion
 function [baseBandAnalogI,...] = dac(...)
    % In-phase component
    baseBandSigI = real(baseBandSig);
    % Quadrature component
    baseBandSigQ = imag(baseBandSig);
    % baseband signal samples
    n = 0:length(baseBandSig)-1;
    % distribute samples over multiples
    nTs = ifftBinSize(2)*(n*Ts)/length(baseBandSig);
    nTsMax = max(nTs);
    % Interpolation intervals for DAC up to nTs
    t = 0:Dt:nTsMax;
    baseBandAnalogI = spline(nTs, baseBandSigI, t);
    baseBandAnalogQ = spline(nTs, baseBandSigQ, t);
 end

%% Frequency upscaling for pass band 
 function bandPassSig = freqUpScale(...)
    % Mixing to get cos(fc+fm) + cos(fc-fm)
    mixedSig = baseBAgI.*(cos(fc*t)) + baseBAgQ.*(sin(fc*t));
    % High pass filter to get RF signal
    fs = Dt^-1;
    % Applying amplification
    bandPassSig = 1000*highpass(mixedSig, fc, fs);
 end
