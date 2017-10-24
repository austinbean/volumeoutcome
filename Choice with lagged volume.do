* Estimating versions of the model with lagged volume in them.
* use "${birthdata}Birth2006.dta", clear

use "${birthdata}CombinedFacCount.dta", clear
drop if fid == .
duplicates drop fid ncdobyear ncdobmonth, force
save "${birthdata}FacCountMissingFidDropped.dta",replace

foreach yr of numlist 2005(1)2012{


	use "${birthdata}Birth`yr'.dta", clear
	
	keep if b_bplace ==1 
	
* Add Zip Code Choice Sets - closest 50 hospitals.

	drop if b_mrzip < 70000 | b_mrzip > 79999
	* TODO - this may not be necessary
	drop if fid == .
	rename b_mrzip PAT_ZIP

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

* Reshape
	reshape long fidcn faclatcn faclongcn zipfacdistancecn, i(patid) j(hs)

* Record Choice
	gen chosen = 0
	bysort patid: replace chosen = 1 if fid == fidcn
	* This records the choice as the OO
	bysort patid: replace chosen = 1 if chosenind == 51 & fidcn == 0
	drop faclatcn faclongcn


* Some checks - does anyone have two chosen facilities?
* And has everyone chosen a facility?  (After these checks, everyone is correct.)
	bysort patid: gen sm = sum(chosen)
	bysort patid: egen ch1 = max(sm)
	bysort patid fidcn: gen fidid = _n
	drop if fidid > 1
	drop sm ch1 fidid
	* can also check this by doing tab chosen and comparing count of 1's to unique patid - will be equal.

	gen zipfacdistancecn2 = zipfacdistancecn^2

	keep patid ncdobmonth ncdobyear fid fidcn PAT_ZIP chosen zipfacdistancecn zipfacdistancecn2 hs

	
* Add more info about these, using FID, I think.  
	rename fid fiddd
	rename fidcn fid
	gen year = `yr'
	merge m:1 fid year using  "${birthdata}AllHospInfo1990-2012.dta"
	drop if _merge == 2
	* remember: cannot drop if fid == 0!
	drop if _merge ==1 & fid != 0
	drop if (ObstetricCare == 0 & NeoIntensive == 0 & SoloIntermediate == 0) & fid != 0
	rename fid fidcn
	rename fiddd fid
	
	
* Fix variables in choice in Outside Option:
	replace NeoIntensive = 0 if fidcn == 0
	replace SoloIntermediate = 0 if fidcn == 0
	replace ObstetricCare = 0 if fidcn == 0
	replace ObstetricsLevel = 0 if fidcn == 0
	replace ObstetricCare = 0 if fidcn == 0
	
* Fix dumb errors in Obstetrics Level
	replace ObstetricsLevel = . if ObstetricsLevel == -9


* Estimating two choice models - first w/out facility FE's, second with.
	label variable zipfacdistancecn "Distance to Chosen"
	label variable zipfacdistancecn2 "Squared Distance to Chosen"
	label variable NeoIntensive "Level 3"
	label variable SoloIntermediate "Level 2"
	label variable ObstetricsLevel "Obstetrics Level"
	label variable chosen "Hosp. Chosen"
	
	eststo cnicu_`yr': clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.ObstetricsLevel, group(patid)
	unique patid
	estadd local pN "`r(N)'"

* Merge predicted shares
	drop _merge
	merge m:1 ncdobyear fid using "${birthdata}allyearnicufidshares.dta"
	drop if _merge != 3
	drop _merge

* Merge facility level counts 
	rename fid fid_cc
	rename fidcn fid
	merge m:1 fid ncdobyear ncdobmonth using "${birthdata}FacCountMissingFidDropped.dta"
	
	drop if _merge != 3
	drop _merge
	*mat a1 = e(b)
	*estimates save "${birthdata}`yr' nicuchoices", replace

	*predict pr1
	
	
	clogit chosen prev_q zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.ObstetricsLevel, group(patid)
	
	clogit chosen prev_*_month zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.ObstetricsLevel, group(patid)

	
	
	/*
* Compute Shares and save
	bysort fidcn: gen shr = sum(pr1)
	bysort fidcn: egen exp_share = max(shr)
	keep fidcn exp_share
	duplicates drop fidcn, force
	rename fidcn fid
	* this next step does not matter.
	gen mnthly_share = exp_share/12
	gen yr = `yr'
	save "${birthdata}`yr'_nicufidshares.dta", replace
	*/	
	
}
