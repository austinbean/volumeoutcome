* Entry/Exit


do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"



use "/Users/austinbean/Desktop/BirthData2005-2012/AllHospInfo1990-2012.dta"

gen exposed = 0
replace exposed = 1 if county == "BEXAR"
replace exposed = 1 if county == "BOWIE"
replace exposed = 1 if county == "COLLIN"
replace exposed = 1 if county == "DALLAS"
replace exposed = 1 if county == "DENTON"
replace exposed = 1 if county == "EL PASO"
replace exposed = 1 if county == "FORT BEND"
replace exposed = 1 if county == "HARRIS"
replace exposed = 1 if county == "HAYS"
replace exposed = 1 if county == "HIDALGO"
replace exposed = 1 if county == "KERR"
replace exposed = 1 if county == "LAMAR"
replace exposed = 1 if county == "MCLENNAN"
replace exposed = 1 if county == "MAVERICK"
replace exposed = 1 if county == "MIDLAND"
replace exposed = 1 if county == "MONTGOMERY"
replace exposed = 1 if county == "ROCKWALL"
replace exposed = 1 if county == "SMITH"
replace exposed = 1 if county == "TITUS"
replace exposed = 1 if county == "TRAVIS"
replace exposed = 1 if county == "VAL VERDE"
replace exposed = 1 if county == "VICTORIA"
replace exposed = 1 if county == "WILLIAMSON"

unique fid if exposed == 1 & year == 2005
unique fid if exposed == 1 & year == 2006
unique fid if exposed == 1 & year == 2007
unique fid if exposed == 1 & year == 2008
unique fid if exposed == 1 & year == 2009
unique fid if exposed == 1 & year == 2010
unique fid if exposed == 1 & year == 2011
unique fid if exposed == 1 & year == 2012




/* 
GOALS: 
How many nicu admits are there?  
How many nicu admits are there outside of the highest volume hospital?
How high would volume be at the highest level hospital assuming all admits there?
What's expected mortality among that group given that volume?
*/
	use "${birthdata}/Births2005-2012wCounts.dta", clear
	keep if b_bplace == 1

* Subset data
	keep facname year ncdobmonth b_bcntyc nicu_year monthly_admit_deaths
	duplicates drop facname year ncdobmonth, force
	
* Compute deaths among nicu admits per month
	bysort facname year (ncdobmonth): egen mm = sum(monthly_admit_deaths)
	bysort facname year (ncdobmonth): egen year_mortality = max(mm)
	label variable year_mortality "fac-spec. yr. mort. nic. ads"
	
	
* keep year observations
	duplicates drop facname year, force
	drop ncdobmonth
	bysort b_bcntyc year: gen cc = _n
	bysort b_bcntyc year: egen countycount = max(cc)
	drop cc
	label variable countycount "num hosps in county"

* County-specific deaths among nicu admits per month:
	bysort b_bcntyc year: gen cm = sum(year_mortality)
	bysort b_bcntyc year: egen county_mort = max(cm)
	drop cm
	label variable county_mort "all county mortality, nicu admits"
	
* Nicu Admits max hosp in county
	bysort b_bcntyc year: egen max_i = max(nicu_year)
	gen mxyr_c = 0
	bysort b_bcntyc year: replace mxyr_c = 1 if nicu_year == max_i
	label variable mxyr_c "max nicu admits in county"

*admits outside of facility with max volume
	bysort b_bcntyc year: gen tsb = sum(nicu_year) if mxyr_c != 1
	* Special change for counties with ONE hospital only - these could be dropped instead
	replace tsb = nicu_year if countycount == 1
	bysort b_bcntyc year: egen br_out = max(tsb)
	label variable br_out "nicu admits outside hosp w/ max"
	
* total deaths outside of hospital w/ max volume
	bysort b_bcntyc year: gen tsd = sum(year_mortality) if mxyr_c != 1
	* special change for counties with ONE hospital only
	replace tsd = year_mortality if countycount == 1
	bysort b_bcntyc year: egen dths_out = max(tsd)
	label variable dths_out "deaths am. nic ads outside max hosp"

* Total yearly admits if hospital with highest volume has ALL of them.
	bysort b_bcntyc year: gen mft = br_out + max_i if mxyr_c == 1
	label variable mft "Total county-level nicu volume"
	
	bysort b_bcntyc year: egen ccc = max(mft)
	bysort b_bcntyc year: replace mft = ccc if mft == .
	drop ccc
	bysort b_bcntyc year: gen mfd = dths_out + year_mortality if mxyr_c == 1
	

