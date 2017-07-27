clc
clear 
close all

addpath('C:\Users\jdubin\Documents\Useful Functions')

f = (10:10:40).*1e3;
fs = 1e6;
nCyc = 10;
gap = 500;
tuk = 0.3;

tb = toneburst(f,fs,nCyc,gap,tuk);

figure;plot(tb)