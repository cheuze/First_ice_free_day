%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generates the daily sea ice area SIA and extent SIE, for CNRM-HR only
% Saves them as .csv
% Arctic defined as all locations north of 30 degree N
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileZ=dir('*_CNRM-CM6-1-HR_ssp585_*.nc');
areaZ=ncread('areacello_Ofx_CNRM-CM6-1-HR_piControl_r1i1p1f2_gn.nc','areacello');
lat=ncread(fileZ(1).name,'lat');
poslat=find(lat>=30);

areaZ(areaZ>1E15)=NaN;

for ifile=1:3
    time=ncread(fileZ(ifile).name,'time');
    for iT=1:length(time)
        siconc=squeeze(ncread(fileZ(ifile).name,'siconc',[1 1 iT],[Inf Inf 1]))./100;
        siconc(siconc>1)=NaN;
        SIA(iT,1)=squeeze(nansum(areaZ(poslat).*siconc(poslat),1)); 
        siconc(siconc<=0.15)=0;siconc(siconc>0.15)=1;
        SIE(iT,1)=squeeze(nansum(areaZ(poslat).*siconc(poslat),1)); 
        clear siconc
    end
    if ifile==1
        saveSIA=SIA(:);
        saveSIE=SIE(:);
        savetime=time(:);
    else
        saveSIA=cat(1,saveSIA,SIA(:));
        saveSIE=cat(1,saveSIE,SIE(:));
        savetime=cat(1,savetime,time(:));
    end
    clear time SIA SIE
end

Time=savetime;
SIA=saveSIA;
SIE=saveSIE;
T=table(Time,SIA,SIE);
writetable(T,'CNRM-CM6-1-HR_r1i1p1f2_ssp585_SIA_SIE_m_o.csv')
