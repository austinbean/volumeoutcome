* Texas DSHS Birth Data

do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"


* Imports and labels:

foreach nm of numlist 2005(1)2012{

import delimited "${birthdata}Birth`nm'.csv"

do "${birthdo}/Label Variables.do"

gen year = `nm'

* Add FIDS to patient records:
* Merge now on names using hosps.csv, which were matched to FIDS by hand.  
	* The file LevelInfo produced in AddFids.do using Import 1990 - 2012.do
merge m:1 fid year using "${birthdata}LevelInfo.dta", gen(facinfo)
drop if facinfo == 2
label variable facinfo "No facility information available"
replace facinfo = 0 if facinfo == 1 | facinfo == 2
replace facinfo = 1 if facinfo == 3
_strip_labels facinfo


save "${birthdata}Birth`nm'.dta", replace

clear
}


* Create Combined Data from All Years:

use "${birthdata}Birth2005.dta", clear

foreach nm of numlist 2006(1)2012{
append using "${birthdata}Birth`nm'.dta"
}
_strip_labels facinfo


save "${birthdata}Births2005-2012.dta", replace



* Combine Facility-level Counts into one:

foreach nm of numlist 2005(1)2012{

use "${birthdata}Birth`nm'.dta", clear

do "${birthdo}Fac-level Counts.do"

save "${birthdata}FacCount`nm'.dta", replace


}


use "${birthdata}FacCount2005.dta", clear
gen yr2005 = 2005

