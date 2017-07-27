% chirp.m
% Original by K. Spratt
% 
% This file generates a logarithmic swept sine chirp of length N samples 
% and outputs to a .txt file
%
% Modified 7-27-2017 by Eli Willard

clc
clear
close all

fs = 44100;          % sample rate, [ samples / second ]
N = 18;              % chirp length = 2^N samples

f1 = 20;             % beginning frequency [ Hz ]
f2 = fs/2;           % final frequency [ Hz ]
t = (0:(2^N)-1)/fs;  % time [ seconds ]
t0 = t(end);         % final time [ seconds ]

% Creates the swept sine tone.
w1 = 2*pi*f1;
w2 = 2*pi*f2;
bait = t0/log(w2/w1);
alf = w1*bait;
sweep = sin(alf*(exp(t/bait)-1));

% The test signal is two chirps, one right after the other.
testsignal = 0.8*[sweep sweep];
t_testsignal = (0:length(testsignal)-1)/fs;

figure(1); 
specgram(testsignal(2^N:2^(N+1)-1),256,fs);
xlabel('Time [sec]');
title('Test Signal');

fileID = fopen('chirp.txt','w');
fprintf(fileID, '%f\n', sweep);
fclose(fileID);

