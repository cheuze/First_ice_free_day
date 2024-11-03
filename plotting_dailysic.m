clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main file for the plotting
% In the same order as in manuscript
% Fig 1 (+supp Fig S1) then Fig 4
% Supplementary Figures S3 to S6
% And material for supplementary tables
% Uses the summary tables that we created by saving the results of the
% other scripts. Can also receive matrices as input instead
% 
% Last modified 3 Nov 2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Main fig 1: Histograms with first/last member of each model only
% Also extracts the value of each model, for later use if needed
% Supp Fig S1 at the end of this part, as the two "diff" histograms

T=readtable('summary_firsticefree.xlsx'); hist=T.hist_2023;
Tmon=readtable('Date_icefree_monthly_3jul.xlsx');
expZ={'ssp119';'ssp126';'ssp245';'ssp370';'ssp585'};

[~,B]=unique(T.Models); B=sort(B);

plotyr_min=NaN(9,5); plotyr_max=NaN(9,5);
plotmon_min=NaN(9,5); plotmon_max=NaN(9,5);
plotdiff_min=NaN(9,5); plotdiff_max=NaN(9,5);

saveyr_min=NaN(length(B),length(expZ));
saveyr_max=saveyr_min; savemon_min=saveyr_min; savemon_max=saveyr_min;
savediff_min=NaN(length(B),length(expZ)); savediff_max=NaN(length(B),length(expZ));
for iexp=1:length(expZ)
    eval(sprintf('yr2023=T.%s_2023;',expZ{iexp})); 
    junk=hist(yr2023==-1); junk(isnan(junk))=2015;
    yr2023(yr2023==-1)=junk;

    eval(sprintf('yrfree=T.%s_free;',expZ{iexp})); 
    yrfree(yrfree==-1)=2200;
    yrfree=yrfree-yr2023; 
    yrfree(yrfree>80)=79;

    eval(sprintf('monfree=Tmon.Date_%s;',expZ{iexp}));
    monfree(monfree==-1)=220000;
    monfree=floor(monfree./100);
    monfree=monfree-yr2023;
    monfree(monfree>80)=79;

    yrmin=[]; yrmax=[];
    monmin=[]; monmax=[];
    diffmin=[]; diffmax=[];
    for imod=1:length(B)-1
        %rewritten to compute the difference daily - monthly of each member
        junk=yrfree(B(imod):B(imod+1)-1);
        junk1=monfree(B(imod):B(imod+1)-1);

        if ~isempty(find(junk==nanmin(junk),1,'first'))
        posmin=find(junk==nanmin(junk),1,'first');
        diffmin=[diffmin; junk1(posmin)-junk(posmin)]; clear posmin
        posmax=find(junk==nanmax(junk),1,'first');
        diffmax=[diffmax; junk1(posmax)-junk(posmax)]; clear posmax
        else
            diffmin=[diffmin;NaN];diffmax=[diffmax;NaN];
        end

        yrmin=[yrmin; nanmin(junk(:))];
        yrmax=[yrmax; nanmax(junk(:))];
        clear junk
        
        monmin=[monmin; nanmin(junk1(:))];
        monmax=[monmax; nanmax(junk1(:))];
        clear junk1
    end
    junk=yrfree(B(end):end);junk1=monfree(B(end):end);
    if ~isempty(find(junk==nanmin(junk),1,'first'))
    posmin=find(junk==nanmin(junk),1,'first');
    diffmin=[diffmin; junk1(posmin)-junk(posmin)]; clear posmin
    posmax=find(junk==nanmax(junk),1,'first');
    diffmax=[diffmax; junk1(posmax)-junk(posmax)]; clear posmax
    else
            diffmin=[diffmin;NaN];diffmax=[diffmax;NaN];
    end
    yrmin=[yrmin; nanmin(junk(:))];
    yrmax=[yrmax; nanmax(junk(:))];
    clear junk
    monmin=[monmin; nanmin(junk1(:))];
    monmax=[monmax; nanmax(junk1(:))];
    clear junk1

    saveyr_min(:,iexp)=yrmin;
    saveyr_max(:,iexp)=yrmax;
    savemon_min(:,iexp)=monmin;
    savemon_max(:,iexp)=monmax;
    savediff_min(:,iexp)=diffmin;
    savediff_max(:,iexp)=diffmax;

    %as % of the models available (i.e. different value per ssp)
    yrmin=yrmin(~isnan(yrmin));yrmax=yrmax(~isnan(yrmax));
    monmin=monmin(~isnan(monmin));monmax=monmax(~isnan(monmax));
    diffmin=diffmin(~isnan(diffmin));diffmax=diffmax(~isnan(diffmax));

    plotyr_min(1,iexp)=100*numel(find(yrmin<=6))./length(yrmin); plotyr_max(1,iexp)=100*numel(find(yrmax<=6))./length(yrmax);
    plotyr_min(2,iexp)=100*numel(find(yrmin>6 & yrmin<=10))./length(yrmin); plotyr_max(2,iexp)=100*numel(find(yrmax>6 & yrmax<=10))./length(yrmax);
    plotmon_min(1,iexp)=100*numel(find(monmin<=6))./length(monmin); plotmon_max(1,iexp)=100*numel(find(monmax<=6))./length(monmax);
    plotmon_min(2,iexp)=100*numel(find(monmin>6 & monmin<=10))./length(monmin); plotmon_max(2,iexp)=100*numel(find(monmax>6 & monmax<=10))./length(monmax);
    plotdiff_min(1,iexp)=100*numel(find(diffmin<=6))./length(diffmin); plotdiff_max(1,iexp)=100*numel(find(diffmax<=6))./length(diffmax);
    plotdiff_min(2,iexp)=100*numel(find(diffmin>6 & diffmin<=10))./length(diffmin); plotdiff_max(2,iexp)=100*numel(find(diffmax>6 & diffmax<=10))./length(diffmax);
    
    for idec=3:9
        plotyr_min(idec,iexp)=100.*(numel(find(yrmin>10+(idec-3)*10 & yrmin<=10+(idec-2)*10)))./length(yrmin);
        plotyr_max(idec,iexp)=100.*(numel(find(yrmax>10+(idec-3)*10 & yrmax<=10+(idec-2)*10)))./length(yrmax);
        plotmon_min(idec,iexp)=100.*(numel(find(monmin>10+(idec-3)*10 & monmin<=10+(idec-2)*10)))./length(monmin);
        plotmon_max(idec,iexp)=100.*(numel(find(monmax>10+(idec-3)*10 & monmax<=10+(idec-2)*10)))./length(monmax);
        plotdiff_min(idec,iexp)=100.*(numel(find(diffmin>10+(idec-3)*10 & diffmin<=10+(idec-2)*10)))./length(diffmin);
        plotdiff_max(idec,iexp)=100.*(numel(find(diffmax>10+(idec-3)*10 & diffmax<=10+(idec-2)*10)))./length(diffmax);
    end

    clear yrfree yr2023 yrmin yrmax monmin monmax diffmin diffmax
