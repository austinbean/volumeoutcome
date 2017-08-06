* Entry/Exit


do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"

use "${birthdata}/Births2005-2012wCounts.dta"


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
* 


* Goal: compute the effect on these firms' competitors.  


/*
Present in data:

- Christus Santa Rosa, 293120
- Christus St Michael, 376245
- Baylor Medical Center at Frisco, 856316
- Presbyterian Hospital of Denton, 1216116
- Memoiral Hermann Sugar Land, 1576070
- St Lukes Sugarland, 1576444
- Houston Northwest Medical Center, 2011895
- Spring Branch Med Center, 2012015
- Memoiral Hermann Southeast, 2015026
- Christus St Catherine, 2016290
- St lukes at the vintage, 2016479
- Central Texas Medical Center, 2093151
- Edinburg Regional Med Center, 2151200
- Doctors Hospital Renaissance, 2156335
- Lake Pointe Medical Center, 3976115

*/
