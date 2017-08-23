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
import delimited "${TXhospital}TX All Distances.csv", clear
 
 

rename v1 PAT_ZIP
rename v2 ZIP_LAT
rename v3 ZIP_LONG

rename v4 fid
rename v5 facility
rename v6 county
drop v7 
rename v8 city
drop v9 
rename v10 TotalBeds
rename v11 NeoIntensive
* Next variable is year - this should be taken care of as the facilty may differ
drop v12 
rename v13 TotalDeliveries
rename v14 TransfersOut_NO_NICU
rename v15 TransfersInFromOthers_HAS_NICU
rename v16 TransfersOut_HAS_NICU
rename v17 nfpstatus
rename v18 FTEPhysDent
rename v19 FTETotalPers
rename v20 SoloIntermediate
rename v21 faclat
rename v22 faclong
rename v23 firstyear
rename v24 lastyear
rename v25 zipfacdistance
 
keep PAT_ZIP ZIP_LAT ZIP_LONG fid faclat faclong zipfacdistance

* Give these variables different names to distinguish them from choice set elements.

rename fid fidcn
rename faclat faclatcn
rename faclong faclongcn
rename zipfacdistance zipfacdistancecn


* This keeps the 50 closest hospitals.  
bysort PAT_ZIP (zipfacdistancecn): gen cntr = _n
keep if cntr <= 50

reshape wide fidcn faclatcn faclongcn zipfacdistancecn, i(PAT_ZIP)  j(cntr)
 
save "${birthdata}closest50hospitals.dta", replace
