function [output] = ImpulGen(num,ori)
    global noiseLabel;
    if noiseLabel == 1      % 手动生成
        output = manual(num);
    elseif noiseLabel==2    % 华为数据
        output = car(num,ori);
    elseif noiseLabel==3
        output = Rejnoise(num);
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

function [impulse] = Rejnoise(num)
    a = 1;
end
