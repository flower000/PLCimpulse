%--------------------------------------------------------------------------
% Project: Impulse noise suppression and arrival time estimation
% Author: ssy
% Date: 2020/2/21
%--------------------------------------------------------------------------
clear all; close all; clc;
%% Initialization of global parameters
global Num INF;
INF = 1e1;
% about transmitter
global Fuc Fus beta Ndf Nhd Ngi Fsc N;		% ITU-G9660: PLC structure
Fus = 25e6; Fuc = 0; Fsc = 24.4140625e3;
N = 2048; Ngi = N/32; Nhd = N/4; Ndf = N/4;
beta = N/8;
global Ts Rs;
Ts = 1.0/Fsc/N;
Rs = Fsc * N;
% preamble structure for power lines------p103
global N1 k1 N2 k2 N3 k3;
N1 = 7; k1 = 8;
N2 = 2; k2 = 8;
N3 = 0; k3 = INF;
global ZeroFre HighFre winLabel;
ZeroFre = 0;	HighFre = 0;	winLabel = false;
% frame structure
global l fraNum;
l = 10;		fraNum = 2;	

%--------------------------------------------------------------------------
% about channel
global  SNR SIR;
SNR = 10;   SIR = -10; % dB
global Pawgn Pim Psig PowerRatio;
PowerRatio = 2;
%--------------------------------------------------------------------------
% about receiver
global isSuppre isSegme;
isSuppre = false;   isSegme = false;
global suplabel CorrLabel;
suplabel = 3;   CorrLabel = 1;
global segnum;
segnum = 4;
global T Tmin k delta stepA stepT;
T = 100;  Tmin = 1e-8;  
k = 100;  delta = 0.98;
stepA = 0.1;    stepT = 0.05;


%% the Transmitter
[Trans] = TransSig();
%% Through channel
recie = ThrouChan(Trans');
%% the Receiver
[Topt,aopt,t1,t2,t3,t4] = estTime(recie);






