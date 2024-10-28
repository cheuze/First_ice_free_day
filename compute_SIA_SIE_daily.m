%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generates the daily sea ice area SIA and extent SIE
% Saves them as .csv
% Different suffixes depending on whether the file is generated using
% siconc (preferred) or siconca 
% Arctic defined as all locations north of 30 degree N
% This script cannot deal with CNRM-HR - too heavy. There is a separate
% script for this model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



sspZ={'ssp119';'ssp126';'ssp245';'ssp370';'ssp585'};

for issp=1:length(sspZ)
    ssp=sspZ{issp};

% Either load a file containing the list of Models and Ensemble members
% Or run generate_modellist.m first

for imod=1:length(SSP)
    if strcmp('CNRM-CM6-1-HR',SSP(imod).Models)==0 && strcmp('NESM3',SSP(imod).Models)==0 
    for iens=1:numel(SSP(imod).Ensembles)
        fileZ=dir(['*_' char(SSP(imod).Models) '_' ssp '_' char(SSP(imod).Ensembles{iens}) '_*.nc']);

        k=strfind(fileZ(1).name,'_');
        if strcmp('siconc',fileZ(1).name(1:k(1)-1))
            fileA=dir(['areacello_*' char(SSP(imod).Models) '*.nc']);
            areaZ=double(ncread(fileA(1).name,'areacello')); clear fileA
            areaZ(areaZ>1E12)=NaN;

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
            %meshgrid the 1D grids (except AWI)
            if min(size(lat))==1
                [lat,lon]=meshgrid(double(lat),double(lon));
            end
            clear lon
            for ifile=1:length(fileZ)
                ky=strfind(fileZ(ifile).name,'_');
                yearZ(ifile)=str2double(fileZ(ifile).name(ky(end)+1:ky(end)+4));
                clear ky
            end
            [~,loadorder]=sort(yearZ); clear yearZ

            for ifile=1:length(fileZ)
                time=ncread(fileZ(loadorder(ifile)).name,'time');
                siconc=double(ncread(fileZ(loadorder(ifile)).name,'siconc'))./100;


                %if sea ice and area don't have the same dimensions, adjust
                if size(siconc,1)<size(areaZ,1)
                    areaZ=areaZ(1:size(siconc,1),:);
                elseif size(siconc,1)>size(areaZ,1)
                    areaZ(end+1:size(siconc,1),:)=areaZ(end,:);
                end
                if size(siconc,2)<size(areaZ,2)
                    areaZ=areaZ(:,1:size(siconc,2));
                elseif size(siconc,2)>size(areaZ,2)
                    areaZ(:,end+1:size(siconc,2))=areaZ(:,end);
                end


                % reshape siconc to make life easier
                siconc=reshape(siconc,[size(siconc,1)*size(siconc,2) size(siconc,3)]);
                % select north of 30 (changed 12 June - was 66N)
                poslat=find(lat>=30);
                jsic=siconc(poslat,:);
                jsic(jsic>1)=NaN;

                % SIA = sum of area x sic
                SIA=squeeze(nansum(areaZ(poslat).*jsic,1)); 
                % select sic >= 15% by setting 0-15 to 0 and rest to 1
                jsic(jsic<=0.15)=0; jsic(jsic>0.15)=1;
                % SIE = sum of selected area 
                SIE=squeeze(nansum(areaZ(poslat).*jsic,1)); 

                clear poslat jsic
                %concatenate here if ifile~=1
                if ifile==1
                    saveSIA=SIA(:);
                    saveSIE=SIE(:);
                    savetime=time(:);
                else
                    saveSIA=cat(1,saveSIA,SIA(:));
                    saveSIE=cat(1,saveSIE,SIE(:));
                    if strcmp('BCC-CSM2-MR',SSP(imod).Models)
                        time=time+ceil(savetime(end));    
                    end
                    savetime=cat(1,savetime,time(:));
                end
                clear SIA SIE siconc time

            end
            clear loadorder
%saving as csv
Time=savetime(:);
SIA=saveSIA(:);
SIE=saveSIE(:);
T=table(Time,SIA,SIE);
writetable(T,[char(SSP(imod).Models) '_' char(SSP(imod).Ensembles{iens}) '_' ssp '_SIA_SIE_m_o.csv'])
clear Time SIA SIE T savetime saveSIA saveSIE
close all


        elseif strcmp('siconca',fileZ(1).name(1:k(1)-1))
            fileA=dir(['areacella_*' char(SSP(imod).Models) '*.nc']);
            areaZ=double(ncread(fileA(1).name,'areacella')); clear fileA

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
            %meshgrid the 1D grids (except AWI)
            if min(size(lat))==1
                [lat,lon]=meshgrid(double(lat),double(lon));
            end
            clear lon
            for ifile=1:length(fileZ)
                ky=strfind(fileZ(ifile).name,'_');
                yearZ(ifile)=str2double(fileZ(ifile).name(ky(end)+1:ky(end)+4));
                clear ky
            end
            [~,loadorder]=sort(yearZ); clear yearZ

            for ifile=1:length(fileZ)
                time=ncread(fileZ(loadorder(ifile)).name,'time');
                siconc=double(ncread(fileZ(loadorder(ifile)).name,'siconca'))./100;


                %if sea ice and area don't have the same dimensions, adjust
                if size(siconc,1)<size(areaZ,1)
                    areaZ=areaZ(1:size(siconc,1),:);
                elseif size(siconc,1)>size(areaZ,1)
                    areaZ(end+1:size(siconc,1),:)=areaZ(end,:);
                end
                if size(siconc,2)<size(areaZ,2)
                    areaZ=areaZ(:,1:size(siconc,2));
                elseif size(siconc,2)>size(areaZ,2)
                    areaZ(:,end+1:size(siconc,2))=areaZ(:,end);
                end


                % reshape siconc to make life easier
                siconc=reshape(siconc,[size(siconc,1)*size(siconc,2) size(siconc,3)]);
                % select north of 30
                poslat=find(lat>=30);
                jsic=siconc(poslat,:);
                jsic(jsic>1)=NaN;

                % SIA = sum of area x sic
                SIA=squeeze(nansum(areaZ(poslat).*jsic,1)); 
                % select sic >= 15% by setting 0-15 to 0, and rest to 1
                jsic(jsic<=0.15)=0;jsic(jsic>0.15)=1;
                % SIE = sum of selected area
                SIE=squeeze(nansum(areaZ(poslat).*jsic,1)); 

                clear poslat jsic
                %concatenate here if ifile~=1
                if ifile==1
                    saveSIA=SIA(:);
                    saveSIE=SIE(:);
                    savetime=time(:);
                else
                    saveSIA=cat(1,saveSIA,SIA(:));
                    saveSIE=cat(1,saveSIE,SIE(:));
                    savetime=cat(1,savetime,time(:));
                end
                clear SIA SIE siconc time

            end
            clear loadorder
%saving as csv
Time=savetime;
SIA=saveSIA;
SIE=saveSIE;
T=table(Time,SIA,SIE);
writetable(T,[char(SSP(imod).Models) '_' char(SSP(imod).Ensembles{iens}) '_' ssp '_SIA_SIE_m_a.csv'])
clear Time SIA SIE T savetime saveSIA saveSIE            
close all
        end %siconc or siconca

    end %iens
    end %if not CNRM-HR, that I need to code at some point
end %imod
clear SSP
end %ssp