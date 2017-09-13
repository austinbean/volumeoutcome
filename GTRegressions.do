* G/T Regressions:

* So far not using health state information at all.  

do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"


use "${birthdata}Births2005-2012wCounts.dta", clear

keep if b_bplace == 1

gen pub = 0
replace pub = 1 if nfpstatus == 16 | nfpstatus == 12 | nfpstatus == 13 | nfpstatus == 15

gen privnfp = 0
replace privnfp = 1 if nfpstatus == 21 | nfpstatus == 23

gen forp = 0
replace forp = 1 if nfpstatus == 31 | nfpstatus == 32 | nfpstatus == 33

gen bedspub = pub*TotalBeds
gen bedsprivnfp = TotalBeds*privnfp
gen bedsforp = TotalBeds*forp

eststo: regress neonataldeath pub privnfp forp TotalBeds bedspub bedsprivnfp bedsforp  NeoIntensive SoloIntermediate i.year 

	* Generate residuals and weights for FGLS
predict p1
gen resid = neonataldeat - p1
gen wts = sqrt(max( resid*(1-resid) , 0.01))

* NB - cannot do i.year in this method, obviously. 

* Generate the i.year variables by hand and transform them.  
gen y2006 = 0 
replace y2006 = 1 if year == 2006

gen y2007= 0
replace y2007 = 1 if year == 2007

gen y2008= 0
replace y2008 = 1 if year == 2008

gen y2009= 0
replace y2009 = 1 if year == 2009

gen y2010= 0
replace y2010 = 1 if year == 2010

gen y2011= 0
replace y2011 = 1 if year == 2011

gen y2012 = 0
replace y2012 = 1 if year == 2012

local v1 = "pub privnfp forp TotalBeds bedspub bedsprivnfp bedsforp  NeoIntensive SoloIntermediate y2006 y2007 y2008 y2009 y2010 y2011 y2012"


	* Now transform variables by that quantity.
	
foreach st1 of local v1{

replace `st1' = `st1'/wts

}	
	
regress neonataldeath `v1' 



* Note the filepath is someplace weird, like in the full versions of the PUDF, I think.  

esttab using "/Users/austinbean/Desktop/Birth2005-2012/basicresults.tex", se ar2 label title("Results") nonumbers mtitles("OLS" "FGLS")



