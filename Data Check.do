* Data Check
* Is the size of the population reasonable, given other data. 

do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
 

* 2010

use "/Users/austinbean/Desktop/Restricted Linked Birth Cohort Records/LinkCO2010US/2010Denominator.dta", clear

keep if ostate == "TX"

count if ab_nicu == "Y"

*  29,461

count if bwtr4 < 2

*  5,671

count if bwtr4 < 2 | ab_nicu == "Y"

* 31,013

use "${birthdata}/Birth2010.dta", clear

count if adm_nicu == 1

* 29, 458

count if b_wt_cgr < 2500

* 33,008

count if b_wt_cgr < 2500 | adm_nicu == 1

*  47,458



*Out of Place?

count if b_wt_cgr > 2500 & adm_nicu == 0

*  134
