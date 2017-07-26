% scattering.m
% Function for calculating insertion loss due to hydrophone


function IL = scattering()

% settings
file{1} = 'pmms_witharray.h5';
file{2} = 'pmms_noarray.h5';
ch = [13 14]; % channels to index
NC = 2; % number of channels
NF = 2; % number of files

% window settings
twindow = 1e-3;


Vt = zeros(2,2,65000);
for i = 1:NF
    info = readDAQdata(file{i});
    for j = 1:NC
        s = info.captures_V(:,ch(j),:);
        Vt(i,j,:) = mean(s,1);
        t = info.t';
    end
end

% time align and detrend each channel, for all files
for i = 1:NC
    v = squeeze(Vt(:,i,:));
    v = signalAlign(v);
    v = detrend(v','constant')';
    Vt(:,i,:) = v;
end

% construct the impulse response
for i = 1:NF
    for j = 1:NC
        [~, ind] = max(abs(Vt(i,j,:)));
        [~, ind1] = min(abs(t-(t(ind) - twindow/2))); % lower bound
        [~, ind2] = min(abs(t-(t(ind) + twindow/2))); % upper bound
        n = length(t(ind1:ind2));
        [f, Vf(i,j,:)] = myfft(t(ind1:ind2),squeeze(Vt(i,j,ind1:ind2)) .* window(@tukeywin,n,.25));
    end
end

% plots
IL = 20*log10(abs(Vf(1,:,:))) - 20*log10(abs(Vf(2,:,:)));
IL = squeeze(IL);

figure
plot(f/1000,IL)
legend({'Phone 1','Phone 2'})
xlabel('f [kHz]')
ylabel('IL [dB]')
title('Insertion loss of prototype array')

end





