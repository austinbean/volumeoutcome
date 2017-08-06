* Regressions 

* Next steps: Entry: does it happen between 2005 and 2012?  Where?  What are effects on volumes?
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
* Doctors Hospital Tidwell, Harris, 2006 - Upgrade 1 to 3
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


do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"

use "${birthdata}/Births2005-2012wCounts.dta"

* Drop home births.
drop if b_bplace != 1

bysort fid: gen fc = _n
bysort fid: egen brtotal = max(fc)

drop if brtotal < 25

* USING INDIVIDUAL MONTH LAGS *

* Regress on lagged volumes and year
logit neonataldeath i.ncdobyear lag_*_months

* Adding NeoIntensive and SoloIntermediate indicators.
logit neonataldeath i.ncdobyear lag_*_months NeoIntensive SoloIntermediate

* Adding some health states:
logit neonataldeath i.ncdobyear lag_*_months NeoIntensive SoloIntermediate

* Include a facility-specific term if available
* A bunch of facilities have no deaths - these are perfect predictors so they must be dropped.  
logit neonataldeath i.ncdobyear lag_*_months NeoIntensive SoloIntermediate i.fid if facinfo == 1
* The above WORKS and does converge reasonably quickly. 

* Adding insurance status:
* TODO - fix this: range is 1-3 I think.  
* Write i.pay.
logit neonataldeath i.ncdobyear lag_*_months NeoIntensive SoloIntermediate pay i.fid if facinfo == 1
 
* Adding some health states bca_aeno - hypsospa:  
logit neonataldeath i.ncdobyear b_m_educ lag_*_months NeoIntensive SoloIntermediate pay bca_aeno-hypsospa i.fid if facinfo == 1
* The above works as well - does converge and reasonably fast.

* Adding FE's for birth weight w500599 - w12501499
logit neonataldeath i.ncdobyear b_m_educ lag_*_months NeoIntensive SoloIntermediate pay bca_aeno-hypsospa i.fid w500599-w12501499 if facinfo == 1

* Adding multiple birth indicator "multiple"
logit neonataldeath i.ncdobyear b_m_educ lag_*_months NeoIntensive SoloIntermediate pay bca_aeno-hypsospa i.fid w500599-w12501499 multiple if facinfo == 1
* This one works, but takes a while:
estimates save nndweight
* file nndweight.ster saved to save time in the future.  

* Adding race information for mother:
logit neonataldeath i.ncdobyear b_m_educ lag_*_months NeoIntensive SoloIntermediate pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple if facinfo == 1
* saving the output:
estimates save nndwrace


* For level 3 only:
keep if facinfo == 1

* with lagged values of nicu admits, payment status, and firm FE's (works):
logit neonataldeath i.ncdobyear lag_*_months pay i.fid if  NeoIntensive == 1

* adding maternal education and health status (works):
logit neonataldeath i.ncdobyear b_m_educ lag_*_months pay bca_aeno-hypsospa i.fid if NeoIntensive == 1

* adding birth weight indicators (works) :
logit neonataldeath i.ncdobyear b_m_educ lag_*_months pay bca_aeno-hypsospa i.fid w500599-w12501499 if NeoIntensive == 1

* adding race indicators for mother (works ):
logit neonataldeath i.ncdobyear b_m_educ lag_*_months i.pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple if NeoIntensive == 1
estimates save nndlev3full

* W/ quadratic lagged volume terms:
foreach nm of numlist 1(1)6{

gen lag_`nm'_months_sq = lag_`nm'_months^2
label variable lag_`nm'_months_sq " squared lagged `nm' month volume "

}
logit neonataldeath i.ncdobyear b_m_educ lag_*_months lag_*_months_sq i.pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple if NeoIntensive == 1
estimates save "/Users/austinbean/Desktop/Birth2005-2012/nndlev3fullsq"

* USING SUM OF LAGGED VOLUMES, w/ squared terms *
foreach nm of numlist 1(1)6{
gen total_`nm'_months_sq = total_`nm'_months^2
label variable total_`nm'_months_sq " squared total `nm' month previous volume "
}

logit neonataldeath total_2_months total_2_months_sq i.ncdobyear b_m_educ i.pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple if NeoIntensive == 1

logit neonataldeath total_3_months total_3_months_sq i.ncdobyear b_m_educ i.pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple if NeoIntensive == 1

logit neonataldeath total_6_months total_6_months_sq i.ncdobyear b_m_educ i.pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple if NeoIntensive == 1



* For Level 2 only - among those NOT transferred: if bo_tra1 == 0 & bo_trans == 0

* with lagged values of nicu admits, payment status, and firm FE's (works):
logit neonataldeath i.ncdobyear lag_*_months pay i.fid if  SoloIntermediate == 1 & bo_tra1 == 0 & bo_trans == 0