foreach nm of numlist 2006(1)2012{

append using "${birthdata}FacCount`nm'.dta", gen(yr`nm')

replace yr`nm' = `nm' if yr`nm' == 1
}



foreach nm of numlist 2005(1)2012{
replace yr`nm' = 0 if yr`nm' == .
}

egen year = rowtotal(yr*)
drop yr*
label variable year "Year"

* Fix first quarters...
label variable prev_q "Previous Q. Volume"
bysort facname (year ncdobmonth): replace prev_q = q4_ad[_n-1] if prev_q == . & ncdobmonth == 1
bysort facname (year ncdobmonth): replace prev_q = prev_q[_n-1] if prev_q == . & ncdobmonth == 2
bysort facname (year ncdobmonth): replace prev_q = prev_q[_n-1] if prev_q == . & ncdobmonth == 3
drop q4_ad

* more lagged quarters 
	bysort facname (year ncdobmonth): gen lag_2_quarters = prev_q[_n-3]
	bysort facname (year ncdobmonth): gen lag_3_quarters = prev_q[_n-6]
	bysort facname (year ncdobmonth): gen lag_4_quarters = prev_q[_n-9]
	label variable lag_2_quarters "2 quarters ago NICU vol"
	label variable lag_3_quarters "3 quarters ago NICU vol"
	label variable lag_4_quarters "4 quarters ago NICU vol"

* lagged months:
	bysort facname (year ncdobmonth): gen prev_1_month = month_count[_n-1]
	bysort facname (year ncdobmonth): gen prev_2_month = month_count[_n-2]
	bysort facname (year ncdobmonth): gen prev_3_month = month_count[_n-3]
	bysort facname (year ncdobmonth): gen prev_4_month = month_count[_n-4]
	bysort facname (year ncdobmonth): gen prev_5_month = month_count[_n-5]
	bysort facname (year ncdobmonth): gen prev_6_month = month_count[_n-6]
	bysort facname (year ncdobmonth): gen prev_7_month = month_count[_n-7]
	bysort facname (year ncdobmonth): gen prev_8_month = month_count[_n-8]
	bysort facname (year ncdobmonth): gen prev_9_month = month_count[_n-9]
	bysort facname (year ncdobmonth): gen prev_10_month = month_count[_n-10]
	bysort facname (year ncdobmonth): gen prev_11_month = month_count[_n-11]
	bysort facname (year ncdobmonth): gen prev_12_month = month_count[_n-12]
	label variable prev_1_month "Total NICU Admits 1 months ago"
	label variable prev_2_month "Total NICU Admits 2 months ago"
	label variable prev_3_month "Total NICU Admits 3 months ago"
	label variable prev_4_month "Total NICU Admits 4 months ago"
	label variable prev_5_month "Total NICU Admits 5 months ago"
	label variable prev_6_month "Total NICU Admits 6 months ago"
	label variable prev_7_month "Total NICU Admits 7 months ago"
	label variable prev_8_month "Total NICU Admits 8 months ago"
	label variable prev_9_month "Total NICU Admits 9 months ago"
	label variable prev_10_month "Total NICU Admits 10 months ago"
	label variable prev_11_month "Total NICU Admits 12 months ago"
	label variable prev_12_month "Total NICU Admits 12 months ago"

* months (n-2) - (n-12).  IE - not last month, but the month before.  If it is December, then I want this to be October back through January.
	bysort facname (year ncdobmonth): gen exper_10 = month_count[_n-2]+month_count[_n-3]+month_count[_n-4]+month_count[_n-5]+month_count[_n-6]+month_count[_n-7]+month_count[_n-8]+month_count[_n-9]+month_count[_n-10]+month_count[_n-11]
	label variable exper_10 "10 months prior experience, not including last month"
	
* prior 11 months:
	bysort facname (year ncdobmonth): gen prev_11_months = month_count[_n-1]+month_count[_n-2]+month_count[_n-3]+month_count[_n-4]+month_count[_n-5]+month_count[_n-6]+month_count[_n-7]+month_count[_n-8]+month_count[_n-9]+month_count[_n-10]+month_count[_n-11]
	label variable prev_11_months "Prior 11 months"
	
* lagged quarters again:
	bysort facname (year ncdobmonth): gen prev_1_q = prev_1_month + prev_2_month + prev_3_month
	bysort facname (year ncdobmonth): gen prev_2_q = prev_4_month + prev_5_month + prev_6_month
	bysort facname (year ncdobmonth): gen prev_3_q = prev_7_month + prev_8_month + prev_9_month
	bysort facname (year ncdobmonth): gen prev_4_q = prev_10_month + prev_11_month + prev_12_month
	label variable prev_1_q "1 lagged quarter admits"
	label variable prev_2_q "2 lagged quarter admits"
	label variable prev_3_q "3 lagged quarter admits"
	label variable prev_4_q "4 lagged quarter admits"
	

* 1 - 6 month counts:
	bysort facname (year ncdobmonth): gen total_1_months = month_count[_n-1] 
	bysort facname (year ncdobmonth): gen total_2_months = month_count[_n-1] + month_count[_n-2]
	bysort facname (year ncdobmonth): gen total_3_months = month_count[_n-1] + month_count[_n-2] + month_count[_n-3]
	bysort facname (year ncdobmonth): gen total_4_months = month_count[_n-1] + month_count[_n-2] + month_count[_n-3] + month_count[_n-4] 
	bysort facname (year ncdobmonth): gen total_5_months = month_count[_n-1] + month_count[_n-2] + month_count[_n-3] + month_count[_n-4] + month_count[_n-5] 
	bysort facname (year ncdobmonth): gen total_6_months = month_count[_n-1] + month_count[_n-2] + month_count[_n-3] + month_count[_n-4] + month_count[_n-5] + month_count[_n-6]
	label variable total_1_months "Cumulative NICU Admits Prior 1 months"
	label variable total_2_months "Cumulative NICU Admits Prior 2 months"
	label variable total_3_months "Cumulative NICU Admits Prior 3 Months"
	label variable total_4_months "Cumulative NICU Admits Prior 4 months"
	label variable total_5_months "Cumulative NICU Admits Prior 5 months"
	label variable total_6_months "Cumulative NICU Admits Prior 6 Months"

	bysort facname (year ncdobmonth): gen total_1_lbw = lbw_month[_n-1] 
	bysort facname (year ncdobmonth): gen total_2_lbw = lbw_month[_n-1] + lbw_month[_n-2]
	bysort facname (year ncdobmonth): gen total_3_lbw = lbw_month[_n-1] + lbw_month[_n-2] + lbw_month[_n-3]
	bysort facname (year ncdobmonth): gen total_4_lbw = lbw_month[_n-1] + lbw_month[_n-2] + lbw_month[_n-3] + lbw_month[_n-4] 
	bysort facname (year ncdobmonth): gen total_5_lbw = lbw_month[_n-1] + lbw_month[_n-2] + lbw_month[_n-3] + lbw_month[_n-4] + lbw_month[_n-5] 
	bysort facname (year ncdobmonth): gen total_6_lbw = lbw_month[_n-1] + lbw_month[_n-2] + lbw_month[_n-3] + lbw_month[_n-4] + lbw_month[_n-5] + lbw_month[_n-6]
	label variable total_1_lbw "Total LBW Prior 1 Months"
	label variable total_2_lbw "Total LBW Prior 2 Months"
	label variable total_3_lbw "Total LBW Prior 3 Months"
	label variable total_4_lbw "Total LBW Prior 4 Months"
	label variable total_5_lbw "Total LBW Prior 5 Months"
	label variable total_6_lbw "Total LBW Prior 6 Months"

bysort facname (year ncdobmonth): gen total_1_vlbw = vlbw_month[_n-1] 
bysort facname (year ncdobmonth): gen total_2_vlbw = vlbw_month[_n-1] + vlbw_month[_n-2]
bysort facname (year ncdobmonth): gen total_3_vlbw = vlbw_month[_n-1] + vlbw_month[_n-2] + vlbw_month[_n-3]
bysort facname (year ncdobmonth): gen total_4_vlbw = vlbw_month[_n-1] + vlbw_month[_n-2] + vlbw_month[_n-3] + vlbw_month[_n-4] 
bysort facname (year ncdobmonth): gen total_5_vlbw = vlbw_month[_n-1] + vlbw_month[_n-2] + vlbw_month[_n-3] + vlbw_month[_n-4] + vlbw_month[_n-5] 
bysort facname (year ncdobmonth): gen total_6_vlbw = vlbw_month[_n-1] + vlbw_month[_n-2] + vlbw_month[_n-3] + vlbw_month[_n-4] + vlbw_month[_n-5] + vlbw_month[_n-6]
label variable total_1_vlbw "Total VLBW Prior 1 Months"
label variable total_2_vlbw "Total VLBW Prior 2 Months"
label variable total_3_vlbw "Total VLBW Prior 3 Months"
label variable total_4_vlbw "Total VLBW Prior 4 Months"
label variable total_5_vlbw "Total VLBW Prior 5 Months"
label variable total_6_vlbw "Total VLBW Prior 6 Months"

* 1 - 6 lags:
bysort facname (year ncdobmonth): gen lag_1_months = month_count[_n-1] 
bysort facname (year ncdobmonth): gen lag_2_months = month_count[_n-2]
bysort facname (year ncdobmonth): gen lag_3_months = month_count[_n-3]
bysort facname (year ncdobmonth): gen lag_4_months = month_count[_n-4] 
bysort facname (year ncdobmonth): gen lag_5_months = month_count[_n-5] 
bysort facname (year ncdobmonth): gen lag_6_months = month_count[_n-6]
label variable lag_1_months " NICU Admits lag 1 months"
label variable lag_2_months " NICU Admits lag 2 months"
label variable lag_3_months " NICU Admits lag 3 Months"
label variable lag_4_months " NICU Admits lag 4 months"
label variable lag_5_months " NICU Admits lag 5 months"
label variable lag_6_months " NICU Admits lag 6 Months"

bysort facname (year ncdobmonth): gen lag_1_lbw = lbw_month[_n-1] 
bysort facname (year ncdobmonth): gen lag_2_lbw = lbw_month[_n-2]
bysort facname (year ncdobmonth): gen lag_3_lbw = lbw_month[_n-3]
bysort facname (year ncdobmonth): gen lag_4_lbw = lbw_month[_n-4] 
bysort facname (year ncdobmonth): gen lag_5_lbw = lbw_month[_n-5] 
bysort facname (year ncdobmonth): gen lag_6_lbw = lbw_month[_n-6]
label variable lag_1_lbw "lag LBW  1 Month"
label variable lag_2_lbw "lag LBW  2 Month"
label variable lag_3_lbw "lag LBW  3 Month"
label variable lag_4_lbw "lag LBW  4 Month"
label variable lag_5_lbw "lag LBW  5 Month"
label variable lag_6_lbw "lag LBW  6 Month"

bysort facname (year ncdobmonth): gen lag_1_vlbw = vlbw_month[_n-1] 
bysort facname (year ncdobmonth): gen lag_2_vlbw = vlbw_month[_n-2]
bysort facname (year ncdobmonth): gen lag_3_vlbw = vlbw_month[_n-3]
bysort facname (year ncdobmonth): gen lag_4_vlbw = vlbw_month[_n-4] 
bysort facname (year ncdobmonth): gen lag_5_vlbw = vlbw_month[_n-5] 
bysort facname (year ncdobmonth): gen lag_6_vlbw = vlbw_month[_n-6]
label variable lag_1_vlbw " VLBW lag 1 Months"
label variable lag_2_vlbw " VLBW lag 2 Months"
label variable lag_3_vlbw " VLBW lag 3 Months"
label variable lag_4_vlbw " VLBW lag 4 Months"
label variable lag_5_vlbw " VLBW lag 5 Months"
label variable lag_6_vlbw " VLBW lag 6 Months"


* Add prior year measures:
	* NICU Admits - this may not be doing the right thing.
	* Where is nicu_year from? From Fac-level Counts.do
	bysort facname (year ncdobmonth): gen nicu_prior_year = nicu_year[_n-12]
	label variable nicu_prior_year "total nicu admits prior year"
	* Deaths
	* All
	bysort facname (year ncdobmonth): gen deaths_prior_year = d_year_all[_n-12]
	label variable deaths_prior_year "total deaths pr. yr inc non-nicu"
	* NICU (deaths among NICU admits)
	bysort facname (year ncdobmonth): gen deaths_nicu_prior_year = deaths_year[_n-12]
	label variable deaths_nicu_prior_year "deaths amg. nicu admits prior year"
	
	


rename year ncdobyear
di "generating here"
gen THCIC_ID = .
do "${TXhospital}TX Hospital Code Match.do"

save "${birthdata}CombinedFacCount.dta", replace

* here collapse some measures down to quarter to merge with inpatient data.  


* Create Transferred Patients files:

foreach nm of numlist 2005(1)2012{

use "${birthdata}Birth`nm'.dta", clear

do "${birthdo}CountTransfers.do"

save "${birthdata}TransferCount`nm'.dta", replace


}


use "${birthdata}TransferCount2005.dta", clear

foreach nm of numlist 2006(1)2012{

append using "${birthdata}TransferCount`nm'.dta"


}


save "${birthdata}CombinedTransferCount.dta", replace


use "${birthdata}Births2005-2012.dta", clear


* Merge facility information.  
merge m:1 facname ncdobyear ncdobmonth using "${birthdata}CombinedFacCount.dta", nogen
* those not matched are almost all home birth or a limited number of birthing center births
* only 1500 out of 375,000 are dropped if non-matched values are dropped.


* Merge transfers
merge m:1 facname ncdobyear ncdobmonth using "${birthdata}CombinedTransferCount.dta"
drop if _merge == 2
drop _merge



/*
* Hospitals Not Found:
unique facname if b_bplace == 1 & _merge != 3
* Number of unique values of facname is  52
unique facname, by(year) gen(hnumber)
*/



* replace missing for zeros - count variables will be missing if there are no transfers, eg.
replace vlbw_month = 0 if vlbw_month == .
replace vlbw_month_ex = 0 if vlbw_month_ex == .
replace vlbw_month_mort = 0 if vlbw_month_mort == .
replace vlbw_month_mort_ex = 0 if vlbw_month_mort_ex == .

replace lbw_month = 0 if lbw_month == .
replace lbw_month_ex = 0 if lbw_month_ex == .
replace lbw_month_mort = 0 if lbw_month_mort == .
replace lbw_month_mort_ex = 0 if lbw_month_mort_ex == .

replace transin = 0 if transin == .
replace transin_lbw = 0 if transin_lbw == .
replace transin_vlbw = 0 if transin_vlbw == .
replace transin_death = 0 if transin_death == .

replace transout = 0 if transout == .
replace transout_lbw = 0 if transout_lbw == .
replace transout_vlbw = 0 if transout_vlbw == .
replace transout_deaths = 0 if transout_deaths == .


* Capacity measures:
* These are complicated.
* think further about SoloIntermediate or NeoIntensiveCapacity.
* And the indicators for the facilities themselves too.  NeoIntensive and SoloIntermediate

gen capex = 0 if NeoIntensive == 1
replace capex = 1 if ((month_count+transin-transout) > NeoIntensiveCapacity) & NeoIntensiveCapacity != 0 & NeoIntensiveCapacity != . & month_count != .
label variable capex "more NICU admits than beds for the month"

gen cap2 = 2*NeoIntensiveCapacity
gen capex2 = 0 if NeoIntensive == 1
replace capex2 = 1 if ((month_count+transin-transout) > cap2) & month_count != . & NeoIntensiveCapacity != 0 & NeoIntensiveCapacity != .
label variable capex2 "more NICU admits than 2 times beds"

gen capex_trans = 0
replace capex_trans = 1 if (month_count+transin - transout) > NeoIntensiveCapacity & NeoIntensiveCapacity != . & NeoIntensiveCapacity != 0
label variable capex_trans "utilization mins transfers out"

gen bddays = NeoIntensiveCapacity*30 if NeoIntensiveCapacity != . & NeoIntensiveCapacity != 0

gen avg_util = (month_count+transin - transout)*13 + transout if (NeoIntensiveCapacity != 0 & NeoIntensiveCapacity != .) 
label variable avg_util "days util 13 days pp for non-transferred"

gen avg_util2 = (month_count+transin - transout)*26 + transout if (NeoIntensiveCapacity != 0 & NeoIntensiveCapacity != .) 
label variable avg_util2 "days util 26 days pp for non-transferred"

gen used_days = bddays - avg_util if (NeoIntensiveCapacity != 0 & NeoIntensiveCapacity != .)
label variable used_days "bed days utilized assuming 13 days/patient"

gen used_days2 = bddays - avg_util2 if (NeoIntensiveCapacity != 0 & NeoIntensiveCapacity != .)
label variable used_days2 "bed days utilized assuming 26 days/patient"

* Normalize these by beds 

gen extra_bed_days = used_days/NeoIntensiveCapacity if (NeoIntensiveCapacity != 0 & NeoIntensiveCapacity != .)
label variable extra_bed_days "total unused bed days (at 13 pp) divided by Capacity"

gen extra_bed_days2 = used_days2/NeoIntensiveCapacity if (NeoIntensiveCapacity != 0 & NeoIntensiveCapacity != .)
label variable extra_bed_days2 "total unused bed days (at 26 pp) divided by Capacity"


* Add the THCIC_ID from the Inpatient Discharge Records to get distances:
/*
TX Choice Model Extras.do contains a call to this function.
5% of the data can't be matched.
This also makes use of TX Merge Hospital Choices VARIANT.do.
*/

/*
gen THCIC_ID = .
quietly do "${TXhospital}TX Hospital Code Match.do"
*/

* Zip codes choice sets - 10 closest hospitals: 
* about 2% of the sample is not matched - most are from out of state.
rename b_mrzip PAT_ZIP
merge m:1 PAT_ZIP using "${TXhospital}TX Zip Code Choice Sets.dta"
drop if _merge == 2 | _merge == 1
drop _merge

* Add closest hospital - tracks which hospital is actually closest, whether chosen or not:
merge m:1 PAT_ZIP using "${TXhospital}TX Zip Distances to Closest Hospital.dta"
drop if _merge == 2 | _merge == 1
drop _merge

* Add distances to 50 closest hospitals - 50 closest hospitals to each zip code, whether chosen or not.
merge m:1 PAT_ZIP using "${birthdata}closest50hospitals.dta"
drop if _merge == 2 | _merge == 1
drop _merge


* VLBW/Year Indicators for B/P Regressions:
	* for Level 3: 0-25, 25-50, 50-100, >100
gen l3_25 = 0
replace l3_25 = 1 if NeoIntensive == 1 & vlbw_year <= 25

gen l3_25_50 = 0
replace l3_25_50 = 1 if NeoIntensive == 1 & vlbw_year>25 & vlbw_year <= 50

gen l3_50_100 = 0
replace l3_50_100 = 1 if NeoIntensive == 1 & vlbw_year > 50 & vlbw_year <= 100

gen l3_100 = 0
replace l3_100 = 1 if NeoIntensive == 1 & vlbw_year > 100 & vlbw_year != .

	*Level 2
gen l2_10 = 0
replace l2_10 = 1 if SoloIntermediate == 1 & vlbw_year <= 10

gen l2_10_25 = 0
replace l2_10_25 = 1 if SoloIntermediate == 1 & vlbw_year > 10 & vlbw_year <= 25

gen l2_25 = 0 
replace l2_25 = 1 if SoloIntermediate == 1 & vlbw_year > 25 & vlbw_year != .

	* Level 1
gen l1_10 = 0
replace l1_10 = 1 if SoloIntermediate == 0 & NeoIntensive == 0 & vlbw_year <= 10

gen l1_10_100 = 0
replace l1_10_100 = 1 if SoloIntermediate == 0 & NeoIntensive == 0 & vlbw_year > 10 & vlbw_year != .

	* level 3 levels.
gen lev3vols = 0
replace lev3vols = 1 if l3_25 == 1
replace lev3vols = 2 if l3_25_50 == 1
replace lev3vols = 3 if l3_50_100 == 1
replace lev3vols = 4 if l3_100 == 1
label define l3l 0 "Not level 3"
label define l3l 1 " < 25 patients", add
label define l3l 2 "25-50 patients", add
label define l3l 3 "50 - 100 patients", add
label define l3l 4 ">100 patients", add
label values lev3vols l3l



* Combined racial categories:

gen m_hispanic = 0
replace m_hispanic =1 if m_hismex == 1 | m_hispr == 1 | m_hiscub == 1 | m_hisoth == 1 | m_h_unk == 1

gen m_asian = 0
replace m_asian = 1 if m_rasnin == 1 | m_rchina == 1 | m_rfilip == 1 | m_rjapan == 1 | m_rkorea == 1 | m_rviet == 1 | m_rothas == 1 

gen m_pacisl = 0
replace m_pacisl = 1 if m_rhawai == 1 | m_rguam == 1 | m_rsamoa == 1 | m_rothpa == 1 

gen m_whtnhis = 0 
replace m_whtnhis = 1 if m_rwhite == 1 & m_hispanic == 0


* set distance to missing in 50 closest firms to remove this as a potential instrument.



gen chosenind = .

forvalues i=1/50{
di "`i'"
replace chosenind = `i' if fidcn`i' == fid
}


gen chdist = .

forvalues n = 1/50{

replace chdist = zipfacdistancecn`n' if chosenind == `n'

}
label variable chdist "distance to chosen hospital"


/*
forvalues i = 1/50{

replace zipfacdistancecn`i' = . if chosenind == `i'

}
*/

* Add hospital-specific mortality: Total Deliveries > 20 weeks from hospital survey, total mortality from this data.
	* should do all mortality, lbw mortality, vlbw mortality and mortality among NICU admits
	* Mortality among all births. 
	gen all_mort_rate = (deaths_prior_year/birth_previous)*1000 if birth_previous > 10
	replace all_mort_rate = 0 if deaths_prior_year == 0 | birth_previous == 0
	label variable all_mort_rate "All-patient mortality rate per 1000"
	* Among nicu admits only
	gen nicu_mort_rate = (deaths_nicu_prior_year/nicu_prior_year)*1000 if nicu_prior_year > 10
	replace nicu_mort_rate = 0 if deaths_nicu_prior_year == 0 | nicu_prior_year == 0
	label variable nicu_mort_rate "Mort rate amng NICU admits per 1000"



save "${birthdata}Births2005-2012wCounts.dta", replace


