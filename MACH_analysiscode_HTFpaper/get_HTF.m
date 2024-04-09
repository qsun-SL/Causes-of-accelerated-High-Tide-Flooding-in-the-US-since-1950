function [HTF,HTF_noMSL, ...
          HTF_GRD,HTF_GRD_lo,HTF_GRD_hi,HTF_GRD_mu, ...
          HTF_VLM,HTF_VLM_lo,HTF_VLM_hi,HTF_VLM_mu, ...
          HTF_SDR,HTF_SDR_lo,HTF_SDR_hi,HTF_SDR_mu ] ...
    =get_HTF(t_year,t_day,t_hour,NOAA_wl,NOAA_fth,MSL,MMSL,GRD,VLM,SDR,pn)
%% Title
% This function calculate the annual sum of high tide flooding days/hours
% for the raw water level, as well the MSL removed and individual component
% of the SL rise.
%
% INPUT:
%     t_year/t_day/t_hourt_hour: annual/daily/hourly time vector
%     NOAA_wl: hourly NOAA water level (raw data)
%     NOAA_fth: NOAA flooding threshold values for minor, media, and major
%     MSL: hourly mean sea level series
%     MMSL: mean of MSL for period of 1950-1968
%     GRD: Hourly adjusted GRD data with zero mean for 1950-1968
%     VLM: Hourly adjusted VLM data with zero mean for 1950-1968
%     np: percentile of rang at both sides of 50%.
%
% OUTPUT:
%     HTF: annual high tide flooding days/hours for raw water level
%     HTF_noMSL: MSL removed HTF days/hours;
%     HTF_GRD_lo,HTF_GRD_hi,HTF_GRD_mu: HTF due to GRD of 50%-np,50%+np and mean
%     HTF_VLM_lo,HTF_VLM_hi,HTF_VLM_mu: HTF due to VLM of 50%-np,50%+np and mean
%     HTF_SDR_lo,HTF_SDR_hi,HTF_SDR_mu: HTF due to SDR of 50%-np,50%+np and mean
%     HTF_GRD,HTF_VLM,HTF_SDR: HTF due to GRD, VLM, and SDR of all ensemble members
%
% VERSION: Qiang Sun, 2022.09.06

%% 1. get the HTF days/hours
HTF       = cell(1,2); %[annual HTF days, annual HTF hours]
HTF_noMSL = HTF;
% calculate annual flood days/hours of raw WL, for minor, moderate and major (mmm)
[HTF{1,1},HTF{1,2},HTF_mask_hour,HTF_mask_day] ...
   =get_flood_annual(t_year,t_day,t_hour,NOAA_wl,NOAA_fth);
% calculate annual flood days/hours for control (MSL removed) WL, for minor, moderate and major (mmm)
[HTF_noMSL{1,1},HTF_noMSL{1,2},HTF_noMSL_mask_hour,HTF_noMSL_mask_day] ...
   =get_flood_annual(t_year,t_day,t_hour, NOAA_wl-(MSL-MMSL), NOAA_fth);
% calculate the HTF hours/days based on the WL budgets.
HTF_GRD=cell(size(HTF));
HTF_VLM=HTF_GRD;
HTF_SDR=HTF_GRD;
HTF_GRD{1,1}=zeros( length(t_year), size(SDR,2) );
HTF_GRD{1,2}=HTF_GRD{1,1};
HTF_VLM{1,1}=HTF_GRD{1,1};
HTF_VLM{1,2}=HTF_GRD{1,1};
HTF_SDR{1,1}=HTF_GRD{1,1};
HTF_SDR{1,2}=HTF_GRD{1,1};
n=0;
for j=1:size(GRD,2)
  for k=1:size(VLM,2)
    n=n+1;
    [ HTF_GRD{1,1}(:,n),HTF_GRD{1,2}(:,n), ...
      HTF_VLM{1,1}(:,n),HTF_VLM{1,2}(:,n), ...
      HTF_SDR{1,1}(:,n),HTF_SDR{1,2}(:,n) ] ...
     = get_flood_component( HTF_mask_hour, HTF_mask_day, ...
                            HTF_noMSL_mask_hour, HTF_noMSL_mask_day, ...
                            MSL-MMSL, ...
                            GRD(:,j), VLM(:,k), SDR(:,n), ...
                            t_year, t_day, t_hour, ...
                            HTF, HTF_noMSL );
  end
end


%% 2. processing the HTF days/hours for errorbar ploting
HTF_GRD_lo = cell(size(HTF));
HTF_GRD_hi = HTF_GRD_lo;
HTF_GRD_mu = HTF_GRD_lo;
    
HTF_VLM_lo = HTF_GRD_lo;
HTF_VLM_hi = HTF_GRD_lo;
HTF_VLM_mu = HTF_GRD_lo;
    
HTF_SDR_lo = HTF_GRD_lo;
HTF_SDR_hi = HTF_GRD_lo;
HTF_SDR_mu = HTF_GRD_lo;

for j=1:size(HTF,2)
  HTF_GRD_lo{1,j}=prctile(HTF_GRD{1,j},50-pn,2);
  HTF_GRD_hi{1,j}=prctile(HTF_GRD{1,j},50+pn,2);
  HTF_GRD_mu{1,j}=mean(HTF_GRD{1,j},2);

  HTF_VLM_lo{1,j}=prctile(HTF_VLM{1,j},50-pn,2);
  HTF_VLM_hi{1,j}=prctile(HTF_VLM{1,j},50+pn,2);
  HTF_VLM_mu{1,j}=mean(HTF_VLM{1,j},2);

  HTF_SDR_lo{1,j}=prctile(HTF_SDR{1,j},50-pn,2);
  HTF_SDR_hi{1,j}=prctile(HTF_SDR{1,j},50+pn,2);
  HTF_SDR_mu{1,j}=mean(HTF_SDR{1,j},2);
end

  
end
