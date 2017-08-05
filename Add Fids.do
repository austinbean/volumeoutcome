* Add Fids:
do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"


import delimited "${birthdata}/hosps.csv", clear

keep  facname fid

save "${birthdata}/fids.dta", replace


* Also generate and add level information:  

do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/Import 1990 - 2012.do"

keep fid year NeoIntensive SoloIntermediate NeoIntensiveCapacity NeoIntermediateCapacity

save "${birthdata}/LevelInfo.dta", replace
