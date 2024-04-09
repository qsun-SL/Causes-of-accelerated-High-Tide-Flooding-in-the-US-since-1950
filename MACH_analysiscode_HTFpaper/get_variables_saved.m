function get_variables_saved(fname,id,varargin)
%% Title
% This function saves the variables in the paralle for-loop
%
% INPUT:
%   fname: name of the file to be saved with full path
%   id: the number to indicate the variables
%   varargin: the cell contains the varibales to be saved
%
% OUTPUT:
%   save the varibales to a mat-file
%
% VERSION, Qiang Suin, 2022.11.18

if id==1
  HTF=varargin{1};
  HTF_noMSL=varargin{2};
  memo=varargin{3};  HTF_GRD_days=memo{1,1}; clear memo;
  HTF_GRD_lo=varargin{4};
  HTF_GRD_hi=varargin{5};
  HTF_GRD_mu=varargin{6};
  memo=varargin{7};  HTF_VLM_days=memo{1,1}; clear memo;
  HTF_VLM_lo=varargin{8};
  HTF_VLM_hi=varargin{9};
  HTF_VLM_mu=varargin{10};
  memo=varargin{11};  HTF_SDR_days=memo{1,1}; clear memo;
  HTF_SDR_lo=varargin{12};
  HTF_SDR_hi=varargin{13};
  HTF_SDR_mu=varargin{14};
  VLM_ptb=varargin{15};
  GRD_mu_19year=varargin{16};
  VLM_mu_19year=varargin{17};
  SDR_mu_19year=varargin{18};
  HTF_19year=varargin{19};
  HTF_noMSL_19year=varargin{20};
  HTF_GRD_mu_19year=varargin{21};
  HTF_VLM_mu_19year=varargin{22};
  HTF_SDR_mu_19year=varargin{23};
  MSL_trd_10year=varargin{24};
  GRD_trd_10year=varargin{25};
  VLM_trd_10year=varargin{26};
  SDR_trd_10year=varargin{27};
  if length(varargin)>27
    HTF_md=varargin{28};
    HTF_md_noMSL=varargin{29};
  end
  save(fname,'HTF*','VLM_ptb','*19year','*10year','-v7.3');
elseif id==2
  HTF_GIA=varargin{1};
  HTF_nonGIA=varargin{2};
  GIA=varargin{3};
  nonGIA=varargin{4};
  GIA_19year=varargin{5};
  nonGIA_19year=varargin{6};
  HTF_GIA_19year=varargin{7};
  HTF_nonGIA_19year=varargin{8};
  save(fname,'HTF*','GIA','nonGIA','*19year','-v7.3');
else
  disp('Incorrect id for the function of get_variables_saved!');
  keybaord;
end


end
