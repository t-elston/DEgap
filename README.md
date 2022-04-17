# DEgap
MATLAB code used to analyze data the from "Outcome uncertainty influences probability perception and risk attitudes" in RSOS (2021)

After loading the code onto your machine, open the file aaaDE_MainAnalysis_v02.m. This is the high-level script that all analyses are called from. 
These code depend on loading data in excel tables, which are also provided on this OSF repository. Be sure to specify where these data are on your 
computer by changing the BETWEENDIR and WITHINDIR variables in aaaDE_MainAnalysis_v02. 

To look at individual plots and their accompanying statistics, set break points at the end of each analysis function. Generally, the functions
which plot data also analyzed data. 
