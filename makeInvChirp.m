
% the chirp used in this source is NOT the 100-100kHz log FM, so make a new
% chirp

clear
close all

fdir = '\\q20-pma-3\D\MLP\Project Information\Experiment\Sources\Custom Source\Fir Tank Testing - 160616\';
fname = @(x) sprintf('X160616%u.ASC',x);

d = importdata(fullfile(fdir,fname(1)));
M = 50e3;
Fs = 250e3;
dt = 1/Fs;
t = (0:dt:((M-1)*dt))'; % time signal

x = d(1:end-1,1);

% plot signal
figure
plot(t*1000,x)


% spectrum
[f, X] = myfft(t,x);
figure
plot(f/1000,2*abs(X))
xlim([0 125])
xlabel('Frequency [kHz]')
ylabel('Spectrum [V]')
title('Single sided spectrum of x')

% compute spectrogram - to ensure chirp style
% w = 500;
% no = w/5;
% [S, ff, tt] = spectrogram(x,w,no,f,Fs);
% [FF, TT] = ndgrid(ff,tt);
% figure
% surf(FF,TT,abs(S))
% shading flat

%% ATTEMPT TO RECREATE OG SIGNAL

t0 = 100e-3; % duration
f1 = 500;
f2 = 125e3;
w1 = 2*pi*f1;
w2 = 2*pi*f2;
bait = t0/log(w2/w1);
alf = w1*bait;
sweep = .15*sin(alf*(exp(t/bait)-1));

twait = 11.86e-3;
Nwait = round(twait/dt); % shift
[~, ind] = min(abs(t - t0));

% truncate and shift
sweep1 = sweep; % copy for inverse chirp
t1 = t;
t1(ind+1:end) = [];
sweep(ind+1:end) = 0; % truncate to 0
sweep1(ind+1:end) = [];
sweep = circshift(sweep,Nwait);

figure
plot(t,x,t,sweep)
xlabel('t [ms]')
ylabel('signal [V]')
title('Original chirp and recreated chirp')

%% MAKE INVERSE CHIRP

% since signal already at f2 = nyquist, 
sweep_inv1 = ifft(1./fft(sweep1));

% discard numerical BS
s = round(.9*length(sweep_inv1));
sweep_inv1(s:end) = [];
t1(s:end) = [];

figure
plot(t1*1000,sweep_inv1)
xlabel('t [ms]')
ylabel('signal [V]')
title('Inverse chirp')

% plot result
ir = conv(sweep_inv1,sweep);
tir = 0:dt:((length(ir)-1)*dt);

figure
plot(tir*1000,ir)
xlabel('t [ms]')
ylabel('signal [V]')
title('Convolution of chirp and inverse chirp')

