%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determines whether the historical run finishes above 2023 SIA daily minimum
% 2023 minimum daily SIA = 3.39 E12
% Saves the results in the structure mathist
%
%If yes, sets Status2014 to 1, saves the 2014 daily min SIA in Value2014. Year2023 and Value2023 are empty. 
%If no, sets Status2014 to 0, Value2014 is empty, and detects the last year when SIA was above 2023 SIA. 
%Saves the 2023-equivalent date and value in Year2023 and Value2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


mathist=struct('Models',[],'Ensembles',[],'Status2014',[],'Value2014',[],'Year2023',[],'Value2023',[]);

fileZ=dir('historical_*.csv');
for ifile=1:length(fileZ)
    k=strfind(fileZ(ifile).name,'_');
    mathist(ifile).Models=string(fileZ(ifile).name(k(1)+1:k(2)-1));
    mathist(ifile).Ensembles=string(fileZ(ifile).name(k(2)+1:k(3)-1)); clear k
    T=readtable(fileZ(ifile).name);

    if ~isempty(find(~isnan(T.SIA) & ~isinf(T.SIA) & T.SIA<1E15))
        minsia=zeros(165,1);
        for iyr=1:165 %1 = 2014, 165 = 1850
            junksic=T.SIA(end-365*iyr+1:end-365*(iyr-1));
            minsia(iyr,1)=nanmin(junksic);
            clear junksic
        end

        if minsia(1,1)>=3.39E12
        mathist(ifile).Status2014=1;
        mathist(ifile).Value2014=minsia(1,1)/1E12;
        else
        mathist(ifile).Status2014=0;
        minsia=flipud(minsia);
        pos=find(minsia>=3.39E12,1,'last');
        mathist(ifile).Year2023=1849+pos;
        mathist(ifile).Value2023=minsia(pos)/1E12; 
        end
        clear pos minsia

    end
    clear T

end