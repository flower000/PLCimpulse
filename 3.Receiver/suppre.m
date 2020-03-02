function [output,T1,a1] = suppre(signal)
%suppre: to suppress impulse noise of the signal
   global suplabel;
   %{
   if suplabel==1
        [T1,a1] = bruteForce(signal);
   elseif suplabel==2
       [T2,a2] = Simulannealing(signal);
   end
   %}
   [T1,a1] = bruteForce(signal);
   [T2,a2] = Simulannealing(signal);
   output = f(signal,T,a);
end

function [T,a] = bruteForce(signal)
%generationAT: obtain the optimal parameters T and a for impulse noise suppression
    global stepA stepT;
    scaleA = 1:stepA:4;
    scaleT = 0:stepT:4;
    res = ones(length(scaleA),length(scaleT));
    for a_index = 1:length(scaleA)
        for T_index = 1:length(scaleT)
            temp = f(signal,scaleT(T_index),scaleA(a_index));     % Receiver doesn't know P 
            ave = mean(temp.^2);
            res(a_index,T_index) = SINR(ave);
        end
    end
    % display
    %{
    figure;
    pcolor(scaleT,scaleA,res);
    shading interp;
    colorbar;   colormap(jet);
    xlabel('T');ylabel('a');
    %}
    
    % T
    [~,resT] = max(max(res));
    T = scaleT(resT);
    % a
    [~,resA] = max(res(:,resT));
    a = scaleA(resA);
end

function [Topt,Aopt] = Simulannealing(signal)
    global T Tmin k delta stepT stepA;
    Topt = rand()*4;   Aopt = rand()*4;
    temp = f(signal,Topt,Aopt);
    E = SINR(mean(temp.^2));
    while(T>Tmin)
        T_next = Topt + (randi(3)-2)*stepT;  A_next = Aopt + (randi(3)-2)*stepA;
        if A_next<1
            A_next = 1;
        end
        if T_next < 0z
            T_next = 0;
        end
        signal_next = f(signal,T_next,A_next);
        E_next = SINR(mean(signal_next.^2));
        dE = E_next - E;
        if dE >= 0
            Topt = T_next; Aopt = A_next;   E = E_next;
        elseif exp(dE/T) > rand()
            Topt = T_next; Aopt = A_next;   E = E_next;
        end
        T = delta * T;
        %i = i+1;
    end
end






























