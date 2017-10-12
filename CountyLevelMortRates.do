* try to get county level stuff...

* load, drop home births, keep one observations per facility-month
	use "${birthdata}Births2005-2012wCounts.dta", clear
	drop if b_bplace != 1
	duplicates drop facname ncdobmonth ncdobyear, force

* Get rid of individual level vars:
	drop bs_sex b_citynm b_btype b_bplace PAT_ZIP b_m_educ-m_rwhite m_rblack-large_gest_age fid transfid
	drop fid1-zipfacdistancecn50
	drop m_hispanic-chdist
	drop population-longitude
	sort b_bcntyc ncdobyear ncdobmonth facna

* What do I want?  Something like... average facility specific mortality rates (annually)

	sort b_bcntyc ncdobmonth ncdobyear

* keep if b_bcntyc == 227
* Gen track of quarter
	gen quarter = 0
	replace quarter = 1 if ncdobmonth == 1 | ncdobmonth == 2 | ncdobmonth == 3
	replace quarter = 2 if ncdobmonth == 4 | ncdobmonth == 5 | ncdobmonth == 6
	replace quarter = 3 if ncdobmonth == 7 | ncdobmonth == 8 | ncdobmonth == 9
	replace quarter = 4 if ncdobmonth == 10 | ncdobmonth == 11 | ncdobmonth == 12


* a mean of prev_q total_q_nicu

	bysort b_bcntyc ncdobyear quarter: egen co_mean_i = mean(prev_q) if NeoIntensive == 1
	bysort b_bcntyc ncdobyear quarter: egen county_mean_nicu_admits = max(co_mean_i)
	drop co_mean_i
	label variable county_mean_nicu_admits "county-level mean nicu admits, all L 3 facs"