end
clear B

figure; 
hold on
bar(plotyr_min,'hist')
%legend(expZ,'Location','northwest')
set(gca,'XLim',[.5 9.5])
set(gca,'XTickLabels',{'<=6';'7-10';'11-20';'21-30';'31-40';'41-50';'51-60';'61-70';'>70'});
set(gca,'YLim',[0 70])
ylabel('Percentage of models')
xlabel('Years until ice free')
box on
f=gcf;
print(f,'Histograms_daily_earliest','-r200','-dpng')

figure; 
hold on
bar(plotyr_max,'hist')
%legend(expZ,'Location','northwest')
set(gca,'XLim',[.5 9.5])
set(gca,'XTickLabels',{'<=6';'7-10';'11-20';'21-30';'31-40';'41-50';'51-60';'61-70';'>70'});
set(gca,'YLim',[0 70])
ylabel('Percentage of models')
xlabel('Years until ice free')
box on
f=gcf;
print(f,'Histograms_daily_latest','-r200','-dpng')

figure; 
hold on
bar(plotmon_min,'hist')
%legend(expZ,'Location','northwest')
set(gca,'XLim',[.5 9.5])
set(gca,'XTickLabels',{'<=6';'7-10';'11-20';'21-30';'31-40';'41-50';'51-60';'61-70';'>70'});
set(gca,'YLim',[0 70])
ylabel('Percentage of models')
xlabel('Years until ice free')
box on
f=gcf;
print(f,'Histograms_monthly_earliest','-r200','-dpng')

