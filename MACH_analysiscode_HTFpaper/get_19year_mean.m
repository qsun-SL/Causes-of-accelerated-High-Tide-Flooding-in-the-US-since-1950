function [GRD_mu_19year,VLM_mu_19year,SDR_mu_19year,RMSL_19year, ...
          HTF_19year,HTF_noMSL_19year,HTF_GRD_mu_19year,HTF_VLM_mu_19year,HTF_SDR_mu_19year] ...
         =get_19year_mean(NOAA_t_hour,NOAA_t_year,GRD_mu,VLM_mu,SDR_mu,NOAA_MSL, ...
                          HTF,HTF_noMSL,HTF_GRD_mu,HTF_VLM_mu,HTF_SDR_mu, ...
                          NOAA_dcov_19year)
%% Title
% This function calculate the 19-year mean of input variables
%
% VERSION, Qiang Sun, 2022.11.18
% VERSION, Qiang Sun, 2023.02.27, corrected a bug in calculating the 19-year mean 
%                                 GRD, VLM, and SDR at line 29. 

GRD_mu_19year=nan(size(NOAA_t_year));
VLM_mu_19year=GRD_mu_19year;
SDR_mu_19year=GRD_mu_19year;
HTF_19year        = cell(size(HTF));
HTF_noMSL_19year  = HTF_19year;
HTF_GRD_mu_19year = HTF_19year;
HTF_VLM_mu_19year = HTF_19year;
HTF_SDR_mu_19year = HTF_19year;
HTF_19year{1,1}=nan(size(NOAA_t_year));  HTF_19year{1,2}        = HTF_19year{1,1};
HTF_noMSL_19year{1,1} =HTF_19year{1,1};  HTF_noMSL_19year{1,2}  = HTF_19year{1,1};
HTF_GRD_mu_19year{1,1}=HTF_19year{1,1};  HTF_GRD_mu_19year{1,2} = HTF_19year{1,1};
HTF_VLM_mu_19year{1,1}=HTF_19year{1,1};  HTF_VLM_mu_19year{1,2} = HTF_19year{1,1};
HTF_SDR_mu_19year{1,1}=HTF_19year{1,1};  HTF_SDR_mu_19year{1,2} = HTF_19year{1,1};
for k=10:size(NOAA_t_year,1)-9
  % 19-year averaged bugets water levels
  ind_1=find(NOAA_t_hour==NOAA_t_year(k-9));
  ind_2=find(NOAA_t_hour==datenum(str2num(datestr(NOAA_t_year(k+9),'yyyy')),12,31,23,0,0));
  GRD_mu(isnan(NOAA_MSL))=nan;
  VLM_mu(isnan(NOAA_MSL))=nan;
  SDR_mu(isnan(NOAA_MSL))=nan
  GRD_mu_19year(k)=mean(GRD_mu(ind_1:ind_2),'omitnan');
  VLM_mu_19year(k)=mean(VLM_mu(ind_1:ind_2),'omitnan');
  SDR_mu_19year(k)=mean(SDR_mu(ind_1:ind_2),'omitnan');
  RMSL_19year(k)=mean(NOAA_MSL(ind_1:ind_2),'omitnan');
  clear ind_1 ind_2;
  % 19-year averaged HTF
  for j=1:size(HTF,2)
    HTF_19year{1,j}(k)        = sum(HTF{1,j}(k-9:k+9))        /19 /NOAA_dcov_19year(k);
    HTF_noMSL_19year{1,j}(k)  = sum(HTF_noMSL{1,j}(k-9:k+9))  /19 /NOAA_dcov_19year(k);
    HTF_GRD_mu_19year{1,j}(k) = sum(HTF_GRD_mu{1,j}(k-9:k+9)) /19 /NOAA_dcov_19year(k);
    HTF_VLM_mu_19year{1,j}(k) = sum(HTF_VLM_mu{1,j}(k-9:k+9)) /19 /NOAA_dcov_19year(k);
    HTF_SDR_mu_19year{1,j}(k) = sum(HTF_SDR_mu{1,j}(k-9:k+9)) /19 /NOAA_dcov_19year(k);
  end
end


end
