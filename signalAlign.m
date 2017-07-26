function signals_aligned = signalAlign(signals)
% signals_aligned = signalAlign(signals)
%
% Via cross correlation, time align all signals relative to the first
% signal.
%
% INPUTS:
%       signals: [num signals x N] array of signals, length N
%
% OUTPUTS:
%       signals_aligned: [num signals x N] array of aligned signals, length
%       N
%
% Original code written by Kyle Spratt
%
% Jason Kulpe
% 2/25/16


numsigs = size(signals,1);
N = size(signals,2);

signals_aligned = zeros(size(signals));
signals_aligned(1,:) = signals(1,:);
for k = 2:numsigs
    % Cross correlation
    [C,lags] = xcorr(signals(1,:),signals(k,:));
    n_lag = find(abs(C) == max(abs(C)));
    n_lag = n_lag(1);
    
    % Quadratic interpolation to find peak
    shift = lags(n_lag) + 0.5*(C(n_lag-1)-C(n_lag+1))/(C(n_lag-1)-2*C(n_lag)+C(n_lag+1));
    
    % Shift signal using linear phase factor in frequency domain
    if mod(N,2) == 0
        SHIFT = exp(-2*pi*1i*shift*([0:N/2-1 -N/2:-1])/N);
    else
        SHIFT = exp(-2*pi*1i*shift*([0:(N-1)/2 -(N-1)/2:-1])/N);
    end
    signals_aligned(k,:) = real(ifft(fft(signals(k,:)).*SHIFT));
end
% re-transpose not necessary
