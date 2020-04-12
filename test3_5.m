function [] = test3_5()
    %% generate
    global Num N Psig Pim Pawgn;
    QAMseri = QAMgene(N);
    ofdm = sqrt(N) * real(ifft(QAMseri,N));
    ofdm = ofdm';
    Num = length(ofdm);
	Psig = mean(1);
    %% channel
    global SIR SNR;
    SNR = 30;   SIR = 0;
    Pim = Psig*10^(-SIR/10);   Pawgn = Psig*10^(-SNR/10);
    global noiseLabel;
    noiseLabel = 4;     % 自己产生簇状脉冲噪声
    noise0 = [];
    %load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\电瓶车\noise0.mat'
    impulse = ImpulGen(Num,noise0);
    recie = ThrouChan(ofdm,impulse);
    %% receiver
    global iteration;
    iteration = 50;
    global suplabel simple;
    suplabel = 1;       % 最优的
    simple = 3;     % 三段式
    c = cell(5*iteration,7);
    for SIR = 0:5:20
        Pim = Psig*10^(-SIR/10);
        fprintf('信干比为：%d\n',SIR);
        for index = 1:iteration
            impulse = ImpulGen(Num,noise0);
            recie = ThrouChan(ofdm,impulse);
            [~,~,Tcom,acom] = suppre(ofdm,recie);
            % 计算接收信号的一些特征量
            c{SIR/5*iteration+index,1} = recie;           % 信号
            c{SIR/5*iteration+index,2} = mean(abs(recie));     % 信号绝对值 平均值
            c{SIR/5*iteration+index,3} = var(recie);      % 信号方差
            c{SIR/5*iteration+index,4} = max(abs(recie)); % 最大值
            c{SIR/5*iteration+index,5} = Tcom;           % T           
            c{SIR/5*iteration+index,6} = acom;           % a
            % 打印
            fprintf('----轮数：%d,T=%d,a=%d\n',index,Tcom,acom);
        end
    end
    save c.mat c;
    
    %% best
%      global suplabel;
%      suplabel = 1;       % 最优的
%      global simple;
%      simple = 2;
%      [~,~,Tcom,~] = suppre(ofdm,recie)
end

