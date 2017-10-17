/*
Run some regular and IV probits with the goal of creating a table with the coefficients.
*/



* Setup...
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

	merge m:1 ncdobyear fid using "${birthdata}allyearnicufidshares.dta"

	keep if _merge == 3
	
	gen vlbw = 0
	replace vlbw = 1 if b_wt_cgr <= 1500

	
* Run the probits without the IV:
	* Just lagged volume
	eststo noiv_v: probit neonataldeath prev_q
	estadd local IV "No"
	estadd local Year "No"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* Lagged volume and year
	eststo noiv_vy: probit neonataldeath prev_q i.ncdobyear
	* lagged volume, year, estimated gestation
	eststo noiv_vyg: probit neonataldeath prev_q i.ncdobyear i.b_es_ges
	* lagged volume, year, estimated gestation, payment status
	eststo noiv_vygp: probit neonataldeath prev_q i.ncdobyear i.b_es_ges i.pay
	* lagged volume, year, estimated gestation, payment status, vlbw status
	eststo noiv_vygpw: probit neonataldeath prev_q i.ncdobyear i.b_es_ges i.pay i.vlbw
	* lagged volume, year, estimated gestation, payment status, vlbw status, health states
	eststo noiv_vygpwh: probit neonataldeath prev_q i.ncdobyear i.b_es_ges i.pay i.vlbw as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
	
	esttab noiv_v noiv_vy noiv_vyg noiv_vygp noiv_vygpw noiv_vygpwh
	
* Run the probits with the volume IV:
	* Just lagged volume
	eststo iv_v: ivprobit neonataldeath (prev_q = exp_share)
	estadd local IV "Yes"
	estadd local Year "No"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* Lagged volume and year
	eststo iv_vy: ivprobit neonataldeath (prev_q = exp_share ) i.ncdobyear
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation
	eststo iv_vyg: ivprobit neonataldeath (prev_q = exp_share ) i.ncdobyear i.b_es_ges
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status
	eststo iv_vygp: ivprobit neonataldeath (prev_q = exp_share ) i.ncdobyear i.b_es_ges i.pay
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status, vlbw status
	eststo iv_vygpw: ivprobit neonataldeath (prev_q = exp_share ) i.ncdobyear i.b_es_ges i.pay i.vlbw
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status, vlbw status, health states
	eststo iv_vygpwh: ivprobit neonataldeath (prev_q = exp_share ) i.ncdobyear i.b_es_ges i.pay i.vlbw as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local HealthStates "Yes"
		
	esttab noiv_v iv_vyg iv_vygp iv_vygpw iv_vygpwh, keep(prev_q) stats(IV Year Gestation Insurance VLBW HealthStates)	mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV")
		
		
* Table: 		
		
	esttab noiv_v iv_vyg iv_vygp iv_vygpw iv_vygpwh, keep(prev_q) mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Year Gestation Insurance VLBW HealthStates r2 N, fmt(%9.3f %9.0g) labels(R-sq)) style(tex) cells(b se) legend eqlabels(none) collabels(none)
	
