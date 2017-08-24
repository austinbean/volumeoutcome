* Regressions 


do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"

use "${birthdata}/Births2005-2012wCounts.dta"

* Drop home births.
drop if b_bplace != 1

bysort fid: gen fc = _n
bysort fid: egen brtotal = max(fc)

drop if brtotal < 25

**** Closest replica of B/P:

logit neonataldeath 










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

* W/ quadratic lagged volume terms, for VLBW only:
keep if b_wt_cgr < 1500
foreach nm of numlist 1(1)6{

gen lag_`nm'_months_sq = lag_`nm'_months^2
label variable lag_`nm'_months_sq " squared lagged `nm' month volume "

}
logit neonataldeath i.ncdobyear b_m_educ lag_*_months lag_*_months_sq i.pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple if NeoIntensive == 1

estimates save "/Users/austinbean/Desktop/Birth2005-2012/nndlev3fullsqvlbw"

* W/ quadratic lagged volume terms in VLBW admits for VLBW admits only:
keep if b_wt_cgr < 1500
foreach nm of numlist 1(1)6{

gen lag_`nm'_vlbw_sq = lag_`nm'_vlbw^2
label variable lag_`nm'_vlbw_sq " squared lagged `nm' month volume "

}
logit neonataldeath i.ncdobyear b_m_educ lag_*_vlbw lag_*_vlbw_sq i.pay bca_aeno-hypsospa i.fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple if NeoIntensive == 1

estimates save "/Users/austinbean/Desktop/Birth2005-2012/nndlev3sqvlbw"



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
foreach nm of numlist 1(1)6{
gen lag_`nm'_months_sq = lag_`nm'_months^2
label variable lag_`nm'_months_sq " squared lagged `nm' month volume "
}
keep neonataldeath ncdobyear b_m_educ lag_*_months lag_*_months_sq pay bca_aeno-hypsospa fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple
collapse (mean) *
expand = 11
replace lag_1_months = 20*(_n-1)
replace lag_1_months_sq = (20*(_n-1))^2
replace ncdobyear = 2012
replace fid = 0
estimates use "/Users/austinbean/Desktop/Birth2005-2012/nndlev3fullsq.ster"
predict prnnd
twoway line prnnd lag_1_months, xtitle("NICU Volume Previous Month") ytitle("Probability of Death") title("Mortality as a Function of NICU Volume") graphregion(color(white)) xline(34, lcolor(red)) xline(143, lcolor(red)) text(0.025 34 "Average Travis County" "Monthly NICU Admits", place(e))  text(0.0225 143 "Total Travis County" "Monthly NICU Admits", place(e)) 

* Quadratic Volume for VLBW infants only.
preserve
foreach nm of numlist 1(1)6{
gen lag_`nm'_months_sq = lag_`nm'_months^2
label variable lag_`nm'_months_sq " squared lagged `nm' month volume "
}
keep if b_wt_cgr < 1500
keep neonataldeath ncdobyear b_m_educ lag_*_vlbw lag_*_vlbw_sq pay bca_aeno-hypsospa fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple
collapse (mean) *
expand = 11
replace lag_1_vlbw = 20*(_n-1)
replace lag_1_vlbw_sq = (20*(_n-1))^2
replace ncdobyear = 2012
replace fid = 0
estimates use "/Users/austinbean/Desktop/Birth2005-2012/nndlev3sqvlbw.ster"
predict prnnd
twoway line prnnd lag_1_vlbw, xtitle("NICU Volume Previous Month") ytitle("Probability of Death") title("VLBW Mortality as a Function of NICU Volume") graphregion(color(white)) xline(34, lcolor(red)) xline(143, lcolor(red)) text(0.055 34 "Average Travis County" "Monthly NICU Admits", place(e))  text(0.055 143 "Total Travis County" "Monthly NICU Admits", place(e)) 




* Quadratic volume, including more months:
preserve
foreach nm of numlist 1(1)6{
replace lag_`nm'_months = 20*(_n-1)
replace lag_`nm'_months_sq = (20*(_n-1))^2
}
keep neonataldeath ncdobyear b_m_educ lag_*_months lag_*_months_sq pay bca_aeno-hypsospa fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple
collapse (mean) *
expand = 11
replace ncdobyear = 2012
replace fid = 0
estimates use "/Users/austinbean/Desktop/Birth2005-2012/nndlev3fullsq.ster"
predict prnnd
twoway line prnnd lag_1_months, xtitle("NICU Volume Previous Month") ytitle("Probability of Death") title("VLBW Mortality as a Function of NICU Volume") graphregion(color(white)) xline(34, lcolor(red)) xline(143, lcolor(red)) text(0.025 34 "Average Travis County" "Monthly NICU Admits", place(e))  text(0.0225 143 "Total Travis County" "Monthly NICU Admits", place(e)) 




* Quadratic volume, lagged one month - expanding each observation separately:
* Computing the mean *by hospital* for the whole population at each volume.
preserve
keep if b_bplace == 1
foreach nm of numlist 1(1)6{
gen lag_`nm'_months_sq = lag_`nm'_months^2
label variable lag_`nm'_months_sq " squared lagged `nm' month volume "
}
keep neonataldeath ncdobyear b_m_educ lag_*_months lag_*_months_sq pay bca_aeno-hypsospa fid w500599-w12501499 m_hisnot m_rwhite m_rblack multiple
gen id = _n
expand = 11
bysort id: replace lag_1_months = 20*(_n-1)
bysort id: replace lag_1_months_sq = (20*(_n-1))^2

