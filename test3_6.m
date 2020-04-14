function [] = test3_6()
    %% generate
    global Num N Psig Pim Pawgn;
    QAMseri = QAMgene(2*N);     % 4096
    ofdm = sqrt(2*N) * real(ifft(QAMseri,2*N));
    ofdm = ofdm';
    Num = length(ofdm);
	Psig = mean(1);
    %% channel
    global SIR SNR;
    SNR = 30;   SIR = 20;
    Pim = Psig*10^(-SIR/10);   Pawgn = Psig*10^(-SNR/10);
    global noiseLabel;
    noiseLabel = 4;     % �Լ�������״��������
    noise0 = [];
    %load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\��ƿ��\noise0.mat'
    impulse = ImpulGen(Num,noise0);
    recie = ThrouChan(ofdm,impulse);
    %% receiver
    global iteration obserWIN Ts;
    ofdm = ofdm(1:obserWIN);    Num = obserWIN;
    iteration = 30;
    range = 0:1:14;
    global suplabel simple;
    suplabel = 1;       % ���ŵ�
    simple = 3;     % ����ʽ
    aTbase = cell(length(range)*iteration,8);
    
    global mu sigma implen EX2;
    tau = implen*Ts/2;
    omega = 20*pi/tau;
    start = 6;
    t = [0:Ts:(implen-1)*Ts];
    unit_ht = zeros(1,implen);
    unit_ht(1,1:start) = [1,-1,0.75,0.6,-0.7,0.5];
    temp = exp(-2*t/tau).*cos(omega*t);
    unit_ht(1,(start+1):end) =  0.3*temp(1:end-start);   unitPower = sum(unit_ht.^2);
    %plot(t,unit_ht);
    
    % ��¼
    count = 1;
    static = zeros(iteration,length(range),2);
    obserWIN = 200;
    for SIR = range
        Pim = Psig*10^(-SIR/10);
        fprintf('�Ÿɱ�Ϊ��%d\n',SIR);
        
        for index = 1:iteration
            % �����ź�
            QAMseri = QAMgene(2*N);
            ofdm = sqrt(2*N) * real(ifft(QAMseri,2*N));
            ofdm = ofdm';
    %             obserWIN = 2048;
            ofdm = ofdm(1:obserWIN);
%             impulse = ImpulGen(Num,noise0);
            % ������������
            if randi(2)==1
                amplitude = normrnd(mu,sigma,1,1);
            else
                amplitude = normrnd(-mu,sigma,1,1);
            end
            temp = amplitude * unit_ht;
            scale = 0.5 * sqrt(Pim*2048 / unitPower/EX2);
            impulse = temp * scale;
            impulse = awgn(impulse,30,'measured');
            recie = ThrouChan(ofdm,impulse(1,1:obserWIN));
            
            % ���
%             for t = 1:length(recie)
%                 if((recie(t)>3.05 || recie(t)<-3.05) && mean(recie(t:t+1).^2)>=7)    % ����3sigma��˵�������������
%                     break;
%                 end
%             end
%             if t+obserWIN-1<length(ofdm)
%                 OFDM = ofdm(1,t:t+obserWIN-1);
%                 recie = recie(1,t:t+obserWIN-1);
%                 [~,~,Tcom,acom] = suppre(OFDM,recie);
%             else
%                 OFDM = ofdm(1,t-obserWIN+1:t);
%                 recie = recie(1,t-obserWIN+1:t);
%                 Tcom = 3*1;
%                 acom = 1;
%             end
            %plot(ofdm); hold on; plot(impulse);hold off;
            [~,~,Tcom,acom] = suppre(ofdm,recie);
            static(index,count,1) = Tcom;    % ���ŵ�
            % ͳ����1����s[n]ƽ��ֵ
            static(index,count,2) = sta1(recie);
            
            % ��������źŵ�һЩ������
            aTbase{(count-1)*iteration+index,1} = recie;           % �ź�
            aTbase{(count-1)*iteration+index,2} = mean(abs(recie));% �źž���ֵ ƽ��ֵ
            aTbase{(count-1)*iteration+index,3} = var(recie);      % �źŷ���
            aTbase{(count-1)*iteration+index,4} = max(abs(recie)); % ���ֵ
            aTbase{(count-1)*iteration+index,5} = sum(recie.^2);   % �ܹ���
            aTbase{(count-1)*iteration+index,6} = scale;           % scale
            aTbase{(count-1)*iteration+index,7} = acom;            % acom
            aTbase{(count-1)*iteration+index,8} = Tcom;            % Tcom
