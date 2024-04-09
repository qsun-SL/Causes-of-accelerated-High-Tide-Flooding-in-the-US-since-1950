%% Title
% calcualte the nuisance floods time in year window for all NOAA gauge stations.
% the flooding days are broken down according to the MSL budgets.
%
% VERSION, Qiang Sun, 2022.09.08
% VERSION, Qiang Sun, 2022.11.17, sensitive tests with NOAA epoch (1950-1968) as control period.
% VERSION, Qiang Sun, 2023.01.10, using the control period (1950-1968), but with 100 members of 
%                                 ensemble of VLM. The gauges are also extended to AK and islands.
% VERSION, Qiang Sun, 2023.01.24, neglect calculating the *_lo and *_hi of GRD, VLM and SDR.
close all; clear; clc; tic

%% 1. set input data
% setup parameters
year_str=1950; % starting year of all data time series
year_end=2020;
pn=34; % percentile of 50%+-np for rangs in plots
ref_wl='STND';
rpath='/glade/work/qiangsun/TU_MATLAB/NASA_Nuisance_flooding/HTF_paper_final';
dpath=[rpath,'/NOAA_HTF_breakdown_20230110/HTF_data_20230110'];
ppath=[rpath,'/NOAA_HTF_breakdown_20230110/Graphic_output_20230110'];

%% load in the all NOAA gauge info
%load([rpath,'/NOAA_gauge_data_20230110/NOAA_station_info_20230110.mat'], ...
%     'NOAA_name','NOAA_id','NOAA_flag','NOAA_fth', ...
%     'NOAA_str','NOAA_end','NOAA_dcov_year');
%  memo_name=NOAA_name; 
%  memo_id=NOAA_id;
%  memo_fth=NOAA_fth;
%  clear NOAA_name NOAA_id NOAA_fth;
% load in the GRD data  
load([dpath,'/MBary_VLM/MBary_Soenke_20230120.mat'],'tA','NOAA_ID','MBary');
  GRD_year=MBary./1000; % mm -> m
  GRD_t_year=nan(size(tA));
  for i=1:length(tA)
    GRD_t_year(i) = ConvertSerialYearToDate( tA(i) );
  end
  GRD_ID=NOAA_ID;
  clear tA NOAA_ID MBary;
% load in the VLM data 
load([dpath,'/MBary_VLM/VLM_Soenke_20230120'],'MID','T','MDAsm');
  VLM_ID=MID;
  VLM_trend=T(:,1)./1000; % mm -> m
  VLM_sigma=T(:,3)./1000; % mm -> m
  VLM_nl_year=MDAsm; % non-linear VLM, already in m
  VLM_nl_t_year=GRD_t_year; % non-linear VLM is from 1899.5 to 2020.5
  clear MID T MDAsm;

