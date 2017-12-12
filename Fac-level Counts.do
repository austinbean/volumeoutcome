* Compute Fac-level Counts. 

*use "${birthdata}Birth2007.dta", clear

/*
Per hospital/month observation 
	LBW
		Admits
		Total
		Transfers
		w/o Transfers
	VLBW
		Admits
		Total
		Transfers
		w/o Transfers
	Mortality
		LBW
		VLBW
		Total
		w/o Transfers
	Admits Total
		lbw admits
		vlbw admits

*/




* Current problem - some months have zeros for VLBW births or deaths.  Keep them.   

* TODO - count only among those who were NOT transferred and among facilities which have level 2 or level 3 ONLY.


	sort facname ncdobmonth

* NOTE: small number of home births.

* Generate variable to track transfers

	gen transferred = 0
	replace transferred = 1 if bo_trans == 1
	label variable transferred "Infant transferred"


* All NICU admits, transferred or not:
	replace adm_nicu = 0 if adm_nicu == 2
	bysort facname ncdobmonth: gen f_c_i = sum(adm_nicu)
	bysort facname ncdobmonth: egen month_count = max(f_c_i)
	drop f_c_i
	label variable month_count "Total NICU admits in month INC transfers"


* NICU admits by quarter at facility level:
	gen q1_i = 0
	gen q2_i = 0
	gen q3_i = 0
	gen q4_i = 0
	bysort facname ncdobmonth: replace q1_i = 1 if adm_nicu == 1 & ncdobmonth <= 3
	bysort facname ncdobmonth: replace q2_i = 1 if adm_nicu == 1 & ncdobmonth <= 6 & ncdobmonth > 3
	bysort facname ncdobmonth: replace q3_i = 1 if adm_nicu == 1 & ncdobmonth <= 9 & ncdobmonth > 6
	bysort facname ncdobmonth: replace q4_i = 1 if adm_nicu == 1 & ncdobmonth <= 12 & ncdobmonth > 9
	bysort facname q1_i: gen q11 = sum(q1_i)
	bysort facname q2_i: gen q21 = sum(q2_i)
	bysort facname q3_i: gen q31 = sum(q3_i)
	bysort facname q4_i: gen q41 = sum(q4_i)
	bysort facname: egen q1_ad = max(q11)
	bysort facname: egen q2_ad = max(q21)
	bysort facname: egen q3_ad = max(q31)
	bysort facname: egen q4_ad = max(q41)
	gen prev_q = .
	replace prev_q = q1_ad if ncdobmonth <= 6 & ncdobmonth > 3
	replace prev_q = q2_ad if ncdobmonth <= 9 & ncdobmonth > 6
	replace prev_q = q3_ad if ncdobmonth <= 12 & ncdobmonth > 9
	label variable prev_q "prior quarter total NICU admits"
	drop q*_i q11 q21 q31 q41 q1_ad q2_ad q3_ad 
	
	
* Count of NICU admits by month, EX transfers
	gen nic_ad = 0
	replace nic_ad = 1 if adm_nicu == 1 & transferred == 0
	bysort facname ncdobmonth: gen f_c = sum(nic_ad)
	bysort facname ncdobmonth: egen month_count_ex = max(f_c)
	drop f_c nic_ad
	label variable month_count_ex "Hosp. Spc. Total NICU admits in month EX transfers"


* Counts of LBW, VLBW by month :

	gen vlbw = 0
	replace vlbw = 1 if b_wt_cgr <= 1500

	gen lbw = 0
	replace lbw = 1 if b_wt_cgr <= 2500
	
	
	/*
	*
	* To count fraction of ALL nicu admits who are LBW or VLBW
	egen tna = sum(adm_nicu)
	gen lb_na = 0
	replace lb_na = 1 if adm_nicu == 1 & lbw == 1
	egen tlbwna = sum(lb_na)
	gen vlb_na = 0
	replace vlb_na = 1 if adm_nicu == 1 & vlbw == 1
	egen tvlbwna = sum(vlb_na)
	gen fr_na_lb = tlbwna/tna
	label variable fr_na_lb "fraction of all nicu admits lbw"
	gen fr_na_vlb = tvlbwna/tna
	label variable fr_na_vlb  "fraction of all nicu admits vlbw"
	*/
	
	
