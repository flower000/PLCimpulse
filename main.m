%--------------------------------------------------------------------------
% Project: Impulse noise suppression and arrival time estimation
% Author: ssy
% Date: 2020/2/21
%--------------------------------------------------------------------------
%% Initialization of global parameters
% about transmitter
global INF;
INF = 1e10;
global Fs Time N duplicLen;
Fs = 1e-4;  Time = 1;   N = Time/Fs;
duplicLen = floor(N / 3);
% about channel
global  SNR SIR delay;
delay = 0.2;  SNR = 100;   SIR = 1; % dB
global Pawgn Pim;
% about receiver
global isSuppre isSegme;
isSuppre = false;   isSegme = false;
global suplabel;
suplabel = 1;

%% the Transmitter
[Trans,P] = TransSig();
%% Through channel
recie = ThrouChan(Trans,P);
%% the Receiver
[t1,t2] = estTime(recie,P);






