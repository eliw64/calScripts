% CalRVS.m
% Function for calculating RVS from a series of tone bursts running in
% 1 khz steps
%
% Last modified: Eli Willard
% 7-25-2017
%
% Inputs:
% fname - full path of scope output file
% stdname - full path of standard hydrophone calibration data
%
% Outputs:
% RVS - receive voltage sensitivity vector

function RVS = CalRVS(fpath, stdname)

% channel setup
ch.drive = 1; % scope input from function generator
ch.std = 2; % scope input from standard hydrophone
ch.phone = 3; % scope input from custom hydrophone
gain = 1;


% Load and clean up data
files = dir(fullfile(fpath, '*.ASC')); % change '*.ASC' to cal file
data = calFileLoad(fullfile(fpath, {files(:).name}), ch);

% construct time and freq vector
Fs = 5e6; % sample rate from scope
dt = 1/Fs;
N = length(data(1).drive);
t = 0 : dt : (N-1) * dt; % time vector
freq = 5 : 25; % tone burst frequency vector [kHz]

% load RVS data from standard
M = load(stdname);
standard.freq = M(:,1)';
standard.RVS = M(:,2)';

% window setup - need to window steady state portion of signal
win.type = 'tukeywin';
win.start = 7237; % start window at this sample
win.stop = 1.08e4; % stop window at this sample
win.N = win.stop - win.start + 1; % number of points in window
trunc = win.start : win.stop;
mywin = window(win.type, win.N)';

for jj = 1 : length(data)
    
    % align signals
    Y = signalAlign([data(jj).std; data(jj).phone]);
    
    % enable to plot aligned signals
%     figure; plot(Y(1,:)); hold on; plot(Y(2,:))
    
    % apply window to standard and custom hydrophone signals
    for kk = 1 : 2
        X(kk,:) = Y(kk,trunc) .* mywin;
    end
    
    % enable to plot windowed and aligned signals
    % figure; plot(X(1,:)); hold on; plot(X(2,:))
    
    
    % calculate rms voltage of custom hydrophone and standard
    vRms.phone(jj) = rms(X(2,:));
    vRms.standard(jj) = rms(X(1,:));
    
    stdcal(jj) = interp1(standard.freq,standard.RVS, freq(jj) * 1e3,'pchip',NaN);
    
    RVS(jj) = 20 * log10((gain * vRms.phone(jj)) / vRms.standard(jj)) + stdcal(jj);
end

% generate plots

figure;
plot(freq, RVS); %hold on; plot(freq, stdcal)
% figure;
% plot(freq, gain.*vRms.phone); hold on; plot(freq, vRms.standard)
% figure; plot(freq,(gain .* vRms.phone) ./ vRms.standard)


end