* Estimated Quarterly mortality rate w/ volume translated to yearly:	
	gen mortrate = 0
	replace mortrate = 0.0151 if              mft <= 80
	replace mortrate = 0.0145 if mft > 80   & mft <= 160
	replace mortrate = 0.0138 if mft > 160  & mft <= 240
	replace mortrate = 0.0132 if mft > 240  & mft <= 320
	replace mortrate = 0.0126 if mft > 320  & mft <= 400 
	replace mortrate = 0.0121 if mft > 400  & mft <= 480
	replace mortrate = 0.0115 if mft > 480  & mft <= 560 
	replace mortrate = 0.0110 if mft > 560  & mft <= 640 
	replace mortrate = 0.0105 if mft > 640  & mft <= 720
	replace mortrate = 0.0100 if mft > 720  & mft <= 800 
	replace mortrate = 0.0096 if mft > 800  & mft <= 880 
	replace mortrate = 0.0091 if mft > 880  & mft <= 960 
	replace mortrate = 0.0087 if mft > 960  & mft <= 1040 
	replace mortrate = 0.0083 if mft > 1040 & mft <= 1120 
	replace mortrate = 0.0079 if mft > 1120 & mft <= 1200 
	replace mortrate = 0.0075 if mft > 1200 & mft <= 1280 
	replace mortrate = 0.0072 if mft > 1280 & mft <= 1360 
	replace mortrate = 0.0068 if mft > 1360 & mft <= 1440
	replace mortrate = 0.0065 if mft > 1440 & mft <= 1520 
	replace mortrate = 0.0062 if mft > 1520 & mft <= 1600
	replace mortrate = 0.0059 if mft > 1600 & mft <= 1680 
	replace mortrate = 0.0056 if mft > 1680 & mft <= 1760 
	replace mortrate = 0.0053 if mft > 1760 & mft <= 1840 
	replace mortrate = 0.0051 if mft > 1840
	
* Expected Mortality:

	gen exp_mrt = mortrate*mft
	label variable exp_mrt "Exp. Mort. rate w/ vol. consolidation"

* Same as above mortality rate, but matching nicu_year, so at hospital level
	gen mrtrt2 = 0
	replace mrtrt2 = 0.0151 if              nicu_year <= 80
	replace mrtrt2 = 0.0145 if nicu_year > 80   & nicu_year <= 160
	replace mrtrt2 = 0.0138 if nicu_year > 160  & nicu_year <= 240
	replace mrtrt2 = 0.0132 if nicu_year > 240  & nicu_year <= 320
	replace mrtrt2 = 0.0126 if nicu_year > 320  & nicu_year <= 400 
	replace mrtrt2 = 0.0121 if nicu_year > 400  & nicu_year <= 480
	replace mrtrt2 = 0.0115 if nicu_year > 480  & nicu_year <= 560 
	replace mrtrt2 = 0.0110 if nicu_year > 560  & nicu_year <= 640 
	replace mrtrt2 = 0.0105 if nicu_year > 640  & nicu_year <= 720
	replace mrtrt2 = 0.0100 if nicu_year > 720  & nicu_year <= 800 
	replace mrtrt2 = 0.0096 if nicu_year > 800  & nicu_year <= 880 
	replace mrtrt2 = 0.0091 if nicu_year > 880  & nicu_year <= 960 
	replace mrtrt2 = 0.0087 if nicu_year > 960  & nicu_year <= 1040 
	replace mrtrt2 = 0.0083 if nicu_year > 1040 & nicu_year <= 1120 
	replace mrtrt2 = 0.0079 if nicu_year > 1120 & nicu_year <= 1200 
	replace mrtrt2 = 0.0075 if nicu_year > 1200 & nicu_year <= 1280 
	replace mrtrt2 = 0.0072 if nicu_year > 1280 & nicu_year <= 1360 
	replace mrtrt2 = 0.0068 if nicu_year > 1360 & nicu_year <= 1440
	replace mrtrt2 = 0.0065 if nicu_year > 1440 & nicu_year <= 1520 
	replace mrtrt2 = 0.0062 if nicu_year > 1520 & nicu_year <= 1600
	replace mrtrt2 = 0.0059 if nicu_year > 1600 & nicu_year <= 1680 
	replace mrtrt2 = 0.0056 if nicu_year > 1680 & nicu_year <= 1760 
	replace mrtrt2 = 0.0053 if nicu_year > 1760 & nicu_year <= 1840 
	replace mrtrt2 = 0.0051 if nicu_year > 1840	
	
