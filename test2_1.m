function [] = test2_1()
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
    SNR = 30;
    global noiseLabel;
    noiseLabel = 2;
    load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\电瓶车\noise0.mat'
    %% aT lib
    global iteration;
    global suplabel;
    suplabel = 1;       % 最优的
    c = cell(21,6);
    for SIR = 0:1:20
        Pim = Psig*10^(-SIR/10);
        fprintf('信干比为：%d',SIR);
        for index = 1:iteration
            impulse = ImpulGen(Num,noise0);
            recie = ThrouChan(ofdm,impulse);
            [~,~,Tcom,acom] = suppre(recie);
            % 计算接收信号的一些特征量
            c{SIR*iteration+index,1} = recie;           % 信号
            c{SIR*iteration+index,2} = mean(recie);     % 信号平均值
            c{SIR*iteration+index,3} = var(recie);      % 信号方差
            c{SIR*iteration+index,4} = max(abs(recie)); % 最大值
            c{SIR*iteration+index,5} = acom;           % a
            c{SIR*iteration+index,6} = Tcom;           % T
            % 打印
            fprintf('----轮数：%d',index);
        end
    end
    save c.mat c;
end