figure; 
hold on
bar(plotmon_max,'hist')
%legend(expZ,'Location','northwest')
set(gca,'XLim',[.5 9.5])
set(gca,'XTickLabels',{'<=6';'7-10';'11-20';'21-30';'31-40';'41-50';'51-60';'61-70';'>70'});
set(gca,'YLim',[0 70])
ylabel('Percentage of models')
xlabel('Years until ice free')
box on
f=gcf;
print(f,'Histograms_monthly_latest','-r200','-dpng')

% And supp figure S1
figure; 
hold on
bar(plotdiff_min,'hist')
%legend(expZ,'Location','northwest')
set(gca,'XLim',[.5 9.5])
set(gca,'XTickLabels',{'<=6';'7-10';'11-20';'21-30';'31-40';'41-50';'51-60';'61-70';'>70'});
%set(gca,'YLim',[0 40])
ylabel('Percentage of models')
xlabel('Years until monthly ice free')
box on
f=gcf;
print(f,'Histograms_diff_earliest','-r200','-dpng')

figure; 
hold on
bar(plotdiff_max,'hist')
%legend(expZ,'Location','northwest')
set(gca,'XLim',[.5 9.5])
set(gca,'XTickLabels',{'<=6';'7-10';'11-20';'21-30';'31-40';'41-50';'51-60';'61-70';'>70'});
%set(gca,'YLim',[0 40])
ylabel('Percentage of models')
xlabel('Year until monthly ice free')
box on
f=gcf;
print(f,'Histograms_diff_latest','-r200','-dpng')

%% Main figure 4: all the models, last year only, max air temp, and min - max pressures
% 5 day running mean
% Since revision 1, all models in grey, and multi run average in black

matref=readtable('ChosenOnes.xlsx');

f1=figure('Visible','off'); hax1=gca; box on; grid on; hold on
plot(hax1,[1 255],[0 0],':k'); hold on
plot(hax1,[1 255],[-20 -20],':k'); hold on
f2=figure('Visible','off'); hax2=gca; box on; grid on; hold on
plot(hax2,[1 255],[1010 1010],'k'); hold on
plot(hax2,[1 255],[1025 1025],'k'); hold on
f3=figure('Visible','off'); hax3=gca; box on; grid on; hold on
plot(hax3,[1 255],[1010 1010],'k'); hold on
plot(hax3,[1 255],[995 995],'k'); hold on

