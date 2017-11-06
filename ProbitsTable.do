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
	label variable exp_share "Expected Volume"
	keep if _merge == 3
	
	gen vlbw = 0
	replace vlbw = 1 if b_wt_cgr <= 1500
	label variable vlbw "VLBW"
	label variable prev_q "Prev. Q. Vol."

	
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
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status
	eststo noiv_vygp: probit neonataldeath prev_q i.ncdobyear i.b_es_ges i.pay
	* lagged volume, year, estimated gestation, payment status, vlbw status
	eststo noiv_vygpw: probit neonataldeath prev_q i.ncdobyear i.b_es_ges i.pay i.vlbw
	* lagged volume, year, estimated gestation, payment status, vlbw status, health states
	eststo noiv_vygpwh: probit neonataldeath prev_q i.ncdobyear i.b_es_ges i.pay i.vlbw as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
	
	esttab noiv_v noiv_vy noiv_vyg noiv_vygp noiv_vygpw noiv_vygpwh
	
* Run the probits with the volume IV - PREVIOUS QUARTER:
	* Just lagged volume
	eststo iv_v: ivprobit neonataldeath (prev_q = exp_share)
	estadd local IV "Yes"
	estadd local Year "No"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* Lagged volume and year
	eststo iv_vy: ivprobit neonataldeath (prev_q = exp_share ) i.ncdobyear i.vlbw
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* lagged volume, year, estimated gestation
	eststo iv_vyg: ivprobit neonataldeath (prev_q = exp_share ) i.ncdobyear i.b_es_ges
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* lagged volume, year, estimated gestation, payment status
	eststo iv_vygp: ivprobit neonataldeath (prev_q = exp_share ) i.ncdobyear i.b_es_ges i.pay
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* lagged volume, year, estimated gestation, payment status, vlbw status
	eststo iv_vygpw: ivprobit neonataldeath (prev_q = exp_share ) i.ncdobyear i.b_es_ges i.pay i.vlbw
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* lagged volume, year, estimated gestation, payment status, vlbw status, health states
	eststo iv_vygpwh: ivprobit neonataldeath (prev_q = exp_share ) i.ncdobyear i.b_es_ges i.pay i.vlbw as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local HealthStates "Yes"
	estadd scalar ExogeneityPval e(p_exog)
				
		
* Table:
	/*
	noiv/iv = without or with IV for volume.  
	v = volume
	y = year 
	g = gestational age 
	p = insurance type 
	w = vlbw status 
	h = health states
	*/
	
* short table:, fmt(%9.3f %9.0g)
	esttab noiv_vyg iv_vyg iv_vygp iv_vygpw iv_vygpwh, label keep(prev_q)  mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates ExogeneityPval N, labels("IV" "Ins." "VLBW" "Health States" "Hausman Test") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	
	esttab noiv_vyg iv_vyg iv_vygp iv_vygpw iv_vygpwh using "/Users/austinbean/Desktop/Birth2005-2012/ivshorttable.tex", replace label keep(prev_q)  mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates ExogeneityPval N, labels("IV" "Ins." "VLBW" "Health States" "Hausman Test") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	
* long table
	esttab noiv_vyg iv_vyg iv_vygp iv_vygpw iv_vygpwh , drop(*year *b_es_ges) label mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates ExogeneityPval N, fmt(%9.3f %9.0g)) style(tex) cells(b se) legend eqlabels(none) collabels(none)

	esttab noiv_vyg iv_vyg iv_vygp iv_vygpw iv_vygpwh using "/Users/austinbean/Desktop/Birth2005-2012/ivslongtable.tex", drop(*year *b_es_ges) longtable replace label mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates ExogeneityPval N, fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	

	

