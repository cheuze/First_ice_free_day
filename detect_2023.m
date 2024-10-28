%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Detects the 2023-equivalent year for all SSP experiments
% Saves it in a structure Model - Ensemble - each experiment
% 2023 is the last year where the minimum daily SIA >= 3.39 E12
% If no value can be found, set to -1. See detect_2023_ifinhistorical.m then.
%
% For the subselection of models listed in Models_v1.xlsx that has
% Column 1: Models [string]
% Column 2: Ref, reference date for that model's format, as YYYYMMDD [int]
% Column 3: YearLength, number of days in a year for that model [int]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AA=readtable('C:\Users\xheuce\Dropbox\CMIP6\seaice\Models_v1.xlsx');
matref_2023=struct('Models',[],'Ensembles',[],'Index_ssp119',[],'Date_ssp119',[],'Value_ssp119',[],...
    'Index_ssp126',[],'Date_ssp126',[],'Value_ssp126',[],...
    'Index_ssp245',[],'Date_ssp245',[],'Value_ssp245',[],...
    'Index_ssp370',[],'Date_ssp370',[],'Value_ssp370',[],...
    'Index_ssp585',[],'Date_ssp585',[],'Value_ssp585',[]);
sspZ={'ssp119';'ssp126';'ssp245';'ssp370';'ssp585'};

cd('C:\Users\xheuce\Dropbox\CMIP6\seaice\csv_timeseries')

overcompt=1; %change only when done with a model
for imod=1:size(AA,1)
%Generate my time matrix, based on the model's format
%column 1 = year; column 2 = month; column 3 = day, column 4 = time index in the model format

comptmod=0;

if AA.YearLength(imod)==360
    mattime(1:85*360,4)=[(2015-floor(AA.Ref(imod)/10000))*360+1:(2100-floor(AA.Ref(imod)/10000))*360];
    stepY=repmat(2015:2099,[360 1]); mattime(1:85*360,1)=stepY(:);
    step1=repmat(1:12,[30 1]); step1=step1(:);
    mattime(1:85*360,2)=repmat(step1,[85 1]); clear step1 stepY
    mattime(1:85*360,3)=repmat(1:30,[1 85*12])';
elseif AA.YearLength(imod)==365
    %must shift by number of 29 Feb since their ref
    date1=datenum(floor(AA.Ref(imod)/10000),1,1);
    date2=datenum(2100,1,1);
    [YY,MM,DD]=datevec(date1:date2);
    posleap=find(MM==2 & DD==29);
    YY(posleap)=NaN; MM(posleap)=NaN; DD(posleap)=NaN; clear posleap date1 date2
    YY=YY(~isnan(YY)); MM=MM(~isnan(MM)); DD=DD(~isnan(DD)); nbdays=1:length(MM);
    pos2015=find(YY==2015,1,'first');
    mattime(:,1)=YY(pos2015:end);
    mattime(:,2)=MM(pos2015:end);
    mattime(:,3)=DD(pos2015:end);
    mattime(:,4)=nbdays(pos2015:end); clear YY MM pos2015 nbdays DD
else
    %use everything
    date1=datenum(floor(AA.Ref(imod)/10000),1,1);
    date2=datenum(2100,1,1);
    [YY,MM,DD]=datevec(date1:date2); nbdays=1:length(MM);
    pos2015=find(YY==2015,1,'first');
    mattime(:,1)=YY(pos2015:end);
    mattime(:,2)=MM(pos2015:end);
    mattime(:,3)=DD(pos2015:end);
    mattime(:,4)=nbdays(pos2015:end); clear YY MM DD pos2015 nbdays
end

%I need the list of unique ensemble members
    fileZ=dir([char(AA(imod,1).Models) '_*.csv']);
    for ifile=1:length(fileZ)
        k=strfind(fileZ(ifile).name,'_');        
        ens=string(fileZ(ifile).name(k(1)+1:k(2)-1)); clear k
        if ifile==1
            matref_2023(overcompt,1).Models=AA(imod,1).Models;
            matref_2023(overcompt,1).Ensembles=ens;
            comptmod=comptmod+1;
        else
            flag=0;
            for ifile2=overcompt:overcompt+comptmod-1
                flag=max(flag,strcmp(char(ens),char(matref_2023(ifile2,1).Ensembles)));
            end
            if flag==0
                matref_2023(overcompt+comptmod,1).Models=AA(imod,1).Models;
                matref_2023(overcompt+comptmod,1).Ensembles=ens;
                comptmod=comptmod+1;
            end
            clear flag
        end
    end
    clear fileZ

    %now, for each ensemble member, if data for that run
    for iens=1:comptmod
        for issp=1:length(sspZ)
            fileZ=dir([char(AA(imod,1).Models) '_' char(matref_2023(overcompt+iens-1,1).Ensembles) '_' sspZ{issp} '_*.csv']);
            if ~isempty(fileZ)
                T=readtable(fileZ(1).name); %Python and Matlab agree except for CNRM
                if ~isempty(find(~isnan(T.SIA) & ~isinf(T.SIA) & T.SIA<1E15))
                    minsia=zeros(85,2);
                    for iyr=2015:2099
                        posyr=find(mattime(:,1)==iyr);
                        posyr=posyr(posyr<=size(T,1));
                        if ~isempty(posyr)
                            junksic=T.SIA(posyr);
                            minsia(iyr-2014,1)=nanmin(T.SIA(posyr)); 
                            minsia(iyr-2014,2)=find(junksic==minsia(iyr-2014,1),1,'last')+posyr(1)-1;
                        end
                        clear posyr junksic 
                    end

                    pos2023=find(minsia(:,1)>=3.39E12,1,'last');         
                    if ~isempty(pos2023)
                    eval(sprintf('matref_2023(overcompt+iens-1,1).Index_%s=minsia(pos2023,2);',sspZ{issp}));
                    junk=mattime(minsia(pos2023,2),1);%*10000+mattime(minsia(pos2023,2),2)*100+mattime(minsia(pos2023,2),3);
                    eval(sprintf('matref_2023(overcompt+iens-1,1).Date_%s=junk;',sspZ{issp}));            
                    eval(sprintf('matref_2023(overcompt+iens-1,1).Value_%s=minsia(pos2023,1)/1E12;',sspZ{issp}));
                    else
                    eval(sprintf('matref_2023(overcompt+iens-1,1).Index_%s=-1;',sspZ{issp}));
                    eval(sprintf('matref_2023(overcompt+iens-1,1).Date_%s=-1;',sspZ{issp}));            
                    eval(sprintf('matref_2023(overcompt+iens-1,1).Value_%s=-1;',sspZ{issp}));    
                    end
                    clear pos2023 junk minsia
                end
            end

            clear fileZ
        end %issp
    end %iens

overcompt=overcompt+comptmod; clear mattime
end %imod

%optional saving - file used in detect_firsticefreemonth.m
writetable(struct2table(matref_2023),'SIA2023_all.xlsx')