* adding maternal education and health status (works):
logit neonataldeath i.ncdobyear b_m_educ lag_*_months pay bca_aeno-hypsospa i.fid if SoloIntermediate == 1 & bo_tra1 == 0 & bo_trans == 0

* adding birth weight indicators (works ) :
logit neonataldeath i.ncdobyear b_m_educ lag_*_months pay bca_aeno-hypsospa i.fid w500599-w12501499 if SoloIntermediate == 1 & bo_tra1 == 0 & bo_trans == 0

* adding race indicators for mother (works ):
logit neonataldeath i.ncdobyear b_m_educ lag_*_months pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple if SoloIntermediate == 1 & bo_tra1 == 0 & bo_trans == 0
estimates save nndlev2full


* When specializing to those not transferred, this gives magnitudes which are more reasonable: the negative effect in Intensive is much larger

* For level 1 among not transferred:
* These models must be different because the lagged volume indicators do not make sense

* with lagged values of nicu admits, payment status, and firm FE's (works):
logit neonataldeath i.ncdobyear lag_*_months pay i.fid if  SoloIntermediate == 0 & NeoIntensive == 0 & bo_tra1 == 0 & bo_trans == 0

* adding maternal education and health status (works):
logit neonataldeath i.ncdobyear b_m_educ lag_*_months pay bca_aeno-hypsospa i.fid if SoloIntermediate == 0 & NeoIntensive == 0 & bo_tra1 == 0 & bo_trans == 0

* adding birth weight indicators (works ) :
logit neonataldeath i.ncdobyear b_m_educ lag_*_months pay bca_aeno-hypsospa i.fid w500599-w12501499 if SoloIntermediate == 0 & NeoIntensive == 0& bo_tra1 == 0 & bo_trans == 0

* adding race indicators for mother (works ):
logit neonataldeath i.ncdobyear b_m_educ lag_*_months pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple if SoloIntermediate == 0 & NeoIntensive == 0 & bo_tra1 == 0 & bo_trans == 0

 
 
* Create variables at means.

* Travis County:
* browse if b_bcntyc == 227


* Linear Volume Only:
preserve
keep neonataldeath ncdobyear b_m_educ lag_*_months pay bca_aeno-hypsospa fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple
collapse (mean) *
expand = 11
replace lag_1_months = 20*(_n-1)
replace ncdobyear = 2012
replace fid = 0
estimates use "/Users/austinbean/Desktop/Birth2005-2012/nndlev3full.ster"
predict prnnd
twoway line prnnd lag_1_months, xtitle("NICU Volume Previous Month") ytitle("Probability of Death") title("VLBW Mortality as a Function of NICU Volume") graphregion(color(white)) xline(34, lcolor(red)) xline(143, lcolor(red)) text(0.025 34 "Average Travis County" "Monthly NICU Admits", place(e))  text(0.0225 143 "Total Travis County" "Monthly NICU Admits", place(e)) 

* Quadratic volume, lagged one month:
preserve
keep neonataldeath ncdobyear b_m_educ lag_*_months lag_*_months_sq pay bca_aeno-hypsospa fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple
collapse (mean) *
expand = 11
replace lag_1_months = 20*(_n-1)
replace lag_1_months_sq = (20*(_n-1))^2
replace ncdobyear = 2012
replace fid = 0
estimates use "/Users/austinbean/Desktop/Birth2005-2012/nndlev3fullsq.ster"
predict prnnd
twoway line prnnd lag_1_months, xtitle("NICU Volume Previous Month") ytitle("Probability of Death") title("VLBW Mortality as a Function of NICU Volume") graphregion(color(white)) xline(34, lcolor(red)) xline(143, lcolor(red)) text(0.025 34 "Average Travis County" "Monthly NICU Admits", place(e))  text(0.0225 143 "Total Travis County" "Monthly NICU Admits", place(e)) 


* Quadratic volume, including more months:
preserve
keep neonataldeath ncdobyear b_m_educ lag_*_months lag_*_months_sq pay bca_aeno-hypsospa fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple
collapse (mean) *
expand = 11
foreach nm of numlist 1(1)6{
replace lag_`nm'_months = 20*(_n-1)
replace lag_`nm'_months_sq = (20*(_n-1))^2
}
replace ncdobyear = 2012
replace fid = 0
estimates use "/Users/austinbean/Desktop/Birth2005-2012/nndlev3fullsq.ster"
predict prnnd
twoway line prnnd lag_1_months, xtitle("NICU Volume Previous Month") ytitle("Probability of Death") title("VLBW Mortality as a Function of NICU Volume") graphregion(color(white)) xline(34, lcolor(red)) xline(143, lcolor(red)) text(0.025 34 "Average Travis County" "Monthly NICU Admits", place(e))  text(0.0225 143 "Total Travis County" "Monthly NICU Admits", place(e)) 











