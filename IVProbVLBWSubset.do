* Regular and IV Probit for a Subset:

/*

- Two things here: 
	1.  estimate regular probit and iv probit models JUST using vlbw population.
	2.  estimate using the whole population
	
- For each, compute the marginal effects in the vlbw population
	- So one will be: marginal effects on vlbw using model estimated on vlbw population
	- The other: marginal effects on vlbw using model estimate on whole population
*/


* Import

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
	gen vlbw = 0
	replace vlbw = 1 if b_wt_cgr < 1500
	
	
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


* Regular and IV Probit - ALL PATIENTS:
* No IV for Volume: 
	probit neonataldeath  prev_q i.b_es_ges i.pay i.ncdobyear i.vlbw as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
	eststo allp_noiv: probit neonataldeath  prev_q i.b_es_ges i.pay i.ncdobyear i.vlbw as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
	margins, at((mean) _all  prev_q = (0(20)460) vlbw = 1 ) post
	est store prob_marg_no_iv_vlbw
	estimates save "/Users/austinbean/Desktop/Birth2005-2012/prob_marg_no_iv_vlbw.ster", replace
	* estimates use "/Users/austinbean/Desktop/Birth2005-2012/prob_marg_no_iv_vlbw.ster"
	marginsplot, recastci(rarea) ciopts(color(gray*0.6))  recast(line) plot1opts(lcolor(black)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability - VLBW Only") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") subtitle("For VLBW Patients Only") saving("/Users/austinbean/Desktop/Birth2005-2012/volprob_noiv_vlbw.gph", replace)


* w/ IV for volume and year FE's:
	ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay i.ncdobyear i.vlbw as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
	eststo allp_iv:  ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay i.ncdobyear i.vlbw as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
	* takes a LONG time. started at: 12:40, finished at: 2:30.  Ugh.  
	margins, at((mean) _all vlbw = 1 prev_q = (0(20)460)) predict(pr) post saving("/Users/austinbean/Desktop/ivprbmarg_vlbw.dta", replace)
	est store prob_marg_w_iv_vlbw
	estimates save "/Users/austinbean/Desktop/Birth2005-2012/prob_marg_w_iv_vlbw.ster", replace
	* estimates use "/Users/austinbean/Desktop/Birth2005-2012/prob_margins_w_iv.ster"
	marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") subtitle( "Volume IV") saving("/Users/austinbean/Desktop/Birth2005-2012/Volume IV Probit, VLBW.gph", replace)

* Saving the Probit and IV probit results out as a table:
	esttab using "/Users/austinbean/Desktop/Birth2005-2012/ivprobresults_vlbw.tex", se ar2 label title("Results - All Patient Model") nonumbers mtitles("Probit" "IV Probit") replace

* Plotting both of the sets of marginal effects:
	coefplot prob_marg_no_iv_vlbw prob_marg_w_iv_vlbw,  recast(line) vertical title("Effect of Volume on Outcome, All Patient Model") subtitle("With and Without Volume IV - VLBW Patients Only") ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits")  xlabel(   1 "0" 2 "20" 3 "40" 4 "60" 5 "80" 6 "100" 7 "120" 8 "140" 9 "160" 10 "180" 11 "200" 12 "220" 13 "240" 14 "260" 15 "280" 16 "300" 17 "320" 18 "340" 19 "360" 20 "380" 21 "400" 22 "420" 23 "440" 24 "460", angle(45)) graphregion(color(white))
	graph save Graph "/Users/austinbean/Desktop/Birth2005-2012/Combined IV Prob Volume VLBW.gph", replace

	
	
	
* Regular and IV Probit - VLBW PATIENTS ONLY:
* No IV for Volume: 
	preserve
	keep if vlbw == 1
	probit neonataldeath  prev_q i.b_es_ges i.pay i.ncdobyear as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa if vlbw == 1  
	eststo: probit neonataldeath  prev_q i.b_es_ges i.pay i.ncdobyear as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa if vlbw == 1
	margins, at((mean) _all  prev_q = (0(20)460) ) post
	est store prob_marg_no_iv_vlbw_only
	estimates save "/Users/austinbean/Desktop/Birth2005-2012/prob_marg_noiv_vlb_on.ster", replace
	* estimates use "/Users/austinbean/Desktop/Birth2005-2012/prob_marg_noiv_vlb_on.ster"
	marginsplot, recastci(rarea) ciopts(color(gray*0.6))  recast(line) plot1opts(lcolor(black)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability - VLBW Only") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") subtitle("For VLBW Patients Only") saving("/Users/austinbean/Desktop/Birth2005-2012/volprob_noiv_vlbwonly.gph", replace)


* w/ IV for volume and year FE's:
	ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay i.ncdobyear as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa if vlbw == 1
	eststo:  ivprobit neonataldeath  (prev_q = exp_share ) i.b_es_ges i.pay i.ncdobyear as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa if vlbw == 1
	* takes a LONG time. started at: 12:40, finished at: 2:30.  Ugh.  
	margins, at((mean) _all prev_q = (0(20)460)) predict(pr) post saving("/Users/austinbean/Desktop/ivprbmarg_vlbwonly.dta", replace)
	est store prob_marg_w_iv_vlbwonly
	estimates save "/Users/austinbean/Desktop/Birth2005-2012/prob_marg_wiv_vlbon.ster", replace
	* estimates use "/Users/austinbean/Desktop/Birth2005-2012/prob_marg_wiv_vlbon.ster"
	marginsplot, recastci(rarea) ciopts(color(*0.6)) recast(line) plot1opts(lcolor(red)) graphregion(color(white)) xlabel(#10) ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits") title("Effect of Volume on Mortality Probability") subtitle( "Volume IV") saving("/Users/austinbean/Desktop/Birth2005-2012/Volume IV Probit, VLBW Only.gph", replace)

* Saving the Probit and IV probit results out as a table:
	esttab using "/Users/austinbean/Desktop/Birth2005-2012/ivprobresults_vlbwonly.tex", se ar2 label title("Results - VLBW Only Model") nonumbers mtitles("Probit" "IV Probit") replace

* Plotting both of the sets of marginal effects:
	coefplot prob_marg_no_iv_vlbw_only prob_marg_w_iv_vlbwonly,  recast(line) vertical title("Effect of Volume on Outcome") subtitle("With and Without Volume IV - VLBW Patients Only") ytitle("Mortality Probability") xtitle("Prior Quarter NICU Admits")  xlabel(   1 "0" 2 "20" 3 "40" 4 "60" 5 "80" 6 "100" 7 "120" 8 "140" 9 "160" 10 "180" 11 "200" 12 "220" 13 "240" 14 "260" 15 "280" 16 "300" 17 "320" 18 "340" 19 "360" 20 "380" 21 "400" 22 "420" 23 "440" 24 "460", angle(45)) graphregion(color(white))
	graph save Graph "/Users/austinbean/Desktop/Birth2005-2012/Combined IV Prob Volume VLBW Only.gph", replace
	restore