* LOW BIRTH WEIGHT
	* Low Birth Weight, including and excluding transfers - not restricting to NICU admits.
		bysort facname ncdobmonth lbw: gen lb_c_i = _n if lbw == 1 
		bysort facname ncdobmonth: egen lbw_month = max(lb_c_i)
		drop lb_c_i
		label variable lbw_month "Hosp. Spc. LBW babies in month, inc transfers"
	* Excluding - this is all LBW ex transfers
		bysort facname ncdobmonth lbw transferred: gen lb_c_i = _n if lbw == 1 & transferred == 0 
		bysort facname ncdobmonth: egen lbw_month_ex = max(lb_c_i)
		drop lb_c_i
		label variable lbw_month_ex "Hosp. Spc. LBW babies in month, EX transfers"
	* LBW for those admitted to NICU:
		gen lb_ad = 0
		replace lb_ad = 1 if lbw == 1 & adm_nicu == 1
		bysort facname ncdobmonth: egen lbw_month_adm = sum(lb_ad)
		drop lb_ad
		label variable lbw_month_adm "LBW admitted NICU, month"
	* LBW for those admitted AND not transferred	
		gen lb_ad = 0
		replace lb_ad = 1 if lbw == 1 & adm_nicu == 1 & bo_trans == 0
		bysort facname ncdobmonth: egen lbw_month_adm_ex = sum(lb_ad)
		drop lb_ad
		label variable lbw_month_adm_ex "LBW admitted NICU, month, ex trans"
		
		

* VERY LOW BIRTH WEIGHT
	* Very Low Birth Weight, including and excluding transfers
		bysort facname ncdobmonth vlbw: gen vl_c_i = _n if vlbw == 1
		bysort facname ncdobmonth: egen vlbw_month = max(vl_c_i)
		drop vl_c_i
		label variable vlbw_month "Hosp. Spc. VLBW babies in month, including all"
	* Excluding - this is all vlbw ex transfers
		bysort facname ncdobmonth vlbw transferred: gen vl_c_i = _n if vlbw == 1 & transferred == 0 
		bysort facname ncdobmonth: egen vlbw_month_ex = max(vl_c_i)
		drop vl_c_i
		label variable vlbw_month_ex "Hosp. Spc. VLBW babies in month, excluding transfers"
	* VLBW for admitted to nicu, inc transfers
		gen vl_ad = 0
		replace vl_ad = 1 if vlbw == 1 & adm_nicu == 1 
		bysort facname ncdobmonth: egen vlbw_month_adm = sum(vl_ad)
		drop vl_ad
		label variable vlbw_month_adm "vlbw admitted to nicu, inc trans"
	* VLBW for admitted, ex transfers
		gen vl_ade = 0
		replace vl_ade = 1 if vlbw == 1 & adm_nicu == 1 & bo_trans == 1
		bysort facname ncdobmonth: egen vlbw_month_adm_ex = sum(vl_ade)
		drop vl_ade
		label variable vlbw_month_adm_ex "vlbw admitted to nicu, ex trans"
		
		

* Fix some missing entries.
	* For both total LBW and VLBW by month, if missing make 0
	bysort facname ncdobmonth: replace lbw_month = 0 if lbw_month == .
	bysort facname ncdobmonth: replace vlbw_month = 0 if vlbw_month == .
	* The same, but for the variables without transfers
	bysort facname ncdobmonth: replace lbw_month_ex = 0 if lbw_month_ex == .
	bysort facname ncdobmonth: replace vlbw_month_ex = 0 if vlbw_month_ex == .


