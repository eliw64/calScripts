% CalTVR.m
% Function for calculating TVR from a series of tone bursts running in
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

function TVR = calTVR(fpath, stdname)

% channel setup
ch.drive = 1; % scope input from function generator
ch.std = 2; % scope input from standard hydrophone
ch.phone = 3; % scope input from cusotm phone

R = 1; % distance from source to receiver [m]

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
win.start = 2517; % start window at this sample
win.stop = 7000; % stop window at this sample
win.N = win.stop - win.start + 1; % number of points in window
trunc = win.start : win.stop;
mywin = window(win.type, win.N)';

for jj = 1 : length(data)
    
    % align signals
    Y = signalAlign([data(jj).drive; data(jj).std]);
    
    % enable to plot aligned signals
    % figure; plot(Y(1,:)); hold on; plot(Y(2,:))
    
    % apply window to standard and custom hydrophone signals
    for kk = 1 : 2
        X(kk,:) = Y(kk,trunc) .* mywin;
    end
    
    % enable to plot windowed and aligned signals
    % figure; plot(X(1,:)); hold on; plot(X(2,:))
    
    % calculate rms voltage of drive and standard
    vRms.drive = rms(X(1,:));
    vRms.standard = rms(X(2,:));
    
    stdcal(jj) = interp1(standard.freq,standard.RVS,freq(jj) * 1e3,'pchip',NaN);
    
    TVR(jj) = 20*log10(abs(vRms.standard / vRms.drive)) - stdcal(jj)  + 20*log10(R);
end

% generate plots

figure;
plot(freq, TVR); % hold on; plot(freq, stdcal)
% figure;
% plot(freq, gain.*vRms.phone); hold on; plot(freq, vRms.standard)
% figure; plot(freq,(gain .* vRms.phone) ./ vRms.standard)


end