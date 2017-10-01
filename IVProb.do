* IV Probit w/ Instrumented Volume

* Uses quarterly volume prediction from PredictVolume.do


* Probit w/ and w/ out volume instrument.  


do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"

use "${birthdata}/Births2005-2012wCounts.dta", clear

* Drop home births.
drop if b_bplace != 1

* drop those never admitted to nicu.
drop if adm_nicu == 0

bysort fid: gen fc = _n
bysort fid: egen brtotal = max(fc)

drop if brtotal < 25
drop if b_wt_cgr < 500
/*
gen qr = 0
replace qr = 1 if ncdobmonth == 1 | ncdobmonth == 2 | ncdobmonth == 3
replace qr = 2 if ncdobmonth == 4 | ncdobmonth == 5 | ncdobmonth == 6
replace qr = 3 if ncdobmonth == 7 | ncdobmonth == 8 | ncdobmonth == 9
replace qr = 4 if ncdobmonth == 10 | ncdobmonth == 11 | ncdobmonth == 12
sort ncdobyear qr fid
*/
merge m:1 ncdobyear fid using "${birthdata}allyearnicufidshares.dta"

keep if _merge == 3


* Use three month shares:
* These do not correspond exactly to the correct quarterly values...
* But these work, though in the iv the main effect is not significant.
gen lag3months = lag_1_months + lag_2_months + lag_3_months

* W/ quadratic lagged volume terms:
foreach nm of numlist 1(1)6{

gen lag_`nm'_months_sq = lag_`nm'_months^2
label variable lag_`nm'_months_sq " squared lagged `nm' month volume "

}

gen mnth2 = mnthly_share^2


/*
* These work...

* Previous Quarter:

probit neonataldeath prev_q

ivprobit neonataldeath (prev_q = exp_share)
 
probit neonataldeath  prev_q i.b_es_ges 

ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges 

probit neonataldeath  prev_q i.b_es_ges i.pay

ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay

probit neonataldeath  prev_q i.b_es_ges i.pay bca_aeno-hypsospa

ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay bca_aeno-hypsospa

* full set of health states

probit neonataldeath  prev_q i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
* prev_q |  -.0005672   .0000728    -7.79

ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
* prev_q |  -.0002086   .0000985    -2.12   0.034
estimates save "/Users/austinbean/Desktop/Birth2005-2012/ivprobfull.ster", replace


* would be better to do this at some gestational age.  and a payment status.  
margins, dydx(prev_q) predict(pr) atmeans


preserve
keep neonataldeath prev_q exp_share b_es_ges pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
collapse (mean) *
gen id = _n
expand = 11
bysort id: replace prev_q = 20*(_n-1)
replace pay = 1

estimates use "/Users/austinbean/Desktop/Birth2005-2012/ivprobfullsq.ster"





	* These are fine, but failure is perfectly predicted for many facilities since no one dies.  Not that informative.
probit neonataldeath  prev_q i.b_es_ges i.pay bca_aeno-hypsospa i.fid

ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay bca_aeno-hypsospa i.fid

probit neonataldeath  prev_q i.b_es_ges i.pay bca_aeno-hypsospa multiple

ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay bca_aeno-hypsospa multiple


* One Month:
probit neonataldeath lag_1_months i.b_es_ges

ivprobit neonataldeath  (lag_1_months = exp_share )  i.b_es_ges

probit neonataldeath lag_1_months i.b_es_ges i.pay

ivprobit neonataldeath  (lag_1_months = exp_share )  i.b_es_ges i.pay

probit neonataldeath lag_1_months i.b_es_ges i.pay bca_aeno-hypsospa

ivprobit neonataldeath  (lag_1_months = exp_share )  i.b_es_ges i.pay bca_aeno-hypsospa
	* many fid fe's excluded.
probit neonataldeath lag_1_months i.b_es_ges i.pay bca_aeno-hypsospa i.fid

ivprobit neonataldeath  (lag_1_months = exp_share )  i.b_es_ges i.pay bca_aeno-hypsospa i.fid

probit neonataldeath lag_1_months i.b_es_ges i.pay bca_aeno-hypsospa multiple

ivprobit neonataldeath  (lag_1_months = exp_share )  i.b_es_ges i.pay bca_aeno-hypsospa multiple


*/


* 09/30/2017 - 


probit neonataldeath  prev_q i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa

margins, dydx(prev_q) predict(pr) atmeans


margins, at((mean) _all  prev_q = (0(20)460) )
marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability")

* partial effect at means, varying volume between 1 and 95 percentile, for Medicaid patients.
* Future... overlay these for two insurance types.
margins, at((mean) _all prev_q = (0(20)460) pay = 1)
marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") subtitle( "No IV, Medcaid Patients")