* Compute some MORTALITY counts at LBW or VLBW by month and all patients:
	* VERY LOW BIRTH WEIGHT
		* Very low birth weight mortality
			gen vlbw_mort = 0
			replace vlbw_mort = 1 if vlbw == 1 & neonataldeath == 1
		* vlbw, mortality, excluding transfers
			gen vlbw_mort_ex = 0
			replace vlbw_mort_ex = 1 if vlbw == 1 & neonataldeath == 1 & transferred == 0
		* vlbw, mortality, nicu admit
			gen vl_m_na = 0
			replace vl_m_na = 1 if vlbw == 1 & neonataldeath == 1 & adm_nicu == 1
		* vlbw, mortality, nicu admit, not transferred
			gen vl_m_na_ex = 0
			replace vl_m_na_ex = 1 if vlbw == 1 & neonataldeath == 1 & adm_nicu == 1 & transferred == 0	
		* VLBW mortality including transfers:
			bysort facname ncdobmonth vlbw_mort: gen vl_i = sum(vlbw_mort)
			bysort facname ncdobmonth: egen vlbw_month_mort = max(vl_i)
			drop vl_i vlbw_mort
			label variable vlbw_month_mort "Hosp. Spc. Monthly VLBW mortality, inc transfers"
		* VLBW mortality excluding transfers:
			bysort facname ncdobmonth vlbw_mort_ex: gen vl_i = sum(vlbw_mort_ex)
			bysort facname ncdobmonth: egen vlbw_month_mort_ex = max(vl_i)
			drop vl_i vlbw_mort_ex
			label variable vlbw_month_mort_ex "Hosp. Spc. Monthly VLBW mortality, EX transfers"
		* VLBW mortality, nicu admits, inc transfers:
			bysort facname ncdobmonth: egen vlbw_mort_na = sum(vl_m_na)
			label variable vlbw_mort_na "month vlbw mort, nicu ads"
		* VLBW mortality, nicu admits, ex transfers:
			bysort facname ncdobmonth: egen vlbw_mort_na_ex = sum(vl_m_na_ex)
			label variable vlbw_mort_na_ex "month vlbw mort, nicu ads, ex trans"
		* Drop temporaries
			drop vl_m_na vl_m_na_ex
			

				
	* LOW BIRTH WEIGHT
		* Low birth weight, mortality
			gen lbw_mort = 0
			replace lbw_mort = 1 if lbw == 1 & neonataldeath == 1
		* lbw, mortality, excluding transfers
			gen lbw_mort_ex = 0
			replace lbw_mort_ex = 1 if lbw == 1 & neonataldeath == 1 & transferred == 0
		* lbw, mortality, nicu admit
			gen lb_m_na = 0
			replace lb_m_na = 1 if lbw == 1 & neonataldeath == 1 & adm_nicu == 1
		* lbw, mortality, nicu admit, not transferred
			gen lb_m_na_ex = 0
			replace lb_m_na_ex = 1 if lbw == 1 & neonataldeath == 1 & adm_nicu == 1 & transferred == 0	
		* LBW mortality, including transfers
			bysort facname ncdobmonth lbw_mort: egen lb_i = sum(lbw_mort)
			bysort facname ncdobmonth: egen lbw_month_mort = max(lb_i)
			drop lb_i lbw_mort
			label variable lbw_month_mort "Hosp. Spc. Monthly LBW mortality, inc transfers"
		* LBW mortality, excluding transfers
			bysort facname ncdobmonth lbw_mort_ex: egen lb_i = sum(lbw_mort_ex)
			bysort facname ncdobmonth: egen lbw_month_mort_ex = max(lb_i)
			drop lb_i lbw_mort_ex
			label variable lbw_month_mort_ex "Hosp. Spc. Monthly LBW mortality, ex transfers"
		* LBW mortality, nicu admits, inc transfers
			bysort facname ncdobmonth: egen lbw_mort_na = sum(lb_m_na)
			label variable lbw_mort_na "LBW mort, nicu admit"
		* LBW Mortality, nicu admits, ex transfers
			bysort facname ncdobmonth: egen lbw_mort_na_ex = sum(lb_m_na_ex)
			label variable lbw_mort_na_ex "LBW mort, nicu admit, ex_trans"
		* Drop temporaries
			drop lb_m_na lb_m_na_ex
			

	* Replace some missing values
		bysort facname ncdobmonth: replace vlbw_month_mort = 0 if vlbw_month_mort == .
		bysort facname ncdobmonth: replace lbw_month_mort = 0 if lbw_month_mort == .
	
		bysort facname ncdobmonth: replace vlbw_month_mort_ex = 0 if vlbw_month_mort_ex == .
		bysort facname ncdobmonth: replace lbw_month_mort_ex = 0 if lbw_month_mort_ex == .

	* ALL Mortality
		* Mortality among ALL nicu admits, 	
			gen nd = 0
			bysort facname ncdobmonth: replace nd = 1 if adm_nicu == 1 & neonataldeath == 1
			bysort facname ncdobmonth: gen nnd_i = sum(nd)
			bysort facname ncdobmonth: egen monthly_admit_deaths = max(nnd_i)
			drop nnd_i nd
			label variable monthly_admit_deaths "monthly deaths among nicu admits"
			
		* All mortality by month:
			bysort facname ncdobmonth: gen mm = sum(neonataldeath)
			bysort facname ncdobmonth: egen month_mort_all = max(mm)
			drop mm
			label variable month_mort_all "all monthly mortality, inc. non-nicu-admits"
			
			

	
