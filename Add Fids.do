* Add Fids:
do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"


import delimited "${birthdo}hosps.csv", clear

keep  facname fid

save "${birthdata}fids.dta", replace


/* 

What is this?  Would like to merge in the main file on
bo_facil to add fids for transferred facilities, creating the
variable transfid.  
This is the easiest way to do that with the hosps.csv file.  
Note that bo_facil is the name of facility to which infant transferred.
bo_fac1 is the name of the facility to which the mother was transffered.  
*/

import delimited "${birthdo}hosps.csv", clear

keep  facname fid
rename facname bo_facil
rename fid transfid

save "${birthdata}transfids.dta", replace


* Also generate and add level information:  

quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/Import 1990 - 2012.do"

keep fid year NeoIntensive SoloIntermediate NeoIntensiveCapacity NeoIntermediateCapacity TotalDeliveries TransfersOut_NO_NICU-TransfersOut_HAS_NICU TransfersInternally_HAS_NICU

save "${birthdata}LevelInfo.dta", replace



*  Get all distances:
* This is only the closest 10 per zipcode.  What file creates TX Zip All Hospital Distances.csv???
* I think the file I want is "TX Hospital Sets.do"
* And see this file: "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX All Distances.csv"
 import delimited "${TXhospital}TX Zip All Hospital Distances.csv"
 
keep zip ziplat ziplong fid faclat faclong zipfacdistance

bysort zip (fid): gen cntr = _n

reshape wide 
 
 
