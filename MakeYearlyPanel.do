* Make yearly panel.


* Get the Level Information and Delivery Information
	
	use "/Users/austinbean/Desktop/BirthData2005-2012/AllHospInfo1990-2012.dta", clear
	keep if year >= 2005
	keep fid TotalDeliveries year NeoIntensive SoloIntermediate NeoIntensiveCapacity NeoIntermediateCapacity
	save "/Users/austinbean/Desktop/BirthData2005-2012/AllBirths2005-2012.dta", replace


* Create Panel of Facility-level NICU Admit and Death:
	use "${birthdata}FacCount2005.dta", clear
	gen yr2005 = 2005
	
	foreach nm of numlist 2006(1)2012{
	
	append using "${birthdata}FacCount`nm'.dta", gen(yr`nm')
	
	replace yr`nm' = `nm' if yr`nm' == 1
	}
	
	foreach nm of numlist 2005(1)2012{
	replace yr`nm' = 0 if yr`nm' == .
	}
	
	egen year = rowtotal(yr*)
	drop yr*
	label variable year "Year"
	
	duplicates drop facname year, force
	
	drop ncdobmonth

	keep facname fid year  b_bcntyc  ///
	yearly_admit_deaths  ///
	vlbw_mort_na_ex vlbw_mort_na lbw_mort_na_ex lbw_mort_na ///
	nicu_year nicu_year_ex lbw_year lbw_year_ex lbw_year_na lbw_year_na_ex vlbw_year vlbw_year_ex vlbw_year_na vlbw_year_na_ex ///
	d_year_all deaths_year d_vlbw_year_total d_vlbw_year_total_ex d_vlbw_year_na_total d_vlbw_year_na_ex ///
	d_lbw_year_total d_lbw_year_total_ex d_lbw_year_na_total d_lbw_year_na_ex
	
	
	* Cannot merge with missing fid information.
	drop if fid == .
	* TODO - there is an issue to fix here.  There are duplicate fids / duplicate names
	duplicates drop fid year, force
	
	merge 1:1 fid year using "/Users/austinbean/Desktop/BirthData2005-2012/AllBirths2005-2012.dta"
	drop if _merge != 3
