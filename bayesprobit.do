* Try using Bayesm to get the probit



do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"

use "${birthdata}Birth2007.dta", clear

/* keep Tom Green County (San Angelo) only just to keep size small. */
	*keep if b_bcntyc == 226
/* keep Travis county */
	keep if b_bcntyc == 227

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
	
* For Travis County... keep only TC facilities.
	keep if fidcn == 4530200 | fidcn == 4536253 | fidcn == 4530170 | fidcn == 4530190 | fidcn == 4536048 | fidcn == 4536337 | fidcn == 4536338 | fidcn == 0
	bysort patid: replace hs = _n
	bysort patid: egen nnn = max(hs)
	tab nnn 
	drop if nnn != 8
	drop nnn

	
	* set factor var for fidcn w/out base category
	fvset base none fidcn

* probit on distance
bayes: mprobit chosen i.fidcn zipfacdistancecn zipfacdistancecn2






* add "dryrun" at the end of any command to see the parameter names

	bayesmh neonataldeath i.fidcn b_wt_cgr, reffects(fidcn) likelihood(probit) ///
	prior({neonataldeath:b_wt_cgr}, normal(0, 100)) ///
	prior({neonataldeath:i.fidcn}, normal({mu}, {sig2})) ///
	prior({mu}, normal(0,100)) ///
	prior({sig2}, igamma(0.001, 0.001)) ///
	prior({_cons}, normal(0,1000)) 

* Health states to include:
* i.b_es_ges i.pay 
* as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   

	bayesmh neonataldeath b_wt_cgr ///
	antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa, ///
	reffects(fidcn) likelihood(probit) ///
	prior({neonataldeath:b_wt_cgr}, normal(0, 100)) ///
	prior({neonataldeath:i.fidcn}, normal({mu}, {sig2})) ///
	prior({mu}, normal(0,100)) ///
	prior({sig2}, igamma(0.001, 0.001)) ///
	prior({_cons}, normal(0,1000)) ///
	prior({neonataldeath:antibiot}, normal(0,100)) ///
	prior({neonataldeath:seizure}, normal(0,100)) ///
	prior({neonataldeath:b_injury}, normal(0,100)) ///
	prior({neonataldeath:bca_aeno}, normal(0,100)) ///
	prior({neonataldeath:bca_spin}, normal(0,100)) ///
	prior({neonataldeath:congenhd}, normal(0,100)) ///
	prior({neonataldeath:bca_hern}, normal(0,100)) ///
	prior({neonataldeath:congenom}, normal(0,100)) ///
	prior({neonataldeath:congenga}, normal(0,100)) ///
	prior({neonataldeath:bca_limb}, normal(0,100)) ///
	prior({neonataldeath:hypsospa}, normal(0,100)) 
	
	* can specify all the priors above as: prior( {neonataldeath:bca_hern}{neonataldeath:antibiot} ... normal(0,100))

	
* try to look at the graph:
* bayesgraph diagnostic {neonataldeath:4513000.fidcn}


* The equation for the choice...
gen choice = 0
replace choice = 1 if fidcn == fid

bayesmh choice, reffects(fidcn) likelihood(probit) ///
prior({choice:i.fidcn}, normal({mu}, {sig2})) ///
prior({mu}, normal(0,100)) ///
prior({sig2}, igamma(0.001, 0.001)) ///
prior({choice:_cons}, normal(0,1000)) 


gen choice = 0
replace choice = 1 if fidcn == fid

bayesmh choice zipfacdistancecn zipfacdistancecn2, reffects(fidcn) likelihood(probit) ///
prior({choice:i.fidcn}, normal({mu}, {sig2})) ///
prior({mu}, normal(0,100)) ///
prior({sig2}, igamma(0.001, 0.001)) ///
prior({choice:_cons}, normal(0,1000)) ///
prior({choice:zipfacdistancecn}, normal(0, 5)) ///
prior({choice:zipfacdistancecn2}, normal(0,5)) 



* bayesgraph diagnostic {choice:4513000.fidcn}
* bayesgraph diagnostic {choice:4536253.fidcn}


* Combined...
* This seems like it can work, actually.  

bayesmh (choice i.fidcn, likelihood(probit)) (neonataldeath i.fidcn, likelihood(probit)), ///
prior({choice:i.fidcn}, normal({mu}, {sig2})) ///
prior({neonataldeath:i.fidcn}, normal({mu}, {sig2})) ///
prior({mu}, normal(0,100)) ///
prior({sig2}, igamma(0.001, 0.001)) ///
prior({choice:_cons}, normal(0,100)) ///
prior({neonataldeath:_cons}, normal(0,100)) 


* Another combined version with more health states...

