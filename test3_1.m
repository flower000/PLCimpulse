function [] = test3_1()
    %% generate
    global Num N Psig Pim Pawgn;
    load header.mat; OFDM = output;
	ofdm = ifft(OFDM,N)';
    %ofdm = QAMgene(N);      % real signal
    %ofdm = ifft(ofdm)';
    ofdm = ofdm / sqrt(mean(ofdm.^2));
    Num = length(ofdm);
	Psig = mean(ofdm.^2);
    %% channel
    global SIR SNR;
    SNR = 30;   SIR = 0;
    Pim = Psig*10^(-SIR/10);   Pawgn = Psig*10^(-SNR/10);
    global noiseLabel;
    noiseLabel = 2;
    noise0 = [];
    load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\��ƿ��\noise0.mat'
    impulse = ImpulGen(Num,noise0);
    recie = ThrouChan(ofdm,impulse);
    %% receiver
    % û���źŽ׶�
    noise = recie - ofdm;   % awgn + impulseNoise
    P0 = noise.^2;  r0 = mean(P0);
    beta0 = 3;  thres0 = beta0 * sqrt(r0);    figure;hold on;plot(recie);legend('�����ź�','����');
    PI = noise(noise>thres0 | noise<-thres0);
    %PI = zeros(size(noise));    PI(noise>thres0 | noise<-thres0) = noise(noise>thres0 | noise<-thres0);
    % ���źŽ׶�
    recie(noise>thres0 | noise<-thres0) = 0;
    P1 = recie.^2;  r1 = mean(P1);
    beta1 = 2.5;  thres1 = beta1 * sqrt(r1);
    % ����
    T = thres1; a = sqrt(mean(PI.^2)) / 8 / T;
    
    % �ϵ��ӽǱȽ�
    global suplabel;
    suplabel = 1;       % ���ŵ�
    [~,~,Tcom,acom] = suppre(recie);
end