function [lat] = FirstSelectiveBin(sigtime,n)
% assess the first bin in time when significant difference is stable for n
% consecutive bins
%
% Input:
%   sigtime: vector of 0s and 1s
%   n: number of consecutive 1s required
%
% Example:
% lat = assess1stBin([0 0 1 0 0 0 1 1 1 1 1],5);
% gives the result: 7
%
% seb.crouzet@gmail.com

lat = NaN;
mycount = 0;
for t = 1:length(sigtime)
    if sigtime(t) == 1;
        mycount = mycount+1;
        if mycount == n;
            lat = t - (n-1);
            break
        end
    else mycount = 0;
    end
end

