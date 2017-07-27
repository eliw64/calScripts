% Impulse response measurement using the OMNIMIC & a chirp.
clear all;

% CHOOSE OPERATING SYSTEM!
OS = 'MAC';
%OS = 'WINDOWS';

%% MAKE A TEST SIGNAL!
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

%% CONNECT TO THE OMNIMIC!
info = audiodevinfo;
numDevices = audiodevinfo(1);
ID = 0;
for n = 1:numDevices
    if strcmp(OS,'MAC')
        if strncmp(info.input(n).Name,'OmniMic',7) % MAC
            ID = n;
        end
    elseif strcmp(OS,'WINDOWS')
        if strncmp(info.input(n).Name,'Microphone (2- OmniMic',22) % WINDOWS
            ID = n; % Might have to change to "n-1" in Windows!
        end
    end
end
if ID == 0
    error('OMNI mic could not be found!')
end

%% RECORD WHILE PLAYING TEST SIGNAL!
recorder = audiorecorder(fs, 16, 1, ID);
player = audioplayer(testsignal, fs);

disp('Recording Started.')
record(recorder); % Start recording
play(player);     % Start test signal playback (default output device)
while(isplaying(player))
    % Wait around until test signal has finished playing.
    pause(eps); 
end
stop(recorder);   % Stop recording
disp('Recording Ended.');

% Get recorded data.
signal = getaudiodata(recorder).';
t_signal = (0:length(signal)-1)/fs;

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

% MAKE IMPULSE RESPONSE!
ir = real(ifft(fft(signal(2^N:2^(N+1)-1))./fft(sweep(1:2^N))));
t_ir = (0:length(ir)-1)/fs;
figure(2);
subplot(2,1,1);
plot(t_ir,ir); grid on;
xlabel('Time [sec]');
subplot(2,1,2);
specgram(ir,256,fs);
caxis([-60 -15]);
title('Impulse Response');

%save(datestr(now));