* dropping home births
	keep if b_bplace == 1
	
	
* count VLBW and LBW nicu admits:
	gen lbna = 0
	replace lbna = 1 if adm_nicu == 1 & lbw == 1
	bysort facname ncdobmonth: gen lb_i = sum(lbna)
	bysort facname ncdobmonth: egen lbw_nicad = max(lb_i)
	*drop lbna lb_i
	label variable lbw_nicad "nicu admits also LBW"
	
	gen vlbna = 0
	replace vlbna = 1 if adm_nicu == 1 & vlbw == 1
	bysort facname ncdobmonth: gen vlb_i = sum(vlbna)
	bysort facname ncdobmonth: egen vlbw_nicad = max(vlb_i)
	*drop vlbna vlb_i
	label variable vlbw_nicad "nicu admits also vlbw"
	

	

* Travis County:
* browse if b_bcntyc == 227
 
	duplicates drop facname ncdobmonth, force
	
	
* Fractions of nicu admits VLBW and LBW
	gen nicu_frac_lbw = lbw_nicad/month_count
	label variable nicu_frac_lbw "fraction of nicu admits lbw"
	replace nicu_frac_lbw = 0 if month_count == 0
	
	gen nicu_frac_vlbw = vlbw_nicad/month_count
	label variable nicu_frac_vlbw "fraction of nicu admits VLBW"
	replace nicu_frac_vlbw = 0 if month_count == 0
	
	
	
* Annual mortality among admits:
	bysort facname: gen yra_i = sum(monthly_admit_deaths)
	bysort facname: egen yearly_admit_deaths = max(yra_i)
	drop yra_i
	label variable yearly_admit_deaths "yearly deaths among nicu admits"
	
	
* Make county level counts by quarter
	bysort b_bcntyc : gen q1_i = sum(month_count) if ncdobmonth <= 3
	bysort b_bcntyc : gen q2_i = sum(month_count) if ncdobmonth <= 6 & ncdobmonth > 3
	bysort b_bcntyc : gen q3_i = sum(month_count) if ncdobmonth <= 9 & ncdobmonth > 6
	bysort b_bcntyc : gen q4_i = sum(month_count) if ncdobmonth <= 12 & ncdobmonth > 9
	bysort b_bcntyc : egen q11 = max(q1_i)
	bysort b_bcntyc : egen q21 = max(q2_i)
	bysort b_bcntyc : egen q31 = max(q3_i)
	bysort b_bcntyc : egen q41 = max(q4_i)

	gen total_q_nicu = .
	replace total_q_nicu = q11 if ncdobmonth <= 3  
	replace total_q_nicu = q21 if ncdobmonth <= 6 & ncdobmonth > 3
	replace total_q_nicu = q31 if ncdobmonth <= 9 & ncdobmonth > 6
	replace total_q_nicu = q41 if ncdobmonth <= 12 & ncdobmonth > 9

	label variable total_q_nicu "quarter total county NICU admits"
	drop q*_i q11 q21 q31 q41
	
