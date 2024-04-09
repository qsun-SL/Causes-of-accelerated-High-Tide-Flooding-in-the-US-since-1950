function [SDR,SDR_mu]=get_SDR(NOAA_t_hour,MSL,MMSL,GRD,VLM,pn)
%% Title
% This function claculate the SDR from the MSL, RGD and VLM for all their 
% ensemble members, and get it percentiles values for plotting.
%
% INPUT:
%     NOAA_t_hour: hourly time vector of NOAA water level data
%     MSL: hourly mean sea level series
%     MMSL: mean of MSL for period of 1950-1968
%     GRD_t_hour: hourly time vector of GRD
%     GRD: hourly adjusted RGD data
%     VLM: hourly adjusted VLM data
%     np: percentile of rang at both sides of 50%.
%
% OUTPUT:
%     SDR_lo,SDR_hi,SDR_mu: hourly adjusted SDR for percentiles of 50%-np,50%+np and 50%.
%     SDR: hourly SDR get from the adjusted VLM and GRD, all ensemble members.
%
% VERSION: Qiang Sun, 2022.09.06
% VERSION, Qiang Sun, 2023.01.24, neglect calculating the SDR_lo and SDR_hi.

% creat a hourly ensemble member of SDR
SDR=nan( length(NOAA_t_hour), size(GRD,2)*size(VLM,2) );
n=0; 
for j=1:size(GRD,2)
  for k=1:size(VLM,2)
    n=n+1;
    SDR(:,n)=MSL-MMSL-GRD(:,j)-VLM(:,k);
  end
end
clear n;
SDR_mu=mean(SDR,2,'omitnan');

%% processing SDR data for ploting
%% the array of SDR is too large to calculate the mean as a whole. So we cut
%% it into pieces with time vectors of 10,000 hours.
%%SDR_lo=nan(size(SDR,1),1);
%%SDR_hi=SDR_lo;
%SDR_mu=SDR_lo;
%keyboard
%n=[0:1e4:length(NOAA_t_hour)]';
%for i=1:length(n)-1
%  a=n(i)+1; b=n(i+1);
%  SDR_lo(a:b)=prctile(squeeze(SDR(a:b,:)),50-pn,2);
%  SDR_hi(a:b)=prctile(squeeze(SDR(a:b,:)),50+pn,2);
%  SDR_mu(a:b)=mean(squeeze(SDR(a:b,:)),2,'omitnan');  
%end
%if n(end)<length(NOAA_t_hour)
%  a=n(end)+1; b=length(NOAA_t_hour);
%  SDR_lo(a:b)=prctile(squeeze(SDR(a:b,:)),50-pn,2);
%  SDR_hi(a:b)=prctile(squeeze(SDR(a:b,:)),50+pn,2);
%  SDR_mu(a:b)=mean(squeeze(SDR(a:b,:)),2,'omitnan');  
%end

end
