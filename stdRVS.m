% stdRVS.m
% This function interpolates an RVS value for the the BnK 8103 hydrophone
% at a given frequency.
% 
% Inputs: freq - frequency for interpolation
% Outputs: RVSInterp - interpolated RVS value
%
% Last modified 7-25-17 by Eli Willard

function RVSInterp = stdRVS(freq)
d = importdata('BnK8013FreqResponse.txt');
standard.freq = d.data(:,1);
standard.RVS = d.data(:,2);
RVSInterp = interp1(standard.freq,standard.RVS,freq,'pchip',NaN);
end