* County deaths by quarter:
	gen q1_i = 0
	gen q2_i = 0
	gen q3_i = 0
	gen q4_i = 0
	bysort b_bcntyc ncdobmonth: replace q1_i = monthly_admit_deaths if ncdobmonth <= 3
	bysort b_bcntyc ncdobmonth: replace q2_i = monthly_admit_deaths if ncdobmonth <= 6 & ncdobmonth > 3
	bysort b_bcntyc ncdobmonth: replace q3_i = monthly_admit_deaths if ncdobmonth <= 9 & ncdobmonth > 6
	bysort b_bcntyc ncdobmonth: replace q4_i = monthly_admit_deaths if ncdobmonth <= 12 & ncdobmonth > 9
	bysort b_bcntyc ncdobmonth: egen qs1 = sum(q1_i)
	bysort b_bcntyc : egen qs2 = sum(q2_i)
	bysort b_bcntyc : egen qs3 = sum(q3_i)
	bysort b_bcntyc : egen qs4 = sum(q4_i)
	
	bysort b_bcntyc : egen q11 = max(qs1)
	bysort b_bcntyc : egen q21 = max(qs2)
	bysort b_bcntyc : egen q31 = max(qs3)
	bysort b_bcntyc : egen q41 = max(qs4)
	gen total_q_deaths = .
	replace total_q_deaths = q11 if ncdobmonth <= 3  
	replace total_q_deaths = q21 if ncdobmonth <= 6 & ncdobmonth > 3
	replace total_q_deaths = q31 if ncdobmonth <= 9 & ncdobmonth > 6
	replace total_q_deaths = q41 if ncdobmonth <= 12 & ncdobmonth > 9
	label variable total_q_deaths "quarter total county nn deaths"
	drop q*_i qs* q11 q21 q31 q41

* Keep subset:

	keep facname fid ncdobmonth b_bcntyc month_count month_count_ex ///
	lbw_month lbw_month_ex vlbw_month vlbw_month_ex lbw_month_mort ///
	vlbw_month_mort vlbw_month_mort_ex lbw_month_mort_ex prev_q q4_ad ///
	monthly_admit_deaths yearly_admit_deaths total_q_deaths total_q_nicu month_mort_all ///
	lbw_month_adm_ex lbw_month_adm vlbw_month_adm vlbw_month_adm_ex ///
	vlbw_mort_na_ex vlbw_mort_na lbw_mort_na_ex lbw_mort_na




