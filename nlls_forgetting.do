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
	{bdiab = 1.0}*diab_pre + {bdig=1.0}*diab_ges + {bcrh=1.0}*brf_crhy + {bpgh=1.0}*brf_pghy + {brfe=1.0}*brf_eclm + {bprem=1.0}*pre_prem + 
	{btrs=1.0}*bo_trans + {bster=1.0}*lab_ster )

	
	