* hospital specific mortality...
	gen hs_mrt = nicu_year*mrtrt2
	label variable hs_mrt "mortality rate at hospital specific volume"
	
	bysort b_bcntyc year: gen smm_i = sum(hs_mrt)
	bysort b_bcntyc year: egen cnty_mort = max(smm_i)
	label variable cnty_mort "EXP. county mort., separate hospitals"
	drop smm_i

* Compare to realized county mortality.	
	gen rl_lives = county_mort - exp_mrt
	label variable rl_lives "real. mort. nicu admits - pred. w/ consolidation"
	
	
* Lives saved at the county level...
	gen lives = cnty_mort - exp_mrt
	label variable lives "mort w/out consolidation - mort w/ consolidation"
	
* Look at counties individually:

	keep b_bcntyc countycount year cnty_mort exp_mrt lives rl_lives county_mort
	duplicates drop b_bcntyc year, force
	drop if countycount == 1
	
* Large counties...  All counties in the state with populations over 250,000
/*
Harris      - 101
Dallas      - 57
Tarrant     - 220
Bexar       - 15
Travis      - 227
El Paso     - 71
Collin      - 43
Hidalgo     - 108
Denton      - 61
Fort Bend   - 79
Montgomery  - 170
Williamson  - 246
Cameron     - 31
Nueces      - 178
Brazoria    - 20 
Bell        - 14
Galveston   - 84
Lubbock     - 152
Jefferson   - 123
Webb        - 240

*/
	
	gen LARGE = 0 
	replace LARGE = 1 if b_bcntyc == 101 | b_bcntyc == 57 | b_bcntyc == 220 | b_bcntyc == 15 | b_bcntyc == 227 | b_bcntyc == 71 | b_bcntyc == 43 | ///
	b_bcntyc == 108 | b_bcntyc == 61 | b_bcntyc == 79 | b_bcntyc == 170 | b_bcntyc == 246 | b_bcntyc == 31 | b_bcntyc == 178 | b_bcntyc ==  20 | ///
	b_bcntyc == 14 | b_bcntyc == 84 | b_bcntyc == 152 | b_bcntyc == 123 | b_bcntyc == 240 
	keep if LARGE == 1
	bysort LARGE year: egen lss = sum(lives)
	eststo summarize lss
	
	
* County-level SD in lives saved.  
	bysort b_bcntyc: egen l_sd = sd(lives)
	bysort b_bcntyc: egen rl_sd = sd(rl_lives)
	
	

/*


    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
         lss |        160    135.5093    11.10724   117.0064   151.2732



*/
	

