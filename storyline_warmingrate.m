%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Warming rate compared to pre-industrial for the quick transition simulations
% Uses ChosenOnes.xlsx, which summarises the main characteristics of these
% simulations:
% Column 1: Model [string]
% Column 2: Ensemble [string]
% Column 3: Experiment, as per the netcdf file names, e.g. ssp119 [string]
% Column 4: Year2023, as YYYY [int]
% Column 5: YearFree, i.e. year with first ice free day, as YYYY [int]
% Column 6: YearLength, in number of days [int]
% Column 7: DayFree, i.e. day of year of first ice free day [int]
%
% Warming rate is global, area-weighted
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% step 1: 50-year mean daily tas in piC

modelZ={'ACCESS-CM2';'CanESM5';'EC-Earth3';'MPI-ESM1-2-LR'};
yearlengthZ=[365.2422;365;365.2422;365.2422];

for imod=1:length(modelZ)
    fileA=dir(['areacella_*' modelZ{imod} '_*.nc']);
    areaZ=ncread(fileA(1).name,'areacella');
    clear fileA

    fileZ=dir(['tas_*' modelZ{imod} '_*.nc']); globtemp=[];
    for ifile=1:length(fileZ)
        tas=ncread(fileZ(ifile).name,'tas');

        tas=reshape(tas,[size(tas,1)*size(tas,2) size(tas,3)]);
        jarea=repmat(areaZ(:),[1 size(tas,3)]);

        globtemp=[globtemp nansum(tas.*jarea./nansum(areaZ(:)),1)]; 
        clear tas jarea       
    end

    %got to use a loop because of 29 feb
    for iyr=1:50
        glob1(iyr,:)=globtemp(floor(iyr*yearlengthZ(imod))-364:floor(iyr*yearlengthZ(imod)));
    end

    %easier if I save csvs
    junk=nanmean(glob1,1);
    T=table(junk(:));
    writetable(T,['globtemp_piC_' modelZ{imod} '.csv'])

    clear areaZ fileZ glob1 globtemp T junk
end

%should have saved 

%% step 2: 5-year mean daily tas around ice-free

clear all; close all;

matref=readtable('ChosenOnes.xlsx');


for imod=1:size(matref,1) 
    %need the area as well
    fileA=dir(['areacella_*' char(matref.Model(imod)) '_*.nc']);
    areaZ=ncread(fileA(1).name,'areacella'); clear fileA
    
    fileZ=dir(['tas_*_' char(matref.Model(imod)) '_' char(matref.Exp(imod)) '_' char(matref.Ensemble(imod)) '_*.nc']);
    %modified from above: which netcdf contains which year
    loadme=NaN(5,2); %file number and date of 1st Jan of that year, 2 years before and 2 years after ice free
    compt=1;
    for ifile=1:length(fileZ)
        ky=strfind(fileZ(ifile).name,'_');
        year1=str2double(fileZ(ifile).name(ky(end)+1:ky(end)+4));
        year2=str2double(fileZ(ifile).name(ky(end)+10:ky(end)+13));

        for iyr=matref.YearFree(imod)-2:matref.YearFree(imod)+2
        if year1<=iyr && year2>=iyr
            loadme(compt,1)=ifile;
            loadme(compt,2)=floor((iyr-year1)*matref.YearLength(imod))+1;
            compt=compt+1;
        end
        end
        clear ky year2 year1
    end 
    clear compt

    %now load the 5 years        
    for iyr=1:5 %we load one year at a time
    tas=squeeze(ncread(fileZ(loadme(iyr,1)).name,'tas',[1 1 loadme(iyr,2)],[Inf Inf floor(matref.YearLength(imod))]));
    tas=reshape(tas,[size(tas,1)*size(tas,2) size(tas,3)]); 
    %fuck the 29 Feb
    tas=tas(:,end-364:end);
    jarea=repmat(areaZ(:),[1 size(tas,3)]);
    globtemp(iyr,:)=nansum(tas.*jarea./nansum(areaZ(:)),1);     
    clear tas jarea
    end 

    junk=nanmean(globtemp,1);
    T=table(junk(:));
    writetable(T,['globtemp_' char(matref.Exp(imod)) '_' char(matref.Model(imod)) '_' char(matref.Ensemble(imod)) '.csv'])

    clear T junk globtemp loadme fileZ areaZ
end

%% step 3: yearly mean diff 

clear all; close all;

matref=readtable('ChosenOnes.xlsx');

compt=1;
for imod=[1:4 8:size(matref,1)] %skipping EC-Earth AerChem 
    T_free=table2array(readtable(['globtemp_' char(matref.Exp(imod)) '_' char(matref.Model(imod)) '_' char(matref.Ensemble(imod)) '.csv']));
    T_piC=table2array(readtable(['globtemp_piC_' char(matref.Model(imod)) '.csv']));

    matmat(compt,1)=nanmean(T_free-T_piC);

    compt=compt+1;
    clear T_free T_piC
end