% Impulse response plotter for Uchi data
% Modified 4/19/2017
% Inputs: .mat data saved from Uchi recordings
% Outputs: ir - calculated impulse response
%          Fs - sampling frequency

function [impulse, Fs] = IR_plot(FileName)
file_loc = 'C:\Users\eliw\Documents\Class\Architectural\Uchi';
load(fullfile(file_loc, FileName));


%% PLOT THE WAVEFORMS!
figure(1); 
subplot(2,1,1);
specgram(testsignal(2^N:2^(N+1)-1),256,fs);
xlabel('Time [sec]');
title('Test Signal');
subplot(2,1,2);
specgram(signal(2^N:2^(N+1)-1),256,fs);
xlabel('Time [sec]');
title('Recorded Signal');

% PLOT IMPULSE RESPONSE!

% Normalize impulse
ir = ir ./ max(max(abs(ir)));
figure(2);
% subplot(2,1,1);
% plot(t_ir,ir); grid on;
xlabel('Time [sec]');
% subplot(2,1,2);
specgram(ir,256,fs);
axis([0 .7 -inf inf])
caxis([-60 -15]);
title('Impulse Response');

impulse = ir;
Fs  = fs;
end