* Run the probits with the volume IV - FULL YEAR:
	eststo noivy_vyg: probit neonataldeath nicu_year i.ncdobyear i.b_es_ges
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* Just lagged volume
	eststo ivy_v: ivprobit neonataldeath (nicu_year = exp_share)
	estadd local IV "Yes"
	estadd local Year "No"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* Lagged volume and year
	eststo ivy_vy: ivprobit neonataldeath (nicu_year = exp_share ) i.ncdobyear i.vlbw
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* lagged volume, year, estimated gestation
	eststo ivy_vyg: ivprobit neonataldeath (nicu_year = exp_share ) i.ncdobyear i.b_es_ges
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* lagged volume, year, estimated gestation, payment status
	eststo ivy_vygp: ivprobit neonataldeath (nicu_year = exp_share ) i.ncdobyear i.b_es_ges i.pay
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* lagged volume, year, estimated gestation, payment status, vlbw status
	eststo ivy_vygpw: ivprobit neonataldeath (nicu_year = exp_share ) i.ncdobyear i.b_es_ges i.pay i.vlbw
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* lagged volume, year, estimated gestation, payment status, vlbw status, health states
	eststo ivy_vygpwh: ivprobit neonataldeath (nicu_year = exp_share ) i.ncdobyear i.b_es_ges i.pay i.vlbw as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa, first
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local HealthStates "Yes"
	estadd scalar ExogeneityPval e(p_exog)
				
		
* Table:
	/*
	noiv/iv = without or with IV for volume.  
	v = volume
	y = year 
	g = gestational age 
	p = insurance type 
	w = vlbw status 
	h = health states
	*/
	
* short table:, fmt(%9.3f %9.0g)
	esttab noivy_vyg ivy_vyg ivy_vygp ivy_vygpw ivy_vygpwh, label keep(nicu_year)  mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates ExogeneityPval N, labels("IV" "Ins." "VLBW" "Health States" "Hausman Test") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	
	esttab noivy_vyg ivy_vyg ivy_vygp ivy_vygpw ivy_vygpwh using "/Users/austinbean/Desktop/Birth2005-2012/ivshorttable_year.tex", replace label keep(nicu_year)  mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates ExogeneityPval N, labels("IV" "Ins." "VLBW" "Health States" "Hausman Test") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	
* long table
	esttab noivy_vyg ivy_vyg ivy_vygp ivy_vygpw ivy_vygpwh , drop(*year *b_es_ges) label mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates ExogeneityPval N, fmt(%9.3f %9.0g)) style(tex) cells(b se) legend eqlabels(none) collabels(none)

	esttab noivy_vyg ivy_vyg ivy_vygp ivy_vygpw ivy_vygpwh using "/Users/austinbean/Desktop/Birth2005-2012/ivslongtable_year.tex", drop(*year *b_es_ges) longtable replace label mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates ExogeneityPval N, fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	

	

* Run the probits with the volume IV - prev_month:
	eststo noivm_vyg: probit neonataldeath prev_1_month i.ncdobyear i.b_es_ges
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* Just lagged volume
	eststo ivm_v: ivprobit neonataldeath (prev_1_month = exp_share)
	estadd local IV "Yes"
	estadd local Year "No"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* Lagged volume and year
	eststo ivm_vy: ivprobit neonataldeath (prev_1_month = exp_share ) i.ncdobyear i.vlbw
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* lagged volume, year, estimated gestation
	eststo ivm_vyg: ivprobit neonataldeath (prev_1_month = exp_share ) i.ncdobyear i.b_es_ges
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* lagged volume, year, estimated gestation, payment status
	eststo ivm_vygp: ivprobit neonataldeath (prev_1_month = exp_share ) i.ncdobyear i.b_es_ges i.pay
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* lagged volume, year, estimated gestation, payment status, vlbw status
	eststo ivm_vygpw: ivprobit neonataldeath (prev_1_month = exp_share ) i.ncdobyear i.b_es_ges i.pay i.vlbw
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local HealthStates "No"
	estadd scalar ExogeneityPval e(p_exog)
	* lagged volume, year, estimated gestation, payment status, vlbw status, health states
	eststo ivm_vygpwh: ivprobit neonataldeath (prev_1_month = exp_share ) i.ncdobyear i.b_es_ges i.pay i.vlbw as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local HealthStates "Yes"
	estadd scalar ExogeneityPval e(p_exog)
				
		
* Table:
	/*
	noiv/iv = without or with IV for volume.  
	v = volume
	y = year 
	g = gestational age 
	p = insurance type 
	w = vlbw status 
	h = health states
	*/
	
