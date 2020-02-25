a = [1,2,3,4]';

s =f(a,2,1.5);
function [output] = f(signal,T,a)
%f: the filter function
    output = zeros(length(signal),1);
    output(abs(signal)<=T) = signal((abs(signal)<=T));
    output(abs(signal)>T & abs(signal)<=a*T) = T;
end