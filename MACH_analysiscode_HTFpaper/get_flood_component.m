function [NXD_GRD,NXH_GRD,NXD_VLM,NXH_VLM,NXD_SDR,NXH_SDR] ...
    = get_flood_component(tot_mask_H,tot_mask_D,noMSL_mask_H,noMSL_mask_D, ...
                          MSL_H,GRD_H,VLM_H,SDR_H,t_Y,t_D,t_H,NOAA_HTF,NOAA_HTF_noMSL)
%% Title
% Calculate the HTF hours and days for individual sea-level rise components
%
% INPUT:
%     tot_mask_H, tot_mask_D:   masks of days/hours when total WL higher than thresholds for minor/moderate/major flooding
%     noMSL_mask_H, noMSL_mask_D: masks of days/hours when MSL removed WL higher than thresholds for minor/moderate/major flooding
%     MSL_H,GRD_H,VLM_H, SDR_H: hourly WL for MSL, GRD, VLM and SDR with the mean removed for reference period
%     t_H,t_Y: hourly/yearly MATLAB time
%     NOAA_HTF, NOAA_HTF_noMSL: HTF days and hours for total and control WL
%
% OUTPUT:
%     NXD_GRD, NXH_GRD: annual HTF days/hours for GRD
%     NXD_VLM, NXH_VLM: annual HTF days/hours for VLM
%     NXD_SDR, NXH_SDR: annual HTF days/hours for SteroDynamic + Residual
%
% VERSION, Qiang Sun, 2022.09.06


%% 1. go through the hourly masks and calcualte the percentages in case of
% total water level flooding, but not in the control water level
% or the flooding in control , but not in total.
prc_GRD_H=zeros(size(tot_mask_H));
prc_VLM_H=prc_GRD_H;
prc_SDR_H=prc_GRD_H;
for i=1:length(tot_mask_H)
  if tot_mask_H(i)==1 && noMSL_mask_H(i)==0 % HTF_RMSL_mask=tot_mask_H-noMSL_mask_H=1
    prc_GRD_H(i)=GRD_H(i)/MSL_H(i);
    prc_VLM_H(i)=VLM_H(i)/MSL_H(i);
    prc_SDR_H(i)=SDR_H(i)/MSL_H(i);
  elseif tot_mask_H(i)==0 && noMSL_mask_H(i)==1 % HTF_RMSL_mask=tot_mask_H-noMSL_mask_H=-1
    % in this case, we need to remove it from the total budget calculation 
    prc_GRD_H(i)= -( GRD_H(i)/MSL_H(i) );
    prc_VLM_H(i)= -( VLM_H(i)/MSL_H(i) );
    prc_SDR_H(i)= -( SDR_H(i)/MSL_H(i) );
  end
  % check hourly water level budgets
  if ( (tot_mask_H(i)==1 && noMSL_mask_H(i)==0) || ...
       (tot_mask_H(i)==0 && noMSL_mask_H(i)==1) ) && ...
     1-abs(prc_GRD_H(i)+prc_VLM_H(i)+prc_SDR_H(i))>1e10
    disp('Hourly RMSL buget is not closed!')
    keyboard
  end
end


%% 2. go through the daily mask and calculate the daily mean of percentages
% get the daily mean percentages
prc_GRD_D=zeros(size(tot_mask_D));
prc_VLM_D=prc_GRD_D;
prc_SDR_D=prc_GRD_D;
for i=1:length(tot_mask_D)
  if ( tot_mask_D(i)==1 && noMSL_mask_D(i)==0 ) || ...
     ( tot_mask_D(i)==0 && noMSL_mask_D(i)==1 )
    ind=find(t_H==t_D(i));
    if ( nnz(prc_GRD_H(ind:ind+23))~=nnz(prc_SDR_H(ind:ind+23)) ) || ...
       ( nnz(prc_GRD_H(ind:ind+23))~=nnz(prc_VLM_H(ind:ind+23)) )
      disp('The number of non-zero hours of flood is not equal for three components');
    end
    prc_GRD_D(i)=sum(prc_GRD_H(ind:ind+23))/nnz(prc_GRD_H(ind:ind+23));
    prc_VLM_D(i)=sum(prc_VLM_H(ind:ind+23))/nnz(prc_VLM_H(ind:ind+23));
    prc_SDR_D(i)=sum(prc_SDR_H(ind:ind+23))/nnz(prc_SDR_H(ind:ind+23));
  end
  % check daily water level budgets
  if ( ( tot_mask_D(i)==1 && noMSL_mask_D(i)==0 ) || ...
       ( tot_mask_D(i)==0 && noMSL_mask_D(i)==1 ) ) && ...
      1-abs(prc_GRD_D(i)+prc_VLM_D(i)+prc_SDR_D(i))>1e-10
    disp('Daily RMSL buget is not closed!')
    keyboard
  end
end


%% 3. get the annual sum of flood hours and days
NXD_GRD=zeros(size(t_Y));
NXH_GRD=NXD_GRD;
NXD_VLM=NXD_GRD;
NXH_VLM=NXD_GRD;
NXD_SDR=NXD_GRD;
NXH_SDR=NXD_GRD;
for i=1:length(t_Y)
% annual HFT hours
  ind_str=find(t_H==t_Y(i));
  if i<length(t_Y)
    ind_end=find(t_H==t_Y(i+1))-1;
  else
    ind_end=length(t_H);
  end
  NXH_GRD(i)=sum(prc_GRD_H(ind_str:ind_end));
  NXH_VLM(i)=sum(prc_VLM_H(ind_str:ind_end));
  NXH_SDR(i)=sum(prc_SDR_H(ind_str:ind_end));
  clear ind*
% annual HFT days  
  ind_str=find(t_D==t_Y(i));
  if i<length(t_Y)
    ind_end=find(t_D==t_Y(i+1))-1;
  else
    ind_end=length(t_D);
  end
  NXD_GRD(i)=sum(prc_GRD_D(ind_str:ind_end));
  NXD_VLM(i)=sum(prc_VLM_D(ind_str:ind_end));
  NXD_SDR(i)=sum(prc_SDR_D(ind_str:ind_end));
  clear ind
end


%% 4. check the closing of HTF days/hours
% check the closing of flooding days
rsd_D=NOAA_HTF{1}-NOAA_HTF_noMSL{1}-(NXD_GRD+NXD_VLM+NXD_SDR);
rsd_H=NOAA_HTF{2}-NOAA_HTF_noMSL{2}-(NXH_GRD+NXH_VLM+NXH_SDR);
if any(abs(rsd_D(:))>1e-10) || any(abs(rsd_H(:))>1e-10)
  disp(['HFT budgets don''t close: max(|rsd_D|)=',num2str(max(abs(rsd_D(:)))), ...
                                '; max(|rsd_H|)=',num2str(max(abs(rsd_H(:))))]);
  keyboard;
end


end