for imod=1:size(matref,1) 
    fileZ=dir(['tas_*_' char(matref.Model(imod)) '_' char(matref.Exp(imod)) '_' char(matref.Ensemble(imod)) '_*.nc']);
    loadme=NaN(1,2); 
    for ifile=1:length(fileZ)
        ky=strfind(fileZ(ifile).name,'_');
        year1=str2double(fileZ(ifile).name(ky(end)+1:ky(end)+4));
        year2=str2double(fileZ(ifile).name(ky(end)+10:ky(end)+13));

        iyr=matref.YearFree(imod);
        if year1<=iyr && year2>=iyr
            loadme(1,1)=ifile;
            loadme(1,2)=floor((iyr-year1)*matref.YearLength(imod))+1;
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
    poslat=find(lat>=80);
    
    %now load the ice free year      
    tas=squeeze(ncread([fileZ(loadme(1,1)).name],'tas',[1 1 loadme(1,2)],[Inf Inf floor(matref.YearLength(imod))]));
    tas=reshape(tas,[size(tas,1)*size(tas,2) size(tas,3)]);tas=nanmax(tas(poslat,:),[],1);

    psl=squeeze(ncread(['psl' fileZ(loadme(1,1)).name(4:end)],'psl',[1 1 loadme(1,2)],[Inf Inf floor(matref.YearLength(imod))]));
    psl=reshape(psl,[size(psl,1)*size(psl,2) size(psl,3)]);
    psl_max=nanmax(psl(poslat,:),[],1);psl_min=nanmin(psl(poslat,:),[],1);

    %running mean here
    psl_max=my_nanfilter(psl_max,10,'tri');psl_min=my_nanfilter(psl_min,10,'tri');
    tas=my_nanfilter(tas,10,'tri');
   
    plot(hax1,tas(1:255)-273.15,'Color',[.7 .7 .7],'LineWidth',0.5); hold on
    plot(hax2,psl_max(1:255)./100,'Color',[.7 .7 .7],'LineWidth',0.5); hold on       
    plot(hax3,psl_min(1:255)./100,'Color',[.7 .7 .7],'LineWidth',0.5); hold on 

plot_tas(imod,:)=tas;
plot_psl_min(imod,:)=psl_min;
plot_psl_max(imod,:)=psl_max;
    
clear tas poslat tasplot lat lon fileZ loadme psl_*
end

plot_tas=nanmedian(plot_tas,1);
plot_psl_min=nanmedian(plot_psl_min,1);
plot_psl_max=nanmedian(plot_psl_max,1);

plot(hax1,plot_tas(1:255)-273.15,'Color','k','LineWidth',1.5); hold on    
plot(hax2,plot_psl_max(1:255)./100,'Color','k','LineWidth',1.5); hold on    
plot(hax3,plot_psl_min(1:255)./100,'Color','k','LineWidth',1.5); hold on       

set(hax1,'XLim',[1 255]);set(hax2,'XLim',[1 255]);set(hax3,'XLim',[1 255])

print(f1,'test_mediancases_lastyear_tasmax_5day','-r300','-dpng')
print(f2,'test_mediancases_lastyear_pslmax_5day','-r300','-dpng')
print(f3,'test_mediancases_lastyear_pslmin_5day','-r300','-dpng')



close all

%% Supp Figs S3 and S4 - Timeseries of tas and psl, all years 2023 to ice free

matref=readtable('C:\Users\xheuce\Dropbox\CMIP6\seaice\ChosenOnes.xlsx');

ccc(1,:)=[0 0 128]./255;
ccc(2,:)=[0 0 255]./255;
ccc(3,:)=[65 105 255]./255;
ccc(4,:)=[123 104 238]./255;
ccc(5,:)=[148 0 211]./255;
ccc(6,:)=[238 130 238]./255;
ccc(7,:)=[255 0 255]./255;