/*
* Entry: does it happen between 2005 and 2012?  Where?  What are effects on volumes?
* Entrants/Level Changes: 
* Christus Santa Rosa,               Bexar,      2008 - Level 3
* Wadley Regional Med Center,        Bowie,      2007 - Downgrade 3 to 2
* Christus St Michael, 			     Bowie,      2010 - Level 3
* Baylor Medical Center Frisco,      Collin,     2007 - Level 3
* Doctors Hospital White Rock Lake,  Dallas,     2010 - Upgrade Level 2 to Level 3 -> nearest neighbors... WH WRL: 1136005, Parkland 1130950, Presbyterian 1131050, Baylor Garland 1131616, Dallas Regional 1132528
* Richardson Regional, 				 Dallas,     2006 - Downgrade 3 to 1
* Presbyterian Hospital of Denton,   Denton,     2006 - Upgrade Level 1 to 3
* University Medical Center El Paso, El Paso,    2011 - Downgrade 3 to 1
* OakBend Medical Center, 			 Fort Bend,  2010 - Upgrade 2 to 3
* Memorial Hermann Sugar Land,       Fort Bend,  2007 - Upgrade 1 to 3
* St Lukes Sugar Land,               Fort Bend,  2009 - Upgrade 1 to 3
* San Jacinto Methodist,             Harris,	 2007 - Upgrade 1 to 2
* Houston Northwest, 			     Harris,	 2006 - Upgrade 1 to 3
* Methodist Hospital, 				 Harris,	 2011 - Upgrade 2 to 3
* River Oaks Hospital,				 Harris,	 2007 - Downgrade 3 to 1
* Spring Branch Med Center, 	     Harris,	 2008 - Upgrade 1 to 3
* Memorial Hermann Northwest, 		 Harris,	 2008 - Downgrade 3 to 1
* Memorial Hermann Southeast, 		 Harris,	 2006 - Downgrade 2 to 1
* Memorial Hermann Southeast, 		 Harris,	 2008 - Upgrade 1 to 3
* Tomball Regional, 				 Harris,	 2007 - Upgrade 1 to 3
* Christus St Catherine, 			 Harris,	 2012 - Upgrade 1 to 3
* St Lukes at the Vintage, 			 Harris, 	 2011 - Upgrade 1 to 3
******* Doctors Hospital Tidwell,    Harris,     2006 - Upgrade 1 to 3
* Doctors Hospital Tidwell, 		 Harris,     2009 - Downgrade 3 to 1
* Central Texas Med Center, 		 Hays,       2009 - Upgrade 1 to 3
* Edinburg Regional Med Center, 	 Hidalgo,    2007 - Upgrade 1 to 3
* Doctors Hospital at Renaissance,   Hidalgo,    2007 - Upgrade 1 to 3
* Peterson Regional Hospital, 		 Kerr,       2008 - Downgrade 2 to 1
* Paris Regional Medical, 			 Lamar,      2007 - Upgrade 1 to 2
* Paris Regional Medical, 			 Lamar,      2009 - Upgrade 2 to 3
* Providence Health Center,			 McLennan,   2007 - Upgrade 1 to 2
* Providence Health Center, 		 McLennan,   2009 - Downgrade 2 to 1
* Fort Duncan Med Center, 			 Maverick,   2006 - Downgrade 2 to 1
* Midland Memorial, 				 Midland,    2009 - Downgrade 3 to 1
* Memorial Hermann the Woodlands,    Montgomery, 2006 - Upgrade 2 to 3
* Lake Pointe Medical Center, 		 Rockwall,   2007 - Upgrade 1 to 3
* Mother Frances County, 			 Smith,      2009 - Upgrade 2 to 3
* Titus Regional Medical Center,     Titus,      2005 - Downgrade 3 to 1
* Titus Regional Medical Center, 	 Titus,      2008 - Upgrade 1 to 2
* Seton Northwest, 					 Travis,     2006 - Upgrade 1 to 2
* Val Verde Regional, 				 Val Verde , 2008 - Downgrade 3 to 2
* Citizens Medical Center, 			 Victora,    2012 - Downgrade 3 to 1
* Cedar Park Regional,  			 Williamson, 2012 - Upgrade 1 to 2

* Goal: compute the effect on these firms' competitors.  

Present in data:

- Christus Santa Rosa, Bexar, 293120, 2008
- Christus St Michael, 376245
- Baylor Medical Center at Frisco, 856316
- Presbyterian Hospital of Denton, 1216116
- Memorial Hermann Sugar Land, 1576070
- St Lukes Sugarland, 1576444
- Houston Northwest Medical Center, 2011895
- Spring Branch Med Center, 2012015
- Memorial Hermann Southeast, 2015026
- Christus St Catherine, 2016290
- St lukes at the vintage, 2016479
- Central Texas Medical Center, 2093151
- Edinburg Regional Med Center, 2151200
- Doctors Hospital Renaissance, 2156335
- Lake Pointe Medical Center, 3976115

*/

gen added3 = 0
replace added3 = 1 if fid == 293120 & year == 2008 
/* Christus SR, Bexar */

replace added3 = 1 if fid == 376245 & year == 2010 
/*  Christus SM, Bowie */

replace added3 = 1 if fid == 856316 & year == 2007 
/* Baylor Frisco, Collin */

replace added3 = 1 if fid == 1216116 & year == 2006 
/* Presbyterian Denton, Denton */
/*

browse if fid == 1216116 & (ncdobyear == 2005 | ncdobyear == 2006 | ncdobyear == 2007 )
- Transfers all to Cook childrens, then stops doing so.  
*/



replace added3 = 1 if fid == 1576070 & year == 2007 
/* Memorial Hermann Sugarland,  Fort Bend */

replace added3 = 1 if fid == 1576444 & year == 2009 
/* St Lukes Sugarland, Fort Bend */

replace added3 = 1 if fid == 2011895 & year == 2006 
/* Houston Northwest, Harris */

