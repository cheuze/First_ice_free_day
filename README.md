Scripts to recreate the results of Heuzé and Jahn (2024) "The first ice-free day in the Arctic Ocean could occur before 2030"

These scripts require the following CMIP6 variables, for the models / ensemble members / experiments of your choice:
- daily siconc (preferred) or siconca
- areacello if using siconc; areacella if using siconca
- monthly simass
- daily tas
- daily psl

The netcdf files containing the daily and monthly SIA and SIE values can be recreated using the scripts here, or can be directly downloaded from the Arctic Data Center.

Also uploaded the two optional xls tables:
- Models_v1 lists the models that passed the historical comparison test;
- ChosenOnes lists the models, ensemble members, and experiments of the quick transition simulations that we investigated using the storyline approach.

Each script comes with a long preamble that gives more information about thresholds used, output structure etc
