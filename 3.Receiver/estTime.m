function [T,a,output1,output2,output3,output4] = estTime(signal)
%estTime: to estimate the arrival time
%   
    [temp1,T,a] = suppre(signal);
    temp2 = signal;
    
    %
    global Ts;
    t = 0:Ts:(length(temp1)-1)*Ts;
    figure;
    hold on;
    plot(t,temp1,t,temp2);
    set(gca,'XLim',[2e-4,2.02e-4]);
    legend('抑制','无抑制');
    xlabel('时间');   ylabel('相对幅度');
    title('抑制脉冲噪声');
    hold off;
    
    [corr1,corr2,corr3,corr4] = CorrCurv(temp1,temp2);
    
    %display
    display(corr1,corr2,corr3,corr4);
    [~,output1] = max(corr1);
    [~,output2] = max(corr2);
    [~,output3] = max(corr3);
    [~,output4] = max(corr4);
end

function [] = display(corr1,corr2,corr3,corr4)
    global Ts;
    t = 0:Ts:(length(corr1)-1)*Ts;
    figure;
    hold on;
    title('相关峰');
    % suppression + seg/noseg
    subplot(2,2,1);
    yyaxis left;
    plot(t,abs(corr1));     xlabel('时间');
    set(gca,'XLim',[3.6e-4,3.85e-4]);
    ylabel('相对幅度1');
    yyaxis right;
    plot(t,abs(corr2));
    ylabel('相对幅度2');
    legend('无分块+消噪','分块+消噪');
    % suppression + seg/noseg
    subplot(2,2,2);
    yyaxis left;
    plot(t,abs(corr3));     xlabel('时间');
    set(gca,'XLim',[3.6e-4,3.85e-4]);
    ylabel('相对幅度1');
    yyaxis right;
    plot(t,abs(corr4));
    ylabel('相对幅度2');
    legend('无分块+无消噪','分块+无消噪');
    % noseg + suppression/nosupp
    subplot(2,2,3);
    yyaxis left;
    plot(t,abs(corr1));     xlabel('时间');
    set(gca,'XLim',[3.6e-4,3.85e-4]);
    ylabel('相对幅度1');
    yyaxis right;
    plot(t,abs(corr3));
    ylabel('相对幅度2');
    legend('消噪+无分块','无消噪+无分块');
    % suppression + seg/noseg
    subplot(2,2,4);
    yyaxis left;
    plot(t,abs(corr2));     xlabel('时间');
    set(gca,'XLim',[3.6e-4,3.85e-4]);
    ylabel('相对幅度1');
    yyaxis right;
    plot(t,abs(corr4));
    ylabel('相对幅度2');
    legend('消噪+分块','无消噪+分块');
end
