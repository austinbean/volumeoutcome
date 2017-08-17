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

sort bo_trans

bysort transfid ncdobmonth: gen t_c = sum(bo_trans)
bysort transfid ncdobmonth: egen transin = max(t_c)
drop t_c
label variable transin "Transfers in, all"

gen lbw = 0
replace lbw = 1 if b_wt_cgr < 2500
bysort transfid ncdobmonth lbw: gen translbw = sum(lbw)
bysort transfid ncdobmonth: egen transin_lbw = max(translbw)
drop translbw
label variable transin_lbw "Transfers in, LBW"

gen vlbw = 0
replace vlbw = 1 if b_wt_cgr < 1500
bysort transfid ncdobmonth vlbw: gen transvlbw = sum(vlbw)
bysort transfid ncdobmonth: egen transin_vlbw = max(transvlbw)
drop transvlbw
label variable transin_vlbw "Transfers in, VLBW"

bysort transfid ncdobmonth neonataldeath: gen transd = sum(neonataldeath)
bysort transfid ncdobmonth: egen transin_death = max(transd)
drop transd
label variable transin_death "Transfers in, later died"

keep bo_facil ncdobyear ncdobmonth transfid transin transin_lbw transin_vlbw transin_death
duplicates drop bo_facil ncdobmonth, force

drop if transfid == .

rename bo_facil facname
rename transfid fid
