clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the list of unique Models / Ensemble members available
% Saves in a structure called SSP
% Structure can be turned into Models.xlsx for convenience
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sspZ={'ssp119';'ssp126';'ssp245';'ssp370';'ssp585'};

for issp=1:length(sspZ)
    ssp=sspZ{issp};

paramZ={'siconc';'siconca'};

compt=1;SSP=struct('Models',[],'Ensembles',{});
for ipar=1:length(paramZ)
    fileZ=dir([paramZ{ipar} '*_' ssp '_*.nc']); 
    
    for ifile=1:length(fileZ)
        k=strfind(fileZ(ifile).name,'_');        
        model=string(fileZ(ifile).name(k(2)+1:k(3)-1));
        ensemble=string(fileZ(ifile).name(k(4)+1:k(5)-1));

        if compt==1 %if first file
            SSP(compt,1).Models=model; %model name stored, no Q asked
            SSP(compt,1).Ensembles{end+1}=ensemble; 
            compt=compt+1;
        else
            flag=0; ic=1;
            while ic<=compt-1 && flag==0
                flag=strcmp(model,SSP(ic,1).Models); %change flag value if model already in
                ic=ic+1;
            end
            if flag==0 %if flag value not changed
                SSP(compt,1).Models=model;
                SSP(compt,1).Ensembles{1,1}=ensemble;
                %store also ensemble
                compt=compt+1;
            else %match with ic-1 - check if ensemble differs
                flagE=0;
                for iens=1:length(SSP(ic-1,1).Ensembles)
                    flagE=strcmp(ensemble,SSP(ic-1,1).Ensembles{iens}); 
                end
                if flagE==0           
                    SSP(ic-1,1).Ensembles{end+1,1}=ensemble;
                end
                clear flagE flagG storeIens jG jE
            end
        end
                
        
        clear k model jgrid ensemble
    end
    clear fileZ
end
clear flag compt ic iens ifile iG ipar
end