function [output] = QAMgene(len)	% the num of the QAM symbol: len
% 	tempI = randi(2,len/2-1,1)*2-3;
% 	tempQ = randi(2,len/2-1,1)*2-3;
% 	temp = tempI + 1i * tempQ;
% 	output = [ZeroFre,temp',HighFre,conj(fliplr(temp'))];
	tempI = randi(2,len,1)*2-3;
	tempQ = randi(2,len,1)*2-3;
    temp = tempI + 1i * tempQ;
    output = temp;
end