function [MinRT] = ComputeMinRT(RT,correct,cumul)
% Compute MinRT

% HARDCODED PARAMETERS
bincenters = 0:10:1000;
nBinSuc = 5;
method = 'chi2';
%method = 'bootstrap';
seuil = 0.05; % only used by chi2 method

binHIT = hist(RT(correct==1), bincenters);
binFA  = hist(RT(correct==0), bincenters);
nTrial = sum(binHIT) + sum(binFA);

% Cumulative RT distribs (can be good for single subject analysis)
if cumul==1
    binHIT = cumsum(binHIT);
    binFA = cumsum(binFA);
end

MinRT = NaN;
compte=0;
for bin = 1:length(binHIT)
    vecbin = [binHIT(bin) binFA(bin)];
    estime = sum(vecbin)/2;
    if sum(vecbin)>10
        if strcmp(method,'bootstrap')
            ci = bootci(100,@mean,[ones(1,binHIT(bin)) zeros(1,binFA(bin))]);
            if ci(1)>0.5 %(above chance level)
                compte = compte+1;
            else compte=0;
            end
        elseif strcmp(method,'chi2')
            chideux = (((vecbin(1)-estime)^2)/estime) + (((vecbin(2)-estime)^2)/estime);
            if chi2cdf(chideux,1)>seuil && (vecbin(1)>vecbin(2))
                compte = compte+1;
            else compte=0;
            end
        end
        if compte==nBinSuc
            MinRT = bincenters(bin-(compte-1));
            break
        end
    end
end