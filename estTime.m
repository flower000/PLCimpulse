function [output1,output2] = estTime(signal,P)
%estTime: to estimate the arrival time
%   
    global isSegme;
    [temp1,T,a] = suppre(signal,P);
    temp2 = signal;
    if isSegme == true
        [corr1,corr2] = Corseg(temp1,temp2);
    else
        [corr1,corr2] = CorNoseg(temp1,temp2);
    end
    %display
    display(temp1,temp2,corr1,corr2);
    [~,output1] = max(abs(corr1));
    [~,output2] = max(abs(corr2));
end

function [] = display(temp1,temp2,corr1,corr2)
    figure;
    subplot(1,2,1);
    plot(abs(temp1));
    title('消噪信号');
    subplot(1,2,2);
    plot(abs(temp2));
    title('无消噪信号');
    figure;
    hold on;
    yyaxis left;
    plot(abs(corr1));
    xlabel('index');
    ylabel('消噪相关峰');
    yyaxis right;
    plot(abs(corr2),'r');
    ylabel('无消噪相关峰');
end

function [output,T,a] = suppre(signal,P)
%suppre: to suppress impulse noise of the signal
   [T,a] = generationAT(signal,P);
   output = f(signal,T,a);
end

function [T,a] = generationAT(signal,P)
%generationAT: obtain the optimal parameters T and a for impulse noise suppression
   global suplabel;
   if suplabel==1
        [T,a] = bruteForce(signal,P);
   end
end

function [T,a] = bruteForce(signal,P)
%generationAT: obtain the optimal parameters T and a for impulse noise suppression
    global INF Pim Pawgn;
    MIN = INF;
    temp = zeros(length(signal),1);
    scaleA = 1:0.1:10;
    scaleT = 0.5:0.1:20;
    res = ones(length(scaleA),length(scaleT));
    for a = 1:length(scaleA)
        for T = 1:length(scaleT)
            temp = f(signal,scaleT(T)*sqrt(P),scaleA(a));     % Receiver doesn't know P 
            ave = sum(temp.*conj(temp))/length(temp);
            %res(a,T) = P/(ave-P);
            res(a,T) = SINR(ave,P);
            %MIN = min(MIN,res(a,T));
        end
    end
    %res = res - MIN;
    % display
    figure;
    pcolor(scaleT,scaleA,res);
    shading interp;
    colorbar;   colormap(jet);
    xlabel('T');ylabel('a');
    % T
    [~,resT] = max(max(res));
    T = scaleT(resT);
    % a
    [~,resA] = max(res(:,resT));
    a = scaleA(resA);
end
function [output] = SINR(ave,P)
    global Pim Pawgn;
    conve = P/(Pim+Pawgn);
    MAX = P/Pawgn;
    if ave<P
        output = MAX * ave;
    else
        output = (MAX-conve) * exp(P-ave) + conve;
    end
end
function [output] = f(signal,T,a)
%f: the filter function
    output = zeros(length(signal),1);
    output(abs(signal)<=T) = signal((abs(signal)<=T));
    output(abs(signal)>T & abs(signal)<=a*T) = T;
end

function [output1,output2] = Corseg(signal1,signal2)
%Corseg: obtain correlation curve with segment
    output1 = signal1;
    output2 = signal2;
end

function [output1,output2] = CorNoseg(signal1,signal2)
%CorNoseg: obtain correlation curve without segment
    global duplicLen;
    len = length(signal1)-2*duplicLen+1;
    % with suppression
    output1 = zeros(len,1);
    output1(1) = sum(signal1(1:duplicLen).*conj(signal1(duplicLen+1:2*duplicLen)));
    for index = 2:len
        output1(index) = output1(index-1) + signal1(index+duplicLen-1)* ...
            conj(signal1(index+2*duplicLen-1)) - signal1(index-1)* ...
            conj(signal1(index+duplicLen-1));
    end
    % without suppression
    output2 = zeros(len,1);
    output2(1) = sum(signal2(1:duplicLen).*conj(signal2(duplicLen+1:2*duplicLen)));
    for index = 2:len
        output2(index) = output2(index-1) + signal2(index+duplicLen-1)* ...
            conj(signal2(index+2*duplicLen-1)) - signal2(index-1)* ...
            conj(signal2(index+duplicLen-1));
    end
end