*replace added3 = 1 if fid == 2012015 & year == 2008 /* No records - Spring Branch Med, Harris */

replace added3 = 1 if fid == 2015026 & year == 2006 
/* Memorial Hermann Southeast, Harris */

replace added3 = 1 if fid == 2016290 & year == 2012 
/* Christus St Catherine, Harris */

replace added3 = 1 if fid == 2016479 & year == 2011 
/* St Lukes Vintage, Harris */

replace added3 = 1 if fid == 2093151 & year == 2009 
/* Central Texas Med, Hays */

replace added3 = 1 if fid == 2151200 & year == 2007 
/* Edinburg Regional, Hidalgo */

replace added3 = 1 if fid == 2156335 & year == 2007 
/* Doctors Renaissance, Hidalgo  */

replace added3 = 1 if fid == 3976115 & year == 2007 
/* Lake Pointe Medical, Rockwall */


* TODO... add county numbers.  Use variable label.do  
gen neighbor3 = 0
replace neighbor3 = 1 if b_bcntyc == 15 & year == 2008 & added3 == 0 
/* Christus SR, Bexar */

replace neighbor3 = 1 if b_bcntyc == 19 & year == 2010 & added3 == 0 
/*  Christus SM, Bowie */

replace neighbor3 = 1 if b_bcntyc == 43 & year == 2007 & added3 == 0 
/* Baylor Frisco, Collin */

replace neighbor3 = 1 if b_bcntyc == 61 & year == 2006 & added3 == 0
 /* Presbyterian Denton, Denton */
 
replace neighbor3 = 1 if b_bcntyc == 79 & year == 2007 & added3 == 0 
/* Memorial Hermann Sugarland,  Fort Bend */

replace neighbor3 = 1 if b_bcntyc == 79 & year == 2009 & added3 == 0 
/* St Lukes Sugarland, Fort Bend */

replace neighbor3 = 1 if b_bcntyc == 101 & year == 2006 & added3 == 0 
/* Houston Northwest, Harris */

replace neighbor3 = 1 if b_bcntyc == 101 & year == 2008 & added3 == 0 
/* Spring Branch Med, Harris */

replace neighbor3 = 1 if b_bcntyc == 101 & year == 2006 & added3 == 0 
/* Memorial Hermann Southeast, Harris */

replace neighbor3 = 1 if b_bcntyc == 101 & year == 2012 & added3 == 0 
/* Christus St Catherine, Harris */

replace neighbor3 = 1 if b_bcntyc == 101 & year == 2011 & added3 == 0 
/* St Lukes Vintage, Harris */

replace neighbor3 = 1 if b_bcntyc == 105 & year == 2009 & added3 == 0  
// Central Texas Med, Hays 

replace neighbor3 = 1 if b_bcntyc == 108 & year == 2007 & added3 == 0 
/* Edinburg Regional, Hidalgo */

replace neighbor3 = 1 if b_bcntyc == 108 & year == 2007 & added3 == 0 
/* Doctors Renaissance, Hidalgo  */

replace neighbor3 = 1 if b_bcntyc == 199 & year == 2007 & added3 == 0 
/* Lake Pointe Medical, Rockwall */


* All counties of interest:

gen ofinterest = 0
replace ofinterest = 1 if b_bcntyc == 199 | b_bcntyc == 108 | b_bcntyc ==105 | b_bcntyc ==101 | b_bcntyc ==79 | b_bcntyc == 61 | b_bcntyc == 43 | b_bcntyc == 19 | b_bcntyc == 15


* drop non-hospitals

drop if b_bplace != 1

* track entry in county 
bysort b_bcntyc year: gen ent_i = sum(added3)
bysort b_bcntyc year: egen entry = max(ent_i)
replace entry = 1 if entry > 1
label variable entry "some entry in county during year"

* track patients admitted to nicu, among those not transferred.
gen transferred = 0
replace transferred = 1 if bo_trans == 1 | bo_tra1 == 1
gen adm_no_trans = 0
replace adm_no_trans = 1 if transferred == 0 & adm_nicu == 1

* sum total admits to NICU 
bysort facname year: gen ads = sum(adm_no_trans)
bysort facname year: egen admits = max(ads)
drop ads
label variable admits "patients admitted to NICU and not transferred"

* how many admits TO THE NICU did you add if you added the facility?

bysort facname (year): gen admit_incr = ((admits[_n+1] + admits[_n+2] + admits[_n+3])/3) if added3 == 1
label variable admit_incr " three year average NICU admits following level 3 investment " 


