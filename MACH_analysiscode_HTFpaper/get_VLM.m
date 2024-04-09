function [VLM,VLM_mu,VLM_ptb] ...
    =get_VLM(NOAA_ID,VLM_ID,NOAA_t_hour,VLM_trend,VLM_sigma,pn, ...
             mask_nl,VLM_nl_year,VLM_nl_t_year,NOAA_MSL,varargin)
%% Title
% This function interpolate the trend of VLM from Sönke to hourly data
% and adjust them to zero mean between 1950 to 1968. It also perturb the
% trend 100 times with normal random values.
%
% INPUT:
%     NOAA_ID: NOAA gauge ID (single value)
%     VLM_ID: vector of NOAA gauge ID where VLM is provided
%     NOAA_t_hour: hourly time vector of NOAA water level data
%     VLM_trend: linear VLM trend (single value)
%     VLM_sigma: deviation of VLM trend
%     np: percentile of rang at both sides of 50%.
%     mask_nl: mask of site with non-linear VLM
%     VLM_nl_year: time-series of non-linear VLM
%     VLM_nl_t_year: time vector of non-linear VLM
%     NOAA_MSL: MSL of the site, use to trim hourly non-linear VLM
%
% OUTPUT:
%     VLM: Hourly adjusted VLM data with zero mean for 1950-1968, all ensemble members.
%     VLM_lo,VLM_hi,VLM_mu: hourly adjusted VLM for percentiles of 50%-np,50%+np and 50%.
%
% VERSION: Qiang Sun, 2022.09.06
% VERSION, Qiang Sun, 2023.01.20, increase ensembles from 10 to 100.
% VERSION, Qiang Sun, 2023.01.24, neglect calculating the VLM_lo and VLM_hi.
%                                 add varargin so the function either creat a VLM_ptb or read previous used one.

% matching the location
ind=find(VLM_ID==NOAA_ID);
if isempty(ind)
  disp(['VLM data cannot be found at NOAA ',num2str(NOAA_ID)]);
  keyboard;
end

% perturb and interpolate the VLM trend term to hourly values
ind_1950=find(NOAA_t_hour==datenum(1950, 1, 1, 0,0,0));
ind_1968=find(NOAA_t_hour==datenum(1968,12,31,23,0,0));
ind_MSL_str=find(~isnan(NOAA_MSL),1,'first');
ind_MSL_end=find(~isnan(NOAA_MSL),1,'last');

if mask_nl(ind)==0 % with linear trend of VLM

  memo=nan(length(NOAA_t_hour),100);
  VLM=memo;
  % either creat random normal VLM_ptb, or read it in from previous analysis
  if isnan(varargin{1})
    VLM_ptb=normrnd(VLM_trend(ind),VLM_sigma(ind),[100,1]);
  else
    VLM_ptb=varargin{1};
  end
  for j=1:size(VLM,2)
    memo(:,j) = VLM_ptb(j)/(24*365.25).*linspace(1,length(NOAA_t_hour),length(NOAA_t_hour))';
    % adjested for zero mean between 1950 and 1968 
    VLM(:,j)=memo(:,j)-mean(memo(ind_1950:ind_1968,j)); % zero-mean in control period
  end

elseif mask_nl(ind)==1  % with non-linear trend of VLM

  % interpolate the annual non-inear VLM to hourly VLM
  memo=nan(length(NOAA_t_hour),100);
  VLM=memo;
  % either creat random normal VLM_ptb, or read it in from previous analysis
  if isnan(varargin{1})
    VLM_ptb=normrnd(VLM_trend(ind),VLM_sigma(ind),[100,1]); % 100 ensembles of VLM is based on linear trends
  else
    VLM_ptb=varargin{1};
  end
  VLM_trend_0=VLM_trend(ind).*linspace(1,length(VLM_nl_t_year),length(VLM_nl_t_year))'; % original annual trend
  for j=1:size(VLM,2)
    VLM_trend_1=VLM_ptb(j).*linspace(1,length(VLM_nl_t_year),length(VLM_nl_t_year))'; % each ensemble of annual trend
    memo(:,j) = interp1(VLM_nl_t_year, VLM_nl_year(:,ind)-VLM_trend_0+VLM_trend_1, ...
                        NOAA_t_hour,'spline');
    % adjested for zero mean between 1950 and 1968 
    memo0=memo(:,j)-mean(memo(ind_1950:ind_1968,j)); % zero-mean in control period
    VLM(ind_MSL_str:ind_MSL_end,j)=memo0(ind_MSL_str:ind_MSL_end);
    clear memo0;
  end
  clear memo ind_*;
 
end

% processing VLM data for ploting
%VLM_lo=prctile(VLM,50-pn,2);
%VLM_hi=prctile(VLM,50+pn,2);
VLM_mu =mean(VLM,2);

  
end
