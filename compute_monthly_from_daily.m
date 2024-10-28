%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Compute monthly timeseries from daily csv
% Saves them as csvs
% For the subselection of models listed in Models_v1.xlsx that has
% Column 1: Models [string]
% Column 2: Ref, reference date for that model's format, as YYYYMMDD [int]
% Column 3: YearLength, number of days in a year for that model [int]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

AA=readtable('Models_v1.xlsx');
sspZ={'ssp119';'ssp126';'ssp245';'ssp370';'ssp585'};


for imod=1:size(AA,1)
%Generate my time matrix, based on the model's format
%column 1 = year; column 2 = month; column 3 = time index in the model format

if AA.YearLength(imod)==360
    mattime(1:85*360,3)=[(2015-floor(AA.Ref(imod)/10000))*360+1:(2100-floor(AA.Ref(imod)/10000))*360];
    stepY=repmat(2015:2099,[360 1]); mattime(1:85*360,1)=stepY(:);
    step1=repmat(1:12,[30 1]); step1=step1(:);
    mattime(1:85*360,2)=repmat(step1,[85 1]); clear step1 stepY
elseif AA.YearLength(imod)==365
    %must shift by number of 29 Feb since their ref
    date1=datenum(floor(AA.Ref(imod)/10000),1,1);
    date2=datenum(2100,1,1);
    [YY,MM,DD]=datevec(date1:date2);
    posleap=find(MM==2 & DD==29);
    YY(posleap)=NaN; MM(posleap)=NaN; clear DD posleap date1 date2
    YY=YY(~isnan(YY)); MM=MM(~isnan(MM)); nbdays=1:length(MM);
    pos2015=find(YY==2015,1,'first');
    mattime(:,1)=YY(pos2015:end);
    mattime(:,2)=MM(pos2015:end);
    mattime(:,3)=nbdays(pos2015:end); clear YY MM pos2015 nbdays
else
    %use everything
    date1=datenum(floor(AA.Ref(imod)/10000),1,1);
    date2=datenum(2100,1,1);
    [YY,MM,~]=datevec(date1:date2); nbdays=1:length(MM);
    pos2015=find(YY==2015,1,'first');
    mattime(:,1)=YY(pos2015:end);
    mattime(:,2)=MM(pos2015:end);
    mattime(:,3)=nbdays(pos2015:end); clear YY MM pos2015 nbdays
end

for issp=1:length(sspZ)    
    fileZ=dir([char(AA(imod,1).Models) '_*_' sspZ{issp} '_*.csv']);
    if ~isempty(fileZ)
        for ifile=1:length(fileZ)
             k=strfind(fileZ(ifile).name,'_');        
             ens=string(fileZ(ifile).name(k(1)+1:k(2)-1)); clear k        
             if ~isfile([char(AA(imod,1).Models) '_' char(ens) '_' sspZ{issp} '_monthly.csv'])
                T=readtable(fileZ(ifile).name);
                SIA_mon=NaN(85*12,1);
                SIE_mon=SIA_mon; compt=1;
                Time_mon=SIA_mon;
                    for iyr=2015:2099
                        for imth=1:12
                            Time_mon(compt,1)=100*iyr+imth;
                            posmth=find(mattime(:,1)==iyr & mattime(:,2)==imth);
                            posmod=NaN(length(posmth));
                            for iputain=1:length(posmth)
                                if ~isempty(find(round(T.Time)==mattime(posmth(iputain),3)))
                            posmod(iputain)=find(round(T.Time)==mattime(posmth(iputain),3),1,'first');
                                end
                            end
                            posmod=posmod(~isnan(posmod));
                            if ~isempty(posmod)
                                SIA_mon(compt,1)=nanmean(T.SIA(posmod));
                                SIE_mon(compt,1)=nanmean(T.SIE(posmod));
                            end
                            compt=compt+1;
                            clear posmth posmod iputain
                        end %imth
                    end %iyr

T_mon=table(Time_mon,SIA_mon,SIE_mon);
writetable(T_mon,[char(AA(imod,1).Models) '_' char(ens) '_' sspZ{issp} '_monthly.csv']);
clear *_mon T 
             end %if not already converted
clear ens
        end %for each file
    end %if there are files
    clear fileZ
end %issp
clear mattime
end %imod
