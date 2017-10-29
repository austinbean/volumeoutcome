* Nonlinear least squares...
/*

Not as bad as I thought. 
TODO - transformation of delta1 in Benkard style nlls. 
*/


do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"


/*
* This needs to be run only when CombinedFacCount.dta is changed, just to drop some missing values.
use "${birthdata}CombinedFacCount.dta", clear
drop if fid == .
duplicates drop fid ncdobyear ncdobmonth, force
save "${birthdata}FacCountMissingFidDropped.dta",replace
*/

* use "${birthdata}Birth2006.dta", clear
	* APPEND later years.  
	use "${birthdata}Birth2006.dta", clear
	gen y2006 = 1
	append using "${birthdata}Birth2007.dta", gen(y2007)
	append using "${birthdata}Birth2008.dta", gen(y2008)
	append using "${birthdata}Birth2009.dta", gen(y2009)
	append using "${birthdata}Birth2010.dta", gen(y2010)
	append using "${birthdata}Birth2011.dta", gen(y2011)
	append using "${birthdata}Birth2012.dta", gen(y2012)

	* Clean up year indicators	
	local yrl y2006 y2007 y2008 y2009 y2010 y2011 y2012
	foreach v1 of local yrl{
		replace `v1' = 0 if `v1' == .
	}
	

* drop home births
	keep if b_bplace ==1 
	
* drop non nicu admits
	keep if adm_nicu == 1

* OPTIONAL: specialize to VLBW only	
    *keep if b_wt_cgr < 1500
	
* Add monthly count	
	merge m:1 fid ncdobyear ncdobmonth using "${birthdata}FacCountMissingFidDropped.dta"
	drop if _merge != 3
	
* Racial Categories:
	gen asian = 0
	replace asian = 1 if m_rasnin == 1 | m_rchina == 1 | m_rfilip == 1 | m_rjapan == 1 | m_rkorea == 1 | m_rviet == 1 | m_rothas == 1 
	gen afam = 0
	replace afam = 1 if m_rblack == 1
	gen white = 0
	replace white = 1 if m_rwhite == 1
	gen pacis = 0
	replace pacis = 1 if m_rhawai == 1 | m_rguam == 1 | m_rsamoa == 1 | m_rothpa == 1
* Ethnic: Gen hispanic
	gen hispanic = 0
	replace hispanic = 1 if m_hismex == 1 | m_hispr== 1 | m_hiscub== 1 | m_hisoth== 1  | m_h_unk== 1 
	
* Insurance Status:
	gen medicaid = 0
	replace medicaid = 1 if pay == 1
	gen privateins = 0 
	replace privateins = 1 if pay == 2
	gen otherins = 0
	replace otherins = 1 if pay != 2 & pay != 1

* You need to add the constant manually:
	gen b_const = 1
	
	
* drop any observation which has a missing value in any variable used below - nl is very, very fussy
	local nlv prev_11_months month_count b_const NeoIntensive SoloIntermediate as_vent rep_ther antibiot seizure b_injury bca_aeno bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb bca_spin hypsospa y2006-y2012 b_wt_cgr pc_y_n
	foreach vll of local nlv{
		drop if `vll' == .
	}
	local nl2 exper_10 prev_1_month NeoIntensive SoloIntermediate ObstetricCare diab_pre diab_ges brf_crhy brf_pghy brf_eclm pre_prem bo_trans medicaid privateins otherins white afam asian pacis hispanic pay lab_ster hypsospa bca_limb congenga congenom bca_hern congenhd pc_y_n b_wt_cgr as_vent rep_ther antibiot seizure b_injury bca_aeno bca_spin b_const y2006 y2007 y2008 y2009 y2010 y2011 y2012
	foreach vll of local nl2{
		drop if `vll' == .
	}
	
	
