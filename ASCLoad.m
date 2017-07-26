% ASCLoad.m
% Function for loading and cleaning up .ASC files from Agilent scope
%
% Original: Justin Dubin
% Modified: 6-13-2017 by Eli Willard
%
% In: fpre - prefix of first .ASC file in sequence, i.e. 'T170612'
%     ifile - serial number of first file to process, i.e. 1
%     efile - serial number of last file to process, 'i.e. 25
%     ch - struct with channels of drive, std, and phone
% Out: data_out - N channels x number of points vector of processed data 

function data_out = ASCLoad(fPre, ifile, efile, ch)
% Data Parameters
fSuf = '.ASC';
cd 'Z:\Transducer Models and Measurements\062117 tank test\SN7 30dB gain'


for ii = ifile:efile;
    
    % Load Data
    str = num2str(ii);
    while length(str) < 3
        str = ['0',str];
    end
    fname = strcat(fPre, str, fSuf);
    data = load(fname)';
    
    % Remove Outliers
    data = data(1:3,2:end-1);
    
    % Remove DC Offset
    for jj = 1:3
        data(jj,:) = data(jj,:) - mean(data(jj,:));
    end
   data_out(ii).drive = data(ch.drive, :);
   data_out(ii).std = data(ch.std, :);
   data_out(ii).phone = data(ch.phone, :);
    
end
    
end
