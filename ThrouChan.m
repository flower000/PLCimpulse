function [output] = ThrouChan(input,P)
%TransSig: the generation the Rx
%   
% delay
    global delay Fs SNR;
    del = [zeros(delay/Fs,1);input];
%% AWGN
    withAWGN = awgn(del,SNR,'measured');
%% impulse noise
    output = withAWGN + ImpulGen(length(withAWGN),P);
    figure;
    plot(abs(output));
end

function [impulse] = ImpulGen(num,P)
%ImpulGen: the generation the Impulse noise
%   
    global SIR;
    impulNum = randi(num/3) + num/3;
    impulse = zeros(num,1);
%% real part
    impulse1 = zeros(num,1);
    % impulse 1
    start1 = randi(100);
    step1 = 120;
    matr1 = start1:step1:min(start1+step1*(impulNum/2),num);
    impulse1(matr1) = impulse1(matr1) + rand(length(matr1),1);
    % impulse 2
    start2 = randi(100);
    step2 = 120;
    matr2 = start2:step2:min(start2+step2*(impulNum/3),num);
    impulse1(matr2) = impulse1(matr2) + rand(length(matr2),1);
%% imag part
    impulse2 = zeros(num,1);
    % impulse 1
    start1 = randi(100);
    step1 = 120;
    matr1 = start1:step1:min(start1+step1*(impulNum/2),num);
    impulse2(matr1) = impulse2(matr1) + rand(length(matr1),1);
    % impulse 2
    start2 = randi(100);
    step2 = 120;
    matr2 = start2:step2:min(start2+step2*(impulNum/3),num);
    impulse2(matr2) = impulse2(matr2) + rand(length(matr2),1);
%% normalization with SIR
    impulse = impulse1 + 1i*impulse2;
    impulse = impulse * sqrt(P*10^(-SIR/10) / sum(impulse.*conj(impulse))*length(impulse));
end