disp('Loading data: done!');

  
%% 2. set the criteria for gauges, and loop through them
% criteria for gauge selections
% 1. the gauge has lat/lon.
% 2. the gauge has flood threshold either calculated based on Sweet et al.
%    (2018) or from Sweet et al. (2020).
% 3. the gauge starts/ends at least 10 years after/before the two 19-year 
%    periods.
% 4. the data coverage rate for 1950-1968 and 2002-2020 are greated than
%    50%.
%tot_gauge=0;
%mask_gauge=cell(size(memo_id));
%for i=1:length(memo_id)
%  mask_gauge{i}=zeros(size(memo_id{i}));
%  for j=1:length(memo_id{i})
%    if ~isempty(NOAA_dcov_year{i}{j})
%      yy_str=max(year(NOAA_dcov_year{i}{j}(1,1)),  year_str);
%      yy_end=min(year(NOAA_dcov_year{i}{j}(end,1)),year_end);
%      ind_str=find(year(NOAA_dcov_year{i}{j}(:,1))==yy_str);
%      ind_1968=find(year(NOAA_dcov_year{i}{j}(:,1))==1968); % end of 19-year in 1950-1968
%      ind_2002=find(year(NOAA_dcov_year{i}{j}(:,1))==2002); % start of 19-year in 2002-2020
%      ind_end=find(year(NOAA_dcov_year{i}{j}(:,1))==yy_end);
%      if NOAA_flag{i}(j,1)==1 && ...  % gauge has lat/lon
%         NOAA_flag{i}(j,2)>=2 && ...  % gauge has a flooding threhold
%         yy_str<=1959 && yy_end>=2011 && ... % at least start/end 10 years after/before the two 19-year periods
%         ( sum(NOAA_dcov_year{i}{j}(ind_str:ind_1968,2))/19>=0.5 && ... % data coverage >= 50% for 1950-1968
%           sum(NOAA_dcov_year{i}{j}(ind_2002:ind_end,2))/19>=0.5 )      % data coverage >= 50% for 2002-2020
%        tot_gauge=tot_gauge+1;
%        mask_gauge{i}(j)=1;
%      end
%      clear ind_* yy_*
%    end
%  end
%end
%
%% merge gauge data from multiple file into cells in categories, and 
%% calculate the MSL.
%NOAA_name   = cell(tot_gauge,1);
%NOAA_data   = NOAA_name;
%NOAA_MSL    = NOAA_name;
%NOAA_datum  = NOAA_name;
%NOAA_dcov_19year = NOAA_name;
%NOAA_dcov_10year = NOAA_name;
%NOAA_MSL_19year  = NOAA_name;
%
%NOAA_ID        = nan(tot_gauge,1);
%NOAA_lat       = NOAA_ID;
%NOAA_lon       = NOAA_ID;
%MMSL_1950_1968 = NOAA_ID;
%NOAA_fth       = NOAA_ID;
%% NOTE: I find that the lon/lat are different on the NOAA Tide Predictions web pages downloaded 
%% on 2020.09.06 and on 2023.01.10. To make a fair comparison, I use the lon/lat of previous
%% analysis data.
%prv=load(['/glade/work/qiangsun/TU_MATLAB/NASA_Nuisance_flooding/HTF_paper_final/NOAA_HTF_breakdown_20221117', ...
%          '/HTF_data_20220906/NOAA_wl_4analysis_20220906.mat'],'NOAA_ID','NOAA_lon','NOAA_lat');
%n=0;
%
%for i=1:length(memo_id)  
%  for j=1:size(memo_id{i},1)
%    if mask_gauge{i}(j)==1
%      n=n+1;
%      memo=memo_name{i}{j};  memo=strrep(memo,', ','+');  memo=strrep(memo,' ','+');
%      load([rpath,'/NOAA_gauge_data_20230110/', ...
%            num2str(memo_id{i}(j)),'_',memo,'_',num2str(year(NOAA_str{i}(j))),'-',num2str(year(NOAA_end{i}(j))),'_',ref_wl,'_hourly.mat'], ...
%            't_hour','data','lat','lon','datum');
%      clear memo;
%
%      % assign data general info
%      NOAA_name{n}=memo_name{i}{j};
%      NOAA_ID(n)=memo_id{i}(j);
%      NOAA_lat(n)=lat;
%      NOAA_lon(n)=lon;
%      NOAA_datum{n}=datum;
%      NOAA_fth(n)=memo_fth{i}(j,:);
%      % check agreement of lon/lat with previous analysis data. If different, replace with previous lon/lat
%      ind_id=find(prv.NOAA_ID==NOAA_ID(n));
%      if ~isempty(ind_id)
%        if NOAA_lon(n)~=prv.NOAA_lon(ind_id) || NOAA_lat(n)~=prv.NOAA_lat(ind_id)
%          NOAA_lon(n)=prv.NOAA_lon(ind_id);
%          NOAA_lat(n)=prv.NOAA_lat(ind_id);
%        end
%      end
%              
%      % creat time vector of hourly data
%      if ~exist('NOAA_t_hour','var')
%        th=0;
%        td=0;
%        ty=0;
%        for yr=year_str:year_end
%          ty=ty+1;
%          NOAA_t_year(ty,1)=datenum(yr,1,1,0,0,0);
%          for mn=1:12
%            if mn==1; dd_end=31;
%            elseif mn==2 && mod(yr,4)==0
%              if mod(yr,100)==0 && mod(yr,400)~=0; dd_end=28;
%              else;  dd_end=29;
%              end
%            elseif mn==2 && mod(yr,4)~=0; dd_end=28;
%            elseif mn==3; dd_end=31;
%            elseif mn==4; dd_end=30;
%            elseif mn==5; dd_end=31;
%            elseif mn==6; dd_end=30;
%            elseif mn==7; dd_end=31;
%            elseif mn==8; dd_end=31;
%            elseif mn==9; dd_end=30;
%            elseif mn==10; dd_end=31;
%            elseif mn==11; dd_end=30;
%            elseif mn==12; dd_end=31;
%            end
%            for dd=1:dd_end
%              td=td+1;
%              NOAA_t_day(td,1)=datenum(yr,mn,dd,0,0,0);
%              for hh=0:23
%                th=th+1;
%                NOAA_t_hour(th,1)=datenum(yr,mn,dd,hh,0,0);
%              end
%            end
%            clear dd_end;
%          end
%        end
%      end
%      clear ty td th;
%
%      % assign hourly data for time vector 1950-2020
%      yy_str=max(year(NOAA_dcov_year{i}{j}(1,1)),  year_str);
%      yy_end=min(year(NOAA_dcov_year{i}{j}(end,1)),year_end);
%      NOAA_data{n}=nan(size(NOAA_t_hour));
%      if yy_str==year_str && yy_end==year_end    % data record longer than or same as NOAA_t_hour
%        ind_str=find(t_hour==NOAA_t_hour(1)  );
%        ind_end=find(t_hour==NOAA_t_hour(end));
%        NOAA_data{n}=data(ind_str:ind_end);
%      elseif yy_str>year_str && yy_end<year_end  % data record shorter at both start and end
%        ind_str=find(NOAA_t_hour==t_hour(1)  );
%        ind_end=find(NOAA_t_hour==t_hour(end));
%        NOAA_data{n}(ind_str:ind_end)=data;
%      elseif yy_str>year_str && yy_end==year_end % data record shorter at start
%        ind_str=find(NOAA_t_hour==t_hour(1)  );
%        ind_end=find(t_hour==NOAA_t_hour(end));
%        NOAA_data{n}(ind_str:end)=data(1:ind_end);
%      elseif yy_str==year_str && yy_end<year_end % data record shorter at end
%        ind_str=find(t_hour==NOAA_t_hour(1)  );
%        ind_end=find(NOAA_t_hour==t_hour(end));
%        NOAA_data{n}(1:ind_end)=data(ind_str:end);
%      end
%      clear ind_str ind_end;
%
%      % get 30-day smoothed MSL, and MMSL for 1950-1968
%      indin=find(~isnan(NOAA_data{n}));
%      datain=NOAA_data{n}(indin);
%      memoin=smooth(datain,30*24,'lowess');
%      NOAA_MSL{n}=nan(size(NOAA_data{n}));
%      NOAA_MSL{n}(indin)=memoin;
%      clear indin memoin datain;
%      ind_1950=find(NOAA_t_hour==datenum(1950, 1, 1, 0,0,0));
%      ind_1968=find(NOAA_t_hour==datenum(1968,12,31,23,0,0));
%      MMSL_1950_1968(n)=mean(NOAA_MSL{n}(ind_1950:ind_1968),'omitnan');
%      clear ind_1950 ind_1968;
%
%      % assign the 19-year data coverage at center of every 19-year period.
%      % e.g. 1959 for the priod of 1950-1968.
%      NOAA_dcov_19year{n}=nan(size(NOAA_t_year)); % [mean of 19-year date coverage]
%      ind_str=find(year(NOAA_dcov_year{i}{j}(:,1))==yy_str);
%      ind_end=find(year(NOAA_dcov_year{i}{j}(:,1))==yy_end);      
%      for k=10:length(NOAA_t_year)-9
%        if k==10
%          ind_1=ind_str;
%          ind_2=find(year(NOAA_dcov_year{i}{j}(:,1))==1968);
%        elseif k==length(NOAA_t_year)-9
%          ind_1=find(year(NOAA_dcov_year{i}{j}(:,1))==2002);
%          ind_2=ind_end;            
%        else
%          ind_1=find(NOAA_dcov_year{i}{j}(:,1)==NOAA_t_year(k-9));          
%          ind_2=find(NOAA_dcov_year{i}{j}(:,1)==NOAA_t_year(k+9));
%          if isempty(ind_1); ind_1=ind_str; end % for the data starts later than 1950
%          if isempty(ind_2); ind_2=ind_end; end % for the data ends earlier than 2020
%        end
%        NOAA_dcov_19year{n}(k)=sum(NOAA_dcov_year{i}{j}(ind_1:ind_2,2))/19;
%        clear ind_1 ind_2;
%      end
%      clear ind_str ind_end;
%
%      % assign the decadal data coverage at center of every 10-year period.
%      % e.g. 1955 for the priod of 1950-1959.
%      NOAA_dcov_10year{n}=nan(size(NOAA_t_year)); % [mean of 19-year date coverage]
%      ind_str=find(year(NOAA_dcov_year{i}{j}(:,1))==yy_str);
%      ind_end=find(year(NOAA_dcov_year{i}{j}(:,1))==yy_end);
%      for k=6:length(NOAA_t_year)-4
%        if k==6
%          ind_1=ind_str;
%          ind_2=find(year(NOAA_dcov_year{i}{j}(:,1))==1959);
%        elseif k==length(NOAA_t_year)-4
%          ind_1=find(year(NOAA_dcov_year{i}{j}(:,1))==2011);
%          ind_2=ind_end;
%        else
%          ind_1=find(NOAA_dcov_year{i}{j}(:,1)==NOAA_t_year(k-5));
%          ind_2=find(NOAA_dcov_year{i}{j}(:,1)==NOAA_t_year(k+4));
%          if isempty(ind_1); ind_1=ind_str; end % for the data starts later than 1950
%          if isempty(ind_2); ind_2=ind_end; end % for the data ends earlier than 2020
%        end
%        NOAA_dcov_10year{n}(k)=sum(NOAA_dcov_year{i}{j}(ind_1:ind_2,2))/10;
%        clear ind_1 ind_2;
%      end
%      clear ind_str ind_end;
%
%      % assign the 19-year MSL at center of every 19-year period.
%      NOAA_MSL_19year{n}=nan(size(NOAA_t_year)); % [mean of 19-year water levels]
%      for k=10:length(NOAA_t_year)-9
%        ind_1=find(NOAA_t_hour==NOAA_t_year(k-9));
%        ind_2=find(NOAA_t_hour==datenum(year(NOAA_t_year(k+9)),12,31,23,0,0));
%        NOAA_MSL_19year{n}(k)=mean(NOAA_data{n}(ind_1:ind_2),'omitnan');
%        clear ind_1 ind_2;
%      end
%      clear ind_str ind_end;
%
%    end
%  end
%end
%clear memo_* NOAA_dcov_year NOAA_str NOAA_end NOAA_flag
%save([dpath,'/NOAA_wl_4analysis_20230110.mat'],'NOAA_*','MMSL_*','year_*','-v7.3');
load([dpath,'/NOAA_wl_4analysis_20230110.mat']);
disp('Processing NOAA data: done!');
%keyboard