* WHOLE YEAR VALUES
			
	* Total NICU Admits for the year
		* Transfers Incl.
		bysort facname : gen na_y_i = sum(month_count)
		bysort facname : egen nicu_year = max(na_y_i)
		drop na_y_i
		label variable nicu_year "Fac. Spec. nicu admits in Year"
		* Transfers Excl.
		bysort facname : egen nicu_year_ex = sum(month_count_ex)
		label variable nicu_year_ex "nicu admits year, ex transfers"
	
	
	* Total VLBW and LBW NICU admits in several categories for the year - 
	* All of them (nonadmits and admits, transfers and non), Admits and nonadmits excluding transfers, admits including transfers, admits excluding transfers
		* LBW 
			* All LBW, nonadmits and Transfers Incl.
			bysort facname : gen lbw_y_i = sum(lbw_month)
			bysort facname : egen lbw_year = max(lbw_y_i)
			drop lbw_y_i
			label variable lbw_year "Fac. Spec. Low Birth Weight Infants in Year"
			* All LBW, Transfers Excl.
			bysort facname: egen lbw_year_ex = sum(lbw_month_ex)
			label variable lbw_year_ex "lbw patients year, ex transfers"
			* LBW NICU Admits, Inc Trans.
			bysort facname: egen lbw_year_na = sum(lbw_month_adm)
			label variable lbw_year_na "LBW nicu admits, inc trans"
			* LBW NICU Admits, Ex. Trans.
			bysort facname: egen lbw_year_na_ex = sum(lbw_month_adm_ex)
			label variable lbw_year_na_ex "LBW NICU Admits, ex trans"
			
		* VLBW	
		    * Total VLBW, nonadmits and Transfers Incl.
			bysort facname : gen vlbw_y_i = sum(vlbw_month)
			bysort facname : egen vlbw_year = max(vlbw_y_i)
			drop vlbw_y_i
			label variable vlbw_year "Fac. Spec. Very Low Birth Weight Infants in Year"
			* Total VLBW, Transfers Excl.
			bysort facname: egen vlbw_year_ex = sum(vlbw_month_ex)
			label variable vlbw_year_ex "VLBW infants per year, ex transfers"
			* VLBW NICU Admits, Inc Trans.
			bysort facname: egen vlbw_year_na = sum(vlbw_month_adm)
			label variable vlbw_year_na "VLBW nicu admits, inc trans"
			* VLBW NICU Admits, Ex. Trans.
			bysort facname: egen vlbw_year_na_ex = sum(vlbw_month_adm_ex)
			label variable vlbw_year_na_ex "VLBW NICU Admits, ex trans"
			
		* Mortality
			* Total deaths, admits and nonadmits, inc transfers
				bysort facname : egen d_year_all = sum(month_mort_all)
				label variable d_year_all "all mortality, all patients, inc non ads and trans"
			* Total deaths per month among NICU admits, inc trans
				bysort facname : gen d_y_i = sum(monthly_admit_deaths)
				bysort facname : egen deaths_year = max(d_y_i)
				drop d_y_i
				label variable deaths_year "Fac. Spec. deaths in Year, among nicu admits"
			* VLBW
				* Total Year Mortality among vlbw, inc non-admits and transfers
				bysort facname: egen d_vlbw_year_total = sum(vlbw_month_mort)
				label variable d_vlbw_year_total "All vlbw mort, incl nonadmits and transfers "
				* VLBW Year Mortality, Ex Transfers, inc non admits
				bysort facname: egen d_vlbw_year_total_ex = sum(vlbw_month_mort_ex)
				label variable d_vlbw_year_total_ex "all vlbw mort, incl nonadmits, ex transfers "
				* VLBW year mortality, admits only, inc trans
				bysort facname: egen d_vlbw_year_na_total = sum(vlbw_mort_na)
				label variable d_vlbw_year_na_total "vlbw mort, admits, inc trans"
				* VLBW year mortality, admits, ex trans
				bysort facname: egen d_vlbw_year_na_ex = sum(vlbw_mort_na_ex)
				label variable d_vlbw_year_na_ex "vlbw mort, admits, ex trans"
			* LBW
				* Total Year Mortality among vlbw, inc non-admits and transfers
				bysort facname: egen d_lbw_year_total = sum(lbw_month_mort)
				label variable d_lbw_year_total "All lbw mort, incl nonadmits and transfers "
				* LBW Year Mortality, Ex Transfers, inc non admits
				bysort facname: egen d_lbw_year_total_ex = sum(lbw_month_mort_ex)
				label variable d_lbw_year_total_ex "all lbw mort, incl nonadmits, ex transfers "
				* LBW year mortality, admits only, inc trans
				bysort facname: egen d_lbw_year_na_total = sum(lbw_mort_na)
				label variable d_lbw_year_na_total "lbw mort, admits, inc trans"
				* LBW year mortality, admits, ex trans
				bysort facname: egen d_lbw_year_na_ex = sum(lbw_mort_na_ex)
				label variable d_lbw_year_na_ex "lbw mort, admits, ex trans"
		/*
		* Year Vars listed
		nicu_year nicu_year_ex lbw_year lbw_year_ex lbw_year_na lbw_year_na_ex vlbw_year vlbw_year_ex vlbw_year_na vlbw_year_na_ex
		d_year_all deaths_year d_vlbw_year_total d_vlbw_year_total_ex d_vlbw_year_na_total d_vlbw_year_na_ex
		d_lbw_year_total d_lbw_year_total_ex d_lbw_year_na_total d_lbw_year_na_ex
		*/

