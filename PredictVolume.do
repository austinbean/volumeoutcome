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
	* And has everyone chosen a facility?  (After these checks, everyone is correct.)
bysort patid: gen sm = sum(chosen)
bysort patid: egen ch1 = max(sm)
bysort patid fidcn: gen fidid = _n
drop if fidid > 1
drop sm ch1 fidid
* can also check this by doing tab chosen and comparing count of 1's to unique patid - will be equal.

gen zipfacdistancecn2 = zipfacdistancecn^2

keep patid fid fidcn PAT_ZIP chosen zipfacdistancecn zipfacdistancecn2 hs



clogit chosen zipfacdistancecn zipfacdistancecn2 , group(patid)

mat a1 = e(b)
estimates save "${birthdata}hospchoicedistanceonly", replace

predict pr1


clogit chosen zipfacdistancecn zipfacdistancecn2 i.fidcn, group(patid)
estimates save "${birthdata}hospchoicedistancefes", replace


predict pr2


bysort patid: egen mprob = max(pr2)
gen ind1 = 0
bysort patid: replace ind1 = 1 if pr2 == mprob

gen fdshr = 0
replace fdshr = fidcn if ind1 == 1
bysort patid: egen fshr = max(fdshr)

* try an asclogit to get a zip-specific effect:
* takes too long for now...  
* asclogit chosen zipfacdistancecn zipfacdistancecn2 , case(patid) alternatives(hs) casevars(i.PAT_ZIP) from(a1)