%% 3. loop through all selected gauges and calculate/save results individually
%3.1 setup common variables
% perpare for the non-linear VLM
mask_nl=zeros(size(NOAA_name));
for i=1:length(NOAA_name)
  if any(regexp(NOAA_name{i},', TX'))
    mask_nl(i)=1;
  end
end
% 3.2 loop trough all selected gauges, calculate and save RMSL and HTF budgets
tic
poolobj=parpool(24,'IdleTimeout',60)
parfor i=1:length(NOAA_ID)

  % prepare Gravity, Rotation and viscoelastic solid-Earth Deformation terms
  [GRD,GRD_mu] ...
    =get_GRD(NOAA_ID(i),GRD_ID,GRD_t_year,NOAA_t_hour,GRD_year,pn);

  [VLM_ptb]=get_variables_loaded([dpath,'/',num2str(NOAA_ID(i)),'_NOAA_HTF_20230110.mat'],1);
  % prepare vertical land motion terms
  [VLM,VLM_mu,VLM_ptb] ...
    =get_VLM(NOAA_ID(i),VLM_ID,NOAA_t_hour,VLM_trend,VLM_sigma,pn, ...
             mask_nl,VLM_nl_year,VLM_nl_t_year,NOAA_MSL{i},VLM_ptb);  
  % preparing the SteroDynamic and residual terms (for plotting only)
  [SDR,SDR_mu]=get_SDR(NOAA_t_hour,NOAA_MSL{i},MMSL_1950_1968(i),GRD,VLM,pn);
  % calculate the decadal trends of the RMSL and its components
  [MSL_trd_10year,GRD_trd_10year,VLM_trd_10year,SDR_trd_10year] ...
    =get_WL_trend(NOAA_MSL{i},MMSL_1950_1968(i),GRD,VLM,SDR,NOAA_t_hour);

  % get annual HTF days/hours
  [ HTF,HTF_noMSL, ...
    HTF_GRD,HTF_GRD_lo,HTF_GRD_hi,HTF_GRD_mu, ...
    HTF_VLM,HTF_VLM_lo,HTF_VLM_hi,HTF_VLM_mu, ...
    HTF_SDR,HTF_SDR_lo,HTF_SDR_hi,HTF_SDR_mu ] ...
    =get_HTF( NOAA_t_year, NOAA_t_day, NOAA_t_hour, ...
              NOAA_data{i}, NOAA_fth(i)+NOAA_datum{i}.MHHW, ...
              NOAA_MSL{i}, MMSL_1950_1968(i), ...
              GRD, VLM, SDR, pn );

  % calculate the 19-year averaged water levels of GRD, VLM and SDR, and HTF.
  [GRD_mu_19year,VLM_mu_19year,SDR_mu_19year,RMSL_19year, ...
   HTF_19year,HTF_noMSL_19year,HTF_GRD_mu_19year,HTF_VLM_mu_19year,HTF_SDR_mu_19year] ...
  =get_19year_mean(NOAA_t_hour,NOAA_t_year,GRD_mu,VLM_mu,SDR_mu,NOAA_MSL{i}, ...
                   HTF,HTF_noMSL,HTF_GRD_mu,HTF_VLM_mu,HTF_SDR_mu, ...
                   NOAA_dcov_19year{i});

  % save the output for each gauge
  get_variables_saved([dpath,'/',num2str(NOAA_ID(i)),'_NOAA_HTF_20230110.mat'],1,...
                       HTF,HTF_noMSL, ...
                       HTF_GRD,HTF_GRD_lo,HTF_GRD_hi,HTF_GRD_mu, ....
                       HTF_VLM,HTF_VLM_lo,HTF_VLM_hi,HTF_VLM_mu, ....
                       HTF_SDR,HTF_SDR_lo,HTF_SDR_hi,HTF_SDR_mu, ....
                       VLM_ptb, ...
                       GRD_mu_19year,VLM_mu_19year,SDR_mu_19year, ...
                       HTF_19year,HTF_noMSL_19year, ...
                       HTF_GRD_mu_19year,HTF_VLM_mu_19year,HTF_SDR_mu_19year, ...
                       MSL_trd_10year,GRD_trd_10year,VLM_trd_10year,SDR_trd_10year);

  disp(['Finished calculating NOAA name: ',NOAA_name{i}]);

end
delete(poolobj);clc;
toc


