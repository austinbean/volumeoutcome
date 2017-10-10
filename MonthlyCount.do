* Total All County Admits:

use "${birthdata}Births2005-2012.dta", clear


bysort b_bcntyc ncdobyear ncdobmonth: gen ccs = sum(adm_nicu)
bysort b_bcntyc ncdobyear ncdobmonth: egen ctytotal = max(ccs)
drop ccs

keep b_bcntyc ncdobyear ncdobmonth ctytotal

duplicates drop b_bcntyc ncdobyear ncdobmonth, force

bysort b_bcntyc ncdobyear: egen month_mean = mean(ctytotal)

bysort b_bcntyc: egen max_month_mean = max(month_mean)

bysort b_bcntyc: egen max_any_month = max(ctytotal)


* Check largest NICU too: 

use "/Users/austinbean/Desktop/BirthData2005-2012/AllHospInfo1990-2012.dta", clear

keep if year >= 2005 & year <= 2012

keep if county == "HARRIS" | county == "BEXAR" | county == "TRAVIS" | county == "DALLAS" | county == "TARRANT" | county == "EL PASO"

bysort county: egen maxcap = max(NeoIntensiveCapacity) if NeoIntensiveCapacity != .

bysort county year: gen tcap = sum(NeoIntensiveCapacity) 
bysort county year: egen totcap = max(tcap)

duplicates drop county, force

keep county maxcap
