* Estimating versions of the model with lagged volume in them.
/*
For questions related to 10/24 presentation: 
	- choice model with lagged volume
	- instrumenting given choice w/ lagged volume
	- total population choice w/ lagged volume
*/


/* 
use "${birthdata}Birth2006.dta", clear
gen 
*/

do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"

/*
* This needs to be run only when CombinedFacCount.dta is changed, just to drop some missing values.
use "${birthdata}CombinedFacCount.dta", clear
drop if fid == .
duplicates drop fid ncdobyear ncdobmonth, force
save "${birthdata}FacCountMissingFidDropped.dta",replace
*/
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
	
	*eststo cnicu_`yr': clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.ObstetricsLevel, group(patid)
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

	
	
	*clogit chosen prev_q zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.ObstetricsLevel, group(patid)
	
	clogit chosen prev_*_month zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.ObstetricsLevel, group(patid)
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
	save "${birthdata}`yr'_nicuvolfidshares.dta", replace
	
}





* Get quarterly values:
* Merge this with the patient choice data to see if they care about vlbw, lbw, etc.  

	use "${birthdata}CombinedFacCount.dta", clear
	
	drop prev_1_month-prev_12_month total_1_months-total_6_months total_1_lbw-total_6_lbw total_1_vlbw-total_6_vlbw lag_1_months-lag_6_months lag_1_lbw-lag_6_lbw lag_1_vlbw-lag_6_vlbw

	sort facname ncdobyear ncdobmonth
	* Generate quarterly counts of NICU admits, corresponding to calendar quarters
	bysort facname ncdobyear (ncdobmonth): gen qr1_i = month_count + month_count[_n-1] + month_count[_n-2] if ncdobmonth == 3
	bysort facname ncdobyear (ncdobmonth): gen qr2_i = month_count + month_count[_n-1] + month_count[_n-2] if ncdobmonth == 6
	bysort facname ncdobyear (ncdobmonth): gen qr3_i = month_count + month_count[_n-1] + month_count[_n-2] if ncdobmonth == 9
	bysort facname ncdobyear (ncdobmonth): gen qr4_i = month_count + month_count[_n-1] + month_count[_n-2] if ncdobmonth == 12
	
	bysort facname ncdobyear (ncdobmonth): egen qr1 = max(qr1_i) if ncdobmonth == 1 | ncdobmonth == 2 | ncdobmonth == 3
	bysort facname ncdobyear (ncdobmonth): egen qr2 = max(qr2_i) if ncdobmonth == 4 | ncdobmonth == 5 | ncdobmonth == 6
	bysort facname ncdobyear (ncdobmonth): egen qr3 = max(qr3_i) if ncdobmonth == 7 | ncdobmonth == 8 | ncdobmonth == 9
	bysort facname ncdobyear (ncdobmonth): egen qr4 = max(qr4_i) if ncdobmonth == 10 | ncdobmonth == 11 | ncdobmonth == 12
	
	egen qr_tot = rowtotal(qr1 qr2 qr3 qr4)
	gen quarter = .
	replace quarter = 1 if ncdobmonth == 1 | ncdobmonth == 2 | ncdobmonth == 3
	replace quarter = 2 if ncdobmonth == 4 | ncdobmonth == 5 | ncdobmonth == 6
	replace quarter = 3 if ncdobmonth == 7 | ncdobmonth == 8 | ncdobmonth == 9
	replace quarter = 4 if ncdobmonth == 10 | ncdobmonth == 11 | ncdobmonth == 12
	
	label variable qr_tot "calendar quarter nicu admits"
	label variable quarter "Quarter"
	
	drop qr*_i qr1 qr2 qr3 qr4 

	* Generate quarterly counts of LBW, corresponding to calendar quarter:
	bysort facname ncdobyear (ncdobmonth): gen qr1_i = lbw_month + lbw_month[_n-1] + lbw_month[_n-2] if ncdobmonth == 3
	bysort facname ncdobyear (ncdobmonth): gen qr2_i = lbw_month + lbw_month[_n-1] + lbw_month[_n-2] if ncdobmonth == 6
	bysort facname ncdobyear (ncdobmonth): gen qr3_i = lbw_month + lbw_month[_n-1] + lbw_month[_n-2] if ncdobmonth == 9
	bysort facname ncdobyear (ncdobmonth): gen qr4_i = lbw_month + lbw_month[_n-1] + lbw_month[_n-2] if ncdobmonth == 12
	
	bysort facname ncdobyear (ncdobmonth): egen lbwqr1 = max(qr1_i) if ncdobmonth == 1 | ncdobmonth == 2 | ncdobmonth == 3
	bysort facname ncdobyear (ncdobmonth): egen lbwqr2 = max(qr2_i) if ncdobmonth == 4 | ncdobmonth == 5 | ncdobmonth == 6
	bysort facname ncdobyear (ncdobmonth): egen lbwqr3 = max(qr3_i) if ncdobmonth == 7 | ncdobmonth == 8 | ncdobmonth == 9
	bysort facname ncdobyear (ncdobmonth): egen lbwqr4 = max(qr4_i) if ncdobmonth == 10 | ncdobmonth == 11 | ncdobmonth == 12
	
	egen qr_tot_lbw = rowtotal(lbwqr1 lbwqr2 lbwqr3 lbwqr4)
	label variable qr_tot_lbw "calendar quarter lbw admits"
	drop qr*_i lbwqr1-lbwqr4
	
	
	* Generate Quarterly counts of VLBW, corresponding to calender quarter:
	
	bysort facname ncdobyear (ncdobmonth): gen qr1_i = vlbw_month + vlbw_month[_n-1] + vlbw_month[_n-2] if ncdobmonth == 3
	bysort facname ncdobyear (ncdobmonth): gen qr2_i = vlbw_month + vlbw_month[_n-1] + vlbw_month[_n-2] if ncdobmonth == 6
	bysort facname ncdobyear (ncdobmonth): gen qr3_i = vlbw_month + vlbw_month[_n-1] + vlbw_month[_n-2] if ncdobmonth == 9
	bysort facname ncdobyear (ncdobmonth): gen qr4_i = vlbw_month + vlbw_month[_n-1] + vlbw_month[_n-2] if ncdobmonth == 12
	
	bysort facname ncdobyear (ncdobmonth): egen vlqr1 = max(qr1_i) if ncdobmonth == 1 | ncdobmonth == 2 | ncdobmonth == 3
	bysort facname ncdobyear (ncdobmonth): egen vlqr2 = max(qr2_i) if ncdobmonth == 4 | ncdobmonth == 5 | ncdobmonth == 6
	bysort facname ncdobyear (ncdobmonth): egen vlqr3 = max(qr3_i) if ncdobmonth == 7 | ncdobmonth == 8 | ncdobmonth == 9
	bysort facname ncdobyear (ncdobmonth): egen vlqr4 = max(qr4_i) if ncdobmonth == 10 | ncdobmonth == 11 | ncdobmonth == 12
	
	egen qr_tot_vlbw = rowtotal(vlqr1 vlqr2 vlqr3 vlqr4)
	label variable qr_tot_vlbw "calendar quarter vlbw admits"
	
	drop qr*_i vlqr1-vlqr4
	
	duplicates drop facname ncdobyear quarter, force
	drop ncdobmonth
	drop b_bcntyc
* drop non-quarterly variables.	
	drop month_count* lbw_month* vlbw_month* monthly_admit_deaths month_mort_all prev_*_q
	
	
	save "${birthdata}QuarterlyFacCount.dta", replace
	
	
	
