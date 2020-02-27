function [corr1,corr2,corr3,corr4] = CorrCurv(temp1,temp2)
%UNTITLED 此处显示有关此函数的摘要
% corr1: noseg suppression
% corr2: seg suppression
% corr3: noseg nosuppression
% corr4: seg nosuppression
    global CorrLabel;
    if CorrLabel == 1
        [corr1,corr2,corr3,corr4] = CorrCurv_A(temp1,temp2);
    elseif CorrLabel == 2
        [corr1,corr2,corr3,corr4] = CorrCurv_B(temp1,temp2);
    elseif CorrLabel == 3
        [corr1,corr2,corr3,corr4] = CorrCurv_C(temp1,temp2);
    elseif CorrLabel == 4
        [corr1,corr2,corr3,corr4] = CorrCurv_D(temp1,temp2);
    elseif CorrLabel == 5
        [corr1,corr2,corr3,corr4] = CorrCurv_E(temp1,temp2);
    end
end
%% Method A
function [corr1,corr2,corr3,corr4] = CorrCurv_A(input1,input2)
% window length: seven 'short' symbols and two 'long' symbols
    % corr1 and corr2
    global N Num;
    global N1 k1 N2 k2 N3 k3;
    corr2 = ones(Num-(N1+N2)*N/k1+1,1);      % auto-correlation of the received signal
    corr1 = ones(Num-(N1+N2)*N/k1+1,1);
    %au index = 1:Num-(N1+N2)*N/k1+1
    for index = 1:Num-(N1+N2)*N/k1+1
        %auCorr(index) = auCorr(index-1) + recFrame(index-1+N/k1).*conj(recFrame(index-1+2*N/k1))...
        %    - recFrame(index-1).*conj(recFrame(index-1+N/k1));
        % Section one of the preamble
        temp = input1(index:index+(N1+N2)*N/k1-1);
        for k = 1:N1-1
            temp1 = temp(1+(k-1)*N/k1:k*N/k1);    temp2 = temp(1+k*N/k1:(k+1)*N/k1);
            corr1(index) = corr1(index) * abs(sum(temp1.*temp2));
            corr2(index) = corr2(index) * Segment(temp1,temp2);
        end
        % Section two of the preamble
        for k = 1:N2-1
            temp1 = temp(1+N1*N/k1+(k-1)*N/k2:k*N/k2+N1*N/k1);    temp2 = temp(1+N1*N/k1+k*N/k2:(k+1)*N/k2+N1*N/k1);
            corr1(index) = corr1(index) * abs(sum(temp1.*temp2));
            corr2(index) = corr2(index) * Segment(temp1,temp2);
        end
    end
    
%--------------------------------------------------------------------------------------------    
    % corr3 and corr4
    corr4 = ones(Num-(N1+N2)*N/k1+1,1);      % auto-correlation of the received signal
    corr3 = ones(Num-(N1+N2)*N/k1+1,1);
    %auCorr(1) = sum(recFrame(1:N/k1).*conj(recFrame(N/k1+1:2*N/k1)));
    for index = 1:Num-(N1+N2)*N/k1+1
        %auCorr(index) = auCorr(index-1) + recFrame(index-1+N/k1).*conj(recFrame(index-1+2*N/k1))...
        %    - recFrame(index-1).*conj(recFrame(index-1+N/k1));
        % Section one of the preamble
        temp = input2(index:index+(N1+N2)*N/k1-1);
        for k = 1:N1-1
            temp1 = temp(1+(k-1)*N/k1:k*N/k1);    temp2 = temp(1+k*N/k1:(k+1)*N/k1);
            corr3(index) = corr3(index) * abs(sum(temp1.*temp2));
            corr4(index) = corr4(index) * Segment(temp1,temp2);
        end
        % Section two of the preamble
        for k = 1:N2-1
            temp1 = temp(1+N1*N/k1+(k-1)*N/k2:k*N/k2+N1*N/k1);    temp2 = temp(1+N1*N/k1+k*N/k2:(k+1)*N/k2+N1*N/k1);
            corr3(index) = corr3(index) * abs(sum(temp1.*temp2));
            corr4(index) = corr4(index) * Segment(temp1,temp2);
        end
    end
end
function [corr1,corr2,corr3,corr4] = CorrCurv_B(temp1,temp2)
end
function [corr1,corr2,corr3,corr4] = CorrCurv_C(temp1,temp2)
end
function [corr1,corr2,corr3,corr4] = CorrCurv_D(temp1,temp2)
end
function [corr1,corr2,corr3,corr4] = CorrCurv_E(temp1,temp2)
end