for imod=1:size(matref,1) 
    f1=figure('Units','normalized','Outerposition',[0 0 1 1],'Visible','off'); hax1=axes;hold on; box on
    hax1.PlotBoxAspectRatio=[1 0.75 1];
    f2=figure('Units','normalized','Outerposition',[0 0 1 1],'Visible','off'); hax2=axes;hold on; box on
    hax2.PlotBoxAspectRatio=[1 0.75 1];
    
    fileZ=dir(['psl_*_' char(matref.Model(imod)) '_' char(matref.Exp(imod)) '_' char(matref.Ensemble(imod)) '_*.nc']);
    %modified from above: which netcdf contains which year
    loadme=NaN(9,2); %file number and date of 1st Jan of that year, 2023 to ice free; up to 9 years
    for ifile=1:length(fileZ)
        ky=strfind(fileZ(ifile).name,'_');
        year1=str2double(fileZ(ifile).name(ky(end)+1:ky(end)+4));
        year2=str2double(fileZ(ifile).name(ky(end)+10:ky(end)+13));

        for iyr=matref.Year2023(imod):matref.YearFree(imod)
        if year1<=iyr && year2>=iyr
            loadme(iyr-matref.Year2023(imod)+1,1)=ifile;
            loadme(iyr-matref.Year2023(imod)+1,2)=floor((iyr-year1)*matref.YearLength(imod))+1;
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
    poslat=find(lat>=80);

    %load pre-2023 and average
    jpsl=[]; jtas=[];
    if loadme(1,1)~=1
        for ifile=1:loadme(1,1)-1
            psl=ncread(fileZ(ifile).name,'psl');
            tas=ncread(['tas' fileZ(ifile).name(4:end)],'tas');

            psl=reshape(psl,[size(psl,1)*size(psl,2) size(psl,3)]);psl=psl./100;jpsl=[jpsl nanmean(psl(poslat,:),1)]; 
            tas=reshape(tas,[size(tas,1)*size(tas,2) size(tas,3)]);tas=tas-273.15;jtas=[jtas nanmean(tas(poslat,:),1)]; 
            clear psl tas
        end
    end
    if loadme(1,2)~=1
    psl=squeeze(ncread(fileZ(loadme(1,1)).name,'psl',[1 1 1],[Inf Inf loadme(1,2)-1]));
    tas=squeeze(ncread(['tas' fileZ(loadme(1,1)).name(4:end)],'tas',[1 1 1],[Inf Inf loadme(1,2)-1]));
    psl=reshape(psl,[size(psl,1)*size(psl,2) size(psl,3)]);psl=psl./100;jpsl=[jpsl nanmean(psl(poslat,:),1)]; 
    tas=reshape(tas,[size(tas,1)*size(tas,2) size(tas,3)]);tas=tas-273.15;jtas=[jtas nanmean(tas(poslat,:),1)]; 
    clear psl tas
    end

    for iyr=1:floor(length(jtas)/matref.YearLength(imod))
        pslplot(iyr,:)=jpsl((iyr-1)*floor(matref.YearLength(imod))+1:iyr*floor(matref.YearLength(imod)));
        tasplot(iyr,:)=jtas((iyr-1)*floor(matref.YearLength(imod))+1:iyr*floor(matref.YearLength(imod)));
    end
    clear jpsl jtas

    
    plot(hax1,nanmean(pslplot,1),'k','LineWidth',4)
    hold on
    plot(hax2,nanmean(tasplot,1),'k','LineWidth',3)
    clear pslplot tasplot

    %now load 2023 onwards        
    for iyr=1:matref.YearFree(imod)-matref.Year2023(imod)+1 %we load one year at a time

    psl=squeeze(ncread(fileZ(loadme(iyr,1)).name,'psl',[1 1 loadme(iyr,2)],[Inf Inf floor(matref.YearLength(imod))]));
    %load uas, vas, and tas - they should all be on the same years
    tas=squeeze(ncread(['tas' fileZ(loadme(iyr,1)).name(4:end)],'tas',[1 1 loadme(iyr,2)],[Inf Inf floor(matref.YearLength(imod))]));

    psl=reshape(psl,[size(psl,1)*size(psl,2) size(psl,3)]);psl=psl(poslat,:); psl=psl./100;
    tas=reshape(tas,[size(tas,1)*size(tas,2) size(tas,3)]);tas=tas(poslat,:); tas=tas-273.15;

    psl_extr=nanmean(psl,1);
    psl_extr(psl_extr>=995 & psl_extr<=1025)=NaN;


      
    if iyr==matref.YearFree(imod)-matref.Year2023(imod)+1 % if last year
        plot(hax1,nanmean(psl,1),'Color',[.75 .75 .75],'LineWidth',5); hold on
        plot(hax1,psl_extr,'Color',ccc(end,:),'LineWidth',6)
    else
        plot(hax1,nanmean(psl,1),'Color',[.75 .75 .75],'LineWidth',2); hold on
        plot(hax1,psl_extr,'Color',ccc(iyr,:),'LineWidth',3)
    end

    
    if iyr==matref.YearFree(imod)-matref.Year2023(imod)+1 %if last year
    plot(hax2,nanmean(tas,1),'Color',ccc(end,:),'LineWidth',5);hold on  
    else
    plot(hax2,nanmean(tas,1),'Color',ccc(iyr,:),'LineWidth',1);hold on  
    end
    end

    
    set(hax1,'XLim',[1 365])
    plot(hax1,[1 365],[995 995],':k')
    plot(hax1,[1 365],[1025 1025],':k')
    plot(hax1,[matref.DayFree(imod) matref.DayFree(imod)],[970 1060],'k')
    set(hax1,'YLim',[970 1060])
    box on
    %title(hax1,['psl ' char(matref.Model(imod)) ' ' char(matref.Ensemble(imod)) ' ' char(matref.Exp(imod))])

    set(hax2,'XLim',[1 365])
    set(hax2,'YLim',[-45 5])
    plot(hax2,[matref.DayFree(imod) matref.DayFree(imod)],[-45 5],'k')
    plot(hax2,[1 365],[0 0],':k')
    plot(hax2,[1 365],[-20 -20],':k')
    box on
    %title(hax2,['tas ' char(matref.Model(imod)) ' ' char(matref.Ensemble(imod)) ' ' char(matref.Exp(imod))])

