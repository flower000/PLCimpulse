function [output] = ImpulGen(num,ori)
    global noiseLabel;
    if noiseLabel == 1      % �ֶ�����
        output = manual(num);
    elseif noiseLabel==2    % ��Ϊ����
        output = car(num,ori);
    elseif noiseLabel==3
        output = RejSampling(3*num);
    end
end

%% impulse noise by manually
function [impulse] = manual(num)
%ImpulGen: the generation the Impulse noise
%   
    global Pim Rs;
    impulNum = randi(floor(num/3)) + num/3;
    impulse = zeros(num,1);
    % impulse 1
    start1 = randi(100);
    step1 = floor(1e-6*Rs);
    matr1 = start1:step1:min(start1+step1*(impulNum/2),num);
    impulse(matr1) = impulse(matr1) + rand(length(matr1),1)-0.5;
    % impulse 2
    start2 = randi(100);
    step2 = floor(3e-6*Rs);
    matr2 = start2:step2:min(start2+step2*(impulNum/3),num);
    impulse(matr2) = impulse(matr2) + rand(length(matr2),1)-0.5;
%% normalization with SIR
    impulse = impulse * sqrt(Pim / sum(impulse.^2)*num);
end

%% impulse noise by Huawei
function [impulse] = car(num,ori)
    global Pim;
    start = randi(1000);    %1000;%
    impulse = ori(start:4:start+4*(num-1));
    impulse = impulse * sqrt(Pim / mean(impulse.^2));
end

%% impulse noise by possion process
function [output] = RejSampling(argu)
    global Num;
    global sigma2 hyb k;
    len = length(sigma2);
    sig = sqrt(sigma2(5));
    z = normrnd(0,sig,1,argu);
    qz = 1/(sqrt(2*pi)*sig)*exp(-0.5*z.^2/sig^2);
    u = unifrnd(zeros(1,argu),k*qz);
    pz = normpdf(z',zeros(1,length(sigma2)),sqrt(sigma2));
    coef = repmat(hyb,length(z),1);
    PZ = sum((pz.*coef)');
    sample = z(PZ>=u);
    count = length(sample);
    
    %display_k(z,k*qz,PZ);
    %displayOUT(output);
    %displayVerify(z,PZ,output(1:count));
    global lambda implen;
    %loc = exprnd(lambda,1,ceil(Num/lambda));
    loc = 900*ones(1,ceil(Num/lambda));
    loc = ceil(loc);
    output = zeros(1,Num);
    now = 1;
    for index = 1:length(loc)
        now = now + loc(index);
        if now + implen> Num
            break;
        end
        orde = randperm(count);
        temp = sample(orde(1:implen));
        output(1,now:now+implen-1) = output(1,now:now+implen-1) + temp;
    end
    global Pim scale;
    %Pim*Num = 2*implen*scale^2;
    scale = sqrt(Pim*Num / 2/implen);
    %scale = sqrt(Pim / mean(output.^2));
    output = output * scale;
    output = awgn(output,30,'measured');
    plot(output);
    %set(gca,'XLim',[0,4.5e4]);
    title('��������');
    xlabel('��ɢʱ��');
    ylabel('����');
end

function [] = display_k(z,s,PZ)
    figure; hold on;
    plot(z,s,'c.');
    plot(z,PZ,'r.');
    legend('2.9����֪�ֲ��ܶȺ���','Ŀ��ֲ��ܶȺ���');
    xlabel('������');
    ylabel('��ֵ');
    title('�����ܶȺ���');
    hold off;
end

function [] = displayOUT(output)
    figure;     plot(output);
    xlabel('��ɢʱ��');
    ylabel('��ֵ');
    title('��������');
    set(gca,'XLim',[2e3,2.4e3]);
end

function [] = displayVerify(z,PZ,output)
    figure; hold on;
    plot(z,PZ,'r.');
    % ����ֲ�
    delta = 0.01;
    slice = [-8:delta:8];
    len = length(slice);
    counting = zeros(1,len);
    for index = 1:length(output)
        temp = floor((output(index) + 8)/delta)+1;
        counting(temp) = counting(temp)+1;
    end
    plot(slice,counting/length(output)/delta);
    % ��ͼ
    legend('Ŀ��ֲ�','�����ֲ�');
    xlabel('������');
    ylabel('��ֵ');
    title('�����ܶȺ���');
    hold off;
end
