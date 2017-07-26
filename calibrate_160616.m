

% script to calibrate the custom alignment source from June 16, 2016

clear
close all


% setup
% ch1: input voltage
% ch2: H52 
% ch3: HTI94-SSQ, SN: 502028
% ch4: none

Vpp = 50; % ampltidue
Vfg_pp = .3; % input pp
Twindow = 2.5e-3;
rat = Vpp/Vfg_pp;
b = .25; % tukey param

chV = 1;
chH52 = 2;
chHTI = 3;
NC = 3; % number of channels

fdir = '\\q20-pma-3\D\MLP\Project Information\Experiment\Sources\Custom Source\Fir Tank Testing - 160616\';
fname = @(x) sprintf('X160616%u.ASC',x);

Fs = 250e3; % sampling freq
dt = 1/Fs;

c = 1500; % estimate
depth = 10*.3048; % water depth, m
Nsamp = 16; % number of files to average in time domain
M = 50000; % number of samples
t = 0:dt:(M-1)*dt; % measured t from the scope is different from the t on the chirp
% Rmeas = sqrt(5^2 + 1^2) * .3048; % H94SSQ
Rmeas = 3.84; % computed using delay time in ir


% load inverse sweep
delay = 1.1e-3;
S = load('inverse_chirp_for_500_125k.mat');
invSweep = S.invSweep;


tir = dt*(0:(length(invSweep) + M - 2)) - delay; % time vector

% load all files
d = cell(Nsamp,1);
for i = 1:Nsamp
    raw = importdata(fname(i));
    d{i} = rat*raw(1:end-1,1:3); % 4th channel empty; last entry is anomaly
end


%% PROCESS IR

% compute impulse response
ir = zeros(length(tir),NC);

% for each channel
for i = 1:NC
    
    % compute ir
    z = zeros(length(tir),Nsamp);
    for j = 1:Nsamp
        y = detrend(d{j}(:,i),'constant');
        z(:,j) = conv(y,invSweep); % compute impulse response
    end
    
    % align
    z = signalAlign(z')';
    
    % average in time
    ir(:,i) = mean(z,2);
end

figure
plot(tir*1000,ir)
hold on
xlabel('t [ms]')
ylabel('signal')
legend({'Input voltage','H52','HTI-94 SSQ'})
grid on
axis tight

%% PROCESS IN FREQ DOMAIN

% find tmax of each channel
for i = 1:NC
    [~, ind] = max(abs(ir(:,i)));
    tmax(i) = tir(ind);
    
    % find window
    [~, ind1] = min(abs(tir - (tmax(i)-1/2*Twindow)));
    [~, ind2] = min(abs(tir - (tmax(i)+1/2*Twindow)));
    win = window(@tukeywin,length(ind1:ind2),b);
    plot(tir(ind1:ind2)*1000,win*max(abs(ir(ind1:ind2,i))),'k--') % plot window
    
    % window and take FFT
    [f, V(:,i)] = fft(tir(ind1:ind2),ir(ind1:ind2,i) .* win);
end

    
%% CALCULATE TVR

% load standard (assuming H52-169)
p = importdata('\\q20-pma-3\D\MLP\Project Information\Experiment\Hydrophones\H52_169.txt');
standard.f = p.data(:,1);
standard.RVS = p.data(:,2);
RVS = interp1(standard.f,standard.RVS,f,'pchip',NaN); % interpolate to this freq range, nan outside

% TVR and plot
TVR = 20*log10(abs(V(:,2)./V(:,1))) + 20*log10(Rmeas) - RVS;

figure
semilogx(f/1000,TVR)
xlim([1 125])
xlabel('Frequency [kHz]')
ylabel('TVR [dB]')
title('TVR of custom source re 1 \muPa-m/1 V')
grid on
