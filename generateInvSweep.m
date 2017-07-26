function [invSweep, delay] = generateInvSweep(Fs)
% [invSweep, delay] = generateInvSweep(Fs)
%
% Generate an inverse sweep to be used with a signal of sampling frequency
% Fs.
%
% The time vector for the deconvolved signal will be:
% t = 1/Fs*(0:length(invSweep) + length(signal)-1) - delay
%
% INPUTS:
%       Fs: sampling frequency [Hz]
%
% OUTPUTS:
%       invSweep: time signal for inverse chirp convolution
%       delay: time delay associated with chirp

% load files
% load('\\q20-pma-3\D\MLP\Project Information\Experiment\Scattering Tests\Chirps\CHIRP100.mat');
load('CHIRP100_2p5e6_sample.mat');

% Nyquist frequency (twice highest frequency in chirp)
fs_nyq = 2*f2;

% downsample chirp signal to Nyquist
sweep_nyq = resample(sweep,fs_nyq,fs);

% create inverse chirp by inverting the spectrum
sweep_inv_nyq = ifft(1./fft(sweep_nyq));

% chop off the weird numerical stuff at the end (bit of a fudge)
sweep_inv_nyq = sweep_inv_nyq(1:round(0.9*length(sweep_inv_nyq)));

% sample rate of measured data (i.e. on the scope)
fs_data = Fs;

% upsample chirp & inverse chirp at data samplerate
sweep_data = resample(sweep,fs_data,fs);
sweep_inv = resample(sweep_inv_nyq,fs_data,fs_nyq);
NINV = length(sweep_inv);

% band-limited impulse
delta = conv(sweep_data,sweep_inv);

% processing delay is equal to length of chirp
chirp_delay = T;

t_sweep = (0:length(sweep_data)-1)/fs_data;
t_inv = (0:length(sweep_inv)-1)/fs_data;
t_delta = (0:length(delta)-1)/fs_data - chirp_delay;

% rename
invSweep = sweep_inv;
delay = chirp_delay;




end
