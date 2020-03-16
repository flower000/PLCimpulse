function [output,runtime,T,a] = suppre(signal)
%suppre: to suppress impulse noise of the signal
   global suplabel;
   tic;
   if suplabel==1
        [T,a] = bruteForce(signal);
   elseif suplabel==2
        [T,a] = Simulannealing(signal);
   end
   runtime=toc;
   %[T1,a1] = bruteForce(signal);
   %[T2,a2] = Simulannealing(signal);
   output = f(signal,T,a);
end

function [T,a] = bruteForce(signal)
%generationAT: obtain the optimal parameters T and a for impulse noise suppression
    global stepA stepT;
    scaleA = 1:stepA:4;
    scaleT = 1:stepT:4;
    res = ones(length(scaleA),length(scaleT));
    for a_index = 1:length(scaleA)
        for T_index = 1:length(scaleT)
            temp = f(signal,scaleT(T_index),scaleA(a_index));     % Receiver doesn't know P 
            ave = mean(temp.^2);
            res(a_index,T_index) = SINR(ave);%exp(SINR(ave));
        end
    end
    % display
    
    
    figure;  hold on;
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

function [Topt,Aopt] = Simulannealing(signal)
    global T Tmin delta stepT stepA itertime;
    Tempra = T;
    count = 1;
    recordT = zeros(ceil(log(Tmin/T)/log(delta)),1);    recordA = recordT;
    Teav = zeros(1,itertime); aeav = zeros(1,itertime);   Eeav = zeros(1,itertime);
    for k=1:itertime
        Topt = rand()+2;   Aopt = rand()+1;
        % record
        recordT(count) = Topt;  recordA(count) = Aopt;
        temp = f(signal,Topt,Aopt);
        E = SINR(mean(temp.^2));
        while(Tempra>Tmin)
            count = count + 1;
            T_next = Topt + (randi(3)-2)*stepT;  A_next = Aopt + (randi(3)-2)*stepA;
            if A_next<1
                A_next = 1.1;
            elseif A_next > 5
                A_next = 4;
            end
            if T_next < 1.5
                T_next = 1.8;
            elseif T_next > 5
                T_next = 4;
            end
            signal_next = f(signal,T_next,A_next);
            E_next = SINR(mean(signal_next.^2));
            dE = E_next - E;
            if dE >= 0
                Topt = T_next; Aopt = A_next;   E = E_next;
            elseif exp(dE/Tempra) > rand()
                Topt = T_next; Aopt = A_next;   E = E_next;
            end
            recordT(count) = Topt;  recordA(count) = Aopt;
            Tempra = delta * Tempra;
        end
        Teav(k) = Topt; aeav(k) = Aopt; Eeav(k) = E;
    end
    [~,loc] = min(Eeav);
    Topt = Teav(loc);   Aopt = aeav(loc);
    dispSimu(recordT,recordA);
end

function [] = dispSimu(recordT,recordA)
    for index = 1:length(recordT)
        plot(recordT(index),recordA(index),'*k');
    end
    title('Ä£ÄâÍË»ðËÑË÷Â·¾¶');
end





