estimates use "/Users/austinbean/Desktop/Birth2005-2012/nndlev3fullsq.ster"
predict prnnd

sort fid ncdobyear lag_1_months

collapse (mean) prnnd, by(fid ncdobyear lag_1_months)

* Williamson County - By hospital in year 2012
twoway line prnnd lag_1_months if fid == 4916029 & ncdobyear == 2012 || line prnnd lag_1_months if fid == 4916419 & ncdobyear == 2012 || line prnnd lag_1_months if fid == 4916433 & ncdobyear == 2012 || line prnnd lag_1_months if fid == 4916068 & ncdobyear == 2012 ||  line prnnd lag_1_months if fid == 4916426 & ncdobyear == 2012, xtitle("NICU Volume Previous Month") ytitle("Probability of Death") title("VLBW Mortality as a Function of NICU Volume") graphregion(color(white)) xline(34, lcolor(red)) xline(143, lcolor(red)) text(0.025 34 "Average Travis County" "Monthly NICU Admits", place(e))  text(0.0225 143 "Total Travis County" "Monthly NICU Admits", place(e)) legend(label(1 "Georgetown Hospital - 1") label(2 "Scott and White - 1") label(3 "Seton Med. Center - 3") label(4 "Round Rock Med. Center - 2") label(5 "Cedar Park Regional - 2"))

* Travis County - By hospital in year 2012
*twoway line prnnd lag_1_months if fid == 4530170 & ncdobyear == 2012 || line prnnd lag_1_months if fid == 4530200 & ncdobyear == 2012 || line prnnd lag_1_months if fid == 4536337 & ncdobyear == 2012 || line prnnd lag_1_months if fid == 4536253 & ncdobyear == 2012 ||  line prnnd lag_1_months if fid == 4530190 & ncdobyear == 2012 ||  line prnnd lag_1_months if fid == 4536048 & ncdobyear == 2012, xtitle("NICU Volume Previous Month") ytitle("Probability of Death") title("VLBW Mortality as a Function of NICU Volume") graphregion(color(white)) xline(34, lcolor(red)) xline(143, lcolor(red)) text(0.045 34 "Average Travis County" "Monthly NICU Admits", place(e))  text(0.045 143 "Total Travis County" "Monthly NICU Admits", place(e)) legend(label(1 "Brackenridge") label(2 "Seton Med. Center") label(3 "Seton Northwest") label(4 "North Austin Med. Center") label(5 "St David's") label(6 "South Austin"))

* Travis County WITHOUT NAMES:
* Same as the above with the names removed
twoway line prnnd lag_1_months if fid == 4530170 & ncdobyear == 2012 || line prnnd lag_1_months if fid == 4530200 & ncdobyear == 2012 || line prnnd lag_1_months if fid == 4536337 & ncdobyear == 2012 || line prnnd lag_1_months if fid == 4536253 & ncdobyear == 2012 ||  line prnnd lag_1_months if fid == 4530190 & ncdobyear == 2012 ||  line prnnd lag_1_months if fid == 4536048 & ncdobyear == 2012, xtitle("NICU Volume Previous Month") ytitle("Probability of Death") title("VLBW Mortality as a Function of NICU Volume") graphregion(color(white)) xline(34, lcolor(red)) xline(143, lcolor(red)) text(0.045 34 "Average Travis County" "Monthly NICU Admits", place(e))  text(0.045 143 "Total Travis County" "Monthly NICU Admits", place(e)) legend(label(1 "Hospital 1") label(2 "Hospital 2") label(3 "Hospital 3") label(4 "Hospital 4") label(5 "Hospital 5") label(6 "Hospital 6"))

* Some hospital over several years:
twoway line prnnd lag_1_months if fid == 4530170 & ncdobyear == 2012 || line prnnd lag_1_months if fid == 4530170 & ncdobyear == 2011 || line prnnd lag_1_months if fid == 4530170 & ncdobyear == 2010 || line prnnd lag_1_months if fid == 4530170 & ncdobyear == 2009 ||  line prnnd lag_1_months if fid == 4530170 & ncdobyear == 2008 ||  line prnnd lag_1_months if fid == 4530170 & ncdobyear == 2007 ||  line prnnd lag_1_months if fid == 4530170 & ncdobyear == 2006, xtitle("NICU Volume Previous Month") ytitle("Probability of Death") title("VLBW Mortality as a Function of NICU Volume" "Single Hospital, Travis County, 2006 - 2012") graphregion(color(white)) xline(34, lcolor(red)) xline(143, lcolor(red)) text(0.065 34 "Average Travis County" "Monthly NICU Admits", place(e))  text(0.065 143 "Total Travis County" "Monthly NICU Admits", place(e)) legend(label(1 "2012") label(2 "2011") label(3 "2010") label(4 "2009") label(5 "2008") label(6 "2007") label(7 "2006"))






