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

	use "${birthdata}Birth2006.dta", clear
	* APPEND later years.  
	
	keep if b_bplace ==1 
	
* Add Zip Code Choice Sets - closest 50 hospitals.

	drop if b_mrzip < 70000 | b_mrzip > 79999
	* TODO - this may not be necessary
	drop if fid == .
	
	
	merge m:1 fid ncdobyear ncdobmonth using "${birthdata}FacCountMissingFidDropped.dta"
	
* this actually works, weirdly...
* well, kind of.  Actually the b1 coefficient never changes, which makes NO sense.
	* EVERYTHING with any missing value at all must be dropped.
	nl (neonataldeath = {b0=1.0}*ln( {b1=0.7}*prev_11_months + month_count + 1))
	nl (neonataldeath = {b0=1.0}*ln( {b1=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive)
	nl (neonataldeath = {b0=1.0}*ln( {b1=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate )
	nl (neonataldeath = {b0=1.0}*ln( {b1=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent )
	nl (neonataldeath = {b0=1.0}*ln( {b1=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther)
	nl (neonataldeath = {b0=1.0}*ln( {b1=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot)
	nl (neonataldeath = {b0=1.0}*ln( {b1=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure)
	nl (neonataldeath = {b0=1.0}*ln( {b1=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury)
	nl (neonataldeath = {b0=1.0}*ln( {b1=0.7}*prev_11_months + month_count + 1) + {b2=1.0}*NeoIntensive +{b3=1.0}*SoloIntermediate + {b4=1.0}*as_vent +{b5=1.0}*rep_ther + {b6=1.0}*antibiot + {b7=1.0}*seizure + {b8=1.0}*b_injury + {b9=1.0}*bca_aeno)

	
	
	*  probit neonataldeath prev_*_month i.b_es_ges i.pay      bca_aeno bca_spin congenhd bca_hern congenom congenga bca_limb hypsospa   
