function [output,P] = TransSig()
%TransSig: the generation the Tx
%   
    global Pawgn Pim duplicLen N;
    global SIR SNR;
    model = rand(duplicLen,1) + 1i * rand(duplicLen,1);
    tail = rand(N-2*duplicLen,1) + 1i * rand(N-2*duplicLen,1);
    output = [model;model;tail];
    P = sum(output.*conj(output))/length(output);
    output = output / sqrt(P);
    P = sum(output.*conj(output))/length(output);
    Pim = P*10^(-SIR/10);   Pawgn = P*10^(-SNR/10);
end

