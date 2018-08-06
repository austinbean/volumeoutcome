* Big Counties - transfer networks:



do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"





* big counties: 220, 101, 227. Tarrant, Harris, Travis 

foreach nm of numlist 2005(1)2012{


use "${birthdata}TransferCount`nm'.dta"

sort fid

by fid: egen yr_transout = sum(transout)
label variable yr_transout "Transfers Out (year)"

by fid: egen yr_transin = sum(transin) 
label variable yr_transin "Transfers In (year)"

by fid: egen yr_transout_lbw = sum(transout_lbw)
label variable yr_transout_lbw "LBW Transfers Out (year)"

by fid: egen yr_transout_vlbw = sum(transout_vlbw) 
label variable yr_transout_vlbw "VLBW Transfers Out (year)"

by fid: egen yr_transout_deaths = sum(transout_deaths) 
label variable yr_transout_deaths "Transfers Out Deaths (year)"

by fid: egen yr_transin_lbw  = sum(transin_lbw )
label variable yr_transin_lbw "LBW Transfers In (year)"

by fid: egen yr_transin_vlbw  = sum(transin_vlbw)
label variable yr_transin_vlbw "VLBW Transfers In (Year)"

by fid: egen yr_transin_death = sum(transin_death)
label variable yr_transin_death "Transfers In Deaths (year)"

duplicates drop fid, force
drop ncdobmonth transout transout_lbw transout_vlbw transout_deaths transin transin_lbw transin_vlbw transin_death

sort b_bcntyc

save "${birthdata}YearlyTransferSummary`nm'.dta"

}

* Need to do something else:
* By each separate fid, all transfers TO by destination Fid.  This is more complicated.

foreach nm of numlist 2005(1)2012{

use "${birthdata}Birth`nm'.dta", clear


keep if bo_trans == 1 /* drop untransferred infants */

gen lbw = 0
replace lbw = 1 if b_wt_cgr < 2500

gen vlbw = 0
replace vlbw = 1 if b_wt_cgr < 1500

* Don't do separately by weight yet, but can clearly do so.

bysort fid transfid: gen ctt = _n
bysort fid transfid: egen dc = max(ctt)
drop ctt

* NOTE many missings.  

keep fid transfid dc
duplicates drop fid transfid, force
reshape wide






}