* short table:, fmt(%9.3f %9.0g)
	esttab noivm_vyg ivm_vyg ivm_vygp ivm_vygpw ivm_vygpwh, label keep(prev_1_month)  mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates ExogeneityPval N, labels("IV" "Ins." "VLBW" "Health States" "Hausman Test") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	
	esttab noivm_vyg ivm_vyg ivm_vygp ivm_vygpw ivm_vygpwh using "/Users/austinbean/Desktop/Birth2005-2012/ivshorttable_month.tex", replace label keep(prev_1_month)  mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates ExogeneityPval N, labels("IV" "Ins." "VLBW" "Health States" "Hausman Test") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	
* long table
	esttab noivm_vyg ivm_vyg ivm_vygp ivm_vygpw ivm_vygpwh , drop(*year *b_es_ges) label mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates ExogeneityPval N, fmt(%9.3f %9.0g)) style(tex) cells(b se) legend eqlabels(none) collabels(none)

	esttab noivm_vyg ivm_vyg ivm_vygp ivm_vygpw ivm_vygpwh using "/Users/austinbean/Desktop/Birth2005-2012/ivslongtable_month.tex", drop(*year *b_es_ges) longtable replace label mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates ExogeneityPval N, fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	

	
	


* Run the probits with the volume IV - prev_month:
	foreach nm of numlist 1(1)12{
		label variable prev_`nm'_month "Lag `nm' Months NICU Admits"
	}


	eststo am_vyg: probit neonataldeath prev_*_month i.ncdobyear i.b_es_ges
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* Lagged volume and year
	eststo am_vy: probit neonataldeath prev_*_month  i.ncdobyear i.vlbw
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation
	eststo am_vyg: probit neonataldeath prev_*_month i.ncdobyear i.b_es_ges
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status
	eststo am_vygp: probit neonataldeath prev_*_month i.ncdobyear i.b_es_ges i.pay
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status, vlbw status
	eststo am_vygpw: probit neonataldeath prev_*_month i.ncdobyear i.b_es_ges i.pay i.vlbw
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status, vlbw status, health states
	eststo am_vygpwh: probit neonataldeath prev_*_month i.ncdobyear i.b_es_ges i.pay i.vlbw as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local HealthStates "Yes"
				
		
* Table:
	/*
	noiv/iv = without or with IV for volume.  
	v = volume
	y = year 
	g = gestational age 
	p = insurance type 
	w = vlbw status 
	h = health states
	*/
	
