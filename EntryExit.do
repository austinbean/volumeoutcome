* Entry/Exit


do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"

use "${birthdata}/Births2005-2012wCounts.dta", clear

/*
* Entry: does it happen between 2005 and 2012?  Where?  What are effects on volumes?
* Entrants/Level Changes: 
* Christus Santa Rosa, Bexar, 2008 - Level 3
* Wadley Regional Med Center, Bowie, 2007 - Downgrade 3 to 2
* Christus St Michael, Bowie, 2010 - Level 3
* Baylor Medical Center Frisco, Collin, 2007 - Level 3
* Doctors Hospital White Rock Lake, Dallas, 2010 - Upgrade Level 2 to Level 3
* Richardson Regional, Dallas, 2006 - Downgrade 3 to 1
* Presbyterian Hospital of Denton, Denton, 2006 - Upgrade Level 1 to 3
* University Medical Center El Paso, El Paso, 2011 - Downgrade 3 to 1
* OakBend Medical Center, Fort Bend, 2010 - Upgrade 2 to 3
* Memorial Hermann Sugar Land, Fort Bend, 2007 - Upgrade 1 to 3
* St Lukes Sugar Land, Fort Bend, 2009 - Upgrade 1 to 3
* San Jacinto Methodist, Harris, 2007 - Upgrade 1 to 2
* Houston Northwest, Harris, 2006 - Upgrade 1 to 3
* Methodist Hospital, Harris, 2011 - Upgrade 2 to 3
* River Oaks Hospital, Harris, 2007 - Downgrade 3 to 1
* Spring Branch Med Center, Harris, 2008 - Upgrade 1 to 3
* Memorial Hermann Northwest, Harris, 2008 - Downgrade 3 to 1
* Memorial Hermann Southeast, Harris, 2006 - Downgrade 2 to 1
* Memorial Hermann Southeast, Harris, 2008 - Upgrade 1 to 3
* Tomball Regional, Harris, 2007 - Upgrade 1 to 3
* Christus St Catherine, Harris, 2012 - Upgrade 1 to 3
* St Lukes at the Vintage, Harris, 2011 - Upgrade 1 to 3
******* Doctors Hospital Tidwell, Harris, 2006 - Upgrade 1 to 3
* Doctors Hospital Tidwell, Harris, 2009 - Downgrade 3 to 1
* Central Texas Med Center, Hays, 2009 - Upgrade 1 to 3
* Edinburg Regional Med Center, Hidalgo, 2007 - Upgrade 1 to 3
* Doctors Hospital at Renaissance, Hidalgo, 2007 - Upgrade 1 to 3
* Peterson Regional Hospital, Kerr, 2008 - Downgrade 2 to 1
* Paris Regional Medical, Lamar, 2007 - Upgrade 1 to 2
* Paris Regional Medical, Lamar, 2009 - Upgrade 2 to 3
* Providence Health Center, McLennan, 2007 - Upgrade 1 to 2
* Providence Health Center, McLennan, 2009 - Downgrade 2 to 1
* Fort Duncan Med Center, Maverick, 2006 - Downgrade 2 to 1
* Midland Memorial, Midland, 2009 - Downgrade 3 to 1
* Memorial Hermann the Woodlands, Montgomery, 2006 - Upgrade 2 to 3
* Lake Pointe Medical Center, Rockwall, 2007 - Upgrade 1 to 3
* Mother Frances County, Smith, 2009 - Upgrade 2 to 3
* Titus Regional Medical Center, Titus, 2005 - Downgrade 3 to 1
* Titus Regional Medical Center, Titus, 2008 - Upgrade 1 to 2
* Seton Northwest, Travis, 2006 - Upgrade 1 to 2
* Val Verde Regional, Val Verde , 2008 - Downgrade 3 to 2
* Citizens Medical Center, Victora, 2012 - Downgrade 3 to 1
* Cedar Park Regional, Williamson, 2012 - Upgrade 1 to 2

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

* generate indicator 1 if NOT the entrant in the prior or subsequent year:
* Use neighbor3


* collapse to one entry per year:

duplicates drop facname year, force
keep facname year admits nextent prevent added3 entry

* Now, compute mean admits to NICU ignoring the entering facility...