saveas(f1,['atmos_psl_' char(matref.Model(imod)) '_' char(matref.Ensemble(imod)) '_' char(matref.Exp(imod)) '.png'])
close(f1)
saveas(f2,['atmos_tas_' char(matref.Model(imod)) '_' char(matref.Ensemble(imod)) '_' char(matref.Exp(imod)) '.png'])
close(f2)


clear psl tas poslat
end

%% Supp figure S5 - Atmosphere snapshots

modelZ={'EC-Earth3';'EC-Earth3';'EC-Earth3'};
ensZ={'r8i1p1f1';'r12i1p1f1';'r12i1p1f1'};
expZ={'ssp126';'ssp245';'ssp245'};
yearZ=[2030;2031;2030]; %real model years, not 2023 offset
dayZ=[39;225;135];
legZ={'WAI';'storms';'blocking'};

ccc=cbrewer('div','RdBu',20); ccc(ccc<0)=0; ccc(ccc>1)=1;

for icase=1:3
    psl=ncread(['psl_day_' modelZ{icase} '_' expZ{icase} '_' ensZ{icase} '_gr_' num2str(yearZ(icase)) '0101-' num2str(yearZ(icase)) '1231.nc'],...
        'psl',[1 1 dayZ(icase)],[Inf Inf 1]);
    tas=ncread(['tas_day_' modelZ{icase} '_' expZ{icase} '_' ensZ{icase} '_gr_' num2str(yearZ(icase)) '0101-' num2str(yearZ(icase)) '1231.nc'],...
        'tas',[1 1 dayZ(icase)],[Inf Inf 1]);
    psl=squeeze(psl); psl=psl./100;
    tas=squeeze(tas); tas=tas-273.15;

    lat=ncread(['psl_day_' modelZ{icase} '_' expZ{icase} '_' ensZ{icase} '_gr_' num2str(yearZ(icase)) '0101-' num2str(yearZ(icase)) '1231.nc'],'lat');
    lon=ncread(['psl_day_' modelZ{icase} '_' expZ{icase} '_' ensZ{icase} '_gr_' num2str(yearZ(icase)) '0101-' num2str(yearZ(icase)) '1231.nc'],'lon');
    [lat,lon]=meshgrid(lat,lon);