* this works:
	* EVERYTHING with any missing value at all must be dropped.
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther+ {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot+ {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure+ {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury+ {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno+ {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno+ {b10=1.0}*bca_spin + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)	
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno+ {b10=1.0}*bca_spin + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno+ {b10=1.0}*bca_spin + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + {bpc=1.0}*pc_y_n + {bchd=1.0}*congenhd + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno+ {b10=1.0}*bca_spin + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	

	
* With previous 1 month and acc. experience as sum of prior 10 months - assumes full depreciation after one year.  	
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* Hospital feature: nicu 3
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* Hosp: level 2
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
* Adding more Health states one by one, with exceptions for birth weight and obstetric care and prenatal care y/n
	* as_vent
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* rep_ther
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther+ {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* antibiotics
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot+ {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* seizure
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure+ {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* b_injury
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury+ {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* bca_aeno
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno+ {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* bca_spin
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno+ {b10=1.0}*bca_spin + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* Birth weight
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno+ {b10=1.0}*bca_spin + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* Obstetric care
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno+ {b10=1.0}*bca_spin + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* Prenatal care
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno+ {b10=1.0}*bca_spin + ///
	{bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* congenhd
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* bca_hern
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* congenom
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* congenga
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* bca_limb
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* TODO - maybe missed one 
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	* hypsospa
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)

* Race/Ethnicity categories:
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	
* Insurance categories:
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
	{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	
* transferred:
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
	{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 + ///
	{btrs=1.0}*bo_trans )
	
* lab_ster:
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
	{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 + ///
	{btrs=1.0}*bo_trans + {bster=1.0}*lab_ster )
	
* pregnancy covariates: diab_pre diab_ges brf_crhy brf_pghy brf_eclm pre_prem
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
	{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 + ///
	{bdiab = 1.0}*diab_pre + {bdig=1.0}*diab_ges + {bcrh=1.0}*brf_crhy + {bpgh=1.0}*brf_pghy + {brfe=1.0}*brf_eclm + {bprem=1.0}*pre_prem + ///
	{btrs=1.0}*bo_trans + {bster=1.0}*lab_ster )

	

	
	
	
* FOR THE PRESENTATION ... 
di "YEAR FE AND CONSTANT"
nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {bcons=1.0}*b_const+ {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)

	
/*
Iteration 14:  residual SS =  2460.449


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model |  2.0196072          8  .252450904    R-squared     =     0.0008
    Residual |  2460.4488      25937  .094862505    Adj R-squared =     0.0005
-------------+----------------------------------    Root MSE      =   .3079976
       Total |  2462.4684      25945  .094911096    Res. dev.     =   12511.25

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |  -.0081832   .0023093    -3.54   0.000    -.0127096   -.0036568
         /FR |   .0911944   .2666661     0.34   0.732     -.431486    .6138748
      /bcons |   1.000041          .        .       .            .           .
      /b2006 |  -.8568431   .0130514   -65.65   0.000    -.8824246   -.8312616
      /b2007 |  -.8578851   .0130239   -65.87   0.000    -.8834128   -.8323575
      /b2008 |   -.863828   .0130993   -65.94   0.000    -.8895033   -.8381527
      /b2009 |   -.860184   .0131232   -65.55   0.000    -.8859063   -.8344617
      /b2010 |  -.8598933   .0133336   -64.49   0.000    -.8860279   -.8337587
      /b2011 |  -.8577522   .0132304   -64.83   0.000    -.8836845   -.8318198
      /b2012 |  -.8731404   .0132171   -66.06   0.000    -.8990465   -.8472342
------------------------------------------------------------------------------
  Parameter bcons taken as constant term in model & ANOVA table

*/
di " NO HOSPITAL CHARS"
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1)  + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
	{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 )
	
/*
Iteration 7:  residual SS =  2104.556


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model |  357.91284         38  9.41875901    R-squared     =     0.1453
    Residual |  2104.5556      25907  .081235016    Adj R-squared =     0.1441
-------------+----------------------------------    Root MSE      =   .2850176
       Total |  2462.4684      25945  .094911096    Res. dev.     =    8457.46

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |  -.0084717   .0021839    -3.88   0.000    -.0127522   -.0041911
         /FR |   .0573298   .1576183     0.36   0.716    -.2516108    .3662704
        /bhy |  -.0213739   .0444603    -0.48   0.631    -.1085186    .0657708
      /bbcal |  -.5988977          .        .       .            .           .
        /bcl |   .9999539   .0681601    14.67   0.000     .8663563    1.133551
      /bcona |   .1123668   .0484127     2.32   0.020     .0174751    .2072584
      /bconm |   .3278777   .1105419     2.97   0.003     .1112094     .544546
       /bchn |   .4308749   .0959804     4.49   0.000      .242748    .6190017
       /bchd |   .3761588   .0579662     6.49   0.000     .2625419    .4897757
        /bpc |  -.0243372   .0065698    -3.70   0.000    -.0372144     -.01146
         /bw |  -.0003548   5.85e-06   -60.62   0.000    -.0003663   -.0003433
         /b4 |   -.002949   .0039289    -0.75   0.453    -.0106499    .0047519
         /b5 |   .0024886   .0061491     0.40   0.686    -.0095641    .0145413
         /b6 |  -.0142156   .0052853    -2.69   0.007     -.024575   -.0038562
         /b7 |   .0876199   .0424179     2.07   0.039     .0044785    .1707612
         /b8 |   .0087582   .0545404     0.16   0.872     -.098144    .1156604
         /b9 |   .4209678   .0617206     6.82   0.000     .2999919    .5419436
        /b10 |   -.153693   .0974237    -1.58   0.115    -.3446489    .0372629
       /bhis |   .0175791   .0058275     3.02   0.003      .006157    .0290013
      /bafam |   -.008816   .0074295    -1.19   0.235    -.0233783    .0057462
       /basn |   .0071527   .0108345     0.66   0.509    -.0140835    .0283889
      /bpacs |   .0081647   .0505862     0.16   0.872    -.0909871    .1073166
      /bhisp |   .0032061   .0046678     0.69   0.492    -.0059431    .0123552
       /bmed |   .9706745   .0053915   180.04   0.000     .9601069    .9812421
      /bpriv |   .9727404   .0057975   167.79   0.000      .961377    .9841038
      /boins |   1.004529          .        .       .            .           .
      /bcons |   1.003722          .        .       .            .           .
      /b2006 |  -1.446514   .0169313   -85.43   0.000      -1.4797   -1.413328
      /b2007 |  -1.450137      .0169   -85.81   0.000    -1.483262   -1.417012
      /b2008 |  -1.453401   .0170293   -85.35   0.000    -1.486779   -1.420022
      /b2009 |  -1.449476   .0170508   -85.01   0.000    -1.482896   -1.416055
      /b2010 |  -1.445535   .0172902   -83.60   0.000    -1.479425   -1.411645
      /b2011 |  -1.446632   .0172087   -84.06   0.000    -1.480362   -1.412902
      /b2012 |  -1.460895    .017114   -85.36   0.000     -1.49444   -1.427351
      /bdiab |  -.0096194   .0144175    -0.67   0.505    -.0378785    .0186397
       /bdig |   .0025552   .0090764     0.28   0.778    -.0152351    .0203454
       /bcrh |  -.0421444    .009343    -4.51   0.000    -.0604572   -.0238316
       /bpgh |  -.0465716   .0048919    -9.52   0.000    -.0561601   -.0369832
       /brfe |   -.064992   .0214259    -3.03   0.002     -.106988    -.022996
      /bprem |   .0085061   .0081005     1.05   0.294    -.0073713    .0243835
       /btrs |  -.0042695   .0061316    -0.70   0.486    -.0162877    .0077487
      /bster |  -.0237075   .0051936    -4.56   0.000    -.0338873   -.0135278
------------------------------------------------------------------------------
  Parameter bcons taken as constant term in model & ANOVA table

*/

di "NO HEALTH STATES"
	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
	{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 + ///
	{bdiab = 1.0}*diab_pre + {bdig=1.0}*diab_ges + {bcrh=1.0}*brf_crhy + {bpgh=1.0}*brf_pghy + {brfe=1.0}*brf_eclm + {bprem=1.0}*pre_prem + ///
	{btrs=1.0}*bo_trans + {bster=1.0}*lab_ster )
	
/*



*/

di "NO INS STATUS"

	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 )		

	
/*

*/	
	
	
* TRY adding FE's

levelsof fid, local(fff)

foreach fd of local fff{
	gen ind`fd' = 0
	replace ind`fd' = 1 if fid == `fd'
	label ind`fd' "indicator for fid `fd'"
	drop if ind`fd' == .

}

foreach fd of local fff{
	di "    {b`fd' = 1.0}*ind`fd' +  ///"
}

* Full mode with FE's.  This is basically stupid...
 	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
	{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 + ///
	{bdiab = 1.0}*diab_pre + {bdig=1.0}*diab_ges + {bcrh=1.0}*brf_crhy + {bpgh=1.0}*brf_pghy + {brfe=1.0}*brf_eclm + {bprem=1.0}*pre_prem + ///
	{btrs=1.0}*bo_trans + {bster=1.0}*lab_ster + ///
	{b16122 = 1.0}*ind16122 + {b30105 = 1.0}*ind30105 + {b52390 = 1.0}*ind52390 + {b52395 = 1.0}*ind52395 + {b132096 = 1.0}*ind132096 + {b250295 = 1.0}*ind250295 + {b273410 = 1.0}*ind273410 + /// 
	{b273420 = 1.0}*ind273420 + {b293005 = 1.0}*ind293005 + {b293010 = 1.0}*ind293010 + {b293015 = 1.0}*ind293015 + {b293105 = 1.0}*ind293105 + {b293120 = 1.0}*ind293120 + /// 
	{b293122 = 1.0}*ind293122 + {b296002 = 1.0}*ind296002 + {b296025 = 1.0}*ind296025 + {b296191 = 1.0}*ind296191 + {b296451 = 1.0}*ind296451 + {b350650 = 1.0}*ind350650 + ///
	{b373510 = 1.0}*ind373510 + {b390111 = 1.0}*ind390111 + {b391525 = 1.0}*ind391525 + {b410490 = 1.0}*ind410490 + {b410500 = 1.0}*ind410500 + {b430050 = 1.0}*ind430050 + ///
	{b490465 = 1.0}*ind490465 + {b572853 = 1.0}*ind572853 + {b610460 = 1.0}*ind610460 + {b611790 = 1.0}*ind611790 + {b615100 = 1.0}*ind615100 + {b616318 = 1.0}*ind616318 + /// 
	{b732070 = 1.0}*ind732070 + {b736304 = 1.0}*ind736304 + {b750595 = 1.0}*ind750595 + {b852480 = 1.0}*ind852480 + {b855094 = 1.0}*ind855094 + {b856181 = 1.0}*ind856181 + ///
	{b856301 = 1.0}*ind856301 + {b856316 = 1.0}*ind856316 + {b856354 = 1.0}*ind856354 + {b895105 = 1.0}*ind895105 + {b912625 = 1.0}*ind912625 + {b1130900 = 1.0}*ind1130900 + /// 
	{b1130950 = 1.0}*ind1130950 + {b1131020 = 1.0}*ind1131020 + {b1131021 = 1.0}*ind1131021 + {b1131050 = 1.0}*ind1131050 + {b1131616 = 1.0}*ind1131616 + {b1132055 = 1.0}*ind1132055 + /// 
	{b1132528 = 1.0}*ind1132528 + {b1135009 = 1.0}*ind1135009 + {b1135113 = 1.0}*ind1135113 + {b1136005 = 1.0}*ind1136005 + {b1136007 = 1.0}*ind1136007 + {b1136020 = 1.0}*ind1136020 + /// 
	{b1136268 = 1.0}*ind1136268 + {b1136366 = 1.0}*ind1136366 + {b1136457 = 1.0}*ind1136457 + {b1152195 = 1.0}*ind1152195 + {b1171820 = 1.0}*ind1171820 + {b1215085 = 1.0}*ind1215085 + /// 
	{b1215126 = 1.0}*ind1215126 + {b1216088 = 1.0}*ind1216088 + {b1216116 = 1.0}*ind1216116 + {b1216470 = 1.0}*ind1216470 + {b1230865 = 1.0}*ind1230865 + {b1352660 = 1.0}*ind1352660 + ///
	{b1355097 = 1.0}*ind1355097 + {b1391330 = 1.0}*ind1391330 + {b1393700 = 1.0}*ind1393700 + {b1411240 = 1.0}*ind1411240 + {b1411290 = 1.0}*ind1411290 + {b1411315 = 1.0}*ind1411315 + /// 
	{b1415013 = 1.0}*ind1415013 + {b1415121 = 1.0}*ind1415121 + {b1416439 = 1.0}*ind1416439 + {b1433330 = 1.0}*ind1433330 + {b1470370 = 1.0}*ind1470370 + {b1492180 = 1.0}*ind1492180 + /// 
	{b1532323 = 1.0}*ind1532323 + {b1572912 = 1.0}*ind1572912 + {b1576038 = 1.0}*ind1576038 + {b1576276 = 1.0}*ind1576276 + {b1576444 = 1.0}*ind1576444 + {b1632801 = 1.0}*ind1632801 + ///
	{b1671615 = 1.0}*ind1671615 + {b1672185 = 1.0}*ind1672185 + {b1711511 = 1.0}*ind1711511 + {b1776027 = 1.0}*ind1776027 + {b1792735 = 1.0}*ind1792735 + {b1811145 = 1.0}*ind1811145 + /// 
	{b1813240 = 1.0}*ind1813240 + {b1832150 = 1.0}*ind1832150 + {b1832327 = 1.0}*ind1832327 + {b1836041 = 1.0}*ind1836041 + {b1873189 = 1.0}*ind1873189 + {b1892840 = 1.0}*ind1892840 + ///
	{b2010243 = 1.0}*ind2010243 + {b2011890 = 1.0}*ind2011890 + {b2011895 = 1.0}*ind2011895 + {b2011960 = 1.0}*ind2011960 + {b2011970 = 1.0}*ind2011970 + {b2011985 = 1.0}*ind2011985 + ///
	{b2012000 = 1.0}*ind2012000 + {b2012005 = 1.0}*ind2012005 + {b2012025 = 1.0}*ind2012025 + {b2012778 = 1.0}*ind2012778 + {b2013716 = 1.0}*ind2013716 + {b2015022 = 1.0}*ind2015022 + /// 
	{b2015024 = 1.0}*ind2015024 + {b2015026 = 1.0}*ind2015026 + {b2015031 = 1.0}*ind2015031 + {b2015120 = 1.0}*ind2015120 + {b2015130 = 1.0}*ind2015130 + {b2015135 = 1.0}*ind2015135 + /// 
	{b2015140 = 1.0}*ind2015140 + {b2016009 = 1.0}*ind2016009 + {b2016016 = 1.0}*ind2016016 + {b2016038 = 1.0}*ind2016038 + {b2016065 = 1.0}*ind2016065 + {b2016290 = 1.0}*ind2016290 + ///
	{b2016302 = 1.0}*ind2016302 + {b2016479 = 1.0}*ind2016479 + {b2032430 = 1.0}*ind2032430 + {b2050890 = 1.0}*ind2050890 + {b2093151 = 1.0}*ind2093151 + {b2096455 = 1.0}*ind2096455 + ///
	{b2130125 = 1.0}*ind2130125 + {b2152561 = 1.0}*ind2152561 + {b2153723 = 1.0}*ind2153723 + {b2156047 = 1.0}*ind2156047 + {b2156335 = 1.0}*ind2156335 + {b2171840 = 1.0}*ind2171840 + ///
	{b2192250 = 1.0}*ind2192250 + {b2219225 = 1.0}*ind2219225 + {b2233345 = 1.0}*ind2233345 + {b2250843 = 1.0}*ind2250843 + {b2275088 = 1.0}*ind2275088 + {b2311740 = 1.0}*ind2311740 + ///
	{b2330400 = 1.0}*ind2330400 + {b2412084 = 1.0}*ind2412084 + {b2450244 = 1.0}*ind2450244 + {b2452849 = 1.0}*ind2452849 + {b2510635 = 1.0}*ind2510635 + {b2576008 = 1.0}*ind2576008 + ///
	{b2576026 = 1.0}*ind2576026 + {b2652135 = 1.0}*ind2652135 + {b2732160 = 1.0}*ind2732160 + {b2772760 = 1.0}*ind2772760 + {b2796032 = 1.0}*ind2796032 + {b2853800 = 1.0}*ind2853800 + ///
	{b2910645 = 1.0}*ind2910645 + {b2932533 = 1.0}*ind2932533 + {b2992318 = 1.0}*ind2992318 + {b3036011 = 1.0}*ind3036011 + {b3093650 = 1.0}*ind3093650 + {b3093660 = 1.0}*ind3093660 + ///
	{b3210235 = 1.0}*ind3210235 + {b3231175 = 1.0}*ind3231175 + {b3292535 = 1.0}*ind3292535 + {b3390720 = 1.0}*ind3390720 + {b3396057 = 1.0}*ind3396057 + {b3396189 = 1.0}*ind3396189 + ///
	{b3396327 = 1.0}*ind3396327 + {b3472582 = 1.0}*ind3472582 + {b3475093 = 1.0}*ind3475093 + {b3490795 = 1.0}*ind3490795 + {b3535132 = 1.0}*ind3535132 + {b3550740 = 1.0}*ind3550740 + ///
	{b3556218 = 1.0}*ind3556218 + {b3572814 = 1.0}*ind3572814 + {b3612695 = 1.0}*ind3612695 + {b3632567 = 1.0}*ind3632567 + {b3650574 = 1.0}*ind3650574 + {b3673715 = 1.0}*ind3673715 + /// 
	{b3712057 = 1.0}*ind3712057 + {b3732315 = 1.0}*ind3732315 + {b3750063 = 1.0}*ind3750063 + {b3750070 = 1.0}*ind3750070 + {b3896014 = 1.0}*ind3896014 + {b3976115 = 1.0}*ind3976115 + ///
	{b3976429 = 1.0}*ind3976429 + {b4011810 = 1.0}*ind4011810 + {b4233565 = 1.0}*ind4233565 + {b4275095 = 1.0}*ind4275095 + {b4390108 = 1.0}*ind4390108 + {b4390285 = 1.0}*ind4390285 + ///
	{b4391390 = 1.0}*ind4391390 + {b4391437 = 1.0}*ind4391437 + {b4391440 = 1.0}*ind4391440 + {b4391483 = 1.0}*ind4391483 + {b4391739 = 1.0}*ind4391739 + {b4395139 = 1.0}*ind4395139 + ///  
	{b4395142 = 1.0}*ind4395142 + {b4396125 = 1.0}*ind4396125 + {b4396401 = 1.0}*ind4396401 + {b4410020 = 1.0}*ind4410020 + {b4410034 = 1.0}*ind4410034 + {b4450450 = 1.0}*ind4450450 + ///
	{b4492573 = 1.0}*ind4492573 + {b4513000 = 1.0}*ind4513000 + {b4516013 = 1.0}*ind4516013 + {b4530170 = 1.0}*ind4530170 + {b4530190 = 1.0}*ind4530190 +  /// 
	{b4530200 = 1.0}*ind4530200 + {b4536048 = 1.0}*ind4536048 + {b4536253 = 1.0}*ind4536253 + {b4536337 = 1.0}*ind4536337 + {b4536338 = 1.0}*ind4536338 + ///
	{b4633580 = 1.0}*ind4633580 + {b4651139 = 1.0}*ind4651139 + {b4693630 = 1.0}*ind4693630 + {b4716028 = 1.0}*ind4716028 + {b4770430 = 1.0}*ind4770430 + {b4792220 = 1.0}*ind4792220 + ///
	{b4792230 = 1.0}*ind4792230 + {b4813735 = 1.0}*ind4813735 + {b4853790 = 1.0}*ind4853790 + {b4916029 = 1.0}*ind4916029 + {b4916068 = 1.0}*ind4916068 + ///
	{b4916419 = 1.0}*ind4916419 + {b4916426 = 1.0}*ind4916426 + {b4916433 = 1.0}*ind4916433 + {b4975091 = 1.0}*ind4975091 + {b4992851 = 1.0}*ind4992851 + {b5035018 = 1.0}*ind5035018 )
	
	
	
* Attempt 2:
 	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*exper_10 + prev_1_month + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
	{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 + ///
	{bdiab = 1.0}*diab_pre + {bdig=1.0}*diab_ges + {bcrh=1.0}*brf_crhy + {bpgh=1.0}*brf_pghy + {brfe=1.0}*brf_eclm + {bprem=1.0}*pre_prem + ///
	{btrs=1.0}*bo_trans + {bster=1.0}*lab_ster + ///
	 {b16122 = 1.0}*ind16122 +  ///
 {b30105 = 1.0}*ind30105 +  ///
 {b52390 = 1.0}*ind52390 +  ///
 {b52395 = 1.0}*ind52395 +  ///
 {b132096 = 1.0}*ind132096 +  ///
 {b250295 = 1.0}*ind250295 +  ///
 {b273410 = 1.0}*ind273410 +  ///
 {b273420 = 1.0}*ind273420 +  ///
 {b293005 = 1.0}*ind293005 +  ///
 {b293010 = 1.0}*ind293010 +  ///
 {b293015 = 1.0}*ind293015 +  ///
 {b293105 = 1.0}*ind293105 +  ///
 {b293120 = 1.0}*ind293120 +  ///
 {b293122 = 1.0}*ind293122 +  ///
 {b296002 = 1.0}*ind296002 +  ///
 {b296025 = 1.0}*ind296025 +  ///
 {b296191 = 1.0}*ind296191 +  ///
 {b296451 = 1.0}*ind296451 +  ///
 {b350650 = 1.0}*ind350650 +  ///
 {b373510 = 1.0}*ind373510 +  ///
 {b390111 = 1.0}*ind390111 +  ///
 {b391525 = 1.0}*ind391525 +  ///
 {b410490 = 1.0}*ind410490 +  ///
 {b410500 = 1.0}*ind410500 +  ///
 {b430050 = 1.0}*ind430050 +  ///
 {b490465 = 1.0}*ind490465 +  ///
 {b572853 = 1.0}*ind572853 +  ///
 {b610460 = 1.0}*ind610460 +  ///
 {b611790 = 1.0}*ind611790 +  ///
 {b615100 = 1.0}*ind615100 +  ///
 {b616318 = 1.0}*ind616318 +  ///
 {b732070 = 1.0}*ind732070 +  ///
 {b736304 = 1.0}*ind736304 +  ///
 {b750595 = 1.0}*ind750595 +  ///
 {b852480 = 1.0}*ind852480 +  ///
 {b855094 = 1.0}*ind855094 +  ///
 {b856181 = 1.0}*ind856181 +  ///
 {b856301 = 1.0}*ind856301 +  ///
 {b856316 = 1.0}*ind856316 +  ///
 {b856354 = 1.0}*ind856354 +  ///
 {b895105 = 1.0}*ind895105 +  ///
 {b912625 = 1.0}*ind912625 +  ///
 {b1130900 = 1.0}*ind1130900 +  ///
 {b1130950 = 1.0}*ind1130950 +  ///
 {b1131020 = 1.0}*ind1131020 +  ///
 {b1131021 = 1.0}*ind1131021 +  ///
 {b1131050 = 1.0}*ind1131050 +  ///
 {b1131616 = 1.0}*ind1131616 +  ///
 {b1132055 = 1.0}*ind1132055 +  ///
 {b1132528 = 1.0}*ind1132528 +  ///
 {b1135009 = 1.0}*ind1135009 +  ///
 {b1135113 = 1.0}*ind1135113 +  ///
 {b1136005 = 1.0}*ind1136005 +  ///
 {b1136007 = 1.0}*ind1136007 +  ///
 {b1136020 = 1.0}*ind1136020 +  ///
 {b1136268 = 1.0}*ind1136268 +  ///
 {b1136366 = 1.0}*ind1136366 +  ///
 {b1136457 = 1.0}*ind1136457 +  ///
 {b1152195 = 1.0}*ind1152195 +  ///
 {b1171820 = 1.0}*ind1171820 +  ///
 {b1215085 = 1.0}*ind1215085 +  ///
 {b1215126 = 1.0}*ind1215126 +  ///
 {b1216088 = 1.0}*ind1216088 +  ///
 {b1216116 = 1.0}*ind1216116 +  ///
 {b1216470 = 1.0}*ind1216470 +  ///
 {b1230865 = 1.0}*ind1230865 +  ///
 {b1352660 = 1.0}*ind1352660 +  ///
 {b1355097 = 1.0}*ind1355097 +  ///
 {b1391330 = 1.0}*ind1391330 +  ///
 {b1393700 = 1.0}*ind1393700 +  ///
 {b1411240 = 1.0}*ind1411240 +  ///
 {b1411290 = 1.0}*ind1411290 +  ///
 {b1411315 = 1.0}*ind1411315 +  ///
 {b1415013 = 1.0}*ind1415013 +  ///
 {b1415121 = 1.0}*ind1415121 +  ///
 {b1416439 = 1.0}*ind1416439 +  ///
 {b1433330 = 1.0}*ind1433330 +  ///
 {b1470370 = 1.0}*ind1470370 +  ///
 {b1492180 = 1.0}*ind1492180 +  ///
 {b1532323 = 1.0}*ind1532323 +  ///
 {b1572912 = 1.0}*ind1572912 +  ///
 {b1576038 = 1.0}*ind1576038 +  ///
 {b1576276 = 1.0}*ind1576276 +  ///
 {b1576444 = 1.0}*ind1576444 +  ///
 {b1632801 = 1.0}*ind1632801 +  ///
 {b1671615 = 1.0}*ind1671615 +  ///
 {b1672185 = 1.0}*ind1672185 +  ///
 {b1711511 = 1.0}*ind1711511 +  ///
 {b1776027 = 1.0}*ind1776027 +  ///
 {b1792735 = 1.0}*ind1792735 +  ///
 {b1811145 = 1.0}*ind1811145 +  ///
 {b1813240 = 1.0}*ind1813240 +  ///
 {b1832150 = 1.0}*ind1832150 +  ///
 {b1832327 = 1.0}*ind1832327 +  ///
 {b1836041 = 1.0}*ind1836041 +  ///
 {b1873189 = 1.0}*ind1873189 +  ///
 {b1892840 = 1.0}*ind1892840 +  ///
 {b2010243 = 1.0}*ind2010243 +  ///
 {b2011890 = 1.0}*ind2011890 +  ///
 {b2011895 = 1.0}*ind2011895 +  ///
 {b2011960 = 1.0}*ind2011960 +  ///
 {b2011970 = 1.0}*ind2011970 +  ///
 {b2011985 = 1.0}*ind2011985 +  ///
 {b2012000 = 1.0}*ind2012000 +  ///
 {b2012005 = 1.0}*ind2012005 +  ///
 {b2012025 = 1.0}*ind2012025 +  ///
 {b2012778 = 1.0}*ind2012778 +  ///
 {b2013716 = 1.0}*ind2013716 +  ///
 {b2015022 = 1.0}*ind2015022 +  ///
 {b2015024 = 1.0}*ind2015024 +  ///
 {b2015026 = 1.0}*ind2015026 +  ///
 {b2015031 = 1.0}*ind2015031 +  ///
 {b2015120 = 1.0}*ind2015120 +  ///
 {b2015130 = 1.0}*ind2015130 +  ///
 {b2015135 = 1.0}*ind2015135 +  ///
 {b2015140 = 1.0}*ind2015140 +  ///
 {b2016009 = 1.0}*ind2016009 +  ///
 {b2016016 = 1.0}*ind2016016 +  ///
 {b2016038 = 1.0}*ind2016038 +  ///
 {b2016065 = 1.0}*ind2016065 +  ///
 {b2016290 = 1.0}*ind2016290 +  ///
 {b2016302 = 1.0}*ind2016302 +  ///
 {b2016479 = 1.0}*ind2016479 +  ///
 {b2032430 = 1.0}*ind2032430 +  ///
 {b2050890 = 1.0}*ind2050890 +  ///
 {b2093151 = 1.0}*ind2093151 +  ///
 {b2096455 = 1.0}*ind2096455 +  ///
 {b2130125 = 1.0}*ind2130125 +  ///
 {b2152561 = 1.0}*ind2152561 +  ///
 {b2153723 = 1.0}*ind2153723 +  ///
 {b2156047 = 1.0}*ind2156047 +  ///
 {b2156335 = 1.0}*ind2156335 +  ///
 {b2171840 = 1.0}*ind2171840 +  ///
 {b2192250 = 1.0}*ind2192250 +  ///
 {b2219225 = 1.0}*ind2219225 +  ///
 {b2233345 = 1.0}*ind2233345 +  ///
 {b2250843 = 1.0}*ind2250843 +  ///
 {b2275088 = 1.0}*ind2275088 +  ///
 {b2311740 = 1.0}*ind2311740 +  ///
 {b2330400 = 1.0}*ind2330400 +  ///
 {b2412084 = 1.0}*ind2412084 +  ///
 {b2450244 = 1.0}*ind2450244 +  ///
 {b2452849 = 1.0}*ind2452849 +  ///
 {b2510635 = 1.0}*ind2510635 +  ///
 {b2576008 = 1.0}*ind2576008 +  ///
 {b2576026 = 1.0}*ind2576026 +  ///
 {b2652135 = 1.0}*ind2652135 +  ///
 {b2732160 = 1.0}*ind2732160 +  ///
 {b2772760 = 1.0}*ind2772760 +  ///
 {b2796032 = 1.0}*ind2796032 +  ///
 {b2853800 = 1.0}*ind2853800 +  ///
 {b2910645 = 1.0}*ind2910645 +  ///
 {b2932533 = 1.0}*ind2932533 +  ///
 {b2992318 = 1.0}*ind2992318 +  ///
 {b3036011 = 1.0}*ind3036011 +  ///
 {b3093650 = 1.0}*ind3093650 +  ///
 {b3093660 = 1.0}*ind3093660 +  ///
 {b3210235 = 1.0}*ind3210235 +  ///
 {b3231175 = 1.0}*ind3231175 +  ///
 {b3292535 = 1.0}*ind3292535 +  ///
 {b3390720 = 1.0}*ind3390720 +  ///
 {b3396057 = 1.0}*ind3396057 +  ///
 {b3396189 = 1.0}*ind3396189 +  ///
 {b3396327 = 1.0}*ind3396327 +  ///
 {b3472582 = 1.0}*ind3472582 +  ///
 {b3475093 = 1.0}*ind3475093 +  ///
 {b3490795 = 1.0}*ind3490795 +  ///
 {b3535132 = 1.0}*ind3535132 +  ///
 {b3550740 = 1.0}*ind3550740 +  ///
 {b3556218 = 1.0}*ind3556218 +  ///
 {b3572814 = 1.0}*ind3572814 +  ///
 {b3612695 = 1.0}*ind3612695 +  ///
 {b3632567 = 1.0}*ind3632567 +  ///
 {b3650574 = 1.0}*ind3650574 +  ///
 {b3673715 = 1.0}*ind3673715 +  ///
 {b3712057 = 1.0}*ind3712057 +  ///
 {b3732315 = 1.0}*ind3732315 +  ///
 {b3750063 = 1.0}*ind3750063 +  ///
 {b3750070 = 1.0}*ind3750070 +  ///
 {b3896014 = 1.0}*ind3896014 +  ///
 {b3976115 = 1.0}*ind3976115 +  ///
 {b3976429 = 1.0}*ind3976429 +  ///
 {b4011810 = 1.0}*ind4011810 +  ///
 {b4233565 = 1.0}*ind4233565 +  ///
 {b4275095 = 1.0}*ind4275095 +  ///
 {b4390108 = 1.0}*ind4390108 +  ///
 {b4390285 = 1.0}*ind4390285 +  ///
 {b4391390 = 1.0}*ind4391390 +  ///
 {b4391437 = 1.0}*ind4391437 +  ///
 {b4391440 = 1.0}*ind4391440 +  ///
 {b4391483 = 1.0}*ind4391483 +  ///
 {b4391739 = 1.0}*ind4391739 +  ///
 {b4395139 = 1.0}*ind4395139 +  ///
 {b4395142 = 1.0}*ind4395142 +  ///
 {b4396125 = 1.0}*ind4396125 +  ///
 {b4396401 = 1.0}*ind4396401 +  ///
 {b4410020 = 1.0}*ind4410020 +  ///
 {b4410034 = 1.0}*ind4410034 +  ///
 {b4450450 = 1.0}*ind4450450 +  ///
 {b4492573 = 1.0}*ind4492573 +  ///
 {b4513000 = 1.0}*ind4513000 +  ///
 {b4516013 = 1.0}*ind4516013 +  ///
 {b4530170 = 1.0}*ind4530170 +  ///
 {b4530190 = 1.0}*ind4530190 +  ///
 {b4530200 = 1.0}*ind4530200 +  ///
 {b4536048 = 1.0}*ind4536048 +  ///
 {b4536253 = 1.0}*ind4536253 +  ///
 {b4536337 = 1.0}*ind4536337 +  ///
 {b4536338 = 1.0}*ind4536338 +  ///
 {b4633580 = 1.0}*ind4633580 +  ///
 {b4651139 = 1.0}*ind4651139 +  ///
 {b4693630 = 1.0}*ind4693630 +  ///
 {b4716028 = 1.0}*ind4716028 +  ///
 {b4770430 = 1.0}*ind4770430 +  ///
 {b4792220 = 1.0}*ind4792220 +  ///
 {b4792230 = 1.0}*ind4792230 +  ///
 {b4813735 = 1.0}*ind4813735 +  ///
 {b4853790 = 1.0}*ind4853790 +  ///
 {b4916029 = 1.0}*ind4916029 +  ///
 {b4916068 = 1.0}*ind4916068 +  ///
 {b4916419 = 1.0}*ind4916419 +  ///
 {b4916426 = 1.0}*ind4916426 +  ///
 {b4916433 = 1.0}*ind4916433 +  ///
 {b4975091 = 1.0}*ind4975091 +  ///
 {b4992851 = 1.0}*ind4992851 +  ///
 {b5035018 = 1.0}*ind5035018)
* this works, but the FE's are all not significant and many are estimated to have similar values.  I am not convinced.


* Constant depreciation rate...
*	nl (neonataldeath = {V=1.0}*ln( {FR=0.7}*prev_11_months + month_count + 1) + {bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)

foreach nn of numlist 1/12{
	drop if prev_`nn'_month == .
}

* Constant V:
	nl (neonataldeath = {V=1.0}*prev_1_month + ({V}^2)*prev_2_month + ({V}^3)*prev_3_month + ({V}^4)*prev_4_month + ({V}^5)*prev_5_month + ({V}^6)*prev_6_month + ({V}^7)*prev_7_month + ({V}^8)*prev_8_month + ({V}^9)*prev_9_month + ({V}^10)*prev_10_month + ({V}^11)*prev_11_month +({V}^12)*prev_12_month )


* This simple one works:
	nl (neonataldeath = {rd=1.0}*prev_1_month + ({V=1.0}^2)*prev_2_month + ({V}^3)*prev_3_month + ({V}^4)*prev_4_month + ({V}^5)*prev_5_month + ({V}^6)*prev_6_month + ({V}^7)*prev_7_month + ({V}^8)*prev_8_month + ({V}^9)*prev_9_month + ({V}^10)*prev_10_month + ({V}^11)*prev_11_month +({V}^12)*prev_12_month )

	
*	Some health states: - this one DOES work
	nl (neonataldeath = {rd=1.0}*prev_1_month + ({V=1.0}^2)*prev_2_month + ({V}^3)*prev_3_month + ({V}^4)*prev_4_month + ({V}^5)*prev_5_month + ({V}^6)*prev_6_month + ({V}^7)*prev_7_month + ({V}^8)*prev_8_month + ({V}^9)*prev_9_month + ({V}^10)*prev_10_month + ({V}^11)*prev_11_month +({V}^12)*prev_12_month + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin)
/*
Iteration 439:  residual SS =   2420.24
Iteration 440:  residual SS =   2420.24

Results for the above - VLBW subset:
  Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model |  42.228461         15  2.81523073    R-squared     =     0.0171
    Residual |  2420.2399      25930  .093337444    Adj R-squared =     0.0166
-------------+----------------------------------    Root MSE      =   .3055118
       Total |  2462.4684      25945  .094911096    Res. dev.     =   12083.73

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         /rd |   .0001183   .0000535     2.21   0.027     .0000135    .0002231
          /V |  -9.33e-10          .        .       .            .           .
        /bhy |  -.0462781   .0476257    -0.97   0.331    -.1396271     .047071
      /bbcal |  -.5859407          .        .       .            .           .
        /bcl |   .9419168   .0730253    12.90   0.000     .7987832     1.08505
      /bcona |   .1166032   .0518421     2.25   0.025     .0149898    .2182166
      /bconm |   .3790693   .1184529     3.20   0.001      .146895    .6112435
       /bchn |   .4376658   .1028429     4.26   0.000     .2360879    .6392436
       /bchd |   .3644205   .0621037     5.87   0.000     .2426937    .4861473
        /bpc |   .2035728   .0052868    38.51   0.000     .1932104    .2139352
         /bw |  -.0001206   4.60e-06   -26.24   0.000    -.0001296   -.0001116
         /b4 |   .0404641   .0041339     9.79   0.000     .0323615    .0485668
         /b5 |   .0156532    .006567     2.38   0.017     .0027814     .028525
         /b6 |  -.0159095   .0056107    -2.84   0.005    -.0269068   -.0049122
         /b7 |   .1168977   .0454223     2.57   0.010     .0278675    .2059278
         /b8 |   .0130412   .0584325     0.22   0.823    -.1014898    .1275722
         /b9 |   .4966105   .0661047     7.51   0.000     .3670416    .6261794
        /b10 |  -.1453377   .1043668    -1.39   0.164    -.3499024    .0592269
------------------------------------------------------------------------------
  Parameter V taken as constant term in model & ANOVA table



*/

* This one works too - constraints coeff of 1 on previous month:
	
	nl (neonataldeath = prev_1_month + ({V=1.0}^2)*prev_2_month + ({V}^3)*prev_3_month + ({V}^4)*prev_4_month + ({V}^5)*prev_5_month + ({V}^6)*prev_6_month + ({V}^7)*prev_7_month + ({V}^8)*prev_8_month + ({V}^9)*prev_9_month + ({V}^10)*prev_10_month + ({V}^11)*prev_11_month +({V}^12)*prev_12_month + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin)

/*

Iteration 20:  residual SS =  6.70e+07
Iteration 21:  residual SS =  6.70e+07


Works - VLBW subset:


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model |  -67001430         16 -4187589.38    R-squared     = -2.432e+04
    Residual |   67004185      25930  2584.04108    Adj R-squared = -2.433e+04
-------------+----------------------------------    Root MSE      =   50.83346
       Total |       2755      25946   .10618207    Res. dev.     =   277476.1

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |   2.65e-06   37539.35     0.00   1.000    -73579.21    73579.21
        /bhy |  -.6767903    5.52591    -0.12   0.903    -11.50788     10.1543
      /bbcal |   3.027634   8.473277     0.36   0.721    -13.58046    19.63573
        /bcl |   .1311612          .        .       .            .           .
      /bcona |  -.3933634   6.015567    -0.07   0.948    -12.18421    11.39748
      /bconm |  -5.170815   13.74335    -0.38   0.707    -32.10854    21.76691
       /bchn |   .1072584   11.93385     0.01   0.993    -23.28374    23.49826
       /bchd |  -.1347048   7.206443    -0.02   0.985    -14.25973    13.99032
        /bpc |  -.5187843   .5997091    -0.87   0.387    -1.694247    .6566788
         /bw |  -.0003853   .0005292    -0.73   0.467    -.0014226    .0006521
         /b4 |   .0380139   .4760961     0.08   0.936    -.8951609    .9711887
         /b5 |  -.4258511   .7515812    -0.57   0.571    -1.898992     1.04729
         /b6 |    .098777   .6498717     0.15   0.879    -1.175008    1.372562
         /b7 |  -.4707345    5.27064    -0.09   0.929    -10.80148    9.860012
         /b8 |   1.075658   6.778874     0.16   0.874    -12.21131    14.36263
         /b9 |  -1.870087   7.670509    -0.24   0.807    -16.90471    13.16454
        /b10 |  -.6113419   12.11071    -0.05   0.960      -24.349    23.12631
------------------------------------------------------------------------------

*/

	nl (neonataldeath = prev_1_month + ({V=1.0}^2)*prev_2_month + ({V}^3)*prev_3_month + ({V}^4)*prev_4_month + ({V}^5)*prev_5_month + ({V}^6)*prev_6_month + ({V}^7)*prev_7_month + ({V}^8)*prev_8_month + ({V}^9)*prev_9_month + ({V}^10)*prev_10_month + ({V}^11)*prev_11_month +({V}^12)*prev_12_month + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)


	
	
* The fully complicated one does not
	nl (neonataldeath = {rd=1.0}*prev_1_month + ({V=1.0}^2)*prev_2_month + ({V}^3)*prev_3_month + ({V}^4)*prev_4_month + ({V}^5)*prev_5_month + ({V}^6)*prev_6_month + ({V}^7)*prev_7_month + ({V}^8)*prev_8_month + ({V}^9)*prev_9_month + ({V}^10)*prev_10_month + ({V}^11)*prev_11_month +({V}^12)*prev_12_month + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
		{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
		{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
		{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
		{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 + ///
		{bdiab = 1.0}*diab_pre + {bdig=1.0}*diab_ges + {bcrh=1.0}*brf_crhy + {bpgh=1.0}*brf_pghy + {brfe=1.0}*brf_eclm + {bprem=1.0}*pre_prem + ///
		{btrs=1.0}*bo_trans + {bster=1.0}*lab_ster)

	
nl (neonataldeath = {rd=1.0}*prev_1_month + ({V=1.0}^2)*prev_2_month + ({V}^3)*prev_3_month + ({V}^4)*prev_4_month + ({V}^5)*prev_5_month + ({V}^6)*prev_6_month + ({V}^7)*prev_7_month + ({V}^8)*prev_8_month + ({V}^9)*prev_9_month + ({V}^10)*prev_10_month + ({V}^11)*prev_11_month +({V}^12)*prev_12_month + ///
   	{b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 ) 
	

	
	
	
	
* Trying with four lagged quarterly volumes:
local qrs prev_1_q prev_2_q prev_3_q prev_4_q
	foreach vll of local qrs{
	drop if `vll' == .
	}


* With lagged quarters.  
	nl ( neonataldeath = prev_1_q + {delta=1.0}*prev_2_q + ({delta}^2)*prev_3_q + ({delta}^3)*prev_4_q + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
		{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
		{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)

* With lagged months
		nl ( neonataldeath = prev_1_month + ({V=1.0}^1)*prev_2_month + ({V}^2)*prev_3_month + ({V}^3)*prev_4_month + ({V}^4)*prev_5_month + ({V}^5)*prev_6_month + ({V}^6)*prev_7_month + ({V}^7)*prev_8_month + ({V}^8)*prev_9_month + ({V}^9)*prev_10_month + ({V}^10)*prev_11_month +({V}^11)*prev_12_month + ///
		{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
		{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)


		
		
* constrain positive w/ lagged months:

		nl ( neonataldeath = prev_1_month + (exp({V=1.0}^1))*prev_2_month + (exp({V}^2))*prev_3_month + (exp({V}^3))*prev_4_month + (exp({V}^4))*prev_5_month + (exp({V}^5))*prev_6_month + (exp({V}^6))*prev_7_month + (exp({V}^7))*prev_8_month + (exp({V}^8))*prev_9_month + (exp({V}^9))*prev_10_month + (exp({V}^10))*prev_11_month +(exp({V}^11))*prev_12_month + ///
		{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
		{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)

/*
Works but functional form is actually wrong...  Results:

Iteration 2254:  residual SS =  4.34e+09
Iteration 2255:  residual SS =  4.34e+09


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model | -4.342e+09         22  -197356260    R-squared     = -1.763e+06
    Residual |  4.342e+09      25923  167489.881    Adj R-squared = -1.765e+06
-------------+----------------------------------    Root MSE      =   409.2553
       Total |  2462.4684      25945  .094911096    Res. dev.     =   385704.6

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |   -.399435   .2678343    -1.49   0.136    -.9244051    .1255352
        /bhy |   145.6332   63.79965     2.28   0.022     20.58233     270.684
      /bbcal |   155.1926   97.84135     1.59   0.113    -36.58187    346.9671
        /bcl |  -24.20084          .        .       .            .           .
      /bcona |  -83.63192   69.45161    -1.20   0.229    -219.7609    52.49709
      /bconm |  -346.3432   158.6731    -2.18   0.029    -657.3513   -35.33509
       /bchn |   80.64904   137.7775     0.59   0.558    -189.4024    350.7005
       /bchd |   66.02517   83.20923     0.79   0.428    -97.06954    229.1199
        /bpc |  -124.3193   9.073716   -13.70   0.000    -142.1043   -106.5343
         /bw |  -.0113336   .0083296    -1.36   0.174    -.0276601    .0049929
         /b4 |  -95.70033   5.613063   -17.05   0.000    -106.7022   -84.69842
         /b5 |  -232.0566   8.695305   -26.69   0.000    -249.0999   -215.0133
         /b6 |   76.93465   7.506104    10.25   0.000     62.22227    91.64703
         /b7 |   95.04747    60.8508     1.56   0.118    -24.22348    214.3184
         /b8 |   286.9198   78.26615     3.67   0.000     133.5138    440.3258
         /b9 |  -62.55583    88.5785    -0.71   0.480    -236.1746    111.0629
        /b10 |    45.9364   139.8371     0.33   0.743     -228.152    320.0248
      /bcons |  -236.7429   13.93128   -16.99   0.000     -264.049   -209.4368
      /b2006 |  -9.111049   9.555208    -0.95   0.340    -27.83979    9.617689
      /b2007 |  -16.11494    9.52777    -1.69   0.091     -34.7899     2.56002
      /b2008 |  -16.29983   9.626586    -1.69   0.090    -35.16847    2.568817
      /b2009 |  -27.08405   9.522098    -2.84   0.004    -45.74789   -8.420211
      /b2010 |  -.7413419          .        .       .            .           .
      /b2011 |   2.609895   9.779948     0.27   0.790    -16.55935    21.77913
      /b2012 |  -1.697991    9.69395    -0.18   0.861    -20.69867    17.30269
------------------------------------------------------------------------------
  Parameter bcons taken as constant term in model & ANOVA table

 nl, coeflegend

 nlcom a: exp(_b[V:_cons])

           a:  exp(_b[V:_cons])

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
           a |   .6706989   .1796362     3.73   0.000     .3186185    1.022779
------------------------------------------------------------------------------

*/		
		

* correct functional form...

nl ( neonataldeath = (exp({V=1.0}))*prev_1_month + (exp(2*{V}))*prev_2_month + (exp(3*{V}))*prev_3_month + (exp(4*{V}))*prev_4_month + (exp(5*{V}))*prev_5_month + (exp(6*{V}))*prev_6_month + (exp(7*{V}))*prev_7_month + (exp(8*{V}))*prev_8_month + (exp(9*{V}))*prev_9_month + (exp(10*{V}))*prev_10_month + (exp(11*{V}))*prev_11_month + (exp(12*{V}))*prev_12_month)
nl, coeflegend
nlcom disc: exp(_b[V:_cons])

/*
Iteration 24:  residual SS =  2630.993


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model |  124.00683          1  124.006829    R-squared     =     0.0450
    Residual |  2630.9932      25945  .101406559    Adj R-squared =     0.0450
-------------+----------------------------------    Root MSE      =    .318444
       Total |       2755      25946   .10618207    Res. dev.     =   14250.09

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |  -6.615479   .0285581  -231.65   0.000    -6.671454   -6.559504
------------------------------------------------------------------------------

nlcom disc: exp(_b[V:_cons])

        disc:  exp(_b[V:_cons])

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        disc |   .0013395   .0000383    35.02   0.000     .0012645    .0014144
------------------------------------------------------------------------------



*/

nl ( neonataldeath = (exp({V=1.0}))*prev_1_month + (exp(2*{V}))*prev_2_month + (exp(3*{V}))*prev_3_month + (exp(4*{V}))*prev_4_month + (exp(5*{V}))*prev_5_month + (exp(6*{V}))*prev_6_month + (exp(7*{V}))*prev_7_month + (exp(8*{V}))*prev_8_month + (exp(9*{V}))*prev_9_month + (exp(10*{V}))*prev_10_month + (exp(11*{V}))*prev_11_month + (exp(12*{V}))*prev_12_month + ///
		{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin )
nl, coeflegend
nlcom disc: exp(_b[V:_cons])


/*
Iteration 29:  residual SS =   2420.24


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model |  334.76006         16  20.9225038    R-squared     =     0.1215
    Residual |  2420.2399      25930  .093337445    Adj R-squared =     0.1210
-------------+----------------------------------    Root MSE      =   .3055118
       Total |       2755      25946   .10618207    Res. dev.     =   12083.73

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |  -9.042331   .4519605   -20.01   0.000    -9.928199   -8.156464
        /bhy |  -.0462784   .0476087    -0.97   0.331    -.1395941    .0470372
      /bbcal |  -1.49e+07   .0730294 -2.0e+08   0.000    -1.49e+07   -1.49e+07
        /bcl |   1.49e+07          .        .       .            .           .
      /bcona |   .1166033   .0518421     2.25   0.025     .0149898    .2182167
      /bconm |   .3790696    .118453     3.20   0.001     .1468951    .6112442
       /bchn |   .4376657   .1028429     4.26   0.000     .2360878    .6392435
       /bchd |   .3644205   .0621048     5.87   0.000     .2426916    .4861494
        /bpc |   .2035729   .0052868    38.51   0.000     .1932105    .2139354
         /bw |  -.0001206   4.60e-06   -26.24   0.000    -.0001296   -.0001116
         /b4 |   .0404642   .0041339     9.79   0.000     .0323616    .0485668
         /b5 |   .0156533   .0065671     2.38   0.017     .0027816    .0285251
         /b6 |  -.0159095   .0056107    -2.84   0.005    -.0269069   -.0049122
         /b7 |   .1168976   .0454223     2.57   0.010     .0278675    .2059278
         /b8 |    .013041   .0584326     0.22   0.823    -.1014901    .1275722
         /b9 |   .4966106   .0661048     7.51   0.000     .3670415    .6261798
        /b10 |  -.1453378   .1043669    -1.39   0.164    -.3499027    .0592271
------------------------------------------------------------------------------

. 
end of do-file


. nlcom disc: exp(_b[V:_cons])

        disc:  exp(_b[V:_cons])

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        disc |   .0001183   .0000535     2.21   0.027     .0000135    .0002231
------------------------------------------------------------------------------



*/



nl ( neonataldeath = (exp({V=1.0}))*prev_1_month + (exp(2*{V}))*prev_2_month + (exp(3*{V}))*prev_3_month + (exp(4*{V}))*prev_4_month + (exp(5*{V}))*prev_5_month + (exp(6*{V}))*prev_6_month + (exp(7*{V}))*prev_7_month + (exp(8*{V}))*prev_8_month + (exp(9*{V}))*prev_9_month + (exp(10*{V}))*prev_10_month + (exp(11*{V}))*prev_11_month + (exp(12*{V}))*prev_12_month + ///
	 {bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)

nl, coeflegend
nlcom disc: exp(_b[V:_cons])



nl ( neonataldeath = (exp({V=1.0}))*prev_1_month + (exp(2*{V}))*prev_2_month + (exp(3*{V}))*prev_3_month + (exp(4*{V}))*prev_4_month + (exp(5*{V}))*prev_5_month + (exp(6*{V}))*prev_6_month + (exp(7*{V}))*prev_7_month + (exp(8*{V}))*prev_8_month + (exp(9*{V}))*prev_9_month + (exp(10*{V}))*prev_10_month + (exp(11*{V}))*prev_11_month + (exp(12*{V}))*prev_12_month + ///
	{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
	{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)

nl, coeflegend
nlcom disc: exp(_b[V:_cons])

/*

Iteration 41:  residual SS =  2126.247


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model |  336.22132         21  16.0105388    R-squared     =     0.1365
    Residual |  2126.2471      25924   .08201848    Adj R-squared =     0.1358
-------------+----------------------------------    Root MSE      =   .2863887
       Total |  2462.4684      25945  .094911096    Res. dev.     =   8723.515

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |  -73.19104          .        .       .            .           .
        /bhy |  -.0319688   .0452953    -0.71   0.480    -.1207501    .0568125
      /bbcal |  -2.27e+07          .        .       .            .           .
        /bcl |   2.27e+07   .0684006  3.3e+08   0.000     2.27e+07    2.27e+07
      /bcona |   .1264899   .0485373     2.61   0.009     .0313541    .2216258
      /bconm |   .3309861    .111166     2.98   0.003     .1130945    .5488776
       /bchn |   .4433213   .0962341     4.61   0.000     .2546972    .6319455
       /bchd |   .3859492   .0581781     6.63   0.000     .2719168    .4999816
        /bpc |  -.0386572   .0063189    -6.12   0.000    -.0510426   -.0262719
         /bw |  -.0003565   5.82e-06   -61.23   0.000    -.0003679   -.0003451
         /b4 |   -.005841    .003803    -1.54   0.125    -.0132951    .0016132
         /b5 |  -.0031857   .0056697    -0.56   0.574    -.0142986    .0079273
         /b6 |  -.0120482   .0051593    -2.34   0.020    -.0221608   -.0019356
         /b7 |   .0952203   .0424491     2.24   0.025     .0120177     .178423
         /b8 |   .0045634   .0541662     0.08   0.933    -.1016055    .1107322
         /b9 |    .430235   .0620033     6.94   0.000      .308705    .5517649
        /b10 |  -.1535136   .0981027    -1.56   0.118    -.3458003     .038773
      /bcons |   -7592907   .0097147 -7.8e+08   0.000     -7592907    -7592907
      /b2006 |    7592907    .006685  1.1e+09   0.000      7592907     7592907
      /b2007 |    7592907   .0066661  1.1e+09   0.000      7592907     7592907
      /b2008 |    7592907   .0067352  1.1e+09   0.000      7592907     7592907
      /b2009 |    7592907   .0066629  1.1e+09   0.000      7592907     7592907
      /b2010 |    7592907          .        .       .            .           .
      /b2011 |    7592907   .0068432  1.1e+09   0.000      7592907     7592907
      /b2012 |    7592907   .0067829  1.1e+09   0.000      7592907     7592907
------------------------------------------------------------------------------

nlcom disc: exp(_b[V:_cons])

        disc:  exp(_b[V:_cons])

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        disc |   1.64e-32          .        .       .            .           .
------------------------------------------------------------------------------



*/


	nl (neonataldeath = {V=1.0}*prev_1_month + exp({V}*2)*prev_2_month + exp({V}*3)*prev_3_month + exp({V}*4)*prev_4_month + exp({V}*5)*prev_5_month + exp({V}*6)*prev_6_month + exp({V}*7)*prev_7_month + exp({V}*8)*prev_8_month + exp({V}*9)*prev_9_month + exp({V}*10)*prev_10_month + exp({V}*11)*prev_11_month +exp({V}*12)*prev_12_month + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
		{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
		{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
		{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
		{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 + ///
		{bdiab = 1.0}*diab_pre + {bdig=1.0}*diab_ges + {bcrh=1.0}*brf_crhy + {bpgh=1.0}*brf_pghy + {brfe=1.0}*brf_eclm + {bprem=1.0}*pre_prem + ///
		{btrs=1.0}*bo_trans + {bster=1.0}*lab_ster)

nl, coeflegend
nlcom disc: exp(_b[V:_cons])

/*

Iteration 23:  residual SS =  809981.3


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model | -807518.81         40 -20187.9703    R-squared     =  -327.9306
    Residual |  809981.28      25905  31.2673723    Adj R-squared =  -328.4385
-------------+----------------------------------    Root MSE      =   5.591724
       Total |  2462.4684      25945  .094911096    Res. dev.     =   162911.6

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |  -.6221686   .0003607 -1724.98   0.000    -.6228756   -.6214617
         /b2 |   .0490656    .170039     0.29   0.773    -.2842202    .3823514
         /b3 |   .1425217   .2125746     0.67   0.503    -.2741364    .5591798
        /boc |   .3720952    .335051     1.11   0.267    -.2846232    1.028814
        /bhy |   1.011052   .8722317     1.16   0.246    -.6985709    2.720674
      /bbcal |   -5492676   1.337198 -4.1e+06   0.000     -5492678    -5492673
        /bcl |    5492675          .        .       .            .           .
      /bcona |  -.2933023   .9495641    -0.31   0.757    -2.154501    1.567896
      /bconm |   3.362626    2.16897     1.55   0.121    -.8886746    7.613927
       /bchn |  -.1025491   1.884781    -0.05   0.957    -3.796825    3.591727
       /bchd |   .8762605   1.137607     0.77   0.441    -1.353513    3.106034
        /bpc |  -.1195984    .128681    -0.93   0.353    -.3718202    .1326234
         /bw |  -.0005233   .0001149    -4.55   0.000    -.0007486   -.0002981
         /b4 |  -.0762471   .0774025    -0.99   0.325    -.2279604    .0754661
         /b5 |   -.010856   .1179809    -0.09   0.927    -.2421052    .2203932
         /b6 |  -.0798568   .1035198    -0.77   0.440    -.2827613    .1230476
         /b7 |   .6124729   .8317235     0.74   0.461    -1.017751    2.242697
         /b8 |  -.3383195   1.068846    -0.32   0.752    -2.433316    1.756677
         /b9 |   1.465695   1.211396     1.21   0.226    -.9087087    3.840098
        /b10 |   .3665391   1.915015     0.19   0.848    -3.386996    4.120074
       /bhis |   .2453301   .1143435     2.15   0.032     .0212105    .4694498
      /bafam |   .2865277   .1457863     1.97   0.049     .0007784     .572277
       /basn |   .1434978   .2126859     0.67   0.500    -.2733784     .560374
      /bpacs |   1.587586   .9928049     1.60   0.110    -.3583668    3.533539
      /bhisp |   .2188433   .0916465     2.39   0.017      .039211    .3984756
       /bmed |    8826406   .1064368  8.3e+07   0.000      8826405     8826406
      /bpriv |    8826406   .1143882  7.7e+07   0.000      8826405     8826406
      /boins |    8826406          .        .       .            .           .
      /bcons |   -7681896   .3829372 -2.0e+07   0.000     -7681897    -7681896
      /b2006 |   -1144509   .1310264 -8.7e+06   0.000     -1144509    -1144508
      /b2007 |   -1144509   .1307879 -8.8e+06   0.000     -1144509    -1144509
      /b2008 |   -1144510   .1316835 -8.7e+06   0.000     -1144510    -1144509
      /b2009 |   -1144509   .1302727 -8.8e+06   0.000     -1144509    -1144509
      /b2010 |   -1144509          .        .       .            .           .
      /b2011 |   -1144509   .1337301 -8.6e+06   0.000     -1144509    -1144509
      /b2012 |   -1144509   .1327266 -8.6e+06   0.000     -1144510    -1144509
      /bdiab |   .2766565    .282856     0.98   0.328     -.277757    .8310701
       /bdig |   -.007954   .1780912    -0.04   0.964    -.3570227    .3411147
       /bcrh |  -.5016814   .1833986    -2.74   0.006    -.8611528     -.14221
       /bpgh |  -.1112218   .0959892    -1.16   0.247    -.2993659    .0769223
       /brfe |   -.147238   .4203078    -0.35   0.726    -.9710647    .6765887
      /bprem |   .1018291   .1588848     0.64   0.522    -.2095939    .4132521
       /btrs |   .1329739   .1411742     0.94   0.346    -.1437354    .4096832
      /bster |  -.1032923   .1023279    -1.01   0.313    -.3038606    .0972761
------------------------------------------------------------------------------
  Parameter bcons taken as constant term in model & ANOVA table

. nlcom disc: exp(_b[V:_cons])

        disc:  exp(_b[V:_cons])

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        disc |   .5367791   .0001936  2772.52   0.000     .5363996    .5371586
------------------------------------------------------------------------------



*/



	nl (neonataldeath = {V=1.0}*prev_1_month + exp({V}*2)*prev_2_month + exp({V}*3)*prev_3_month + exp({V}*4)*prev_4_month + exp({V}*5)*prev_5_month + exp({V}*6)*prev_6_month + exp({V}*7)*prev_7_month + exp({V}*8)*prev_8_month + exp({V}*9)*prev_9_month + exp({V}*10)*prev_10_month + exp({V}*11)*prev_11_month +exp({V}*12)*prev_12_month + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
		{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
		{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
		{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 + ///
		{bdiab = 1.0}*diab_pre + {bdig=1.0}*diab_ges + {bcrh=1.0}*brf_crhy + {bpgh=1.0}*brf_pghy + {brfe=1.0}*brf_eclm + {bprem=1.0}*pre_prem + ///
		{btrs=1.0}*bo_trans + {bster=1.0}*lab_ster)
di "WITHOUT DEMOGRAPHICS"
nl, coeflegend
nlcom disc: exp(_b[V:_cons])


/*

Iteration 32:  residual SS =    810315
Iteration 33:  residual SS =    810315


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model | -807852.52         35 -23081.5006    R-squared     =  -328.0661
    Residual |  810314.99      25910  31.2742181    Adj R-squared =  -328.5107
-------------+----------------------------------    Root MSE      =   5.592336
       Total |  2462.4684      25945  .094911096    Res. dev.     =   162922.3

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |   -.622216     .00036 -1728.15   0.000    -.6229217   -.6215103
         /b2 |   .0656962   .1734983     0.38   0.705    -.2743701    .4057625
         /b3 |   .1436978   .2134646     0.67   0.501    -.2747045    .5621002
        /boc |   .3923488   .3354513     1.17   0.242    -.2651545    1.049852
        /bhy |   1.004428   .8723144     1.15   0.250    -.7053567    2.714213
      /bbcal |  -2.31e+07          .        .       .            .           .
        /bcl |   2.31e+07   1.337408  1.7e+07   0.000     2.31e+07    2.31e+07
      /bcona |  -.2670167   .9509458    -0.28   0.779    -2.130923     1.59689
      /bconm |   3.388851   2.168715     1.56   0.118    -.8619512    7.639652
       /bchn |  -.1035577   1.879976    -0.06   0.956    -3.788416      3.5813
       /bchd |   .8988606   1.137033     0.79   0.429    -1.329787    3.127508
        /bpc |  -.1051131   .1285298    -0.82   0.413    -.3570386    .1468125
         /bw |  -.0005296   .0001146    -4.62   0.000    -.0007542   -.0003051
         /b4 |  -.0773089   .0774524    -1.00   0.318    -.2291198     .074502
         /b5 |  -.0266998    .122034    -0.22   0.827    -.2658932    .2124937
         /b6 |  -.0613997   .1039033    -0.59   0.555     -.265056    .1422566
         /b7 |   .6195729   .8325621     0.74   0.457    -1.012295    2.251441
         /b8 |  -.3618142   1.070722    -0.34   0.735    -2.460488    1.736859
         /b9 |   1.512316   1.210885     1.25   0.212    -.8610855    3.885717
        /b10 |   .4271303   1.912845     0.22   0.823    -3.322151    4.176412
       /bmed |    6171492   .1050303  5.9e+07   0.000      6171492     6171492
      /bpriv |    6171492   .1090008  5.7e+07   0.000      6171492     6171492
      /boins |    6171492          .        .       .            .           .
      /bcons |   -7837022   .3603875 -2.2e+07   0.000     -7837022    -7837021
      /b2006 |    1665531   .1309613  1.3e+07   0.000      1665530     1665531
      /b2007 |    1665530   .1307162  1.3e+07   0.000      1665530     1665530
      /b2008 |    1665530   .1316357  1.3e+07   0.000      1665529     1665530
      /b2009 |    1665530   .1302374  1.3e+07   0.000      1665530     1665530
      /b2010 |    1665530          .        .       .            .           .
      /b2011 |    1665530   .1337379  1.2e+07   0.000      1665530     1665530
      /b2012 |    1665530   .1327251  1.3e+07   0.000      1665530     1665530
      /bdiab |   .2797259   .2826857     0.99   0.322    -.2743538    .8338055
       /bdig |   -.011672   .1778033    -0.07   0.948    -.3601763    .3368323
       /bcrh |  -.5027743   .1830495    -2.75   0.006    -.8615615    -.143987
       /bpgh |  -.1103008   .0959351    -1.15   0.250    -.2983389    .0777373
       /brfe |  -.1487628   .4203467    -0.35   0.723    -.9726656    .6751401
      /bprem |   .1006817   .1588164     0.63   0.526    -.2106072    .4119706
       /btrs |   .1151545   .1417415     0.81   0.417    -.1626666    .3929756
      /bster |  -.1092954   .1023481    -1.07   0.286    -.3099035    .0913126
------------------------------------------------------------------------------
  Parameter bcons taken as constant term in model & ANOVA table


. nlcom disc: exp(_b[V:_cons])

        disc:  exp(_b[V:_cons])

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        disc |   .5367537   .0001933  2777.42   0.000     .5363749    .5371324
------------------------------------------------------------------------------


*/


	nl (neonataldeath = {V=1.0}*prev_1_month + exp({V}*2)*prev_2_month + exp({V}*3)*prev_3_month + exp({V}*4)*prev_4_month + exp({V}*5)*prev_5_month + exp({V}*6)*prev_6_month + exp({V}*7)*prev_7_month + exp({V}*8)*prev_8_month + exp({V}*9)*prev_9_month + exp({V}*10)*prev_10_month + exp({V}*11)*prev_11_month +exp({V}*12)*prev_12_month + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
		{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
		{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
		{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 + ///
		{bdiab = 1.0}*diab_pre + {bdig=1.0}*diab_ges + {bcrh=1.0}*brf_crhy + {bpgh=1.0}*brf_pghy + {brfe=1.0}*brf_eclm + {bprem=1.0}*pre_prem + ///
		{btrs=1.0}*bo_trans + {bster=1.0}*lab_ster)
di "WITHOUT INSURANCE STATUS"
nl, coeflegend
nlcom disc: exp(_b[V:_cons])



/*

Iteration 29:  residual SS =  809984.5


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model | -807522.01         38 -21250.5792    R-squared     =  -327.9319
    Residual |  809984.48      25907  31.2650819    Adj R-squared =  -328.4144
-------------+----------------------------------    Root MSE      =   5.591519
       Total |  2462.4684      25945  .094911096    Res. dev.     =   162911.7

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |  -.6221643   .0003589 -1733.71   0.000    -.6228677   -.6214609
         /b2 |   .0567092   .1735299     0.33   0.744     -.283419    .3968374
         /b3 |   .1492046    .213617     0.70   0.485    -.2694965    .5679057
        /boc |   .3757088   .3343287     1.12   0.261    -.2795941    1.031012
        /bhy |   1.013713   .8723079     1.16   0.245    -.6960589    2.723485
      /bbcal |  -2.28e+07          .        .       .            .           .
        /bcl |   2.28e+07   1.337219  1.7e+07   0.000     2.28e+07    2.28e+07
      /bcona |   -.301956   .9489831    -0.32   0.750    -2.162015    1.558104
      /bconm |   3.363749   2.168468     1.55   0.121    -.8865677    7.614066
       /bchn |  -.1344603   1.878321    -0.07   0.943    -3.816075    3.547154
       /bchd |   .8749139   1.136691     0.77   0.441    -1.353064    3.102891
        /bpc |  -.1088078   .1256246    -0.87   0.386    -.3550391    .1374234
         /bw |  -.0005232    .000115    -4.55   0.000    -.0007485   -.0002979
         /b4 |  -.0774779    .077432    -1.00   0.317     -.229249    .0742931
         /b5 |  -.0163717   .1221212    -0.13   0.893    -.2557361    .2229928
         /b6 |  -.0790839   .1035761    -0.76   0.445    -.2820987     .123931
         /b7 |   .6090579   .8320325     0.73   0.464    -1.021772    2.239888
         /b8 |  -.3341492   1.069649    -0.31   0.755     -2.43072    1.762422
         /b9 |   1.462324   1.210836     1.21   0.227    -.9109815     3.83563
        /b10 |   .3704216    1.91144     0.19   0.846    -3.376107    4.116951
       /bhis |   .2436314   .1141903     2.13   0.033     .0198119    .4674508
      /bafam |   .2824141   .1438616     1.96   0.050     .0004374    .5643907
       /basn |   .1433983   .2122241     0.68   0.499    -.2725727    .5593694
      /bpacs |   1.587275    .992472     1.60   0.110    -.3580247    3.532576
      /bhisp |   .2110406   .0867782     2.43   0.015     .0409506    .3811306
      /bcons |   -7294036   .3810029 -1.9e+07   0.000     -7294036    -7294035
      /b2006 |    7294036   .1308199  5.6e+07   0.000      7294036     7294037
      /b2007 |    7294036   .1306309  5.6e+07   0.000      7294036     7294036
      /b2008 |    7294035   .1316422  5.5e+07   0.000      7294035     7294036
      /b2009 |    7294036   .1302454  5.6e+07   0.000      7294036     7294036
      /b2010 |    7294036          .        .       .            .           .
      /b2011 |    7294036   .1337192  5.5e+07   0.000      7294036     7294036
      /b2012 |    7294036   .1327179  5.5e+07   0.000      7294035     7294036
      /bdiab |   .2769586   .2828292     0.98   0.327    -.2774023    .8313196
       /bdig |  -.0087851   .1780372    -0.05   0.961    -.3577479    .3401777
       /bcrh |  -.5013344   .1833707    -2.73   0.006    -.8607511   -.1419177
       /bpgh |  -.1105414   .0959077    -1.15   0.249    -.2985259    .0774431
       /brfe |  -.1482248   .4202563    -0.35   0.724    -.9719505     .675501
      /bprem |   .1003616    .158735     0.63   0.527    -.2107677     .411491
       /btrs |   .1371071   .1420267     0.97   0.334    -.1412732    .4154874
      /bster |  -.1029354   .1022705    -1.01   0.314    -.3033912    .0975205
------------------------------------------------------------------------------
  Parameter bcons taken as constant term in model & ANOVA table

  
  nlcom disc: exp(_b[V:_cons])

        disc:  exp(_b[V:_cons])

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        disc |   .5367814   .0001926  2786.58   0.000     .5364039     .537159
------------------------------------------------------------------------------



*/



	nl (neonataldeath = {V=1.0}*prev_1_month + exp({V}*2)*prev_2_month + exp({V}*3)*prev_3_month + exp({V}*4)*prev_4_month + exp({V}*5)*prev_5_month + exp({V}*6)*prev_6_month + exp({V}*7)*prev_7_month + exp({V}*8)*prev_8_month + exp({V}*9)*prev_9_month + exp({V}*10)*prev_10_month + exp({V}*11)*prev_11_month +exp({V}*12)*prev_12_month + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
		{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
		{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
		{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 + ///
		{bdiab = 1.0}*diab_pre + {bdig=1.0}*diab_ges + {bcrh=1.0}*brf_crhy + {bpgh=1.0}*brf_pghy + {brfe=1.0}*brf_eclm + {bprem=1.0}*pre_prem + ///
		{btrs=1.0}*bo_trans + {bster=1.0}*lab_ster)
di "WITHOUT HEALTH STATES"
nl, coeflegend
nlcom disc: exp(_b[V:_cons])

/*

Iteration 20:  residual SS =  810957.9


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model | -808495.47         25 -32339.8188    R-squared     =  -328.3272
    Residual |  810957.94      25920  31.2869575    Adj R-squared =  -328.6449
-------------+----------------------------------    Root MSE      =   5.593475
       Total |  2462.4684      25945  .094911096    Res. dev.     =   162942.8

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |  -.6222514   .0003505 -1775.29   0.000    -.6229384   -.6215644
         /b2 |   .0966654   .1729666     0.56   0.576    -.2423587    .4356895
         /b3 |   .1174371   .2120764     0.55   0.580    -.2982445    .5331187
        /boc |   .3204874   .3354495     0.96   0.339    -.3370123    .9779871
       /bhis |    .235243   .1139936     2.06   0.039     .0118092    .4586769
      /bafam |   .3176834   .1454135     2.18   0.029     .0326648     .602702
       /basn |   .1342417   .2123222     0.63   0.527    -.2819216    .5504049
      /bpacs |   1.584107   .9926319     1.60   0.111    -.3615062    3.529721
      /bhisp |   .2317586   .0914762     2.53   0.011     .0524601    .4110571
       /bmed |  -1.03e+07   .1043507 -9.9e+07   0.000    -1.03e+07   -1.03e+07
      /bpriv |  -1.03e+07   .1109564 -9.3e+07   0.000    -1.03e+07   -1.03e+07
      /boins |  -1.03e+07          .        .       .            .           .
      /bcons |   1.03e+07   .3508687  2.9e+07   0.000     1.03e+07    1.03e+07
      /b2006 |   35737.06   .1313796  2.7e+05   0.000      35736.8    35737.31
      /b2007 |   35736.64   .1311263  2.7e+05   0.000     35736.39     35736.9
      /b2008 |   35736.22   .1321362  2.7e+05   0.000     35735.96    35736.48
      /b2009 |   35736.78   .1307271  2.7e+05   0.000     35736.52    35737.03
      /b2010 |   35736.73   .1337273  2.7e+05   0.000     35736.47       35737
      /b2011 |   35736.63          .        .       .            .           .
      /b2012 |   35736.42   .1330827  2.7e+05   0.000     35736.15    35736.68
      /bdiab |   .2833545   .2826926     1.00   0.316    -.2707386    .8374476
       /bdig |  -.0385807   .1779027    -0.22   0.828    -.3872799    .3101184
       /bcrh |  -.5061216   .1832961    -2.76   0.006    -.8653921   -.1468511
       /bpgh |  -.1434551   .0956288    -1.50   0.134    -.3308929    .0439826
       /brfe |  -.1549505    .420299    -0.37   0.712    -.9787599    .6688589
      /bprem |   .0782981   .1585322     0.49   0.621    -.2324339      .38903
       /btrs |   .1656128   .1407765     1.18   0.239     -.110317    .4415426
      /bster |   -.134449   .1005506    -1.34   0.181    -.3315338    .0626358
------------------------------------------------------------------------------
  Parameter bcons taken as constant term in model & ANOVA table

 nlcom disc: exp(_b[V:_cons])

        disc:  exp(_b[V:_cons])

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        disc |   .5367347   .0001881  2853.00   0.000      .536366    .5371034
------------------------------------------------------------------------------



*/


	nl (neonataldeath = {V=1.0}*prev_1_month + exp({V}*2)*prev_2_month + exp({V}*3)*prev_3_month + exp({V}*4)*prev_4_month + exp({V}*5)*prev_5_month + exp({V}*6)*prev_6_month + exp({V}*7)*prev_7_month + exp({V}*8)*prev_8_month + exp({V}*9)*prev_9_month + exp({V}*10)*prev_10_month + exp({V}*11)*prev_11_month +exp({V}*12)*prev_12_month  + ///
		{bhis=1.0}*white + {bafam=1.0}*afam + {basn=1.0}*asian + {bpacs=1.0}*pacis + {bhisp=1.0}*hispanic + /// 
		{bmed=1.0}*medicaid + {bpriv=1.0}*privateins + {boins=1.0}*otherins + ///
		{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012 + ///
		{bdiab = 1.0}*diab_pre + {bdig=1.0}*diab_ges + {bcrh=1.0}*brf_crhy + {bpgh=1.0}*brf_pghy + {brfe=1.0}*brf_eclm + {bprem=1.0}*pre_prem + ///
		{btrs=1.0}*bo_trans + {bster=1.0}*lab_ster)
di "WITHOUT HOSPITAL CHARS"
nl, coeflegend
nlcom disc: exp(_b[V:_cons])

/*

Iteration 21:  residual SS =  811024.9


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model | -808562.44         22 -36752.8381    R-squared     =  -328.3544
    Residual |  811024.91      25923  31.2859201    Adj R-squared =  -328.6340
-------------+----------------------------------    Root MSE      =   5.593382
       Total |  2462.4684      25945  .094911096    Res. dev.     =     162945

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |  -.6222208    .000347 -1793.08   0.000     -.622901   -.6215407
       /bhis |   .2417926   .1139313     2.12   0.034      .018481    .4651043
      /bafam |   .3232314   .1453535     2.22   0.026     .0383305    .6081323
       /basn |   .1415383    .212281     0.67   0.505    -.2745444    .5576209
      /bpacs |    1.58842   .9925563     1.60   0.110    -.3570454    3.533885
      /bhisp |   .2350801   .0913885     2.57   0.010     .0559536    .4142066
       /bmed |  -1.02e+07   .0809581 -1.3e+08   0.000    -1.02e+07   -1.02e+07
      /bpriv |  -1.02e+07          .        .       .            .           .
      /boins |  -1.02e+07    .110301 -9.3e+07   0.000    -1.02e+07   -1.02e+07
      /bcons |   1.01e+07   .1679401  6.0e+07   0.000     1.01e+07    1.01e+07
      /b2006 |   106237.1   .1308871  8.1e+05   0.000     106236.8    106237.3
      /b2007 |   106236.6   .1304288  8.1e+05   0.000     106236.4    106236.9
      /b2008 |   106236.2   .1316288  8.1e+05   0.000       106236    106236.5
      /b2009 |   106236.8    .130189  8.2e+05   0.000     106236.5      106237
      /b2010 |   106236.7          .        .       .            .           .
      /b2011 |   106236.6   .1336982  7.9e+05   0.000     106236.4    106236.9
      /b2012 |   106236.4   .1326281  8.0e+05   0.000     106236.2    106236.7
      /bdiab |   .2854345   .2826794     1.01   0.313    -.2686329    .8395018
       /bdig |  -.0353986   .1778828    -0.20   0.842    -.3840587    .3132615
       /bcrh |  -.5065643   .1832831    -2.76   0.006    -.8658094   -.1473193
       /bpgh |  -.1428181   .0956011    -1.49   0.135    -.3302016    .0445654
       /brfe |  -.1547899   .4202518    -0.37   0.713    -.9785068     .668927
      /bprem |   .0819327   .1584549     0.52   0.605    -.2286478    .3925132
       /btrs |   .1295454   .1099392     1.18   0.239    -.0859414    .3450322
      /bster |  -.1303082   .1004699    -1.30   0.195    -.3272348    .0666184
------------------------------------------------------------------------------
  Parameter bcons taken as constant term in model & ANOVA table

  
. nlcom disc: exp(_b[V:_cons])

        disc:  exp(_b[V:_cons])

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        disc |   .5367511   .0001863  2881.74   0.000      .536386    .5371161
------------------------------------------------------------------------------




*/


	nl (neonataldeath = {V=1.0}*prev_1_month + exp({V}*2)*prev_2_month + exp({V}*3)*prev_3_month + exp({V}*4)*prev_4_month + exp({V}*5)*prev_5_month + exp({V}*6)*prev_6_month + exp({V}*7)*prev_7_month + exp({V}*8)*prev_8_month + exp({V}*9)*prev_9_month + exp({V}*10)*prev_10_month + exp({V}*11)*prev_11_month +exp({V}*12)*prev_12_month )
di "JUST YEAR"
nl, coeflegend
nlcom disc: exp(_b[V:_cons])

/*

Iteration 15:  residual SS =  813837.2
Iteration 16:  residual SS =  813837.2


      Source |      SS            df       MS
-------------+----------------------------------    Number of obs =     25,946
       Model |  -811082.2          1 -811082.201    R-squared     =  -294.4037
    Residual |   813837.2      25945  31.3677857    Adj R-squared =  -294.4151
-------------+----------------------------------    Root MSE      =   5.600695
       Total |       2755      25946   .10618207    Res. dev.     =   163034.8

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          /V |  -.6215855   .0002294 -2709.29   0.000    -.6220352   -.6211358
------------------------------------------------------------------------------


 nlcom disc: exp(_b[V:_cons])

        disc:  exp(_b[V:_cons])

------------------------------------------------------------------------------
neonatalde~h |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        disc |   .5370922   .0001232  4358.68   0.000     .5368507    .5373337
------------------------------------------------------------------------------




*/


		
* With lagged quarters.  
	nl ( neonataldeath = prev_1_q + exp({delta=1.0})*prev_2_q + (exp({delta}*2))*prev_3_q + (exp({delta}*3))*prev_4_q + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {boc=1.0}*ObstetricCare + ///
		{bhy=1.0}*hypsospa + {bbcal=1.0}*bca_limb +{bcl=1.0}*bca_limb + {bcona=1.0}*congenga + {bconm = 1.0}*congenom+ {bchn=1.0}*bca_hern + {bchd=1.0}*congenhd + {bpc=1.0}*pc_y_n + {bw=1.0}*b_wt_cgr + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno + {b10=1.0}*bca_spin + ///
		{bcons=1.0}*b_const + {b2006=1.0}*y2006 + {b2007=1.0}*y2007 + {b2008=1.0}*y2008 + {b2009=1.0}*y2009 + {b2010=1.0}*y2010 + {b2011=1.0}*y2011 + {b2012=1.0}*y2012)
	nl, coeflegend
	nlcom d: exp(_b[delta:_cons])
		
		
		
		
		
