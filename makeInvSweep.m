function [t invSweep] = makeInvSweep(V)

fs = 250e3;
Fs = 250e3;
sweep = V;
f2 = 100e3;
fs_nyq = 2*f2; % Nyquist frequency (twice highest frequency in chirp)
sweep_nyq = resample(sweep,fs_nyq,fs); % downsample chirp signal to Nyquist
sweep_inv_nyq = ifft(1./fft(sweep_nyq)); % create inverse chirp by inverting the spectrum
sweep_inv_nyq = sweep_inv_nyq(1:round(0.9*length(sweep_inv_nyq))); % chop off the weird numerical stuff at the end (bit of a fudge)
fs_data = Fs; % sample rate of measured data (i.e. on the scope)
sweep_data = resample(sweep,fs_data,fs); % upsample chirp & inverse chirp at data samplerate
sweep_inv = resample(sweep_inv_nyq,fs_data,fs_nyq);
invSweep = sweep_inv; % rename

% make t
dt = 1/Fs;

% to find the time t, force the input
m1 = length(V);
m2 = length(invSweep);
t = 0:dt:((m1+m2-1-1)*dt); % length of conv is m1+m2-1
t = t-dt*m1;
end