function [output,T,a] = suppre(signal)
%suppre: to suppress impulse noise of the signal
   global suplabel;
   if suplabel==1
        [T,a] = bruteForce(signal);
   end
   output = f(signal,T,a);
end

function [T,a] = bruteForce(signal)
%generationAT: obtain the optimal parameters T and a for impulse noise suppression
    scaleA = 1:0.1:4;
    scaleT = 0:0.05:4;
    res = ones(length(scaleA),length(scaleT));
    for a_index = 1:length(scaleA)
        for T_index = 1:length(scaleT)
            temp = f(signal,scaleT(T_index),scaleA(a_index));     % Receiver doesn't know P 
            ave = mean(temp.^2);
            res(a_index,T_index) = SINR(ave);
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