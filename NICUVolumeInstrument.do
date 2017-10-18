* NICU patients only volume instrument.  
* See other version in VolumeInstrument.do
* This file measures the correlation between the two instruments.  

do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"



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

	keep patid fid fidcn PAT_ZIP chosen zipfacdistancecn zipfacdistancecn2 hs
	
	
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
	



* Estimating two choice models - first w/out facility FE's, second with.

	clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.ObstetricsLevel, group(patid)

	*mat a1 = e(b)
	estimates save "${birthdata}`yr' nicuchoices", replace

	predict pr1


	
	
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
		
	
}


use "${birthdata}2005_nicufidshares.dta", clear

foreach yr of numlist 2006(1)2012{

append using "${birthdata}`yr'_nicufidshares.dta"

}

rename yr ncdobyear

save "${birthdata}allyearnicufidshares.dta", replace

/*
* Checking correlation across the two instruments:

use "${birthdata}allyearnicufidshares.dta", clear
rename exp_share ex2
rename mnthly_share mn2
merge 1:m fid ncdobyear using "${birthdata}allyearfidshares.dta"
corr ex2 exp_share
  
             |      ex2 exp_sh~e
-------------+------------------
         ex2 |   1.0000
   exp_share |   0.9376   1.0000



*/
	
