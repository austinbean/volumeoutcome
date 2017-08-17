* Add Fids:
do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"


import delimited "${birthdo}hosps.csv", clear

keep  facname fid

save "${birthdata}fids.dta", replace


* Also generate and add level information:  

quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/Import 1990 - 2012.do"

keep fid year NeoIntensive SoloIntermediate NeoIntensiveCapacity NeoIntermediateCapacity TotalDeliveries TransfersOut_NO_NICU-TransfersOut_HAS_NICU TransfersInternally_HAS_NICU

save "${birthdata}LevelInfo.dta", replace
