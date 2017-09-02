* Predict Volume.

/*

-Estimate a model of choice, depending on distance alone, eg.
-Use this to predict volumes

*/


do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"

use "${inpatient}2010 4 Quarter PUDF.dta"


	* Keep pregnancy and delivery related
keep if hcfa_mdc == 14 | hcfa_mdc == 15

	* keep only those below 1 year
destring pat_age, replace force
keep if pat_age == 0 | pat_age == 1 

destring pat_zip, replace force

	* Keep only necessary variables.  
keep thcic_id pat_zip


	* Add Hospital FID
gen fid = .
capture rename thcic_id THCIC_ID
quietly do "${TXhospital}TX Hospital Code Match.do"

	* Add Zip Code Choice Sets - closest 50 hospitals.

drop if pat_zip < 70000 | pat_zip > 79999
drop if fid == .

rename pat_zip PAT_ZIP

merge m:1 PAT_ZIP using "${birthdata}closest50hospitals.dta"

drop if _merge != 3

drop _merge

	* Figure out which option chosen.
	
gen chosenind = .

forvalues i=1/50{
di "`i'"
replace chosenind = `i' if fidcn`i' == fid
}


	* Add Outside Option
	* Anyone who didn't choose one of the 50 closest.
gen fidcn51 = 0
gen faclatcn51 = 0
gen faclongcn51 = 0
gen zipfacdistancecn51 = 0

replace chosenind = 51 if chosenind == .

	* Record distance to chosen facility

gen chdist = .

forvalues n = 1/51{

replace chdist = zipfacdistancecn`n' if chosenind == `n'

}
label variable chdist "distance to chosen hospital"

gen chdist2 = chdist^2

gen patid = _n

reshape long fidcn faclatcn faclongcn zipfacdistancecn, i(patid) j(hs)

gen chosen = 0
bysort patid: replace chosen = 1 if fid == fidcn
	* This records the choice as the OO
bysort patid: replace chosen = 1 if chosenind == 51 & fidcn == 0
drop faclatcn faclongcn


	* some checks - does anyone have two chosen facilities?
bysort patid: gen sm = sum(chosen)
bysort patid: egen ch1 = max(sm)

bysort patid fidcn: gen fidid = _n
count if fidid > 1 & chosen == 1







