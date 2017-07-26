% ASCLoad.m
% Function for loading and cleaning up .ASC files from Agilent scope
%
% Original: Justin Dubin
% Modified: 6-13-2017 by Eli Willard
%
% In: fList - list of files to be processed
%     ch - struct with channels of drive, std, and phone
% Out: data_out - N channels x number of points vector of processed data 

function data_out = calFileLoad(fList, ch)
% Data Parameters

    for ii = 1 : length(fList);

        % Load Data
        data = load(fList(ii))';

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
