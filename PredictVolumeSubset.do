* Volume Prediction in LBW/NICU/subset


do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"


use "${birthdata}Births2005-2012wCounts.dta"
keep if b_bplace == 1
keep if year == 2010

drop if PAT_ZIP < 70000 | PAT_ZIP > 79999
drop if fid == .

	* count by fid to compare to predicted share:
preserve
bysort fid: gen fdcn = _n
bysort fid: egen fidcount = max(fdcn)
drop fdcn
label variable fidcount "observed count at fid"
keep fid fidcount
duplicates drop fid, force
save "${birthdata}subpopfidtest.dta", replace
restore


	* Patient Count at zip code level and save results.
preserve
bysort PAT_ZIP: gen zc = _n
bysort PAT_ZIP: egen zipcount = max(zc)
keep PAT_ZIP zipcount
duplicates drop PAT_ZIP, force
save "${birthdata}subpopzipcount.dta", replace
restore

	* Generate Outside Option

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

keep PAT_ZIP zipfacdistancecn*  fidcn* faclatcn* faclongcn* fid patid 

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

keep patid PAT_ZIP fid fidcn  chosen zipfacdistancecn zipfacdistancecn2 hs




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

estimates use "${birthdata}nicuchoicedistanceonly"
predict pr1

estimates use "${birthdata}nicuchoicedistancefes"
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
	
	
* Merge zip information back in, compute shares at zipcode level
* Why are there zip-code level differences in the choice probs when the distances are the same?
* But it shouldn't matter anyway - each individual generates a share.
* But then we sum over probabilities, rather than individuals.
preserve
bysort fidcn: gen s1 = sum(pr2)
bysort fidcn: egen exp_share = max(s1)
keep fidcn exp_share
duplicates drop fidcn, force
rename fidcn fid
save "${birthdata}subpop_fidshares.dta", replace
restore


 * Expected shares from the simpler model:
 
preserve
bysort fidcn: gen shr = sum(pr1)
bysort fidcn: egen exp_share = max(shr)
keep fidcn exp_share
duplicates drop fidcn, force
rename fidcn fid
rename exp_share var_exp_share
save "${birthdata}subpop_fidshares_nofes.dta", replace
restore
	

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


	* check by merging in counts from earlier:
rename fshr fid
merge 1:1 fid using "${birthdata}subpopfidtest.dta"
replace totcnt = 0 if _merge == 2
rename totcnt totalcountnicu
label variable totalcountnicu "nicu model volume prediction"
rename fidcount fidcountsubpop
label variable fidcountsubpop "nicu sub pop actual volume"
drop _merge

merge 1:1 fid using "${birthdata}subpop_fidshares.dta"
label variable exp_share "share as sum of choice probs"

merge 1:1 fid using "${birthdata}subpop_fidshares_nofes.dta", gen(m2)
label variable var_exp_share "share as sum of choice probs, no fes"

*replace totalcountnicu = 0 if _merge == 2
*replace fidcountsubpop = 0 if _merge == 2
*replace exp_share = 0 if _merge == 1
*replace var_exp_share = 0 if m2 == 1
drop _merge m2
rename exp_share PREDshare_subpop
rename var_exp_share PREDshare_subpop_nofes

save "${birthdata}modelchecksub.dta", replace

* Merge with file in PredictVolume.do