f=figure('Units','normalized','Outerposition',[0 0 1 1],'Visible','off');
m_proj('stereographic','lat',90,'lon',0,'radius',30);
m_pcolor(lon,lat,psl); shading flat; colorbar
m_grid('linest','-','XTickLabels',[],'YTickLabels',[]);
m_coast('Color','k');
colorbar
clim([970 1050])
colormap(flipud(ccc))
print(f,['psl_snapshot_' legZ{icase}],'-r300','-dpng')
close(f)

f=figure('Units','normalized','Outerposition',[0 0 1 1],'Visible','off');
m_proj('stereographic','lat',90,'lon',0,'radius',30);
m_pcolor(lon,lat,tas); shading flat; colorbar
m_grid('linest','-','XTickLabels',[],'YTickLabels',[]);
m_coast('Color','k');
colorbar
clim([-45 5])
colormap(flipud(ccc))
print(f,['tas_snapshot_' legZ{icase}],'-r300','-dpng')
close(f)

end


%% Supplementary figure S6: the 5 day storm of EC-Earth

ccc=cbrewer('div','RdBu',20); ccc(ccc<0)=0; ccc(ccc>1)=1;

for iday=229:233
    psl=ncread('psl_day_EC-Earth3_ssp126_r4i1p1f1_gr_20410101-20411231.nc','psl',[1 1 iday],[Inf Inf 1]);
    psl=squeeze(psl); psl=psl./100;

    lat=ncread('psl_day_EC-Earth3_ssp126_r4i1p1f1_gr_20410101-20411231.nc','lat');
    lon=ncread('psl_day_EC-Earth3_ssp126_r4i1p1f1_gr_20410101-20411231.nc','lon');
    [lat,lon]=meshgrid(lat,lon);

f=figure('Units','normalized','Outerposition',[0 0 1 1],'Visible','off');
m_proj('stereographic','lat',90,'lon',0,'radius',30);
m_pcolor(lon,lat,psl); shading flat; colorbar
m_grid('linest','-','XTickLabels',[],'YTickLabels',[]);
m_coast('Color','k');
colorbar
clim([990 1030])
colormap(flipud(ccc))
print(f,['psl_snapshot_lastsstorm_ECEarth_day' num2str(iday)],'-r300','-dpng')
close(f)

clear psl

end

%% For supp table S1 - earliest and latest member of the models
%set hist(isnan(hist))=2015, for the few cases where no "2023" can be found
%in the SSP yet hist has nothing either

clear all; close all
cd('C:\Users\xheuce\Dropbox\CMIP6\seaice')

T=readtable('summary_firsticefree.xlsx'); 
hist=T.hist_2023; hist(isnan(hist))=2015;

expZ={'ssp119';'ssp126';'ssp245';'ssp370';'ssp585'};

[A,B]=unique(T.Models); B=sort(B);

