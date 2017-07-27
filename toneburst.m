function [tb] = toneburst(f,Fs,nCyc,gap,tw)
% toneburst.m creates a tone burst in the sample domain given a frequency
% vector, sampling rate, cycle count, inter-burst gap length, and tukey
% window ratio (optional).
%
%   [tb] = toneburst(f,Fs,nCyc,gap) computes a tone burst for frequency
%   vector f, sampled at Fs, with nCyc cycles per burst, with a inter-burst
%   spacing of gap samples,and a tukey window ratio of 0.1.
%
%   [tb] = toneburst(f,Fs,nCyc,gap,tw) computes a tone burst for frequency
%   vector f, sampled at Fs, with nCyc cycles per burst, with a inter-burst
%   spacing of gap samples,and a custom tukey window ratio.
%

% Define Window Length
dt = 1/Fs; % s
for ii = 1:length(f)
    n(ii) = (nCyc/f(ii)/dt);
    L = ceil(sum(n))+gap*(ii-1);
end

% Build Time Vector
t = 0:dt:dt*(L-1); % s
tb = zeros(1,L);

% Default Tukey Window Slope
if nargin == 4
    tw = 0.1;
end

% Build Tone Burst
for ii = 1:length(f)
    T(ii) = 1/f(ii);
    Tsig(ii) = T(ii)*nCyc;
    nsig(ii) = floor(Tsig(ii)/dt);
    if ii == 1
        tb(1:nsig(ii)) = sin(2*pi*f(ii)*t(1:nsig(ii))).*...
            tukeywin(nsig(ii),tw).';
    else
        tb((1:nsig(ii))+sum(nsig(1:ii-1))+gap*(ii-1)) = ...
            sin(2*pi*f(ii)*t(1:nsig(ii))).*tukeywin(nsig(ii),tw).';
    end
end
tb = [tb zeros(1,gap)];
end