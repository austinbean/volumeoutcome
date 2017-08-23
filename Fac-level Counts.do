* Compute Fac-level Counts. 

*use "/Users/austinbean/Desktop/BirthData2005-2012/Birth2007.dta", clear

* Current problem - some months have zeros for VLBW births or deaths.  Keep them.   

* TODO - count only among those who were NOT transferred and among facilities which have level 2 or level 3 ONLY.


sort facname ncdobmonth

* NOTE: small number of home births.

* Generate variable to track transfers

gen transferred = 0
replace transferred = 1 if bo_trans == 1
label variable transferred "Infant transferred"


* All NICU admits, transferred or not:
replace adm_nicu = 0 if adm_nicu == 2
bysort facname ncdobmonth: gen f_c_i = sum(adm_nicu)
bysort facname ncdobmonth: egen month_count = max(f_c_i)
drop f_c_i
label variable month_count "Total NICU admits in month INC transfers"


* Count of NICU admits by month, EX transfers
gen nic_ad = 0
replace nic_ad = 1 if adm_nicu == 1 & transferred == 0
bysort facname ncdobmonth: gen f_c = sum(nic_ad)
bysort facname ncdobmonth: egen month_count_ex = max(f_c)
drop  f_c
label variable month_count_ex "Total NICU admits in month EX transfers"


* Counts of LBW, VLBW by month :

gen vlbw = 0
replace vlbw = 1 if b_wt_cgr < 1500

gen lbw = 0
replace lbw = 1 if b_wt_cgr < 2500

* Low Birth Weight, including and excluding transfers
bysort facname ncdobmonth lbw: gen lb_c_i = _n if lbw == 1 
bysort facname ncdobmonth: egen lbw_month = max(lb_c_i)
drop lb_c_i
label variable lbw_month "LBW babies in month, inc transfers"
	* Excluding
bysort facname ncdobmonth lbw transferred: gen lb_c_i = _n if lbw == 1 & transferred == 0 
bysort facname ncdobmonth: egen lbw_month_ex = max(lb_c_i)
drop lb_c_i
label variable lbw_month_ex "LBW babies in month, EX transfers"


* Very Low Birth Weight, including and excluding transfers
bysort facname ncdobmonth vlbw: gen vl_c_i = _n if vlbw == 1
bysort facname ncdobmonth: egen vlbw_month = max(vl_c_i)
drop vl_c_i
label variable vlbw_month "VLBW babies in month, including all"
	* Excluding
bysort facname ncdobmonth vlbw transferred: gen vl_c_i = _n if vlbw == 1 & transferred == 0 
bysort facname ncdobmonth: egen vlbw_month_ex = max(vl_c_i)
drop vl_c_i
label variable vlbw_month_ex "VLBW babies in month, excluding transfers"


bysort facname ncdobmonth: replace lbw_month = 0 if lbw_month == .
bysort facname ncdobmonth: replace vlbw_month = 0 if vlbw_month == .

bysort facname ncdobmonth: replace lbw_month_ex = 0 if lbw_month_ex == .
bysort facname ncdobmonth: replace vlbw_month_ex = 0 if vlbw_month_ex == .


* Compute some mortality counts at LBW or VLBW by month:
* Very low birth weight
gen vlbw_mort = 0
replace vlbw_mort = 1 if vlbw == 1 & neonataldeath == 1
	* excluding transfers
gen vlbw_mort_ex = 0
replace vlbw_mort_ex = 1 if vlbw == 1 & neonataldeath == 1 & transferred == 0

* Low birth weight
gen lbw_mort = 0
replace lbw_mort = 1 if lbw == 1 & neonataldeath == 1
	* excluding transfers
gen lbw_mort_ex = 0
replace lbw_mort_ex = 1 if lbw == 1 & neonataldeath == 1 & transferred == 0

* VLBW mortality including transfers
bysort facname ncdobmonth vlbw_mort: gen vl_i = sum(vlbw_mort)
bysort facname ncdobmonth: egen vlbw_month_mort = max(vl_i)
drop vl_i vlbw_mort
label variable vlbw_month_mort "Monthly VLBW mortality, inc transfers"

* VLBW mortality excluding transfers
bysort facname ncdobmonth vlbw_mort_ex: gen vl_i = sum(vlbw_mort_ex)
bysort facname ncdobmonth: egen vlbw_month_mort_ex = max(vl_i)
drop vl_i vlbw_mort_ex
label variable vlbw_month_mort_ex "Monthly VLBW mortality, EX transfers"

* LBW mortality, including transfers
bysort facname ncdobmonth lbw_mort: egen lb_i = sum(lbw_mort)
bysort facname ncdobmonth: egen lbw_month_mort = max(lb_i)
drop lb_i lbw_mort
label variable lbw_month_mort "Monthly LBW mortality, inc transfers"

* LBW mortality, excluding transfers
bysort facname ncdobmonth lbw_mort_ex: egen lb_i = sum(lbw_mort_ex)
bysort facname ncdobmonth: egen lbw_month_mort_ex = max(lb_i)
drop lb_i lbw_mort_ex
label variable lbw_month_mort_ex "Monthly LBW mortality, ex transfers"


bysort facname ncdobmonth: replace vlbw_month_mort = 0 if vlbw_month_mort == .
bysort facname ncdobmonth: replace lbw_month_mort = 0 if lbw_month_mort == .

bysort facname ncdobmonth: replace vlbw_month_mort_ex = 0 if vlbw_month_mort_ex == .
bysort facname ncdobmonth: replace lbw_month_mort_ex = 0 if lbw_month_mort_ex == .


* dropping home births
keep if b_bplace == 1


* Travis County:
* browse if b_bcntyc == 227
 
duplicates drop facname ncdobmonth, force

* Keep subset:

keep facname ncdobmonth b_bcntyc month_count month_count_ex lbw_month lbw_month_ex vlbw_month vlbw_month_ex lbw_month_mort vlbw_month_mort vlbw_month_mort_ex lbw_month_mort_ex

* Count of LBW, VLBW in year:

bysort facname : gen lbw_y_i = sum(lbw_month)
bysort facname : egen lbw_year = max(lbw_y_i)
drop lbw_y_i
label variable lbw_year "Low Birth Weight Infants in Year"

bysort facname : gen vlbw_y_i = sum(vlbw_month)
bysort facname : egen vlbw_year = max(vlbw_y_i)
drop vlbw_y_i
label variable vlbw_year "Very Low Birth Weight Infants in Year"


sort facname ncdobmonth

