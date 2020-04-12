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
    noiseLabel = 4;     % �Լ�������״��������
    noise0 = [];
    %load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\��ƿ��\noise0.mat'
    impulse = ImpulGen(Num,noise0);
    recie = ThrouChan(ofdm,impulse);
    %% receiver
    global iteration;
    iteration = 50;
    global suplabel simple;
    suplabel = 1;       % ���ŵ�
    simple = 3;     % ����ʽ
    c = cell(5*iteration,7);
    for SIR = 0:5:20
        Pim = Psig*10^(-SIR/10);
        fprintf('�Ÿɱ�Ϊ��%d\n',SIR);
        for index = 1:iteration
            impulse = ImpulGen(Num,noise0);
            recie = ThrouChan(ofdm,impulse);
            [~,~,Tcom,acom] = suppre(ofdm,recie);
            % ��������źŵ�һЩ������
            c{SIR/5*iteration+index,1} = recie;           % �ź�
            c{SIR/5*iteration+index,2} = mean(abs(recie));     % �źž���ֵ ƽ��ֵ
            c{SIR/5*iteration+index,3} = var(recie);      % �źŷ���
            c{SIR/5*iteration+index,4} = max(abs(recie)); % ���ֵ
            c{SIR/5*iteration+index,5} = Tcom;           % T           
            c{SIR/5*iteration+index,6} = acom;           % a
            % ��ӡ
            fprintf('----������%d,T=%d,a=%d\n',index,Tcom,acom);
        end
    end
    save c.mat c;
    
    %% best
%      global suplabel;
%      suplabel = 1;       % ���ŵ�
%      global simple;
%      simple = 2;
%      [~,~,Tcom,~] = suppre(ofdm,recie)
end

