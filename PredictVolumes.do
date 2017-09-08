* Predict all volumes using model 1, with no FEs.

do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"

* /2012


forval nm = 2005/2010{

* Use whole years:
	use "${inpatient}`nm' 1 Quarter PUDF.dta"
	append using "${inpatient}`nm' 2 Quarter PUDF.dta", force
	append using "${inpatient}`nm' 3 Quarter PUDF.dta", force
	append using "${inpatient}`nm' 4 Quarter PUDF.dta", force
	
	/*
	There are variable type mismatches in the 2, 3, and 4 quarters of 2010 (only), but these do not matter since only thcic_id and pat_zip are kept.  
	*/

* change variable case:
	rename *, lower

* Keep only the correct MDC
	capture keep if hcfa_mdc == 14 | hcfa_mdc == 15
	capture keep if cms_mdc == 14 | apr_mdc == 15


* keep only those below 1 year
	capture rename patient_age pat_age
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


* Add Outside Option - Anyone who didn't choose one of the 50 closest.
	gen fidcn51 = 0
	gen faclatcn51 = 0
	gen faclongcn51 = 0
	gen zipfacdistancecn51 = 0
	

* Reshape:
	gen patid = _n
	reshape long fidcn faclatcn faclongcn zipfacdistancecn, i(patid) j(hs)

* Drop unnecessary variables:

	gen zipfacdistancecn2 = zipfacdistancecn^2
	keep patid fid fidcn PAT_ZIP zipfacdistancecn zipfacdistancecn2 hs

* Try a second model:
	* this would potentially work with the recreation of "chosen"
	*clogit chosen zipfacdistancecn zipfacdistancecn2 , group(patid)

	
	
* Use existing estimates and predict choice probs:
	estimates use "${birthdata}hospchoicedistanceonly"
	predict pr1


	

* Compute shares from simple choice model:

	bysort fidcn: gen shr = sum(pr1)
	bysort fidcn: egen exp_share = max(shr)
	keep fidcn exp_share
	duplicates drop fidcn, force
	rename fidcn fid
	gen yr = `nm'

	
* Save shares	
	save "${birthdata}predictedshares_`nm'.dta", replace


}

* Combine all of the results
	use "${birthdata}predictedshares_2005.dta", clear

	forval nm = 2006/2010{
		append using "${birthdata}predictedshares_`nm'.dta"
	}
	rename yr ncdobyear
	save "${birthdata}combinedpredictedshares.dta", replace
