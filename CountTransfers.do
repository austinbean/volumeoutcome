* Dealing with transferred patients.
/*
In this file, I want to figure out:
- patients who were transferred in
- patients who were transferred in at low birth weight
- patients who were transferred in at very low birth weight
- patients who were transferred in and died.

Testing: use "/Users/austinbean/Desktop/BirthData2005-2012/Birth2007.dta", clear
*/

* There ARE a bunch of kids who are transferred to a FAC for which I don't have a fid.
* Texas Childrens, which doesn't have to do the survey, accounts for more than half.  
* Maybe this is in the NBER?  Probably it is, but there are 10 hospitals around so it is
* very very hard to tell.  Best guess is that it is around:    29.70786	-95.40158
* But there are 38 unique facilities within 0.14 miles of that location.

keep if bo_trans == 1 /* drop untransferred infants */

gen lbw = 0
replace lbw = 1 if b_wt_cgr < 2500

gen vlbw = 0
replace vlbw = 1 if b_wt_cgr < 1500

* count transfers OUT

bysort fid ncdobmonth: gen t_o = sum(bo_trans)
bysort fid ncdobmonth: egen transout = max(t_o)
drop t_o
label variable transout "Transfers out, all"

bysort fid ncdobmonth lbw: gen t_l = sum(lbw)
bysort fid ncdobmonth: egen transout_lbw = max(t_l)
drop t_l
label variable transout_lbw "Transfers out, LBW"

bysort fid ncdobmonth vlbw: gen t_v = sum(vlbw)
bysort fid ncdobmonth: egen transout_vlbw = max(t_v)
drop t_v
label variable transout_vlbw "Transfers out, VLBW"

bysort fid ncdobmonth neonataldeath: gen n_s = sum(neonataldeath)
bysort fid ncdobmonth: egen transout_deaths = max(n_s)
drop n_s
label variable transout_death "Transfers out, later died"


* Count transfers IN

bysort transfid ncdobmonth: gen t_c = sum(bo_trans)
bysort transfid ncdobmonth: egen transin = max(t_c)
drop t_c
label variable transin "Transfers in, all"


bysort transfid ncdobmonth lbw: gen translbw = sum(lbw)
bysort transfid ncdobmonth: egen transin_lbw = max(translbw)
drop translbw
label variable transin_lbw "Transfers in, LBW"


bysort transfid ncdobmonth vlbw: gen transvlbw = sum(vlbw)
bysort transfid ncdobmonth: egen transin_vlbw = max(transvlbw)
drop transvlbw
label variable transin_vlbw "Transfers in, VLBW"

bysort transfid ncdobmonth neonataldeath: gen transd = sum(neonataldeath)
bysort transfid ncdobmonth: egen transin_death = max(transd)
drop transd
label variable transin_death "Transfers in, later died"

* DO COUNTS FOR THE YEAR

* ADD ADDITIONAL VARIABLES.
keep bo_facil ncdobyear ncdobmonth transfid transin transout transin_lbw transout_lbw transin_vlbw transout_vlbw transin_death transout_death 
duplicates drop bo_facil ncdobmonth, force

drop if transfid == .

rename bo_facil facname
rename transfid fid
