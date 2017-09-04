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

	* count actual fids observed for check of model
preserve
bysort fid: gen fdcn = _n
bysort fid: egen fidcount = max(fdcn)
drop fdcn
label variable fidcount "observed count at fid"
keep fid fidcount
duplicates drop fid, force
save "${birthdata}wholepopfidtest.dta", replace
restore






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


/*
* Estimating two choice models - first w/out facility FE's, second with.

	clogit chosen zipfacdistancecn zipfacdistancecn2 , group(patid)

	mat a1 = e(b)
	estimates save "${birthdata}hospchoicedistanceonly", replace

	predict pr1

	clogit chosen zipfacdistancecn zipfacdistancecn2 i.fidcn, group(patid)
	estimates save "${birthdata}hospchoicedistancefes", replace

	predict pr2
*/

estimates use "${birthdata}hospchoicedistanceonly"
predict pr1

estimates use "${birthdata}hospchoicedistancefes"
predict pr2

	* Max probabilities of choice
	* Track the maximum probability
bysort patid: egen mprob = max(pr2)
gen ind1 = 0
bysort patid: replace ind1 = 1 if pr2 == mprob
drop mprob
	* about 3300 individuals have ind1 == 1 & fidcn == 0 -> i.e, chose the Outside Option (7% of total)
	
	* Does anyone have two choices?
bysort patid: gen smmx = sum(ind1)
bysort patid: egen ch2 = max(smmx)
tab ch2
drop smmx ch2
	* No, no one has two choices.
	

	* Get the FID corresponding to the maximum probability
gen fdshr = 0
replace fdshr = fidcn if ind1 == 1
bysort patid: egen fshr = max(fdshr)
label variable fshr "fid of fac w/ max choice prob"
drop fdshr

duplicates drop patid, force

	* Compute shares
bysort fshr: gen cntr = _n
bysort fshr: egen totcnt = max(cntr)
label variable totcnt "total count of predicted nicu admits"
drop cntr

* keep market shares only:
keep fshr totcnt
duplicates drop fshr, force

/*
	* check by merging in counts from earlier:
rename fshr fid
merge 1:1 fid using "${birthdata}wholepopfidtest.dta"
replace totcnt = 0 if _merge == 2
rename totcnt totalcountwhole
label variable totalcountwhole "whole model volume prediction"
rename fidcount fidcountwhole
label variable fidcountwhole "whole population actual volume"
drop _merge
save "${birthdata}modelcheckwhole.dta", replace

use "${birthdata}modelcheckwhole.dta", clear
merge 1:1 fid using "${birthdata}modelchecksub.dta"
replace totalcountwhole = 0 if _merge == 2
replace fidcountwhole = 0 if _merge == 2
replace totalcountnicu = 0 if _merge == 1
replace fidcountsubpop = 0 if _merge == 1
replace totalcountwhole = totalcountwhole*4
label variable totalcountwhole "whole model volume prediction, x 4"
replace fidcountwhole = fidcountwhole*4
label variable fidcountwhole "whole population actual volume, x 4"
rename fidcountwhole ACTUALvol_allpop
rename totalcountwhole PREDvol_allpop
rename totalcountnicu PREDvol_subset
rename fidcountsubpop ACTUALvol_subset
drop _merge
save "${birthdata}combinedmodelcheck.dta", replace
*/
