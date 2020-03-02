function [T,a,corr1,toa1,corr2,toa2] = test1(signal)
%estTime: to estimate the arrival time
%   
    col = 0:5:20;
    row = 1:2;
    global SIR iteration suplabel;
    T_mean = zeros(iteration,length(col),length(row));     a_mean = T_mean;
    
    for SIR = col
        Temprecie = ThrouChan(signal);
        for index = 1:iteration
            for suplabel = row
                [temp1,TempT,Tempa] = suppre(Temprecie);    temp2 = Temprecie;
                [corr1,toa1,corr2,toa2] = CorrCurv(temp1,temp2);
                % record
                T_mean(index,SIR/5+1,suplabel) = TempT;
                a_mean(index,SIR/5+1,suplabel) = Tempa;
            end
        end
    end
    disp(T_mean,a_mean);
end

function [] = disp(T_mean,a_mean)
    global iteration
    %% relative error
    T_opt = mean(T_mean(:,:,1));
    a_opt = mean(a_mean(:,:,1));
    Tcurve1 = abs(mean(T_mean(:,:,2))-T_opt) ./ T_opt;
    acurve1 = abs(mean(a_mean(:,:,2))-a_opt) ./ a_opt;
    % plot
    figure;
    plot([0:5:20],Tcurve1,[0:5:20],acurve1);
    legend('估计量T的相对误差','估计量a的相对误差');
    title('10dB白噪声下改进算法的性能曲线');
    set(gca,'YLim',[0,1],'XTick',[0:5:20]);
    xlabel('干噪比(dB)');
    ylabel('相对值');
    %% MSE
    T_opt = mean(T_mean(:,:,1));
    a_opt = mean(a_mean(:,:,1));
    Tcurve = sum((T_mean(:,:,2)-repmat(T_opt,iteration,1)).^2) / iteration;
    Tcurve = sqrt(Tcurve);
    acurve = sum((a_mean(:,:,2)-repmat(a_opt,iteration,1)).^2) / iteration;
    acurve = sqrt(acurve);
    % plot
    figure;
    plot([0:5:20],Tcurve,[0:5:20],acurve);
    legend('估计量T的均方差','估计量a的均方差');
    title('10dB白噪声下改进算法的性能曲线');
    set(gca,'YLim',[0,1],'XTick',[0:5:20]);
    xlabel('干噪比(dB)');
    ylabel('相对值');
end

