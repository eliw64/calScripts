
clear
close all

% script to calibrate source SN7
% 5/5/201\7

fname = 'pmms_locsourceSN7_calibration.h5';
info = readDAQdata(fname);
NC = length(info.channel_names);
t = info.t;
twindow = .001;

cfun = @(t,d) 1402.7 + 488*(t/100) - 482*(t/100).^2 + 135*(t/100).^3 + (15.9 + 2.8*(t/100) + 2.4*(t/100)^2).*(1e-5*1000*9.81*d/100);
c = cfun(info.temp_deg_c,info.depth_m);

R = 1; % separation distance

% take captures, signal align over captures, and detrend
V = zeros(size(info.captures_V));
for i = 1:NC
    v = signalAlign(squeeze(info.captures_V(:,i,:)));
    v = detrend(v','constant')';
    V(:,i,:) = v;
end

% average over captures (except 4 and 5)
V1 = 10.13*squeeze(mean(V([1:3 6:20],1,:),1)); % gain to reverse attenuation from the attenuator box
V2 = squeeze(mean(V([1:3 6:20],2,:),1));


[tinv, invSweep] = makeInvSweep(V1);
V3 = circshift(invSweep,30000); % change...

%% WINDOW AND PROCESS

S1 = conv(V1,V3);
S2 = conv(V2,V3);
[~, ind] = max(abs(S1)); % index of max
[~, ind1] = min(abs(tinv - (tinv(ind)-twindow/2)));
[~, ind2] = min(abs(tinv - (tinv(ind)+twindow/2)));
tnew = tinv(ind1:ind2)-tinv(ind1);
n = length(tnew);

% window and take fft
[freq, Y1] = myfft(tnew,S1(ind1:ind2).*window(@tukeywin,n,.25));
[~, Y2] = myfft(tnew,S2(ind1:ind2).*window(@tukeywin,n,.25));

%% PLOT

d = importdata('\\q20-pma-3\D\MLP\Project Information\Experiment\USRD Hydrophones Standards\H52_074.txt');
standard.freq = d.data(:,1);
standard.RVS = d.data(:,2); % RVS

% calibration
TVR = 20*log10(abs(Y2 ./ Y1)) - interp1(standard.freq,standard.RVS,freq,'pchip',NaN) + 20*log10(R);

figure
semilogx(freq/1000,TVR)
xlabel('Frequency [kHz]')
ylabel('TVR [dB]')
grid on
axis tight
title('TVR response for source SN7')
xlim([1 100])