%             % ��ӡ
             fprintf('----������%d,T=%d,a=%d\n',index,Tcom,acom);
        end
        count = count + 1;
    end
    save aTbase.mat aTbase;
    
    %% ��Ԫ�ع�
    anly();
    %% ����
    data = aTbase(:,obserWIN+1:end);
    x1 = data(:,1);
    x2 = data(:,2);
    x3 = data(:,3);
    x4 = data(:,4);
    numSCALE = 13.3395-5.53064*x1-13.1858*exp(x2/4)+0.204*x3+0.0464*x4;
    numPim = unitPower * EX2 * (2*numSCALE).^2/2048;
    numSIR = 10*log(1./numPim)/log(10);
    %% ��ͼ
    %display(static);
end

function [output] = sta1(signal)
    output = mean(abs(signal));
end

function [] = display(static)
    % ����
    optim1 = static(:,:,1);
    mea_opt1 = mean(optim1);
    var_opt1 = var(optim1);
    % �������
    optim2 = static(:,:,2);
    mea_opt2 = mean(optim2);
    var_opt2 = var(optim2);
    
    % ��ͼ��ͼ1��ʾ���ƽ��errorbar
    figure; hold on;
    errorbar(range,mea_opt1,var_opt1,'b-s','MarkerSize',10,'LineWidth',1.3);
    errorbar(range,mea_opt2,var_opt2,'r-o','MarkerSize',10,'LineWidth',1.3)
    %plot([0:5:20],aveERROR,'--k^','MarkerSize',10,'LineWidth',1.3);
    legend('����ֵ','����ֵ');
    xlabel('SIR(dB)');
    ylabel('value');
    title('T��������ֵ(����ʽ)');
    set(gca,'XTick',range,'YLim',[0,4]);
    hold off;
    
    % ��ͼ��ͼ2��ʾ������������
    var2 = sum(abs(optim2-optim1)) + var_opt1;
    figure; hold on;
    plot(range,var_opt1,'b-s','MarkerSize',10,'LineWidth',1.3);
    plot(range,var2,'r-o','MarkerSize',10,'LineWidth',1.3);
    %plot([0:5:20],aveERROR,'--k^','MarkerSize',10,'LineWidth',1.3);
    legend('����ֵ','������Ϲ���ֵ');
    xlabel('SIR(dB)');
    ylabel('value');
    title('T��������ֵ(����ʽ)');
    set(gca,'XTick',range,'YLim',[0,4]);
    hold off;
end

function [] = anly()
    global obserWIN;
    %�źž���ֵ ƽ��ֵ + �źŷ��� + ���ֵ + T
    load aTbase.mat aTbase;
    data = cell2mat(aTbase);     
    data = data(:,obserWIN+1:end);   %
    y = data(:,5);        % scale
    x1 = data(:,1);       % �źž���ֵ ƽ��ֵ
    x2 = data(:,2);       % �źŷ���
    x3 = data(:,3);       % ���ֵ  
    x4 = data(:,4);       % ƽ��a����
    %% ����
    % �������źž���ֵ ƽ��ֵ + �źŷ���
    X1 = [ones(size(y)) x1 x2];
    [b1,bint1,r1,rint1,stats1] = regress(y,X1);
    % �������źž���ֵ ƽ��ֵ + ���ֵ  
    X2 = [ones(size(y)) x1 x3];
    [b2,bint2,r2,rint2,stats2] = regress(y,X2);
    % �������źž���ֵ ƽ��ֵ + T
    X3 = [ones(size(y)) x1 x4];     % 1./log(x4)
    [b3,bint3,r3,rint3,stats3] = regress(y,X3);
    % �������źŷ��� + ���ֵ
    X4 = [ones(size(y)) x2 x3];
    [b4,bint4,r4,rint4,stats4] = regress(y,X4);
    % �������źŷ��� + T
    X5 = [ones(size(y)) x2 x4];
    [b5,bint5,r5,rint5,stats5] = regress(y,X5);
    % ���������ֵ + T
    X6 = [ones(size(y)) x3 x4];
    [b6,bint6,r6,rint6,stats6] = regress(y,X6);
    
    %% �ĸ�
    X = [ones(size(y)) x1 1./log(x2) 1./log(x3) 1./log(x4)];
    [b,bint,r,rint,stats] = regress(y,X);
    
    %% ����
    % �źž���ֵ ƽ��ֵ + �źŷ��� + T
    X_ = [ones(size(y)) x1 x2 x4];
    [b,bint,r,rint,stats] = regress(y,X_);
end