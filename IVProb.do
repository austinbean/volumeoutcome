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
merge m:1 ncdobyear fid qr using "${birthdata}allyearfidshares.dta"

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


* For the presentation, now going to do IV probit with yearly admission value:
	
	* Without the IV
	eststo: probit neonataldeath nicu_year i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
	est store prob_marg_no_iv_year
	margins, at((mean) _all  nicu_year = (0(100)2000) ) post saving("/Users/austinbean/Desktop/noivprb_marg_year.dta", replace) nose

	est sto pmarg_noiv_year
	estimates save "/Users/austinbean/Desktop/Birth2005-2012/prob_marg_no_iv_year.ster", replace
	marginsplot, recastci(rarea) ciopts(color(gray*0.6))  recast(line) plot1opts(lcolor(black)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Year NICU Admits") title("Effect of Volume on Mortality Probability") saving("/Users/austinbean/Desktop/Birth2005-2012/volprob_noiv_year.gph", replace)
	
	* With the IV
	* takes a LONG time. started at: 12:40, finished at: 2:30.  Ugh.  ADD NOSE (nose) to save a lot of time.  
	eststo:  ivprobit neonataldeath  (nicu_year = exp_share ) i.b_es_ges i.pay i.ncdobyear as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
	est store prob_marg_w_iv_year
	margins, at((mean) _all nicu_year = (0(100)2000)) predict(pr) post saving("/Users/austinbean/Desktop/ivprb_marg_year.dta", replace) 
	est sto pmarg_iv_year
	estimates save "/Users/austinbean/Desktop/Birth2005-2012/prob_marg_w_iv_year.ster", replace
	marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Year NICU Admits") title("Effect of Volume on Mortality Probability") subtitle( "Volume IV") saving("/Users/austinbean/Desktop/Birth2005-2012/volprob_iv_year.gph", replace)

	marginsplot, recastci(rarea) noci recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Year NICU Admits") title("Effect of Volume on Mortality Probability") subtitle( "Volume IV") saving("/Users/austinbean/Desktop/Birth2005-2012/volpr_iv_noci_year.gph", replace) xline(450) xline(1700) text(0.007 650 "Travis County" "Yearly Hospital" "Mean Admits") text(0.012 1400 "Travis County" "Yearly" "Total Admits")
	
	
	* Graph of Effects w/ CI's
	coefplot pmarg_noiv_year pmarg_iv_year, recast(line) vertical title("Effect of Volume on Outcome") subtitle("With and Without Volume IV") ytitle("Mortality Probability") xtitle("Prior Year NICU Admits")   graphregion(color(white)) 	xlabel(   1 "0" 2 "100" 3 "200" 4 "300" 5 "400" 6 "500" 7 "600" 8 "700" 9 "800" 10 "900" 11 "1000" 12 "1100" 13 "1200" 14 "1300" 15 "1400" 16 "1500" 17 "1600" 18 "1700" 19 "1800" 20 "1900" 21 "2000" , angle(45))
	graph save Graph "/Users/austinbean/Desktop/Birth2005-2012/yearly_ivnoiv_comparison.gph", replace

	* simple graph w/out CI w/ Travis County labels.  
	coefplot pmarg_noiv_year pmarg_iv_year, noci recast(line) vertical title("Effect of Volume on Outcome") subtitle("With and Without Volume IV") ytitle("Mortality Probability") xtitle("Prior Year NICU Admits")  xlabel(   1 "0" 2 "100" 3 "200" 4 "300" 5 "400" 6 "500" 7 "600" 8 "700" 9 "800" 10 "900" 11 "1000" 12 "1100" 13 "1200" 14 "1300" 15 "1400" 16 "1500" 17 "1600" 18 "1700" 19 "1800" 20 "1900" 21 "2000" , angle(45)) graphregion(color(white)) xline(5.5) xline(18.5) text(0.007 7.6 "Travis County" "Yearly Hospital" "Mean Admits") text(0.012 16 "Travis County" "Yearly" "Total Admits")
	graph save Graph "/Users/austinbean/Desktop/Birth2005-2012/yearly_ivnoiv_travisct.gph", replace



* margin at gestational age:
	probit neonataldeath nicu_year i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
	margins, at((mean) _all  b_es_ges = (23(1)41) ) post  nose
	marginsplot, recastci(rarea) ciopts(color(gray*0.6))  recast(line) plot1opts(lcolor(black)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Gestational Age (Weeks)") title("Effect of Incr. Gest. Age on Mortality Probability") 
	
	*saving("/Users/austinbean/Desktop/Birth2005-2012/volprob_noiv_year.gph", replace)





* These models and this graph are in the paper.  

* Without IV for Volume...
probit neonataldeath  prev_q i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
eststo: probit neonataldeath  prev_q i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   

* With FE for year
probit neonataldeath  prev_q i.b_es_ges i.pay i.ncdobyear as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
eststo: probit neonataldeath  prev_q i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   


margins, at((mean) _all  prev_q = (0(20)460) ) post 
est store prob_margins_no_iv
estimates save "/Users/austinbean/Desktop/Birth2005-2012/prob_margins_no_iv.ster", replace
* estimates use "/Users/austinbean/Desktop/Birth2005-2012/prob_margins_no_iv.ster"
marginsplot, recastci(rarea) ciopts(color(gray*0.6))  recast(line) plot1opts(lcolor(black)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") saving("/Users/austinbean/Desktop/Birth2005-2012/volumeprobit_noiv.gph", replace)

* partial effect at means, varying volume between 1 and 95 percentile, for Medicaid patients.
* Future... overlay these for two insurance types.
margins, at((mean) _all prev_q = (0(20)460) pay = 1)
marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") subtitle( "No IV, Medcaid Patients")


* W/ IV for volume... 
ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
eststo: ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa

* w/ IV for volume and year FE's:
ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay i.ncdobyear as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
eststo:  ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay i.ncdobyear as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa


* takes a LONG time. started at: 12:40, finished at: 2:30.  Ugh.  ADD NOSE (nose) to save a lot of time.  
margins, at((mean) _all prev_q = (0(20)460)) predict(pr) post saving("/Users/austinbean/Desktop/ivprbmarg.dta", replace)
est store prob_margins_w_iv
estimates save "/Users/austinbean/Desktop/Birth2005-2012/prob_margins_w_iv.ster", replace
* estimates use "/Users/austinbean/Desktop/Birth2005-2012/prob_margins_w_iv.ster"
marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") subtitle( "Volume IV") saving("/Users/austinbean/Desktop/Birth2005-2012/Volume IV Probit.gph", replace)



* Saving the Probit and IV probit results out as a table:
esttab using "/Users/austinbean/Desktop/Birth2005-2012/ivprobresults.tex", se ar2 label title("Results") nonumbers mtitles("Probit" "IV Probit") replace




* Plotting both of the sets of marginal effects:


* legend(order(1 "No IV" 2 "With IV")) 
coefplot prob_margins_no_iv prob_margins_w_iv,  recast(line) vertical title("Effect of Volume on Outcome") subtitle("With and Without Volume IV") ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits")  xlabel(   1 "0" 2 "20" 3 "40" 4 "60" 5 "80" 6 "100" 7 "120" 8 "140" 9 "160" 10 "180" 11 "200" 12 "220" 13 "240" 14 "260" 15 "280" 16 "300" 17 "320" 18 "340" 19 "360" 20 "380" 21 "400" 22 "420" 23 "440" 24 "460", angle(45)) graphregion(color(white))
 graph save Graph "/Users/austinbean/Desktop/Birth2005-2012/Combined IV Prob Volume.gph"

 
 * Plot w/ vertical lines after adding nose to the commands to create prob_margins_no_iv and prob_margins_w_iv
 * This creates the graph with vertical lines at volume means and labels
 coefplot prob_margins_no_iv prob_margins_w_iv, recast(line) vertical title("Effect of Volume on Outcome") subtitle("With and Without Volume IV") ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits")  xlabel(   1 "0" 2 "20" 3 "40" 4 "60" 5 "80" 6 "100" 7 "120" 8 "140" 9 "160" 10 "180" 11 "200" 12 "220" 13 "240" 14 "260" 15 "280" 16 "300" 17 "320" 18 "340" 19 "360" 20 "380" 21 "400" 22 "420" 23 "440" 24 "460", angle(45)) graphregion(color(white)) xline(5.5) xline(18.5) text(0.007 7.6 "Travis County" "Quarterly" "Hospital Mean") text(0.012 21 "Travis County" "Quarterly" "Total Admits")
 
 
 
* some probits with lagged hospital volume by month: 
* next: Hospital FE's
 
 probit neonataldeath prev_*_month i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   

 
* Hospital FE models:
	* With previous month:
  probit neonataldeath prev_*_month i.fid 
  probit neonataldeath prev_*_month i.fid i.b_es_ges
  probit neonataldeath prev_*_month i.fid i.b_es_ges i.pay
  probit neonataldeath prev_*_month i.fid i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
  * IV and one lagged month
  ivprobit neonataldeath (prev_1_month = exp_share) i.fid i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
  ivprobit neonataldeath (prev_1_month = exp_share) i.fid i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
	* robust SE
  ivprobit neonataldeath (prev_1_month = exp_share) i.fid i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa, vce(robust)  
	* cluster SE at fid
  ivprobit neonataldeath (prev_1_month = exp_share) i.fid i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa, vce(cluster fid)
  
  
	* With Previous Quarter
  probit neonataldeath prev_q i.fid 
  probit neonataldeath prev_q i.fid i.b_es_ges
  probit neonataldeath prev_q i.fid i.b_es_ges i.pay
  probit neonataldeath prev_q i.fid i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
  est sto prob_pq_fs
  ivprobit neonataldeath (prev_q = exp_share) i.fid i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   

  	* With FOUR lagged Quarters
  probit neonataldeath prev_1_q-prev_4_q i.fid 
  probit neonataldeath prev_1_q-prev_4_q i.fid i.b_es_ges
  probit neonataldeath prev_1_q-prev_4_q i.fid i.b_es_ges i.pay
  probit neonataldeath prev_1_q-prev_4_q i.fid i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
  est sto prob_aq_fs
  
	* With previous year
  probit neonataldeath nicu_year i.fid
  probit neonataldeath nicu_year i.fid i.b_es_ges
  probit neonataldeath nicu_year i.fid i.b_es_ges i.pay
  probit neonataldeath nicu_year i.fid i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
  * robust SE
  probit neonataldeath nicu_year i.fid i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa, vce(robust)  
  * cluster SE at fid level
  probit neonataldeath nicu_year i.fid i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa, vce(cluster fid)

  
  est sto prob_yr_fs
  ivprobit neonataldeath (nicu_year = exp_share) i.fid i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   

	* And IV...  For these the sign is still as expected, but the estimate is less precise and not significant.  
  ivprobit neonataldeath i.fid (prev_q = exp_share)  
  ivprobit neonataldeath i.fid i.b_es_ges (prev_q = exp_share) 
  ivprobit neonataldeath i.fid i.b_es_ges i.pay (prev_q = exp_share) 
  ivprobit neonataldeath (prev_q = exp_share) i.fid i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   

  * Combine estimates, compare coeffs:
  suest prob_pq_fs prob_yr_fs prob_aq_fs
  test [prob_pq_fs_neonataldeath]prev_q = [prob_yr_fs_neonataldeath]nicu_year

 
 
* Compare months separately, year, prior quarter: 
	* Whole Sample
		* Quarterly - four lagged quarters
		probit neonataldeath prev_1_q-prev_4_q i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
		est sto prb_pq_fs
		margins, at((mean) _all prev_1_q = (0(20)500)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") 
	
		* Yearly
		probit neonataldeath  nicu_year i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa 
		est sto prb_py_fs
		margins, at((mean) _all nicu_year = (10(100)2000)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Year NICU Admits") title("Effect of Volume on Mortality Probability") 
	
		* Monthly
		probit neonataldeath  prev_*_month i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
		est sto prb_pm_fs
		margins, at((mean) _all prev_1_month = (0(10)200)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Month NICU Admits") title("Effect of Volume on Mortality Probability") 
		
		* Monthly WITH CURRENT MONTH
		probit neonataldeath month_count prev_*_month i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
		est sto prb_cm_fs
		margins, at((mean) _all prev_1_month = (0(10)200)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Month NICU Admits") title("Effect of Volume on Mortality Probability") 
		* Combine Estimates
		suest prb_cm_fs prb_pm_fs prb_py_fs prb_pq_fs
		* Test equality of prev 1 month w/ prev year
		test [prb_pm_fs_neonataldeath]prev_1_month = [prb_py_fs_neonataldeath]nicu_year
		* Test for Equality of Prev_q and Prev 1 month
		test [prb_pq_fs_neonataldeath]prev_q = [prb_pm_fs_neonataldeath]prev_1_month
		* Test for Equality of prev_q and sum of prev 3 months
		test [prb_pq_fs_neonataldeath]prev_q = ([prb_pm_fs_neonataldeath]prev_1_month + [prb_pm_fs_neonataldeath]prev_2_month + [prb_pm_fs_neonataldeath]prev_3_month)
		* Test for Equality of prior q and prior year
		test [prb_pq_fs_neonataldeath]prev_q = [prb_py_fs_neonataldeath]nicu_year
		
		
		
		* w/ Fid FE's
		* Quarterly
			* Previous 1 Quarter
		probit neonataldeath prev_1_q i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa i.fid
			* Previous 4 Quarters
		probit neonataldeath prev_1_q-prev_4_q i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa i.fid
		est sto prb_pq_fs_fe
		margins, at((mean) _all prev_1_q = (0(20)460)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") 
	
		* Yearly
		probit neonataldeath  nicu_year i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa i.fid
		est sto prb_py_fs_fe
		margins, at((mean) _all nicu_year = (10(100)2000)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Year NICU Admits") title("Effect of Volume on Mortality Probability") 
		est sto prb_pq_fs
		
		* 12 Months full (insurance and health states)
		probit neonataldeath  prev_*_month i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa i.fid
		est sto prb_mn_fs_fe
		estadd local Time "Month"
		estadd local Health "Yes"
		estadd local Ins. "Yes"
		estadd local IV "No"
		* 12 Months, no health states
		probit neonataldeath  prev_*_month i.b_es_ges i.pay i.fid
		est sto prb_mn_i_fe
		estadd local Time "Month"
		estadd local Health "No"
		estadd local Ins. "Yes"
		estadd local IV "No"
		* 12 months, no insurance status		
		probit neonataldeath  prev_*_month i.b_es_ges as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa i.fid
		est sto prb_mn_ihs_fe
		estadd local Time "Month"
		estadd local Health "Yes"
		estadd local Ins. "No"
		estadd local IV "No"
		 
	  
	  
	  
	  
		* Combine Estimates
		suest prb_mn_fs_fe prb_py_fs_fe prb_pq_fs_fe 
		* Test equality:
		test [prb_py_fs_fe_neonataldeath]nicu_year = [prb_mn_fs_fe_neonataldeath]prev_1_month
	  
* Subset of VLBW
	keep if b_wt_cgr <= 1500
	* Do a version of these with VLBW summed up.  
	* without fid FE's
		* Quarterly
		probit neonataldeath  prev_q i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa 
		est sto prb_pq_sub
		margins, at((mean) _all prev_1_month = (0(20)460)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") 
	
		* Yearly
		probit neonataldeath  nicu_year i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
		est sto prb_py_sub
		margins, at((mean) _all nicu_year = (10(100)2000)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Year NICU Admits") title("Effect of Volume on Mortality Probability") 
	
		* Monthly
		probit neonataldeath  prev_*_month i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa 
		est sto prb_pm_sub
		margins, at((mean) _all prev_1_month = (0(10)200)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Month NICU Admits") title("Effect of Volume on Mortality Probability") 
		
		* Monthly WITH CURRENT MONTH
		probit neonataldeath month_count  prev_*_month i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa 
		est sto prb_cm_sub
		margins, at((mean) _all prev_1_month = (0(10)200)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Month NICU Admits") title("Effect of Volume on Mortality Probability") 
		
		* Combine estimates
		suest prb_pq_sub prb_py_sub prb_pm_sub prb_cm_sub
		
		* Test for Equality of Prev_1_month coeff and year coeff
		test [prb_pm_sub_neonataldeath]prev_1_month = [prb_py_sub_neonataldeath]nicu_year
		* Test for Equality of Prev_q and Prev 1 month
		test [prb_pq_sub_neonataldeath]prev_q = [prb_pm_sub_neonataldeath]prev_1_month
		* Test for Equality of prev_q and sum of prev 3 months
		test [prb_pq_sub_neonataldeath]prev_q = ([prb_pm_sub_neonataldeath]prev_1_month + [prb_pm_sub_neonataldeath]prev_2_month + [prb_pm_sub_neonataldeath]prev_3_month)
		* Test for Equality of prior q and prior year
		test [prb_pq_sub_neonataldeath]prev_q = [prb_py_sub_neonataldeath]nicu_year
		
		
	* Also with fid FE's  
		* Quarterly
		probit neonataldeath  prev_q i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa i.fid
		margins, at((mean) _all prev_1_month = (0(20)460)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") 
	
		* Yearly
		probit neonataldeath  nicu_year i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa i.fid 
		margins, at((mean) _all nicu_year = (10(100)2000)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Year NICU Admits") title("Effect of Volume on Mortality Probability") 
	
		* Monthly
		probit neonataldeath  prev_*_month i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa i.fid  
		margins, at((mean) _all prev_1_month = (0(10)200)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Month NICU Admits") title("Effect of Volume on Mortality Probability") 
		
		* Monthly WITH CURRENT MONTH
		probit neonataldeath month_count  prev_*_month i.b_es_ges i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa i.fid  
		margins, at((mean) _all prev_1_month = (0(10)200)) nose predict(pr)
		marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Month NICU Admits") title("Effect of Volume on Mortality Probability") 
	
	
* For stylized graph with NO axis labels:
		marginsplot, recast(line) plot1opts(lcolor(black)) graphregion(color(white)) xlabel(none) ylabel(none) ytitle("Mortality Probability") xtitle("Patient Volume") title("Effect of Patient Volume on Mortality Probability")  xline(80) xline(100) xline(180) text( 0.007 50 "Two" "Separate" "Hospitals") text( 0.007 220 "Combined" "Patient" "Volume")	saving( "/Users/austinbean/Google Drive/Current Projects/Job Market/StylizedVolume.gph", replace)

		
		
* For stylized graph of price effects with no axis labels:		
		marginsplot, recast(line) plot1opts(lcolor(black)) graphregion(color(white)) xlabel(none) ylabel(none) ytitle("Market Price") xtitle("Number of Firms") title("Number of Firms vs. Market Price")  xline(50) xline(500) xline(1500) text( 0.007 200 "Monopoly" "Price") text( 0.007 650 "Duopoly" "Price") text( 0.007 1650 "N-opoly" "Price")	saving( "/Users/austinbean/Google Drive/Current Projects/Job Market/StylizedPrice.gph", replace)

		
* TODO: specification tests...
	
	
	
* The following do finish, but save time by skipping SE's
margins, at((mean) _all) dydx(prev_q)  nose
* Trying w/ prediction
 margins, at((mean) _all) dydx(prev_q) predict(pr) nose
 * This one also works
 margins, at((mean) _all prev_q = (0(20)460)) nose


 
 
 * Overlay graphs of volume IV and regular: 
 * combines them side by side...
 
graph combine "/Users/austinbean/Desktop/Birth2005-2012/volumeprobit_noiv.gph" "/Users/austinbean/Desktop/Birth2005-2012/Volume IV Probit.gph", xcommon ycommon
 
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

