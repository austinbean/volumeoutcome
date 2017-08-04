* Add Fids:

import delimited "/Users/austinbean/Desktop/Birth2005-2012/hosps.csv", clear

keep  facname fid

save "/Users/austinbean/Desktop/Birth2005-2012/fids.dta", replace


* Also generate and add level information:  

do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/Import 1990 - 2012.do"

keep fid year NeoIntensive SoloIntermediate NeoIntensiveCapacity NeoIntermediateCapacity

save "/Users/austinbean/Desktop/Birth2005-2012/LevelInfo.dta", replace
