function [NXD,NXH,XH_mask,XD_mask]=get_flood_annual(t_year,t_day,t_hour,data,fth)
%% Title
% This function calculate the exceedance days and total hours in annual 
% window for given threshold.
%
% INPUT:
%     t_year/t_day/t_hourt_hour: annual/daily/hourly time vector
%     data: observed hourly water levelsof Minor, Moderate and  flooding
%     fth: flood threshold 
%
% OUTPUT:
%     NXD: Numder of Exceedance Days of flood for t_year
%     NXH: Total exceedance hours for flood in t_year
%     XH_mask,XD_mask: mask of exceedance for t_hour and t_day
%
% example:
% [NXD,NXH,XH_mask,XD_mask]=get_flood_annual(t_year,t_day,t_hour,data,nuisance_wl)
%
% VERSION: Qiang Sun, 2022.09.06


%% 1. get mask of hourly and daily flood
XH_mask=zeros(size(t_hour));
XH_mask(data>fth)=1;

XD_mask=zeros(size(t_day));
% a flood is the day with one or more hourly WL exceeding the threhold
for i=1:length(t_day)
  ind=find(t_hour==t_day(i));
  memo=data(ind:ind+23);
  if any(memo>fth)
    XD_mask(i)=1;
  end
  clear memo ind;
end


%% 2. sum total flood hours and days in annual window
NXD=zeros(size(t_year,1),1);
NXH=NXD;
for i=1:length(t_year)
  ind1=find(t_hour==t_year(i));
  if i<length(t_year)
    ind2=find(t_hour==t_year(i+1))-1;
  else
    ind2=length(t_hour);
  end  
  NXH(i)=sum(XH_mask(ind1:ind2));
  clear ind*
  
  ind1=find(t_day==t_year(i));
  if i<length(t_year)
    ind2=find(t_day==t_year(i+1))-1;
  else
    ind2=length(t_day);
  end
  NXD(i)=sum(XD_mask(ind1:ind2));
  clear ind*
end


end