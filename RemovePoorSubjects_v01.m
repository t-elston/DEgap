function outdata = RemovePoorSubjects_v01(wPdata,Within_AllData)


Poor_pIDs = wPdata.Demographics.pID(wPdata.Demographics.CouldExclude);


PoorPerfIX = ismember(Within_AllData.vpNum,Poor_pIDs);
Within_AllData(PoorPerfIX,:)=[];

outdata = Within_AllData;


end % of function