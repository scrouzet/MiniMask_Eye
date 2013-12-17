% Analysis for each observer

addpath('./Functions/');
load('data.mat');
listsub = unique(data.subjectname);
listvis = {'commonoffset' 'trailing' 'noise' 'contrast'}; % to reorder them as I want
nbb = 500;
alpha = 0.05;

for s = 1:numel(listsub)
    for v = 1:numel(listvis)
        current_sub = listsub{s}; 
        current_vis = listvis{v};
        fprintf(1, 'Processing observer %s - %s condition.\n',current_sub, current_vis);
        
        ind = strcmp(data.subjectname,current_sub) & strcmp(data.Visibility,current_vis);
        
        res.(current_vis).(current_sub) = makeRTDistrib(data.RT(ind),data.correct(ind));
        
        % ACCURACY
        R.accuracy(s,v)      = res.(current_vis).(current_sub).accuracy;
        R.accuracy_ci(s,v,:) = res.(current_vis).(current_sub).accuracy_ci;
        
        % MEDIAN RT
        R.medianRT(s,v)   = res.(current_vis).(current_sub).medianRT_cor;
        R.medianRT_ci(s,v,:) = res.(current_vis).(current_sub).medianRT_cor_ci;
        
        % MIN RT
        R.minRT(s,v)   = res.(current_vis).(current_sub).minRT;
        R.minRT_ci(s,v,:) = res.(current_vis).(current_sub).minRT_ci;
        
        %-----------------------------------------------------------------------------------
        % VIRTUAL MIN RT
        ind_com = strcmp(data.subjectname,current_sub) & strcmp(data.Visibility,listvis{1});
        
        REF_nHIT = sum(data.correct(ind_com) == 1);
        REF_nTOT = sum(ind_com == 1);
        
        % get accuracy in this condition (only used for the shadows)
        accuracy = sum(data.correct(ind)) / length(data.correct(ind));
        
        % Estimate the number of responses to transform to incorrect so that
        % the common offset condition matches the given reduced visibility condition
        if v>1
            nHIT2transform = REF_nHIT - round( accuracy * REF_nTOT );
        end
        
        % do the permutation with resampling by hand
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
                
                % make a few correct responses incorrect for the surrogate
                % distributions
                mycor_com(randsample(find(mycor_com),nHIT2transform))=0;      

                R.minRT_virtual(s,v,k) = ComputeMinRT(myRT_com,mycor_com);
            end 
        end        
    end
end
save('res_R_boot.mat','R','-v7.3');