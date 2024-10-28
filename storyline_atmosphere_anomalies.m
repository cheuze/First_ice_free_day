%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computes the 10th and 90th percentiles in PSL, as well as the heating
% degree days, as anomalies last year minus prior years
% Computes for the Central Arctic Ocean and the various seas - see
% definitions lines 65-71
%
% First subsection currently extracts HDD
% To extract PSL, change 'tas' to 'psl' lines 28 and 75, and comment line 91
% 
% Uses ChosenOnes.xlsx, which summarises the main characteristics of the
% quick transition simulations:
% Column 1: Model [string]
% Column 2: Ensemble [string]
% Column 3: Experiment, as per the netcdf file names, e.g. ssp119 [string]
% Column 4: Year2023, as YYYY [int]
% Column 5: YearFree, i.e. year with first ice free day, as YYYY [int]
% Column 6: YearLength, in number of days [int]
% Column 7: DayFree, i.e. day of year of first ice free day [int]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% First, extract all the HDD or psl values of each region

matref=readtable('ChosenOnes.xlsx');
regZ={'CAO';'Barents'; 'Kara'; 'Laptev';'EastSib';'Chukchi';'Beaufort'};

for imod=1:size(matref,1) 
    SIA=ncread(['SIA_SIE_' char(matref.Exp(imod)) '_' char(matref.Model(imod)) '_' char(matref.Ensemble(imod)) '.nc'],'Arctic_SIA');
    fileZ=dir(['tas_*_' char(matref.Model(imod)) '_' char(matref.Exp(imod)) '_' char(matref.Ensemble(imod)) '_*.nc']);

    loadme=NaN(9,2); %file number and date of 1st Jan of that year, 2023 to ice free; up to 9 years
    for ifile=1:length(fileZ)
        ky=strfind(fileZ(ifile).name,'_');
        year1=str2double(fileZ(ifile).name(ky(end)+1:ky(end)+4));
        year2=str2double(fileZ(ifile).name(ky(end)+10:ky(end)+13));
        
        for iyr=matref.YearFree(imod):-1:matref.Year2023(imod)
        if year1<=iyr && year2>=iyr
            ind=matref.YearFree(imod)-matref.Year2023(imod)+1-(iyr-matref.Year2023(imod));
            loadme(ind,1)=ifile;
            loadme(ind,2)=floor((iyr-year1)*matref.YearLength(imod))+1;
            clear ind
        end
        end
        clear ky year2 year1
    end

    %usual lat / lon loading
    try
        lat=double(ncread(fileZ(1).name,'latitude'));
        lon=double(ncread(fileZ(1).name,'longitude'));
    catch
        try
            lat=double(ncread(fileZ(1).name,'lat'));
            lon=double(ncread(fileZ(1).name,'lon'));
        catch
            lat=double(ncread(fileZ(1).name,'nav_lat'));
            lon=double(ncread(fileZ(1).name,'nav_lon'));
        end
    end
    if min(size(lat))==1
        [lat,lon]=meshgrid(double(lat),double(lon));
    end
    lon(lon<0) = lon(lon<0)+360;

    posCAO=find(lat>=80); 
    posBarents=find(lat>=70 & lat<80 & lon>=15 & lon<60);
    posKara=find(lat>=70 & lat<80 & lon>=60 & lon<100);
    posLaptev=find(lat>=70 & lat<80 & lon>=100 & lon<140);
    posEastSib=find(lat>=70 & lat<80 & lon>=140 & lon<180);
    posChukchi=find(lat>=70 & lat<80 & lon>=180 & lon<210);
    posBeaufort=find(lat>=70 & lat<80 & lon>=210 & lon<240);

    for iyr=1:matref.YearFree(imod)-matref.Year2023(imod)+1 %we load one year at a time

    psl=squeeze(ncread(fileZ(loadme(iyr,1)).name,'tas',[1 1 loadme(iyr,2)],[Inf Inf floor(matref.YearLength(imod))]));
    psl=reshape(psl,[size(psl,1)*size(psl,2) size(psl,3)]);


    for ireg=1:length(regZ)
    for iseason=1:4 %with varying length for each season
        eval(sprintf('junk=NaN(numel(pos%s),120);',regZ{ireg}));
        if iseason==1
            eval(sprintf('junk=psl(pos%s,1:100);',regZ{ireg}));
        elseif iseason==2
            eval(sprintf('junk=psl(pos%s,101:150);',regZ{ireg}));
        elseif iseason==3
            eval(sprintf('junk=psl(pos%s,151:225);',regZ{ireg})); 
        else
            eval(sprintf('junk=psl(pos%s,275:end);',regZ{ireg}));
        end
        junk=nansum(junk-273.15,2);
        eval(sprintf('HDD_tas_%s(iyr,iseason,1:numel(junk(:)))=junk(:);',regZ{ireg}))
        clear junk
    end %iseason
    end %ireg

clear psl

    end %iyr
    clear pos* lat lon SIA fileZ loadme
    
save(['atm_' char(matref.Model(imod)) '_' char(matref.Ensemble(imod)) '_' char(matref.Exp(imod)) '.mat'],'HDD_*','-append')
clear max_* min_* mean_* HDD_*
end %imod


%% then to use the files

fileZ=dir('atm_*');

matmat=NaN(length(fileZ),length(regZ),4,3); %4 seasons, 10 and 90 prctiles and CDD, last year minus all prior
% for winter, using year before last (last winter pre ice free)

for ifile=1:length(fileZ)
    load(fileZ(ifile).name)
    for ireg=1:7
        eval(sprintf('junk=psl_%s;',regZ{ireg}));
        eval(sprintf('junkT=HDD_tas_%s;',regZ{ireg}));

        for iseason=1:4
            if iseason==4
                junk1=squeeze(junk(2,iseason,:));
                junk2=squeeze(junk(3:end,iseason,:));
                junkT1=squeeze(junkT(2,iseason,:));
                junkT2=squeeze(junkT(3:end,iseason,:));
            else
                junk1=squeeze(junk(1,iseason,:));
                junk2=squeeze(junk(2:end,iseason,:));
                junkT1=squeeze(junkT(1,iseason,:));
                junkT2=squeeze(junkT(2:end,iseason,:));
            end
            junk1=junk1(junk1~=0);junk2=junk2(junk2~=0);
            junkT1=junkT1(junkT1~=0);junkT2=junkT2(junkT2~=0);

            matmat(ifile,ireg,iseason,1)=prctile(junk1(:),10)./100-prctile(junk2(:),10)./100;
            matmat(ifile,ireg,iseason,2)=prctile(junk1(:),90)./100-prctile(junk2(:),90)./100;
            matmat(ifile,ireg,iseason,3)=nanmean(junkT1)-nanmean(junkT2);


            clear junk1 junk2 junkT1 junkT2
        end
        clear junk
    end
    clear tas_* psl_* HDD_* mean_* min_* max_*
end