* W/ IV for volume... 
ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
	* this takes a HUGE amount of time.  
*margins, at((mean) _all prev_q = (0(20)460) pay = 1) pred(pr)

* The following does finish...
margins, at((mean) _all) dydx(prev_q)  nose

* Removing SE's saves a ton of time.  
* Trying w/ prediction
 margins, at((mean) _all) dydx(prev_q) predict(pr) nose
 
* This one also works
 margins, at((mean) _all prev_q = (0(20)460)) nose

* adding prediction:
 margins, at((mean) _all prev_q = (0(20)460)) predict(pr) saving("/Users/austinbean/Desktop/ivprbmarg.dta", replace)
 marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") subtitle( "Volume IV")

 * Fixing some categorical variables:
 
 margins, at((mean) _all prev_q = (0(20)460) b_es_ges = 35 pay = 1) predict(pr) nose
 
 /*
 
 See IV Prob Margins Results.do for the  command results...
 margins, at((mean) _all prev_q = (0(20)460)) predict(pr) saving("/Users/austinbean/Desktop/ivprbmarg.dta", replace)
 
 
 */
 
 
 
marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") subtitle( "Medcaid Patients")



estimates save "/Users/austinbean/Desktop/Birth2005-2012/ivprobfull.ster", replace






* Previous quarter... 
* facility FE's drop out if someone doesn't die, so since numbers are small it may not work to include them
probit neonataldeath  prev_q i.b_es_ges i.pay bca_aeno-hypsospa multiple

ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay bca_aeno-hypsospa multiple

* Previous month
probit neonataldeath lag_1_months i.b_es_ges i.pay bca_aeno-hypsospa multiple

ivprobit neonataldeath  (lag_1_months = exp_share )  i.b_es_ges i.pay bca_aeno-hypsospa multiple







probit neonataldeath  lag3months  i.b_es_ges

ivprobit neonataldeath  (lag3months = exp_share) i.b_es_ges


ivprobit neonataldeath (lag_1_months lag_1_months_sq = mnthly_share mnth2) 



probit neonataldeath i.ncdobyear b_m_educ lag_*_months lag_*_months_sq i.pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple 
estimates save "/Users/austinbean/Desktop/Birth2005-2012/probit_nndlev3fullsq"







* W/ quadratic lagged volume terms, for VLBW only:
keep if b_wt_cgr < 1500
foreach nm of numlist 1(1)6{

gen lag_`nm'_months_sq = lag_`nm'_months^2
label variable lag_`nm'_months_sq " squared lagged `nm' month volume "

}
probit neonataldeath i.ncdobyear b_m_educ lag_*_months lag_*_months_sq i.pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple if NeoIntensive == 1

estimates save "/Users/austinbean/Desktop/Birth2005-2012/probit_nndlev3fullsqvlbw"

* W/ quadratic lagged volume terms in VLBW admits for VLBW admits only:
keep if b_wt_cgr < 1500
foreach nm of numlist 1(1)6{

gen lag_`nm'_vlbw_sq = lag_`nm'_vlbw^2
label variable lag_`nm'_vlbw_sq " squared lagged `nm' month volume "

}
probit neonataldeath i.ncdobyear b_m_educ lag_*_vlbw lag_*_vlbw_sq i.pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple if NeoIntensive == 1

estimates save "/Users/austinbean/Desktop/Birth2005-2012/probit_nndlev3sqvlbw"






preserve
foreach nm of numlist 1(1)6{
gen lag_`nm'_months_sq = lag_`nm'_months^2
label variable lag_`nm'_months_sq " squared lagged `nm' month volume "
}
keep neonataldeath ncdobyear b_m_educ lag_*_months lag_*_months_sq pay bca_aeno-hypsospa fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple
collapse (mean) *
expand = 11
replace lag_1_months = 20*(_n-1)
replace lag_1_months_sq = (20*(_n-1))^2
replace ncdobyear = 2012
replace fid = 0
estimates use "/Users/austinbean/Desktop/Birth2005-2012/probit_nndlev3fullsq.ster"
predict prnnd
twoway line prnnd lag_1_months, xtitle("NICU Volume Previous Month") ytitle("Probability of Death") title("Mortality as a Function of NICU Volume") graphregion(color(white)) xline(34, lcolor(red)) xline(143, lcolor(red)) text(0.025 34 "Average Travis County" "Monthly NICU Admits", place(e))  text(0.0225 143 "Total Travis County" "Monthly NICU Admits", place(e)) 

