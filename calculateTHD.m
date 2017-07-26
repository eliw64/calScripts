
% script to calculate THD from the 9/6/16 fir tank tests
% 9/7/2016

clear
close all


filedir = '\\q20-pma-3\D\MLP\Project Information\Experiment\HTI 94 SSQ measuring system\THD';
filename = {'data_1Vpp.mat','data_2_5Vpp.mat','data_5Vpp.mat','data_10Vpp.mat','data_20Vpp.mat'};

NF = 21; % number of frequency points
NV = 5; % number of voltages
NC = 2; % number of channels
NS = 8; % number of samples to average over
NP = 2; % number of cases
NFFT = 1e5; % FFT points
NH = 2; % number of harmonics to analyze
NH = NH+1; % add in fundamental
r = 1; % range, m
fres = 16500; % ITC 1001 resonance, Hz

% drive voltages, pp
Vdrive = [1 2.5 5 10 20];

% channel setup
% 'ch1 = input voltage'    'ch2 = hydrophone'    'ch3 = current'    'ch4 = drive voltage'
chInput = 1;
chPhone = 2;
chCurr = 3;
chDrive = 4;

% window settings
s1 = 9400; % start index of pulse
s2 = 29000; % end index of pulse
M = s2-s1+1; % number of samples
w = window(@tukeywin,M,.1);
nc = floor(NFFT/2); % center index for FFTs
band = 1000; % bandwidth, Hz

% load TVR and RVS
d = load('\\q20-pma-3\D\MLP\Project Information\Experiment\Sources\ITC_1001_calibration.mat');
TVRres = interp1(d.freq,d.TVR,fres);
d = load('\\q20-pma-3\D\MLP\Project Information\Experiment\HTI 94 SSQ measuring system\HTI94SSQ_calibration.mat');
RVSres = interp1(d.freq,d.RVS,fres);



%% PROCESS DATA

THDFx = zeros(NF,NV);
THDFy = zeros(NF,NV);

% loop over voltages
for i = 1:NV
    
    S = load(fullfile(filedir,filename{i}));
    
    % common variables
    Fs = S.Fs;
    dt = 1/Fs;
    t = S.t;
    freq = S.freqs;
    
    % process each ping in frequency
    for j = 1:NF
        xx = S.data(chPhone,j).ch; % all NS channels
        yy = S.data(chCurr,j).ch; % all NS channels
        f0 = freq(j)
        
        % signal align both of them to remove movement
        xx = signalAlign(xx')';
        yy = signalAlign(yy')';
        
        % average
        x = mean(xx,2);
        y = mean(yy,2);
        
        % window
        tw = 0:dt:((M-1)*dt); % windowed time signal
        xw = x(s1:s2).*w;
        yw = y(s1:s2).*w;
        
        % take FFTs
        Xw = fft(xw,NFFT)/M;
        Yw = fft(yw,NFFT)/M;
        Xw = 2*abs(Xw(1:nc)); % single sided spectrum
        Yw = 2*abs(Yw(1:nc));
        f = Fs/2*linspace(0,1,NFFT/2)';
        
        % store spectra for later use
        Xstore(:,j,i) = Xw;
        Ystore(:,j,i) = Yw;
        
        % for each harmonic, look for the range and average
        for s = 1:NH
            fnow = s*f0;
            [~, ind1] = min(abs(f - (fnow-band/2)));
            [~, ind2] = min(abs(f - (fnow+band/2)));
            xval(s) = max(Xw(ind1:ind2)); % max should be at fnow but will be slightly differenct
            yval(s) = max(Yw(ind1:ind2));
        end
        
        % caculate THD
        THDFx(j,i) = sqrt(sum(xval(2:end).^2)) / xval(1);
        THDFy(j,i) = sqrt(sum(yval(2:end).^2)) / yval(1);
    end  
end

% calculate other THD
THDRx = THDFx./sqrt(1 + THDFx.^2);
THDRy = THDFy./sqrt(1 + THDFx.^2);

% form legends as desired
VrecPhone_pp = Vdrive/r*10^((TVRres + RVSres)/20);
PrecPhone_rms = sqrt(2)/2 * Vdrive/r*10^(TVRres/20) * 1e-6; % convert Vpp to prms in uPa then to Pa


%% PLOTS

% make legend
strVdrive = @(x) sprintf('V_{drive, pp} = %s V',num2str(x)); % make legend
strVphone = @(x) sprintf('V_{rec, pp} = %2.2f V',x);
strPphone = @(x) sprintf('p_{rec, rms} = %2.2f Pa',x);

% leg = arrayfun(strVphone,Vdrive,'uniformoutput',false);
% leg = arrayfun(strVphone,VrecPhone_pp,'uniformoutput',false);
leg = arrayfun(strPphone,PrecPhone_rms,'uniformoutput',false);

figure
plot(freq/1000,100*THDFx)
legend(leg,'location','northeast')
xlabel('Frequency [kHz]')
ylabel('Level (%)')
title('THD of HTI94-SSQ Output Voltage')

figure
plot(freq/1000,100*THDFy)
legend(leg,'location','northeast')
xlabel('Frequency [kHz]')
ylabel('Level (%)')
title('THD of ITC 1001 Input Current')

figPres