for iexp=1:length(expZ)
    eval(sprintf('yr2023=T.%s_2023;',expZ{iexp})); 
    yr2023(yr2023==-1)=hist(yr2023==-1);

    eval(sprintf('yrfree=T.%s_free;',expZ{iexp})); 
    yrfree(yrfree==-1)=2200;
    yrfree=yrfree-yr2023; 
    yrfree(yrfree>80)=79;

    for imod=1:length(B)-1
        mod(imod,1)=T.Models(B(imod));
        junk=yrfree(B(imod):B(imod+1)-1);
        pos=find(junk==nanmin(junk(:)),1,'first');
        if ~isempty(pos)
        valZ((imod-1)*2+1,1)=junk(pos);
        ensZ((imod-1)*2+1,1)=T.Ensembles(B(imod)-1+pos); clear pos
        pos=find(junk==nanmax(junk(:)),1,'last');
        valZ((imod-1)*2+2,1)=junk(pos);
        ensZ((imod-1)*2+2,1)=T.Ensembles(B(imod)-1+pos); 

        end
        clear junk pos
    end
    imod=length(B);
    mod(imod,1)=T.Models(B(imod));
    junk=yrfree(B(end):end);
    pos=find(junk==nanmin(junk(:)),1,'first');
    if ~isempty(pos)
        valZ((imod-1)*2+1,1)=junk(pos);
        ensZ((imod-1)*2+1,1)=T.Ensembles(B(imod)-1+pos); clear pos
        pos=find(junk==nanmax(junk(:)),1,'last');
        valZ((imod-1)*2+2,1)=junk(pos);
        ensZ((imod-1)*2+2,1)=T.Ensembles(B(imod)-1+pos);

    end
    clear junk pos

    eval(sprintf('Mod_%s=mod;',expZ{iexp}))
    eval(sprintf('Ens_%s=ensZ;',expZ{iexp}))
    eval(sprintf('Val_%s=valZ;',expZ{iexp}))
    
    clear yrfree yr2023 yrmin yrmax valZ ensZ mod
end
clear B

%% Supp table S2, same but for monthly values - earliest and latest member of the models
%set hist(isnan(hist))=2015, for the few cases where no "2023" can be found
%in the SSP yet hist has nothing either

clear all; close all
cd('C:\Users\xheuce\Dropbox\CMIP6\seaice')

T=readtable('summary_firsticefree.xlsx'); 
hist=T.hist_2023; hist(isnan(hist))=2015;

Tmon=readtable('Date_icefree_monthly_3jul.xlsx');
expZ={'ssp119';'ssp126';'ssp245';'ssp370';'ssp585'};

[A,B]=unique(T.Models); B=sort(B);

for iexp=1:length(expZ)
    eval(sprintf('yr2023=T.%s_2023;',expZ{iexp})); 
    yr2023(yr2023==-1)=hist(yr2023==-1);

    eval(sprintf('monfree=Tmon.Date_%s;',expZ{iexp}));
    monfree(monfree==-1)=220000;
    monfree=floor(monfree./100);
    monfree=monfree-yr2023;
    monfree(monfree>80)=79;


    for imod=1:length(B)-1
        mod(imod,1)=T.Models(B(imod));
        junk=monfree(B(imod):B(imod+1)-1);
        pos=find(junk==nanmin(junk(:)),1,'first');
        if ~isempty(pos)
        valZ((imod-1)*2+1,1)=junk(pos);
        ensZ((imod-1)*2+1,1)=T.Ensembles(B(imod)-1+pos); clear pos
        pos=find(junk==nanmax(junk(:)),1,'last');
        valZ((imod-1)*2+2,1)=junk(pos);
        ensZ((imod-1)*2+2,1)=T.Ensembles(B(imod)-1+pos); 

        end
        clear junk pos
    end
    imod=length(B);
    mod(imod,1)=T.Models(B(imod));
    junk=monfree(B(end):end);
    pos=find(junk==nanmin(junk(:)),1,'first');
    if ~isempty(pos)
        valZ((imod-1)*2+1,1)=junk(pos);
        ensZ((imod-1)*2+1,1)=T.Ensembles(B(imod)-1+pos); clear pos
        pos=find(junk==nanmax(junk(:)),1,'last');
        valZ((imod-1)*2+2,1)=junk(pos);
        ensZ((imod-1)*2+2,1)=T.Ensembles(B(imod)-1+pos);

    end
    clear junk pos

    eval(sprintf('Mod_%s=mod;',expZ{iexp}))
    eval(sprintf('Ens_%s=ensZ;',expZ{iexp}))
    eval(sprintf('Val_%s=valZ;',expZ{iexp}))
    
    clear monfree yr2023 yrmin yrmax valZ ensZ mod
end
clear B


