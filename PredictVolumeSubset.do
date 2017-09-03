* Volume Prediction in LBW/NICU/subset


do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"


use "${birthdata}Births2005-2012wCounts.dta"
keep if b_bplace == 1
keep if year == 2010

drop if pat_zip < 70000 | pat_zip > 79999
drop if fid == .

gen fidcn51 = 0
label variable fidcn51 "51 fidcn"
gen faclatcn51 = 0
label variable faclatcn51 "51 faclatcn"
gen faclongcn51 = 0
label variable faclongcn51 "51 faclongcn"
gen zipfacdistancecn51 = 0
label variable zipfacdistancecn51 "51 zipfacdistancecn"

replace chosenind = 51 if chosenind == .


gen chdist2 = chdist^2

gen patid = _n

* drop a bunch of variables here BEFORE the reshape to cut down on the time taken.  

keep zipfacdistancecn*  fidcn* faclatcn* faclongcn* fid patid

reshape long fidcn faclatcn faclongcn zipfacdistancecn, i(patid) j(hs)

		* records the choice, or sets it to OO.
gen chosen = 0
bysort patid: replace chosen = 1 if fid == fidcn
bysort patid: gen chsm = sum(chosen)
bysort patid: egen choo = max(chsm)
bysort patid: replace chosen = 1 if choo == 0 & fidcn == 0





	* some checks - does anyone have two chosen facilities?
	* And has everyone chosen a facility?  (After these checks, everyone is correct.)
bysort patid: gen sm = sum(chosen)
bysort patid: egen ch1 = max(sm)
bysort patid fidcn: gen fidid = _n
drop if fidid > 1
drop sm ch1 fidid
* can also check this by doing tab chosen and comparing count of 1's to unique patid - is equal.


gen zipfacdistancecn2 = zipfacdistancecn^2

keep patid fid fidcn  chosen zipfacdistancecn zipfacdistancecn2 hs




/*
* Estimating two choice models - first w/out facility FE's, second with.

	clogit chosen zipfacdistancecn zipfacdistancecn2 , group(patid)

	mat a1 = e(b)
	estimates save "${birthdata}nicuchoicedistanceonly", replace

	predict pr1

	clogit chosen zipfacdistancecn zipfacdistancecn2 i.fidcn, group(patid)
	estimates save "${birthdata}nicuchoicedistancefes", replace

	predict pr2
*/

bysort patid: egen mprob = max(pr2)
gen ind1 = 0
bysort patid: replace ind1 = 1 if pr2 == mprob

gen fdshr = 0
replace fdshr = fidcn if ind1 == 1
bysort patid: egen fshr = max(fdshr)
label variable fdshr "fid of fac w/ max choice prob"

duplicates drop patid, force

bysort fdshr: gen cntr = _n
bysort fdshr: egen tot = max(cntr)
drop cntr
