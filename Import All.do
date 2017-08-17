* Texas DSHS Birth Data

do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"


* Imports and labels:

foreach nm of numlist 2005(1)2012{

import delimited "${birthdata}Birth`nm'.csv"

do "${birthdo}/Label Variables.do"

gen year = `nm'

* Add FIDS to patient records:
* Merge now on names using hosps.csv, which was matched to FIDS by hand.  

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
append using "${birthdata}Birth`nm'.dta", gen(yr`nm')
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

* Create Transferred Patients files:





* 1 - 6 month counts:
bysort facname (year ncdobmonth): gen total_1_months = month_count[_n-1] 
bysort facname (year ncdobmonth): gen total_2_months = month_count[_n-1] + month_count[_n-2]
bysort facname (year ncdobmonth): gen total_3_months = month_count[_n-1] + month_count[_n-2] + month_count[_n-3]
bysort facname (year ncdobmonth): gen total_4_months = month_count[_n-1] + month_count[_n-2] + month_count[_n-3] + month_count[_n-4] 
bysort facname (year ncdobmonth): gen total_5_months = month_count[_n-1] + month_count[_n-2] + month_count[_n-3] + month_count[_n-4] + month_count[_n-5] 
bysort facname (year ncdobmonth): gen total_6_months = month_count[_n-1] + month_count[_n-2] + month_count[_n-3] + month_count[_n-4] + month_count[_n-5] + month_count[_n-6]
label variable total_1_months "Total NICU Admits Prior 1 months"
label variable total_2_months "Total NICU Admits Prior 2 months"
label variable total_3_months "Total NICU Admits Prior 3 Months"
label variable total_4_months "Total NICU Admits Prior 4 months"
label variable total_5_months "Total NICU Admits Prior 5 months"
label variable total_6_months "Total NICU Admits Prior 6 Months"

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

rename year ncdobyear

save "${birthdata}CombinedFacCount.dta", replace


use "${birthdata}Births2005-2012.dta", clear

merge m:1 facname ncdobyear ncdobmonth using "${birthdata}CombinedFacCount`nm'.dta", nogen

* those not matched are almost all home birth or a limited number of birthing center births
* only 1500 out of 375,000 are dropped if non-matched values are dropped.



/*
* Hospitals Not Found:
unique facname if b_bplace == 1 & _merge != 3
* Number of unique values of facname is  52
unique facname, by(year) gen(hnumber)
*/

gen capex = 0

replace capex = 1 if month_count > NeoIntensiveCapacity



save "${birthdata}Births2005-2012wCounts.dta", replace