* short table:, fmt(%9.3f %9.0g)
	esttab am_vyg am_vyg am_vygp am_vygpw am_vygpwh, label keep(prev_*_month) stats(IV Insurance VLBW HealthStates N, labels("IV" "Ins." "VLBW" "Health States" ) fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	
	esttab am_vyg am_vyg am_vygp am_vygpw am_vygpwh using "/Users/austinbean/Desktop/Birth2005-2012/ivshorttable_allmonth.tex", replace label keep(prev_*_month) stats(IV Insurance VLBW HealthStates N, labels("IV" "Ins." "VLBW" "Health States" ) fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	
* long table
	esttab am_vyg am_vyg am_vygp am_vygpw am_vygpwh , drop(*year *b_es_ges) label stats(IV Insurance VLBW HealthStates N, fmt(%9.3f %9.0g)) style(tex) cells(b se) legend eqlabels(none) collabels(none)

	esttab am_vyg am_vyg am_vygp am_vygpw am_vygpwh using "/Users/austinbean/Desktop/Birth2005-2012/ivslongtable_allmonth.tex", drop(*year *b_es_ges) longtable replace label stats(IV Insurance VLBW HealthStates N, fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	
	
		


* Run the probits with the volume IV - prev_month:
	foreach nm of numlist 1(1)12{
		label variable prev_`nm'_month "Lag `nm' Months NICU Admits"
	}


	eststo amf_vyg: probit neonataldeath prev_*_month i.ncdobyear i.b_es_ges i.fid
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local FEs "Yes"
	estadd local HealthStates "No"
	* Lagged volume and year
	eststo amf_vy: probit neonataldeath prev_*_month  i.ncdobyear i.vlbw i.fid
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local FEs "Yes"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation
	eststo amf_vyg: probit neonataldeath prev_*_month i.ncdobyear i.b_es_ges i.fid
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local FEs "Yes"	
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status
	eststo amf_vygp: probit neonataldeath prev_*_month i.ncdobyear i.b_es_ges i.pay i.fid
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "No"
	estadd local FEs "Yes"	
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status, vlbw status
	eststo amf_vygpw: probit neonataldeath prev_*_month i.ncdobyear i.b_es_ges i.pay i.vlbw i.fid
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local FEs "Yes"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status, vlbw status, health states
	eststo amf_vygpwh: probit neonataldeath prev_*_month i.ncdobyear i.b_es_ges i.pay i.vlbw i.fid as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
	estadd local IV "No"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local FEs "Yes"
	estadd local HealthStates "Yes"
				
		
* Table:
	/*
	noiv/iv = without or with IV for volume.  
	v = volume
	y = year 
	g = gestational age 
	p = insurance type 
	w = vlbw status 
	h = health states
	*/
	
* short table:, fmt(%9.3f %9.0g)
	esttab amf_vyg amf_vyg amf_vygp amf_vygpw amf_vygpwh, label keep(prev_*_month) stats(IV Insurance VLBW HealthStates FEs N, labels("IV" "Ins." "VLBW" "Health States" "FEs" ) fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	
	esttab amf_vyg amf_vyg amf_vygp amf_vygpw amf_vygpwh using "/Users/austinbean/Desktop/Birth2005-2012/ivshorttable_allmonthfes.tex", replace label keep(prev_*_month) stats(IV Insurance VLBW HealthStates FEs N, labels("IV" "Ins." "VLBW" "Health States" "FEs") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	
* long table
	esttab amf_vyg amf_vyg amf_vygp amf_vygpw amf_vygpwh, drop(*year *b_es_ges) label stats(IV Insurance VLBW HealthStates FEs N, fmt(%9.3f %9.0g)) style(tex) cells(b se) legend eqlabels(none) collabels(none)

	esttab amf_vyg amf_vyg amf_vygp amf_vygpw amf_vygpwh using "/Users/austinbean/Desktop/Birth2005-2012/ivslongtable_allmonthfes.tex", drop(*year *b_es_ges) longtable replace label stats(IV Insurance VLBW HealthStates FEs N, fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
	
	
		
	
	
* More specifications with FE's for the presentation:
  label variable nicu_year "Admits Yearly"
  label variable prev_q "Admits Quart."
  label variable prev_1_month "Admits Pr. Month"

  eststo iv_yfhp: ivprobit neonataldeath (nicu_year = exp_share) i.fid i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
  estadd local IV "Yes"
  estadd local FEs "Yes"
  estadd local Time "Yr."
  estadd local Insurance "Yes"
  estadd local HealthStates "Yes"  
  
  eststo iv_yfp: ivprobit neonataldeath (nicu_year = exp_share) i.fid i.pay 
  estadd local IV "Yes"
  estadd local FEs "Yes"
  estadd local Time "Yr."
  estadd local Insurance "Yes"
  estadd local HealthStates "Yes"

  eststo iv_yfh: ivprobit neonataldeath (nicu_year = exp_share) i.fid as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
  estadd local IV "Yes"
  estadd local FEs "Yes"
  estadd local Time "Yr."
  estadd local Insurance "No"
  estadd local HealthStates "No"
  
  eststo iv_qfph: ivprobit neonataldeath (prev_q = exp_share) i.fid i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
  estadd local IV "Yes"
  estadd local FEs "Yes"
  estadd local Time "Q."
  estadd local Insurance "Yes"
  estadd local HealthStates "Yes"

  eststo iv_qfp: ivprobit neonataldeath (prev_q = exp_share) i.fid i.pay 
  estadd local IV "Yes"
  estadd local FEs "Yes"  
  estadd local Time "Q."
  estadd local Insurance "Yes"
  estadd local HealthStates "No"
 
  eststo iv_qfh: ivprobit neonataldeath (prev_q = exp_share) i.fid as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
  estadd local IV "Yes"
  estadd local FEs "Yes"  
  estadd local Time "Q."
  estadd local Insurance "No"
  estadd local HealthStates "Yes"
  
  eststo iv_mfph: ivprobit neonataldeath (prev_1_month = exp_share) i.fid i.pay as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
  estadd local IV "Yes"
  estadd local FEs "Yes"  
  estadd local Time "Mn."
  estadd local Insurance "Yes"
  estadd local HealthStates "Yes"

  eststo iv_mfp: ivprobit neonataldeath (prev_1_month = exp_share) i.fid i.pay 
  estadd local IV "Yes"
  estadd local FEs "Yes"
  estadd local Time "Mn."
  estadd local Insurance "Yes"
  estadd local HealthStates "No"

  eststo iv_mfh: ivprobit neonataldeath (prev_1_month = exp_share) i.fid as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
  estadd local IV "Yes"
  estadd local FEs "Yes"
  estadd local Time "Mn."
  estadd local Insurance "No"
  estadd local HealthStates "Yes"

  esttab iv_yfhp iv_yfp iv_yfh, label keep(nicu_year) stats(IV Insurance FEs Time HealthStates N, labels("IV" "Ins." "FEs" "Time" "Health States" "N") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
  esttab iv_yfhp iv_yfp iv_yfh using "/Users/austinbean/Desktop/Birth2005-2012/ivfeyearshorttable.tex", replace label keep(nicu_year) stats(IV Insurance FEs Time HealthStates N, labels("IV" "Ins." "FEs" "Time" "Health States" "N") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
 
  esttab iv_qfph iv_qfp iv_qfh, label keep(prev_q) stats(IV Insurance FEs Time HealthStates N, labels("IV" "Ins." "FEs" "Time" "Health States" "N") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
  esttab iv_qfph iv_qfp iv_qfh using "/Users/austinbean/Desktop/Birth2005-2012/ivfequarshorttable.tex", replace label keep(prev_q) stats(IV Insurance FEs Time HealthStates N, labels("IV" "Ins." "FEs" "Time" "Health States" "N") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)

  esttab iv_mfph iv_mfp iv_mfh, label keep(prev_1_month) stats(IV Insurance FEs Time HealthStates N, labels("IV" "Ins." "FEs" "Time" "Health States" "N") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)
  esttab iv_mfph iv_mfp iv_mfh using "/Users/austinbean/Desktop/Birth2005-2012/ivfemonthshorttable.tex", replace label keep(prev_1_month) stats(IV Insurance FEs Time HealthStates N, labels("IV" "Ins." "FEs" "Time" "Health States" "N") fmt(%9.3f %9.0g)) style(tex) cells(b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)

	
	
	
	
	
	
* How about some simple 2SLS...
	eststo lr_v: regress neonataldeath prev_q
	estadd local IV "No"
	estadd local Year "No"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	
	eststo tsls_v: ivregress 2sls neonataldeath (prev_q = exp_share)
	estadd local IV "Yes"
	estadd local Year "No"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* Lagged volume and year
	eststo tsls_vy: ivregress 2sls neonataldeath (prev_q = exp_share ) i.ncdobyear i.vlbw
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "No"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation
	eststo tsls_vyg: ivregress 2sls neonataldeath (prev_q = exp_share ) i.ncdobyear i.b_es_ges
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "No"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status
	eststo tsls_vygp: ivregress 2sls neonataldeath (prev_q = exp_share ) i.ncdobyear i.b_es_ges i.pay
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "No"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status, vlbw status
	eststo tsls_vygpw: ivregress 2sls neonataldeath (prev_q = exp_share ) i.ncdobyear i.b_es_ges i.pay i.vlbw
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local HealthStates "No"
	* lagged volume, year, estimated gestation, payment status, vlbw status, health states
	eststo tsls_vygpwh :ivregress 2sls neonataldeath (prev_q = exp_share) i.ncdobyear i.b_es_ges i.pay i.vlbw as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa
	estadd local IV "Yes"
	estadd local Year "Yes"
	estadd local Gestation "Yes"
	estadd local Insurance "Yes"
	estadd local VLBW "Yes"
	estadd local HealthStates "Yes"


	esttab lr_v tsls_v tsls_vy tsls_vygp tsls_vygpw tsls_vygpwh
	
	
	, drop(*year *b_es_ges) label mtitle("No IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV" "Vol. IV") stats(IV Insurance VLBW HealthStates, fmt(%9.3f %9.0g)) style(tex) (b(star fmt(4)) se(fmt(4))) legend eqlabels(none) collabels(none)


	
