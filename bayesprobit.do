* Try using Bayesm to get the probit



do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"

use "${birthdata}Birth2007.dta", clear

/* keep Tom Green County (San Angelo) only just to keep size small. */
keep if b_bcntyc == 226


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
	
	
* JUST KEEP San Angelo Community and Shannon West Texas...

	keep if fidcn == 4516013 | fidcn == 4513000 | fidcn == 0
	bysort patid: replace hs = _n
	bysort patid: egen nnn = max(hs)
	drop nnn


* probit on distance
bayes: mprobit chosen zipfacdistancecn zipfacdistancecn2




* set factor var for fidcn w/out base category
fvset base none fidcn

* add "dryrun" at the end of any command to see the parameter names

bayesmh neonataldeath i.fidcn b_wt_cgr, reffects(fidcn) likelihood(probit) ///
prior({neonataldeath:b_wt_cgr}, normal(0, 100)) ///
prior({neonataldeath:i.fidcn}, normal({mu}, {sig2})) ///
prior({mu}, normal(0,100)) ///
prior({sig2}, igamma(0.001, 0.001)) ///
prior({_cons}, normal(0,1000)) 



* The equation for the choice...
gen choice = 0
replace choice = 1 if fidcn == fid

bayesmh choice i.fidcn, reffects(fidcn) likelihood(probit) ///
prior({choice:i.fidcn}, normal({mu}, {sig2})) ///
prior({mu}, normal(0,100)) ///
prior({sig2}, igamma(0.001, 0.001)) ///
prior({choice:_cons}, normal(0,1000)) 


* Combined...
* This seems like it can work, actually.  

bayesmh (choice i.fidcn, likelihood(probit)) (neonataldeath i.fidcn, likelihood(probit)), ///
prior({choice:i.fidcn}, normal({mu}, {sig2})) ///
prior({neonataldeath:i.fidcn}, normal({mu}, {sig2})) ///
prior({mu}, normal(0,100)) ///
prior({sig2}, igamma(0.001, 0.001)) ///
prior({choice:_cons}, normal(0,100)) ///
prior({neonataldeath:_cons}, normal(0,100)) 

dryrun