* check entry NEXT year:
gen nextent = 0
bysort facname (year): replace nextent = 1 if entry[_n+1] == 1

* check for entry PRIOR year
gen prevent = 0
bysort facname (year): replace prevent = 1 if entry[_n-1] == 1



* collapse to one entry per year:



duplicates drop facname year, force

* generate indicator 1 if NOT the entrant in the prior or subsequent year:
* Use neighbor3
* sort b_bcntyc year


sort fid year
gen next3 = 0
replace next3 = 1 if neighbor3[_n+1] == 1 

bysort fid (year): gen regdiff = admits - admits[_n-1] if next3 == 1 & admits>0 & admits[_n-1]>0
bysort fid (year): gen nextdiff = admits[_n+1] - admits if next3 == 1 & admits>0 & admits[_n+1]>0
bysort fid (year): gen diff = admits - admits[_n-1] if neighbor3 == 1 & added3 == 0 & admits>0 & admits[_n-1]>0


sort b_bcntyc year fid
browse b_bcntyc facname NeoIntensive SoloIntermediate next3 regdiff nextdiff diff if ofinterest == 1

*keep facname year admits nextent prevent added3 entry

** To compute TOTAL deaths at the facility

preserve
bysort fid year: gen trns = sum(bo_trans)
bysort fid year: egen transfers = max(trns)

bysort fid year: gen dts = sum(neonataldeath)
bysort fid year: egen hdeaths = max(dts)

bysort fid year: gen ads = sum(adm_nicu)
bysort fid year: egen nicu_admits = max(ads)


keep facname fid ncdobyear ncdobmonth transfers hdeaths
duplicates drop facname ncdobmonth ncdobyear, force

/*
* Level Changers:
browse if fid == 293120 /* 2008 */
browse if fid == 376245 /* 2010 */
browse if fid == 856316 /* 2007 */
browse if fid == 1216116 /* 2006 */
browse if fid == 2015026 /* 2006 */
browse if fid == 2093151 /* Central Texas Med Center - 2009 */
browse if fid == 2151200 /* Edinburg Regional - 2007 */
browse if fid == 2156335 /* Doctors H - Renaissance - 2007 */

deaths	year  Linked cohort   LC, <= 28 days
1476	2005    2406            1504
1514	2006    2420            1544 
1455	2007    2460            1484
1457	2008    2394            1480
1395	2009    2360            1467
1421	2010    2240            1442
1329	2011
1343	2012



*/


/*

Making a graph: 

browse
preserve
duplicates drop ncdobyear fid, force
keep ncdobyear fid facname added3 NeoIntensive TotalDeliveries TransfersOut_NO_NICU-TransfersOut_HAS_NICU TransfersInternally_HAS_NICU
bysort fid: egen everad = max(added3)
browse if everad == 1
gen hs_totnicu = TransfersInFromOthers_HAS_NICU + TransfersInternally_HAS_NICU
label variable hs_totnicu "total nicu admits, source: hospital survey"
twoway line TotalDeliveries TransfersOut_NO_NICU TransfersInFromOthers_HAS_NICU TransfersInternally_HAS_NICU hs_totnicu ncdobyear if fid == 293120, xline(2008) title("Deliveries at Christus Santa Rosa") xtitle("Year") ytitle("Total Deliveries at >20 Weeks G.A") legend(label(1 "Total Deliveries") label(2 "NICU Transfers Out") label(3 "NICU Transfers In") label(4 "Internal NICU Admits") label(5 "Total NICU Admits") )

twoway line TotalDeliveries ncdobyear if fid == 293120 ||  line TransfersOut_NO_NICU ncdobyear if fid == 293210 & ncdobyear <= 2008 || line TransfersInFromOthers_HAS_NICU ncdobyear if fid == 293210 & ncdobyear >= 2008 || line TransfersInternally_HAS_NICU ncdobyear if fid == 293210 & ncdobyear >= 2008 || line hs_totnicu ncdobyear if fid == 293120 & ncdobyear >= 2008, ///
 xline(2008) title("Deliveries at Christus Santa Rosa") xtitle("Year") ytitle("Total Deliveries at >20 Weeks G.A") ///
 legend(label(1 "Total Deliveries") label(2 "NICU Transfers Out") label(3 "NICU Transfers In") label(4 "Internal NICU Admits") label(5 "Total NICU Admits") )



*/


