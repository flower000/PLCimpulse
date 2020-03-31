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
    load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\��ƿ��\noise0.mat'
    %% aT lib
    global iteration;
    global suplabel;
    suplabel = 1;       % ���ŵ�
    c = cell(21,6);
    for SIR = 0:1:20
        Pim = Psig*10^(-SIR/10);
        fprintf('�Ÿɱ�Ϊ��%d',SIR);
        for index = 1:iteration
            impulse = ImpulGen(Num,noise0);
            recie = ThrouChan(ofdm,impulse);
            [~,~,Tcom,acom] = suppre(recie);
            % ��������źŵ�һЩ������
            c{SIR*iteration+index,1} = recie;           % �ź�
            c{SIR*iteration+index,2} = mean(recie);     % �ź�ƽ��ֵ
            c{SIR*iteration+index,3} = var(recie);      % �źŷ���
            c{SIR*iteration+index,4} = max(abs(recie)); % ���ֵ
            c{SIR*iteration+index,5} = acom;           % a
            c{SIR*iteration+index,6} = Tcom;           % T
            % ��ӡ
            fprintf('----������%d',index);
        end
    end
    save c.mat c;
end