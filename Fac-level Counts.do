* Compute Fac-level Counts. 

*use "/Users/austinbean/Desktop/Birth2005-2012/Birth2007.dta", clear

* Current problem - some months have zeros for VLBW births or deaths.  Keep them.   

* TODO - count only among those who were NOT transferred and among facilities which have level 2 or level 3 ONLY.


sort facname ncdobmonth

* NOTE: small number of home births.

* Generate variable to track transfers

gen transferred = 0
replace transferred = 1 if bo_tra1 == 1 | bo_trans == 1
label variable transferred "Infant transferred"

* Count of NICU admits by month.  The key variable I think is this one.
replace adm_nicu = 0 if adm_nicu == 2
gen nic_ad = 0
replace nic_ad = 1 if adm_nicu == 1 & transferred == 0
bysort facname ncdobmonth: gen f_c = sum(nic_ad)
bysort facname ncdobmonth: egen mnt_c = max(f_c)
bysort facname ncdobmonth: gen f_c_i = sum(adm_nicu)
bysort facname ncdobmonth: egen month_count = max(f_c_i)
drop f_c_i
label variable month_count "Total NICU admits at facility in month"

* Counts of LBW, VLBW by month :

gen vlbw = 0
replace vlbw = 1 if b_wt_cgr < 1500

gen lbw = 0
replace lbw = 1 if b_wt_cgr < 2500

bysort facname ncdobmonth lbw: gen lb_c_i = _n if lbw == 1 
bysort facname ncdobmonth: egen lbw_month = max(lb_c_i)
drop lb_c_i
label variable lbw_month "LBW babies in month"

bysort facname ncdobmonth vlbw: gen vl_c_i = _n if vlbw == 1
bysort facname ncdobmonth: egen vlbw_month = max(vl_c_i)
drop vl_c_i
label variable vlbw_month "VLBW babies in month"

bysort facname ncdobmonth: replace lbw_month = 0 if lbw_month == .
bysort facname ncdobmonth: replace vlbw_month = 0 if vlbw_month == .


* Compute some mortality counts at LBW or VLBW by month:

gen vlbw_mort = 0
replace vlbw_mort = 1 if vlbw == 1 & neonataldeath == 1

gen lbw_mort = 0
replace lbw_mort = 1 if lbw == 1 & neonataldeath == 1

bysort facname ncdobmonth vlbw_mort: gen vlw_i = 1 if vlbw_mort == 1
bysort facname ncdobmonth vlbw_mort: egen vl_i = sum(vlw_i)
bysort facname ncdobmonth: egen vlbw_month_mort = max(vl_i)
drop vlw_i vl_i vlbw_mort
label variable vlbw_month_mort "Monthly VLBW mortality"

bysort facname ncdobmonth lbw_mort: gen lbw_i = 1 if lbw_mort == 1
bysort facname ncdobmonth lbw_mort: egen lb_i = sum(lbw_i)
bysort facname ncdobmonth: egen lbw_month_mort = max(lb_i)
drop lbw_i lb_i lbw_mort
label variable lbw_month_mort "Monthly LBW mortality"

bysort facname ncdobmonth: replace vlbw_month_mort = 0 if vlbw_month_mort == .
bysort facname ncdobmonth: replace lbw_month_mort = 0 if lbw_month_mort == .



* dropping home births
keep if b_bplace == 1

* Keep subset:
keep facname ncdobmonth b_bcntyc month_count lbw_month vlbw_month lbw_month_mort vlbw_month_mort

sort facname ncdobmonth

* Travis County:
* browse if b_bcntyc == 227
 
duplicates drop facname ncdobmonth, force
