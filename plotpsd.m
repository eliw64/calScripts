function [ff,psd] = plotpsd(signal,Fs,plotTitle)
% plotpsd.m plots the Power Spectral Density in dB re 1V/sqrt(Hz) via FFT
% method for any voltage time series data given an input signal and a
% sampling frequency. User has the option to input a custom plot title.
%
%   [ff,psd] = plotpsd(signal,Fs) computes and plots PSD for given input
%   signal sampled at Fs with default plot title.
%
%   [ff,psd] = plotpsd(signal,Fs,plotTitle) computes and plots PSD for
%   given input signal sampled at Fs with custom plot title.
%

% Default Plot Title
if nargin == 2
    plotTitle = 'Power Spectral Density';
end

% Establish Frequency Vector
N = length(signal);
ff = 0:Fs/N:Fs/2;

% Compute FFT
dft = fft(signal);
dft = dft(1:N/2+1);

% Compute PSD
psd = (1/(Fs*N))*abs(dft).^2;
psd(2:end-1) = 2*psd(2:end-1);

% Plot PSD
figure;
semilogx(ff,10*log10(psd))
title(plotTitle)
xlabel('Frequency (Hz)')
ylabel('dB re 1V/\surdHz')
xlim([-inf inf])
grid on;box on
end
