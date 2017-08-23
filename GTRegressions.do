* G/T Regressions:

* So far not using health state information at all.  


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



* Weighted least squares
* 

eststo: vwls neonataldeath pub privnfp forp TotalBeds bedspub bedsprivnfp bedsforp  NeoIntensive SoloIntermediate i.year

* Note the filepath is someplace weird, like in the full versions of the PUDF, I think.  

esttab using basicresults.tex, se ar2 label title("Results") nonumbers mtitles("OLS" "FGLS")
