* Nonlinear least squares... Maybe
/*

Not as bad as I thought.  BUT:
- figure out why the coefficient never changes.
- 

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
* specialize to VLBW only	
    keep if b_wt_cgr < 1500
	
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

