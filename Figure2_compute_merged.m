% Do all the analysis but with 1 virtual big subject (all trials from the 4 observers together)

addpath('./Functions/');
load('data.mat');

listsub = unique(data.subjectname);
listvis = {'commonoffset' 'trailing' 'noise' 'contrast'}; % to reorder them as I want
nbb = 500;
alpha = 0.05;
time_window = 1:400;

for v = 1:numel(listvis) 
    current_vis = listvis{v};
    ind = strcmp(data.Visibility,current_vis);
    
    Rall.(current_vis) = makeAccCumulRT(data.RT(ind), data.correct(ind), time_window, 600, 1);
    
    % To compute the virtual MinSRT for the surrogate distributions--------
    ind_com = strcmp(data.Visibility,listvis{1});
    REF_nHIT = sum(data.correct(ind_com) == 1);
    REF_nTOT = sum(ind_com == 1);
    accuracy = sum(data.correct(ind)) / length(data.correct(ind));
    
    % Estimate the number of responses to transform to incorrect so that
    % the common offset condition matches the given reduced visibility condition
    if v>1
        nHIT2transform = REF_nHIT - round( accuracy * REF_nTOT );
    end
    
    % Do the bootstrap ----------------------------------------------------
    for k=1:nbb % nb of bootstrap resamples
        if mod(k,100)==0, disp(num2str(k)); end
        
        myRT  = data.RT(ind);
        mycor = data.correct(ind);
        
        idx = randsample(1:length(myRT),length(myRT),1);
        myRT  = myRT(idx);
        mycor = mycor(idx);
        
        % do the same but on the virtual common offset distrib
        if v>1 % do it only for reduced visibility conditions
            
            myRT_com  = data.RT(ind_com);
            mycor_com = data.correct(ind_com);
            
            % make a few correct responses incorrect
            mycor_com(randsample(find(mycor_com),nHIT2transform))=0;
            
            Rtemp = makeAccCumulRT(myRT_com, mycor_com, time_window, 600, 0);
            Rall.(current_vis).acc_shadow(:,k) = Rtemp.myacc;
            
            %Rvirtual(s,v,k) = ComputeMinRT(myRT_com,mycor_com);
        end
    end
end
save('res_Rall_boot.mat','Rall','-v7.3');
