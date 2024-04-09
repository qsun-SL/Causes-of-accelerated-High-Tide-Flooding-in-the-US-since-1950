function [MSL_trd_10year,GRD_trd_10year,VLM_trd_10year,SDR_trd_10year] ...
              =get_WL_trend(MSL,MMSL,GRD,VLM,SDR,t_hour)
%% Title
% calculate the linear trend of the RMSL and its components
%
% VERSION, Qiang Sun, 2023.03.14

year_10=[1956:10:2016]';
MSL_trd_10year=nan(size(year_10));
GRD_trd_10year=nan(size(year_10,1),size(GRD,2));
VLM_trd_10year=nan(size(year_10,1),size(VLM,2));
SDR_trd_10year=nan(size(year_10,1),size(SDR,2));
for i=1:length(year_10)
  ind1=find(t_hour==datenum(year_10(i)-5,1,1,0,0,0));
  ind2=find(t_hour==datenum(year_10(i)+4,12,31,23,0,0));

  x=t_hour(ind1:ind2);
  x=x(~isnan(MSL(ind1:ind2)));


  y=MSL(ind1:ind2)-MMSL;
  y=y(~isnan(MSL(ind1:ind2)));
  %MATLAB time has 1 for a day, so by *365.25 with hourly data respect to t_hour, we have annual trend
  p=polyfit(x,y,1)*365.25;
  MSL_trd_10year(i)=p(1); clear y p;

  for j=1:size(GRD,2)

    y=GRD(ind1:ind2,j);
    y=y(~isnan(MSL(ind1:ind2)));
    p=polyfit(x,y,1)*365.25;
    GRD_trd_10year(i,j)=p(1); clear y p;
  
    y=VLM(ind1:ind2,j);
    y=y(~isnan(MSL(ind1:ind2)));
    p=polyfit(x,y,1)*365.25;
    VLM_trd_10year(i,j)=p(1); clear y p;

  end

  for j=1:size(SDR,2)
    y=SDR(ind1:ind2,j);
    y=y(~isnan(MSL(ind1:ind2)));
    p=polyfit(x,y,1)*365.25;
    SDR_trd_10year(i,j)=p(1); clear y p;
  end

  clear x ind*;
end


end
