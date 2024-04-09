function [varargout]=get_variables_loaded(fname,id)
%% Title
% This function loads the variables in the paralle for-loop
%
% INPUT:
%   fname: name of the file with full path to be loaded
%   id: the number to indicate the variables
%
% OUTPUT:
%   varargout: the cell contains the varibales loaded from fname.
%
% VERSION, Qiang Suin, 2023.01.24

if id==1
  load(fname,'VLM_ptb'); 
  varargout{1}=VLM_ptb;
elseif id==2
  load(fname,'VLM_mu','GRD_mu','SDR_mu');
  varargout{1}=VLM_mu;
  varargout{2}=GRD_mu;
  varargout{3}=SDR_mu;  
else
  disp('Incorrect id for the function of get_variables_saved!');
  keybaord;
end


end
