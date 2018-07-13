* Choice with mortality rate:
* Similar to Choice with lagged volume.do
* What are the preferences of patients for mortality rates?  Do they know?  
* This should just say a little file with year and mortality rates, then merge back into the choice model estimation
* with these two variables


do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"

* Use the overall data, not the separate years.
	* the difference is that this isn't exactly the right population.  But ok.  

use "${birthdata}Births2005-2012wCounts.dta", clear
duplicates drop fid year, force
keep fid year deaths_nicu_prior_year deaths_prior_year all_mort_rate nicu_mort_rate

save "${birthdata}MortRates.dta", replace
