function [] = head( dataset )
% Display the first 10 lines of a dataset

% check if input variable is a MATLAB dataset array
if ~isa(dataset,'dataset')
    error('The 1st argument should be a dataset array.');
end

disp( dataset(1:10,:) );

end

