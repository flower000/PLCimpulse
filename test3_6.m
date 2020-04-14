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
    noiseLabel = 4;     % 自己产生簇状脉冲噪声
    noise0 = [];
    %load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\电瓶车\noise0.mat'
    impulse = ImpulGen(Num,noise0);
    recie = ThrouChan(ofdm,impulse);
    %% receiver
    global iteration obserWIN Ts;
    ofdm = ofdm(1:obserWIN);    Num = obserWIN;
    iteration = 30;
    range = 0:1:14;
    global suplabel simple;
    suplabel = 1;       % 最优的
    simple = 3;     % 三段式
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
    
    % 记录
    count = 1;
    static = zeros(iteration,length(range),2);
    obserWIN = 200;
    for SIR = range
        Pim = Psig*10^(-SIR/10);
        fprintf('信干比为：%d\n',SIR);
        
        for index = 1:iteration
            % 产生信号
            QAMseri = QAMgene(2*N);
            ofdm = sqrt(2*N) * real(ifft(QAMseri,2*N));
            ofdm = ofdm';
    %             obserWIN = 2048;
            ofdm = ofdm(1:obserWIN);
%             impulse = ImpulGen(Num,noise0);
            % 计算脉冲噪声
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
            
            % 检测
%             for t = 1:length(recie)
%                 if((recie(t)>3.05 || recie(t)<-3.05) && mean(recie(t:t+1).^2)>=7)    % 大于3sigma，说明出现脉冲干扰
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
            static(index,count,1) = Tcom;    % 最优的
            % 统计量1——s[n]平均值
            static(index,count,2) = sta1(recie);
            
            % 计算接收信号的一些特征量
            aTbase{(count-1)*iteration+index,1} = recie;           % 信号
            aTbase{(count-1)*iteration+index,2} = mean(abs(recie));% 信号绝对值 平均值
            aTbase{(count-1)*iteration+index,3} = var(recie);      % 信号方差
            aTbase{(count-1)*iteration+index,4} = max(abs(recie)); % 最大值
            aTbase{(count-1)*iteration+index,5} = sum(recie.^2);   % 总功率
            aTbase{(count-1)*iteration+index,6} = scale;           % scale
            aTbase{(count-1)*iteration+index,7} = acom;            % acom
            aTbase{(count-1)*iteration+index,8} = Tcom;            % Tcom
%             % 打印
             fprintf('----轮数：%d,T=%d,a=%d\n',index,Tcom,acom);
        end
        count = count + 1;
    end
    save aTbase.mat aTbase;
    
    %% 多元回归
    anly();
    %% 估计
    data = aTbase(:,obserWIN+1:end);
    x1 = data(:,1);
    x2 = data(:,2);
    x3 = data(:,3);
    x4 = data(:,4);
    numSCALE = 13.3395-5.53064*x1-13.1858*exp(x2/4)+0.204*x3+0.0464*x4;
    numPim = unitPower * EX2 * (2*numSCALE).^2/2048;
    numSIR = 10*log(1./numPim)/log(10);
    %% 绘图
    %display(static);
end

function [output] = sta1(signal)
    output = mean(abs(signal));
end

function [] = display(static)
    % 最优
    optim1 = static(:,:,1);
    mea_opt1 = mean(optim1);
    var_opt1 = var(optim1);
    % 线性组合
    optim2 = static(:,:,2);
    mea_opt2 = mean(optim2);
    var_opt2 = var(optim2);
    
    % 作图：图1表示估计结果errorbar
    figure; hold on;
    errorbar(range,mea_opt1,var_opt1,'b-s','MarkerSize',10,'LineWidth',1.3);
    errorbar(range,mea_opt2,var_opt2,'r-o','MarkerSize',10,'LineWidth',1.3)
    %plot([0:5:20],aveERROR,'--k^','MarkerSize',10,'LineWidth',1.3);
    legend('估计值','最优值');
    xlabel('SIR(dB)');
    ylabel('value');
    title('T参数估计值(两段式)');
    set(gca,'XTick',range,'YLim',[0,4]);
    hold off;
    
    % 作图：图2表示方差性能曲线
    var2 = sum(abs(optim2-optim1)) + var_opt1;
    figure; hold on;
    plot(range,var_opt1,'b-s','MarkerSize',10,'LineWidth',1.3);
    plot(range,var2,'r-o','MarkerSize',10,'LineWidth',1.3);
    %plot([0:5:20],aveERROR,'--k^','MarkerSize',10,'LineWidth',1.3);
    legend('最优值','线性组合估计值');
    xlabel('SIR(dB)');
    ylabel('value');
    title('T参数估计值(两段式)');
    set(gca,'XTick',range,'YLim',[0,4]);
    hold off;
end

function [] = anly()
    global obserWIN;
    %信号绝对值 平均值 + 信号方差 + 最大值 + T
    load aTbase.mat aTbase;
    data = cell2mat(aTbase);     
    data = data(:,obserWIN+1:end);   %
    y = data(:,5);        % scale
    x1 = data(:,1);       % 信号绝对值 平均值
    x2 = data(:,2);       % 信号方差
    x3 = data(:,3);       % 最大值  
    x4 = data(:,4);       % 平均a功率
    %% 两个
    % 两个：信号绝对值 平均值 + 信号方差
    X1 = [ones(size(y)) x1 x2];
    [b1,bint1,r1,rint1,stats1] = regress(y,X1);
    % 两个：信号绝对值 平均值 + 最大值  
    X2 = [ones(size(y)) x1 x3];
    [b2,bint2,r2,rint2,stats2] = regress(y,X2);
    % 两个：信号绝对值 平均值 + T
    X3 = [ones(size(y)) x1 x4];     % 1./log(x4)
    [b3,bint3,r3,rint3,stats3] = regress(y,X3);
    % 两个：信号方差 + 最大值
    X4 = [ones(size(y)) x2 x3];
    [b4,bint4,r4,rint4,stats4] = regress(y,X4);
    % 两个：信号方差 + T
    X5 = [ones(size(y)) x2 x4];
    [b5,bint5,r5,rint5,stats5] = regress(y,X5);
    % 两个：最大值 + T
    X6 = [ones(size(y)) x3 x4];
    [b6,bint6,r6,rint6,stats6] = regress(y,X6);
    
    %% 四个
    X = [ones(size(y)) x1 1./log(x2) 1./log(x3) 1./log(x4)];
    [b,bint,r,rint,stats] = regress(y,X);
    
    %% 三个
    % 信号绝对值 平均值 + 信号方差 + T
    X_ = [ones(size(y)) x1 x2 x4];
    [b,bint,r,rint,stats] = regress(y,X_);
end