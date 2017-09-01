* Predict Volume.

/*

-Estimate a model of choice, depending on distance alone, eg.
-Use this to predict volumes

*/


do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"

use "${inpatient}2010 4 Quarter PUDF.dta"

keep if hcfa_mdc == 14 | hcfa_mdc == 15

destring pat_zip, replace force

drop if pat_zip < 70000 | pat_zip > 79999

rename pat_zip PAT_ZIP

merge m:1 PAT_ZIP using "${birthdata}closest50hospitals.dta"

drop if _merge != 3

drop _merge