bayesmh (neonataldeath i.fidcn b_wt_cgr antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa, likelihood(probit) )  ///
	(choice i.fidcn zipfacdistancecn zipfacdistancecn2, likelihood(probit) ), ///
	prior({neonataldeath:b_wt_cgr}, normal(0, 100)) ///
	prior({neonataldeath:_cons},    normal(0,1000)) ///
	prior({neonataldeath:antibiot}, normal(0,100)) ///
	prior({neonataldeath:seizure},  normal(0,100)) ///
	prior({neonataldeath:b_injury}, normal(0,100)) ///
	prior({neonataldeath:bca_aeno}, normal(0,100)) ///
	prior({neonataldeath:bca_spin}, normal(0,100)) ///
	prior({neonataldeath:congenhd}, normal(0,100)) ///
	prior({neonataldeath:bca_hern}, normal(0,100)) ///
	prior({neonataldeath:congenom}, normal(0,100)) ///
	prior({neonataldeath:congenga}, normal(0,100)) ///
	prior({neonataldeath:bca_limb}, normal(0,100)) ///
	prior({neonataldeath:hypsospa}, normal(0,100)) ///
	prior({neonataldeath:i.fidcn},  normal({mu}, {sig2})) ///
	prior({choice:i.fidcn},         normal({mu}, {sig2})) ///
	prior({choice:_cons},           normal(0,1000)) ///
	prior({choice:zipfacdistancecn},normal(0, 5)) ///
	prior({choice:zipfacdistancecn2},normal(0,5)) ///
	prior({mu}, normal(0,100)) ///
	prior({sig2}, igamma(0.001, 0.001))


	
	
	
* For travis cty:

bayestest interval (prob1: {neonataldeath:4536253.fidcn} - ///
 max({neonataldeath:4530170.fidcn}, {neonataldeath:4530190.fidcn}, ///
 {neonataldeath:4530200.fidcn}, {neonataldeath:4536048.fidcn}, ///
 {neonataldeath:4536337.fidcn}, {neonataldeath:4536338.fidcn}) ), upper(0)
 
* Test all Travis county...

bayestest interval (prob12: {neonataldeath:4536253.fidcn} - {neonataldeath:4530170.fidcn}) ), upper(0)
bayestest interval (prob13: {neonataldeath:4536253.fidcn} - {neonataldeath:4530190.fidcn}) ), upper(0)
bayestest interval (prob14: {neonataldeath:4536253.fidcn} - {neonataldeath:4530200.fidcn}) ), upper(0)
bayestest interval (prob15: {neonataldeath:4536253.fidcn} - {neonataldeath:4536048.fidcn}) ), upper(0)
bayestest interval (prob16: {neonataldeath:4536253.fidcn} - {neonataldeath:4536337.fidcn}) ), upper(0)
bayestest interval (prob17: {neonataldeath:4536253.fidcn} - {neonataldeath:4536338.fidcn}) ), upper(0)

bayestest interval (prob23: {neonataldeath:4530170.fidcn} - {neonataldeath:4530190.fidcn}) ), upper(0)
bayestest interval (prob24: {neonataldeath:4530170.fidcn} - {neonataldeath:4530200.fidcn}) ), upper(0)
bayestest interval (prob25: {neonataldeath:4530170.fidcn} - {neonataldeath:4536048.fidcn}) ), upper(0)
bayestest interval (prob26: {neonataldeath:4530170.fidcn} - {neonataldeath:4536337.fidcn}) ), upper(0)
bayestest interval (prob27: {neonataldeath:4530170.fidcn} - {neonataldeath:4536338.fidcn}) ), upper(0)

bayestest interval (prob34: {neonataldeath:4530190.fidcn} - {neonataldeath:4530200.fidcn}) ), upper(0)
bayestest interval (prob35: {neonataldeath:4530190.fidcn} - {neonataldeath:4536048.fidcn}) ), upper(0)
bayestest interval (prob36: {neonataldeath:4530190.fidcn} - {neonataldeath:4536337.fidcn}) ), upper(0)
bayestest interval (prob37: {neonataldeath:4530190.fidcn} - {neonataldeath:4536338.fidcn}) ), upper(0)

bayestest interval (prob45: {neonataldeath:4530200.fidcn} - {neonataldeath:4536048.fidcn}) ), upper(0)
bayestest interval (prob46: {neonataldeath:4530200.fidcn} - {neonataldeath:4536048.fidcn}) ), upper(0)
bayestest interval (prob47: {neonataldeath:4530200.fidcn} - {neonataldeath:4536048.fidcn}) ), upper(0)

bayestest interval (prob56: {neonataldeath:4536048.fidcn} - {neonataldeath:4536337.fidcn}) ), upper(0)
bayestest interval (prob57: {neonataldeath:4536048.fidcn} - {neonataldeath:4536338.fidcn}) ), upper(0)

bayestest interval (prob67: {neonataldeath:4536337.fidcn} - {neonataldeath:4536338.fidcn}) ), upper(0)


