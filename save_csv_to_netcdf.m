%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Saves the csvs as netcdf
% Reads the metadata from SIA2023_all.xlsx, generated by detect_2023.m, for
% consistency between the figures at a later stage.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



matref=readtable('SIA2023_all.xlsx');

expZ={'ssp119';'ssp126';'ssp245';'ssp370';'ssp585'};

for ipos=1:size(matref,1)
    for iexp=1:length(expZ)
        if ~isnan(table2array(matref(ipos,iexp*3)))
           try %looking for m_o.csv
            T=readtable([char(matref.Models(ipos)) '_' char(matref.Ensembles(ipos)) '_' expZ{iexp} '_SIA_SIE_m_o.csv']);
            catch
                try %looking for _o.csv
                    T=readtable([char(matref.Models(ipos)) '_' char(matref.Ensembles(ipos)) '_' expZ{iexp} '_SIA_SIE_o.csv']);
                catch
                    try %looking for m_a.csv
                        T=readtable([char(matref.Models(ipos)) '_' char(matref.Ensembles(ipos)) '_' expZ{iexp} '_SIA_SIE_m_a.csv']);
                    catch %looking for a.csv
                        T=readtable([char(matref.Models(ipos)) '_' char(matref.Ensembles(ipos)) '_' expZ{iexp} '_SIA_SIE_a.csv']);
                    end
                end
            end

            if ~isfile(['SIA_SIE_' expZ{iexp} '_' char(matref.Models(ipos)) '_' char(matref.Ensembles(ipos)) '.nc'])
        
            nccreate(['SIA_SIE_' expZ{iexp} '_' char(matref.Models(ipos)) '_' char(matref.Ensembles(ipos)) '.nc'],'time','Dimensions',{'time',size(T,1)});
            nccreate(['SIA_SIE_' expZ{iexp} '_' char(matref.Models(ipos)) '_' char(matref.Ensembles(ipos)) '.nc'],'Arctic_SIA','Dimensions',{'time',size(T,1)});
            nccreate(['SIA_SIE_' expZ{iexp} '_' char(matref.Models(ipos)) '_' char(matref.Ensembles(ipos)) '.nc'],'Arctic_SIE','Dimensions',{'time',size(T,1)});
            
            ncwrite(['SIA_SIE_' expZ{iexp} '_' char(matref.Models(ipos)) '_' char(matref.Ensembles(ipos)) '.nc'],'time',T.Time);
            ncwrite(['SIA_SIE_' expZ{iexp} '_' char(matref.Models(ipos)) '_' char(matref.Ensembles(ipos)) '.nc'],'Arctic_SIA',T.SIA);
            ncwrite(['SIA_SIE_' expZ{iexp} '_' char(matref.Models(ipos)) '_' char(matref.Ensembles(ipos)) '.nc'],'Arctic_SIE',T.SIE);
            
            clear T
            end %if netcdf not already created
        end %if model/ensemble/exp combination exists
        
    end %iexp
end %ifile