* Count of  LBW, VLBW, deaths by quarter
* Note that quarter total nicu admits are "prev_q"

* LBW patients per quarter, hosp specific:
	bysort facname: gen q1_i = sum(lbw_month) if ncdobmonth <= 3  
	bysort facname: gen q2_i = sum(lbw_month) if ncdobmonth <= 6 & ncdobmonth > 3
	bysort facname: gen q3_i = sum(lbw_month) if ncdobmonth <= 9 & ncdobmonth > 6
	bysort facname: gen q4_i = sum(lbw_month) if ncdobmonth <= 12 & ncdobmonth > 9
	gen lbw_q = 0
	bysort facname: egen q11 = max(q1_i)
	bysort facname: egen q21 = max(q2_i)
	bysort facname: egen q31 = max(q3_i)
	bysort facname: egen q41 = max(q4_i)
	bysort facname: replace lbw_q = q11 if ncdobmonth <= 3
	bysort facname: replace lbw_q = q21 if ncdobmonth <= 6 & ncdobmonth > 3
	bysort facname: replace lbw_q = q31 if ncdobmonth <= 9 & ncdobmonth > 6
	bysort facname: replace lbw_q = q41 if ncdobmonth <= 12 & ncdobmonth > 9
	label variable lbw_q "hosp spec. lbw patients per quarter"
	drop q*_i q11 q21 q31 q41

* VLBW by quarter, hosp specific:	
	bysort facname: gen q1_i = sum(vlbw_month) if ncdobmonth <= 3  
	bysort facname: gen q2_i = sum(vlbw_month) if ncdobmonth <= 6 & ncdobmonth > 3
	bysort facname: gen q3_i = sum(vlbw_month) if ncdobmonth <= 9 & ncdobmonth > 6
	bysort facname: gen q4_i = sum(vlbw_month) if ncdobmonth <= 12 & ncdobmonth > 9
	gen vlbw_q = 0
	bysort facname: egen q11 = max(q1_i)
	bysort facname: egen q21 = max(q2_i)
	bysort facname: egen q31 = max(q3_i)
	bysort facname: egen q41 = max(q4_i)
	bysort facname: replace vlbw_q = q11 if ncdobmonth <= 3
	bysort facname: replace vlbw_q = q21 if ncdobmonth <= 6 & ncdobmonth > 3
	bysort facname: replace vlbw_q = q31 if ncdobmonth <= 9 & ncdobmonth > 6
	bysort facname: replace vlbw_q = q41 if ncdobmonth <= 12 & ncdobmonth > 9
	label variable vlbw_q "hosp spec. vlbw patients per quarter"
	drop q*_i q11 q21 q31 q41
	
* Deaths per quarter, hosp specific:
	bysort facname: gen q1_i = sum(monthly_admit_deaths) if ncdobmonth <= 3  
	bysort facname: gen q2_i = sum(monthly_admit_deaths) if ncdobmonth <= 6 & ncdobmonth > 3
	bysort facname: gen q3_i = sum(monthly_admit_deaths) if ncdobmonth <= 9 & ncdobmonth > 6
	bysort facname: gen q4_i = sum(monthly_admit_deaths) if ncdobmonth <= 12 & ncdobmonth > 9
	gen deaths_q = 0
	bysort facname: egen q11 = max(q1_i)
	bysort facname: egen q21 = max(q2_i)
	bysort facname: egen q31 = max(q3_i)
	bysort facname: egen q41 = max(q4_i)
	bysort facname: replace vlbw_q = q11 if ncdobmonth <= 3
	bysort facname: replace vlbw_q = q21 if ncdobmonth <= 6 & ncdobmonth > 3
	bysort facname: replace vlbw_q = q31 if ncdobmonth <= 9 & ncdobmonth > 6
	bysort facname: replace vlbw_q = q41 if ncdobmonth <= 12 & ncdobmonth > 9
	label variable vlbw_q "hosp spec. deaths ps per quar, nicu ads only"
	drop q*_i q11 q21 q31 q41
	
	
	
