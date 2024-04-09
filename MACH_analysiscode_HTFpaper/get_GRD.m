function [GRD,GRD_mu] ...
    =get_GRD(NOAA_ID,GRD_ID,GRD_t_year,NOAA_data_t,GRD_year,pn)
%% Title
% This function interpolate the yearly GRD data from Sönke to hourly data
% and adjust them to zero mean between 1950 to 1968. It also calcualte the
% percential of the 100 ensemble member for ploting purpose.
%
% INPUT:
%     NOAA_ID: NOAA gauge ID (single value)
%     GRD_ID: vector of NOAA gauge ID where GRD is provided
%     GRD_t_year: yearly time vector of GRD
%     NOAA_data_t: hourly time vector of GRD
%     GRD_year_1950_2020: yearly GRD data
%     np: percentile of rang at both sides of 50%.
%
% OUTPUT:
%     GRD: Hourly adjusted GRD data with zero mean for 1950-1968, all ensemble members.
%     GRD_lo,GRD_hi,GRD_mu: hourly adjusted GRD for percentiles of 50%-np,50%+np and 50%.
%
% VERSION: Qiang Sun, 2022.09.06
% VERSION, Qiang Sun, 2023.01.24, neglect calculating the GRD_lo and GRD_hi.

% matching the location
ind=find(GRD_ID==NOAA_ID);
if isempty(ind)
  disp(['GRD data cannot be found at NOAA ',num2str(NOAA_ID)]);
  keyboard;
end

% interpolate the annual Barystatic terms to hourly vertors
ind_1950=find(NOAA_data_t==datenum(1950,1,1,0,0,0));
ind_1968=find(NOAA_data_t==datenum(1968,12,31,23,0,0));
memo=nan(length(NOAA_data_t),size(squeeze(GRD_year(:,:,ind)),2));
GRD=memo;
for j=1:size(GRD,2)
  memo(:,j) = interp1(GRD_t_year,squeeze(GRD_year(:,j,ind)),NOAA_data_t,'spline');
  % adjested for zero mean between 1950 and 1968
  GRD(:,j)=memo(:,j)-mean(memo(ind_1950:ind_1968,j)); % zero-mean in control period
end

% processing GRD data for ploting. One sigma for error bar.
%GRD_lo=prctile(GRD,50-pn,2);
%GRD_hi=prctile(GRD,50+pn,2);
GRD_mu =mean(GRD,2);


end
