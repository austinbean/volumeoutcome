
* Volume Instrument:
* See the second version of this in NICUVolumeInstrument.do
* That file also measures the correlation of the two instruments.  

do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"

* Want somewhat more info about these, like levels. 
* use "/Users/austinbean/Google Drive/Texas Inpatient Discharge/Full Versions/2005 1 Quarter PUDF.dta", clear



* Predict Volume for all quarters:
* This may not get it right, because this is all patients, whereas I want nicu patients only.  
* But this can be done for those patients only, using the other dataset.  (1)4


foreach yr of numlist 2005(1)2008 2010{

foreach qr of numlist 1{

	use "${inpatient}`yr' `qr' Quarter PUDF.dta", clear
	rename *, lower
	capture rename cms_mdc hcfa_mdc
	capture rename hcfa_drg cms_drg
	capture rename patient_age pat_age
	capture rename first_payment_src first_payment_source

* Label Medicaid and Privately Insured

	gen medicaid = 0
	replace medicaid = 1 if first_payment_source == "MC"
	label variable medicaid "0/1 for Medicaid status, taken from FIRST_PAY.. == MC"

	gen private_ins = 0
	replace private_ins = 1 if first_payment_source == "12" | first_payment_source == "14" | first_payment_source == "CI" | first_payment_source == "BL" | first_payment_source == "HM" | first_payment_source == "LI" | first_payment_source == "LM" 
	label variable private_ins "0/1 for privately insured patient, taken from FIRST_PAY..."
* Medicaid and Private Ins Counts
	count
	local tpc = `r(N)'
	count if medicaid == 1
	local tmc = `r(N)'
	count if private_ins == 1
	local tprc = `r(N)'
	count if medicaid == 0 & private_ins == 0
	local toc = `r(N)'
	
	local q`qr'_fm = `tmc'/`tpc'
	local q`qr'_fp = `tprc'/`tpc'
	local q`qr'_fo = `toc'/`tpc'

* Keep pregnancy and delivery related
	keep if hcfa_mdc == 14 | hcfa_mdc == 15
	
* Optional: keep if DRG != 391 (Normal Newborn)
	*drop if cms_drg == 391 | cms_drg == 795
	
* Drop DRG's which are not relevant	
	if  `yr' < 2008 {
		keep if cms_drg == 385 | cms_drg == 386 | cms_drg == 387 | cms_drg == 388 | cms_drg == 389 | cms_drg == 390 | cms_drg == 391
	}

	else if `yr' >=2008 {
	* TODO - fix this.  
		drop if cms_drg  == 780
		drop if cms_drg >= 981
		drop if cms_drg < 765 | cms_drg > 795
	}


* keep only those below 1 year
	destring pat_age, replace force
	keep if pat_age == 0 | pat_age == 1 

* fix zip code var
	destring pat_zip, replace force
	drop if pat_zip == .

* Keep only necessary variables.  
	keep thcic_id pat_zip private_ins medicaid cms_drg


* Add Hospital FID
	gen fid = .
	capture rename thcic_id THCIC_ID
	quietly do "${TXhospital}TX Hospital Code Match.do"

* Add Zip Code Choice Sets - closest 50 hospitals.

	drop if pat_zip < 70000 | pat_zip > 79999
	drop if fid == .

	rename pat_zip PAT_ZIP

	merge m:1 PAT_ZIP using "${birthdata}closest50hospitals.dta"

	drop if _merge != 3

	drop _merge	
	
* Figure out which option chosen.
	
	gen chosenind = .

	forvalues i=1/50{
	di "`i'"
	replace chosenind = `i' if fidcn`i' == fid
	}


* Add Outside Option
* Anyone who didn't choose one of the 50 closest.
	gen fidcn51 = 0
	gen faclatcn51 = 0
	gen faclongcn51 = 0
	gen zipfacdistancecn51 = 0

	replace chosenind = 51 if chosenind == .

* Record distance to chosen facility

	gen chdist = .
	forvalues n = 1/51{
	replace chdist = zipfacdistancecn`n' if chosenind == `n'
	}
	label variable chdist "distance to chosen hospital"
	gen chdist2 = chdist^2
	gen patid = _n

* Track distances traveled:	
	summarize chdist, d
	local q`qr'_dt = `r(mean)'
	local q`qr'_5p = `r(p5)'
	local q`qr'_95p = `r(p95)'
	
	
* Reshape
	reshape long fidcn faclatcn faclongcn zipfacdistancecn, i(patid) j(hs)
	
	
* Record Choice
	gen chosen = 0
	bysort patid: replace chosen = 1 if fid == fidcn
	* This records the choice as the OO
	bysort patid: replace chosen = 1 if chosenind == 51 & fidcn == 0
	drop faclatcn faclongcn


* Some checks - does anyone have two chosen facilities?
* And has everyone chosen a facility?  (After these checks, everyone is correct.)
	bysort patid: gen sm = sum(chosen)
	bysort patid: egen ch1 = max(sm)
	bysort patid fidcn: gen fidid = _n
	drop if fidid > 1
	drop sm ch1 fidid
	* can also check this by doing tab chosen and comparing count of 1's to unique patid - will be equal.

	gen zipfacdistancecn2 = zipfacdistancecn^2

	keep patid fid fidcn PAT_ZIP chosen zipfacdistancecn zipfacdistancecn2 hs private_ins medicaid cms_drg
	
	
* Add more info about these, using FID, I think.  
	rename fid fiddd
	rename fidcn fid
	gen year = `yr'
	merge m:1 fid year using  "${birthdata}AllHospInfo1990-2012.dta"
	drop if _merge == 2
	* remember: cannot drop if fid == 0!
	drop if _merge ==1 & fid != 0
	drop if (ObstetricCare == 0 & NeoIntensive == 0 & SoloIntermediate == 0) & fid != 0
	rename fid fidcn
	rename fiddd fid
	
	
* Fix variables in choice in Outside Option:
	replace NeoIntensive = 0 if fidcn == 0
	replace SoloIntermediate = 0 if fidcn == 0
	replace ObstetricCare = 0 if fidcn == 0
	replace ObstetricsLevel = 0 if fidcn == 0
	

	* Closest variable...
	bysort patid: egen mind = min(zipfacdistancecn) if zipfacdistancecn > 0
	gen closest = 0
	bysort patid: replace closest = 1 if zipfacdistancecn == mind
	
	* check... for duplicates of closest.  There are none.
	bysort patid: gen dd = sum(closest)
	tab closest
	drop dd
	
	* distance*beds/100
	replace TotalBeds = 0 if fidcn == 0
	gen dist_bed = (TotalBeds*zipfacdistancecn)/100

	

* To check the features of the choice model with a 50 firm threshold (as in TX Merge Hospital Choices Variant.do)
/*
	
	clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate closest dist_bed, group(patid)
	clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate closest dist_bed if medicaid == 1, group(patid)
	clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate closest dist_bed if private == 1, group(patid)

	
	w/ a FE for the facility and a 50 firm threshold:
	clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate closest dist_bed i.fidcn, group(patid)
	
*/	
	
	

* Estimating two choice models - first w/out facility FE's, second with.
	label variable zipfacdistancecn "Distance to Chosen"
	label variable zipfacdistancecn2 "Squared Distance to Chosen"
	label variable NeoIntensive "Level 3"
	label variable SoloIntermediate "Level 2"
	*label variable closest "Closest Hospital"
	*label variable dist_bed "Distance x Beds"
	label variable chosen "Hosp. Chosen"
	label variable ObstetricsLevel "Obstetrics Level"
	
* merge information about the hospital volume quantities of patients treated.  Merge on other firm fid.
	drop _merge
	gen quarter = `qr'
	gen ncdobyear = year
	rename fid fidddd
	rename fidcn fid
	merge m:1 fid ncdobyear quarter using "${birthdata}QuarterlyFacCount.dta", gen(fcount)
	rename fid fidcn
	rename fiddd fid
	* BE CAREFUL with the outside option here!  Don't drop it by accident.  There are 33 unique facilities without information.  Plus one outside option 
	gen ddrp  = 1 if fcount != 3 & fidcn != 0
	drop if ddrp == 1	
	drop fcount ddrp

	eststo c_lg_`yr'_`qr': clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.ObstetricsLevel, group(patid)
	summarize patid, d
	estadd local pN "`r(max)'"

	*mat a1 = e(b)
	*estimates save "${birthdata}`yr' `qr' hospchoicedistanceonly", replace

*	predict pr1
	
* Set values used in regressions below to zero for the outside option	
	local vl1 zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate qr_tot ObstetricsLevel
	foreach v1 of local vl1{
		replace `v1' = 0 if fidcn == 0
	}
	
	* Distance, Squared, Facility, Quarterly Total
	eststo c_lg_`yr'_`qr': clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate qr_tot , group(patid)
	* Distance, Squared, Facility, Quarterly Total, Obstetrics Level
	eststo c_lg_`yr'_`qr': clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate qr_tot i.ObstetricsLevel, group(patid)
	* Distance, Squared, Facility, Quarterly Total, Obstetrics Level, Facility FE
	eststo c_lg_`yr'_`qr': clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate qr_tot i.ObstetricsLevel i.fid, group(patid)
	
	eststo cl_`yr'`qr'_pvfe: clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate qr_tot closest dist_bed i.fidcn, group(patid)

	* no fid FE's
	clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate qr_tot closest dist_bed , group(patid)

	* small model with fe's
	clogit chosen zipfacdistancecn NeoIntensive SoloIntermediate qr_tot i.fidcn, group(patid)

	
	clogit chosen i.cms_drg#NeoIntensive, group(patid)
	
	* DRG interactions - DOES NOT CONVERGE, 
	clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate qr_tot i.cms_drg#NeoIntensive, group(patid)
	
	* Some ASClogits with interactions for characteristics...zipfacdistancecn2 qr_tot
	asclogit chosen zipfacdistancecn NeoIntensive SoloIntermediate qr_tot, case(patid) alternatives(hs)
	
* Compute Shares and save
	bysort fidcn: gen shr = sum(pr1)
	bysort fidcn: egen exp_share = max(shr)
	keep fidcn exp_share
	duplicates drop fidcn, force
	rename fidcn fid
	gen mnthly_share = exp_share/3
	gen yr = `yr'
	gen qr = `qr'
	save "${birthdata}`yr'_`qr'_fidshares.dta", replace
	
	
	
}

use "${birthdata}`yr'_1_fidshares.dta", clear

append using "${birthdata}`yr'_2_fidshares.dta"
append using "${birthdata}`yr'_3_fidshares.dta"
append using "${birthdata}`yr'_4_fidshares.dta"

save "${birthdata}`yr'_fidshares.dta", replace

noi di "`yr' fraction medicaid: "
noi di 0.25*(`q1_fm')+0.25*(`q2_fm')+0.25*(`q3_fm')+0.25*(`q4_fm')

noi di "`yr' fraction private: "
noi di 0.25*(`q1_fp')+0.25*(`q2_fp')+0.25*(`q3_fp')+0.25*(`q4_fp')

noi di "`yr' fraction other: "
noi di 0.25*(`q1_fo')+0.25*(`q2_fo')+0.25*(`q3_fo')+0.25*(`q4_fo')

noi di "`yr' distance traveled: "
noi di 0.25*(`q1_dt')+0.25*(`q2_dt')+0.25*(`q3_dt')+0.25*(`q4_dt')

noi di "`yr' distance traveled 5th percentile: "
noi di 0.25*(`q1_5p')+0.25*(`q2_5p')+0.25*(`q3_5p')+0.25*(`q4_5p')

noi di "`yr' distance traveled: "
noi di 0.25*(`q1_95p')+0.25*(`q2_95p')+0.25*(`q3_95p')+0.25*(`q4_95p')

}



esttab c_lg_2005_1 c_lg_2006_1 c_lg_2007_1 c_lg_2008_4 c_lg_2010_1 using "/Users/austinbean/Desktop/Birth2005-2012/instrumentschoice.tex",  label replace mtitle("Q1 2005" "Q1 2006" "Q1 2007" "Q1 2008" "Q1 2010") style(tex) stats(pN) cells(b se) legend eqlabels(none) collabels(none)

use "${birthdata}2005_fidshares.dta", clear

foreach yr of numlist 2006(1)2008 2010{

append using "${birthdata}`yr'_fidshares.dta"

}

rename yr ncdobyear

save "${birthdata}allyearfidshares.dta", replace



/*

*gen 2009... 
use "${birthdata}allyearfidshares.dta", clear
sort fid ncdobyear
expand 2 if ncdobyear == 2008, gen(ttt)
replace ncdobyear = 2009 if ttt == 1
sort fid  qr ncdobyear
bysort fid qr (ncdobyear) : replace exp_share = 0.5*(exp_share + exp_share[_n+1]) if ttt == 1
drop ttt
*/








/*


* For Q1 2005:
* TODO - figure out why there is a 0 and a 51 separately.  Otherwise this is ok.  
sort patid hs
bysort patid: gen cc = chosen*hs
bysort patid: egen chc = max(cc)
bysort patid: replace chc = 51 if chc == 0
duplicates drop patid, force
drop cc
sort chc
bysort chc: gen cnc = _n
bysort chc: egen chcn = max(cnc)
gen to = _N
gen fr = chcn/to
keep chc fr
duplicates drop fr, force

sort chc 
gen cum = sum(fr)

twoway line cum chc if chc<51, graphregion(color(white)) title("Fraction Choosing N-th Closest or Closer Hospital") subtitle("Among 50 Closest Options") yscale(range(0, 1)) xtitle("N Closest Choices") ytitle("CDF") note("2005 Q 1 Data")




* 50 hospital threshold for everyone:

clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate closest dist_bed i.fidcn, group(patid)



Conditional (fixed-effects) logistic regression

                                                Number of obs     =  2,511,211
                                                LR chi2(252)      =  253404.79
                                                Prob > chi2       =     0.0000
Log likelihood = -148966.45                     Pseudo R2         =     0.4596

-----------------------------------------------------------------------------------
           chosen |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
 zipfacdistancecn |  -.1749183   .0009882  -177.00   0.000    -.1768553   -.1729814
zipfacdistancecn2 |   .0004922   4.53e-06   108.72   0.000     .0004834    .0005011
     NeoIntensive |   6.823559   .1709593    39.91   0.000     6.488485    7.158633
 SoloIntermediate |   5.343246   .1154624    46.28   0.000     5.116944    5.569548
          closest |   .3430094   .0115898    29.60   0.000     .3202939     .365725
         dist_bed |    .001187   .0001481     8.02   0.000     .0008967    .0014772
                  |
            fidcn |
           16122  |    5.09948   .1386555    36.78   0.000      4.82772     5.37124
           30105  |  -23.61445   22463.82    -0.00   0.999    -44051.89    44004.66
           52390  |   3.993691   .1584074    25.21   0.000     3.683218    4.304164
           52395  |  -1.164042   .1889804    -6.16   0.000    -1.534436   -.7936468
          132096  |    2.84842   .2422485    11.76   0.000     2.373622    3.323219
          172577  |   -21.6126   28289.66    -0.00   0.999    -55468.33     55425.1
          213280  |   3.251378   .2190797    14.84   0.000      2.82199    3.680766
          233210  |  -23.74291   80352.21    -0.00   1.000    -157511.2    157463.7
          250295  |   3.669227   .2179098    16.84   0.000     3.242131    4.096322
          273410  |   5.326098   .1314017    40.53   0.000     5.068555     5.58364
          273420  |  -.2328229   .1995767    -1.17   0.243    -.6239861    .1583403
          276050  |   4.239232   .1281283    33.09   0.000     3.988105    4.490359
          293005  |  -1.459821   .2051696    -7.12   0.000    -1.861946   -1.057696
          293010  |  -1.428986   .2045833    -6.98   0.000    -1.829962    -1.02801
          293015  |   4.065555   .1474188    27.58   0.000     3.776619     4.35449
          293070  |   3.931819   .1496419    26.27   0.000     3.638526    4.225112
          293105  |   -1.03357   .2035767    -5.08   0.000    -1.432573   -.6345671
          293120  |   5.521754   .1209955    45.64   0.000     5.284608    5.758901
          293122  |  -.1670783   .2030956    -0.82   0.411    -.5651383    .2309817
          296002  |  -1.009941   .2035345    -4.96   0.000    -1.408861    -.611021
          296025  |  -1.265266   .2041361    -6.20   0.000    -1.665365   -.8651666
          296191  |   5.702233   .1224955    46.55   0.000     5.462146    5.942319
          350650  |  -20.96154   25862.56    -0.00   0.999    -50710.64    50668.72
          373510  |  -33.61105   111877.6    -0.00   1.000    -219309.7    219242.5
          376245  |  -29.80683   450454.9    -0.00   1.000    -882905.3    882845.6
          390111  |   1.262145   .1380043     9.15   0.000     .9916615    1.532629
          391525  |   1.852946   .1142012    16.23   0.000     1.629116    2.076776
          410490  |  -2.491933   .2067789   -12.05   0.000    -2.897212   -2.086654
          410500  |   5.219602    .114053    45.76   0.000     4.996062    5.443141
          430050  |   8.913357   .3133774    28.44   0.000     8.299148    9.527565
          490465  |   6.331207   .1984932    31.90   0.000     5.942167    6.720246
          572853  |   -25.4862   56877.98    -0.00   1.000    -111504.3    111453.3
          610460  |   .3485968   .2592804     1.34   0.179    -.1595835     .856777
          611790  |   .4257963   .2509052     1.70   0.090    -.0659689    .9175615
          615100  |   .5459224   .2579156     2.12   0.034     .0404171    1.051428
          616303  |   3.871779   .3175583    12.19   0.000     3.249376    4.494182
          616318  |   6.961355   .2236286    31.13   0.000     6.523051    7.399659
          672285  |  -24.91527   105681.9    -0.00   1.000    -207157.7    207107.8
          691167  |  -19.28464   17022.24    -0.00   0.999    -33382.26    33343.69
          732070  |   3.329018   .1673664    19.89   0.000     3.000986     3.65705
          750595  |  -22.81629    77154.5    -0.00   1.000    -151242.9    151197.2
          830660  |  -20.74994   67715.34    -0.00   1.000    -132740.4    132698.9
          852480  |   2.908726   .0990391    29.37   0.000     2.714613    3.102839
          855094  |  -2.381469   .1823149   -13.06   0.000      -2.7388   -2.024139
          856181  |   -2.34288    .182392   -12.85   0.000    -2.700362   -1.985398
          856301  |   3.261257    .089538    36.42   0.000     3.085766    3.436749
          856354  |  -4.927179   .2171178   -22.69   0.000    -5.352722   -4.501636
          891170  |  -22.25729   29366.98    -0.00   0.999    -57580.49    57535.97
          895105  |  -23.22519    39095.8    -0.00   1.000    -76649.58    76603.13
          912625  |  -.5323368   .1350131    -3.94   0.000    -.7969576   -.2677161
          939090  |  -22.12256   36357.82    -0.00   1.000    -71282.15     71237.9
          971550  |  -21.52451    18291.5    -0.00   0.999     -35872.2    35829.15
          972574  |  -22.12438   39618.15    -0.00   1.000    -77672.27    77628.02
         1130900  |  -2.303473   .1824637   -12.62   0.000    -2.661095   -1.945851
         1130950  |  -.8693249   .1802018    -4.82   0.000    -1.222514   -.5161359
         1131020  |  -2.345678   .1820245   -12.89   0.000    -2.702439   -1.988916
         1131021  |   2.813171   .1024056    27.47   0.000      2.61246    3.013882
         1131050  |  -1.964999   .1812853   -10.84   0.000    -2.320312   -1.609686
         1131616  |  -3.283589    .186099   -17.64   0.000    -3.648336   -2.918841
         1132055  |  -1.467986   .1343561   -10.93   0.000    -1.731319   -1.204653
         1132528  |   2.777042    .101432    27.38   0.000     2.578239    2.975845
         1135009  |   -2.63405   .1829255   -14.40   0.000    -2.992578   -2.275523
         1135113  |  -1.269501   .1337141    -9.49   0.000    -1.531575   -1.007426
         1136005  |   -2.64646   .1487318   -17.79   0.000    -2.937968   -2.354951
         1136007  |  -4.044577   .1946885   -20.77   0.000    -4.426159   -3.662994
         1136020  |   4.029598   .0762597    52.84   0.000     3.880132    4.179064
         1136268  |  -3.180759   .1869174   -17.02   0.000    -3.547111   -2.814408
         1136366  |  -3.103863   .1858308   -16.70   0.000    -3.468084   -2.739641
         1152195  |  -21.71368   29708.55    -0.00   0.999    -58249.41    58205.98
         1171820  |  -16.34744   6084.873    -0.00   0.998    -11942.48    11909.78
         1215085  |   3.951787   .0890843    44.36   0.000     3.777185    4.126389
         1215126  |  -2.860838    .185388   -15.43   0.000    -3.224192   -2.497484
         1216088  |  -2.857997   .1847919   -15.47   0.000    -3.220182   -2.495811
         1216116  |   4.123264   .0918273    44.90   0.000     3.943286    4.303242
         1230865  |  -24.95187   62026.41    -0.00   1.000    -121594.5    121544.6
         1270573  |  -22.70498   67493.41    -0.00   1.000    -132307.4    132261.9
         1331183  |  -22.75572   29222.37    -0.00   0.999    -57297.55    57252.03
         1352660  |    1.57587   .2609752     6.04   0.000     1.064368    2.087372
         1355097  |   2.123618   .2595008     8.18   0.000     1.615006     2.63223
         1391330  |   2.642512   .1504189    17.57   0.000     2.347696    2.937328
         1393700  |   3.610992   .1056874    34.17   0.000     3.403849    3.818136
         1411240  |   5.022857   .4474306    11.23   0.000     4.145909    5.899805
         1411290  |   5.116425   .4474687    11.43   0.000     4.239402    5.993448
         1411315  |   4.243074    .449575     9.44   0.000     3.361923    5.124225
         1415013  |   3.936433   .4485698     8.78   0.000     3.057252    4.815614
         1415121  |   4.330083   .4488315     9.65   0.000      3.45039    5.209777
         1433330  |   2.871707   .2164916    13.26   0.000     2.447391    3.296023
         1492180  |  -21.59183   28466.58    -0.00   0.999    -55815.06    55771.87
         1532323  |  -15.98865   4996.164    -0.00   0.997    -9808.289    9776.312
         1572912  |  -2.986007   .1364096   -21.89   0.000    -3.253365   -2.718649
         1576038  |  -3.164582   .1334775   -23.71   0.000    -3.426193   -2.902971
         1576070  |  -21.45837   7732.459    -0.00   0.998     -15176.8    15133.88
         1576276  |  -3.359425   .1330194   -25.26   0.000    -3.620138   -3.098712
         1653200  |  -21.93071   44086.95    -0.00   1.000    -86430.77    86386.91
         1671615  |   -1.38582   .1847918    -7.50   0.000    -1.748005   -1.023635
         1672185  |   2.421071   .1027693    23.56   0.000     2.219647    2.622495
         1711511  |  -19.87596   31750.27    -0.00   1.000    -62249.25     62209.5
         1776027  |  -21.83408   25249.71    -0.00   0.999    -49510.36    49466.69
         1792735  |  -21.28292   6413.651    -0.00   0.997    -12591.81    12549.24
         1811145  |   3.408327   .1547403    22.03   0.000     3.105042    3.711613
         1813240  |   4.109125   .1287821    31.91   0.000     3.856717    4.361533
         1832150  |   3.678777   .1597033    23.04   0.000     3.365765     3.99179
         1832327  |  -1.550015   .2085189    -7.43   0.000    -1.958704   -1.141325
         1836041  |   4.851006   .1322005    36.69   0.000     4.591897    5.110114
         1873189  |   4.184282   .1509957    27.71   0.000     3.888336    4.480228
         1892840  |   5.241059   .2421794    21.64   0.000     4.766396    5.715722
         2010243  |   2.686934   .0714008    37.63   0.000     2.546991    2.826877
         2011890  |  -3.637395   .1760664   -20.66   0.000    -3.982479   -3.292311
         2011895  |   2.455144   .0605352    40.56   0.000     2.336497    2.573791
         2011960  |  -3.828946   .1376198   -27.82   0.000    -4.098676   -3.559216
         2011970  |  -4.121732   .1770903   -23.27   0.000    -4.468823   -3.774642
         2011985  |  -3.585287   .1351568   -26.53   0.000     -3.85019   -3.320385
         2012000  |  -3.761595   .1759378   -21.38   0.000    -4.106427   -3.416763
         2012005  |   2.384959   .0614093    38.84   0.000     2.264599    2.505319
         2012007  |  -24.74366   1091.661    -0.02   0.982     -2164.36    2114.873
         2012018  |   -5.12712   .1843997   -27.80   0.000    -5.488537   -4.765704
         2012025  |   -3.26173   .1280995   -25.46   0.000      -3.5128    -3.01066
         2012778  |  -4.303269   .1790979   -24.03   0.000    -4.654295   -3.952244
         2013716  |  -3.463036   .1779647   -19.46   0.000    -3.811841   -3.114232
         2015022  |  -4.295303   .1776314   -24.18   0.000    -4.643454   -3.947152
         2015024  |  -3.484351   .1758595   -19.81   0.000     -3.82903   -3.139673
         2015026  |  -3.195829   .1327645   -24.07   0.000    -3.456043   -2.935616
         2015120  |   -3.55215   .1333081   -26.65   0.000    -3.813429   -3.290871
         2015130  |  -3.087161   .1745616   -17.69   0.000    -3.429295   -2.745027
         2015135  |    1.39653   .0918807    15.20   0.000     1.216447    1.576613
         2015140  |   -3.89803   .1761549   -22.13   0.000    -4.243287   -3.552772
         2016009  |  -4.336326   .1796989   -24.13   0.000    -4.688529   -3.984123
         2016016  |  -3.535428   .1456202   -24.28   0.000    -3.820838   -3.250017
         2016065  |  -4.915946   .1816388   -27.06   0.000    -5.271951    -4.55994
         2016290  |   1.582015   .0798245    19.82   0.000     1.425562    1.738468
         2016302  |  -3.042358    .127479   -23.87   0.000    -3.292212   -2.792504
         2019310  |  -21.31876   5987.248    -0.00   0.997    -11756.11    11713.47
         2050890  |  -23.86711   100354.9    -0.00   1.000    -196715.9    196668.2
         2093151  |   5.015721   .1266335    39.61   0.000     4.767524    5.263918
         2130125  |    4.28534   .1234582    34.71   0.000     4.043366    4.527313
         2151200  |   3.035044   .3094582     9.81   0.000     2.428517    3.641571
         2152561  |   -.560025   .2424806    -2.31   0.021    -1.035278   -.0847718
         2153723  |   .9062861   .2411075     3.76   0.000      .433724    1.378848
         2156047  |   .6923406   .2396195     2.89   0.004      .222695    1.161986
         2156258  |  -22.30945   2575.745    -0.01   0.993    -5070.678    5026.059
         2171840  |   3.491598    .172104    20.29   0.000      3.15428    3.828916
         2192250  |   5.085827   .2514388    20.23   0.000     4.593016    5.578638
         2219225  |   2.690264   .1713795    15.70   0.000     2.354366    3.026162
         2233345  |  -27.00466   16778.97    -0.00   0.999    -32913.18    32859.17
         2250843  |   2.549693   .2364044    10.79   0.000     2.086349    3.013038
         2275088  |   2.697362   .2557251    10.55   0.000      2.19615    3.198574
         2311740  |  -1.620179   .1616622   -10.02   0.000    -1.937031   -1.303327
         2330400  |  -20.36418   16384.68    -0.00   0.999    -32133.75    32093.02
         2412084  |   2.377026   .1870817    12.71   0.000     2.010353      2.7437
         2450244  |  -3.292122   .2016206   -16.33   0.000    -3.687291   -2.896953
         2450258  |  -3.131896   .1993564   -15.71   0.000    -3.522628   -2.741165
         2452849  |  -4.063718   .2155249   -18.85   0.000    -4.486139   -3.641297
         2452850  |   1.907081   .1602997    11.90   0.000       1.5929    2.221263
         2490040  |   3.753243   .1938287    19.36   0.000     3.373346     4.13314
         2510635  |   3.156437   .1300313    24.27   0.000      2.90158    3.411293
         2576008  |   2.219166   .1470908    15.09   0.000     1.930873    2.507459
         2576026  |    2.17464   .1514559    14.36   0.000     1.877792    2.471488
         2652135  |  -2.090008   .3100591    -6.74   0.000    -2.697712   -1.482303
         2732160  |   3.807365   .2111263    18.03   0.000     3.393565    4.221165
         2772760  |  -22.27904   35270.36    -0.00   0.999    -69150.91    69106.35
         2796032  |  -20.39416   27281.95    -0.00   0.999    -53492.03    53451.24
         2853800  |   1.006842    .264831     3.80   0.000     .4877827    1.525901
         2910645  |   1.760201   .1159417    15.18   0.000     1.532959    1.987442
         2992318  |  -20.91609   30765.79    -0.00   0.999    -60320.76    60278.93
         3032360  |   7.085335   .1904438    37.20   0.000     6.712072    7.458598
         3032377  |   5.170342    .214117    24.15   0.000      4.75068    5.590003
         3036011  |   .3529358   .2520101     1.40   0.161    -.1409949    .8468665
         3053364  |  -19.64096   25876.04    -0.00   0.999    -50735.75    50696.46
         3093650  |  -.8821721   .2037289    -4.33   0.000    -1.281473   -.4828708
         3093660  |   5.369696   .1250469    42.94   0.000     5.124609    5.614783
         3179520  |  -19.28075   31136.61    -0.00   1.000    -61045.92    61007.36
         3210235  |   1.561962   .1650439     9.46   0.000     1.238482    1.885443
         3231175  |  -1.945733    .229457    -8.48   0.000    -2.395461   -1.496006
         3251853  |  -20.00295   16824.63    -0.00   0.999    -32995.67    32955.67
         3292535  |   1.111085   .2616654     4.25   0.000     .5982298    1.623939
         3350680  |  -16.30927   6344.375    -0.00   0.998    -12451.06    12418.44
         3372635  |   -23.3338   67280.31    -0.00   1.000    -131890.3    131843.7
         3390720  |  -4.722018   .1883059   -25.08   0.000     -5.09109   -4.352945
         3396057  |  -2.043335   .1255694   -16.27   0.000    -2.289447   -1.797224
         3396189  |  -5.431862   .1917165   -28.33   0.000    -5.807619   -5.056104
         3396327  |  -4.072187   .1813956   -22.45   0.000    -4.427716   -3.716658
         3411169  |   4.259719     .22107    19.27   0.000      3.82643    4.693008
         3472582  |    5.02244   .1511572    33.23   0.000     4.726177    5.318703
         3475093  |   4.427182   .1681581    26.33   0.000     4.097598    4.756766
         3490795  |   2.529167   .1649152    15.34   0.000     2.205939    2.852395
         3535132  |   -20.8302   33093.69    -0.00   0.999    -64883.27    64841.61
         3550740  |  -.8944796   .2339538    -3.82   0.000    -1.353021   -.4359387
         3556218  |   .4850554   .2283159     2.12   0.034     .0375644    .9325464
         3572814  |  -22.01021   35314.01    -0.00   1.000    -69236.19    69192.17
         3612695  |   2.118453    .166731    12.71   0.000     1.791666     2.44524
         3632567  |   -22.1006   18283.87    -0.00   0.999    -35857.82    35813.62
         3650574  |   1.388961   .2689936     5.16   0.000     .8617433    1.916179
         3673715  |   3.280856    .131454    24.96   0.000     3.023211    3.538501
         3711385  |  -23.38404   81304.03    -0.00   1.000    -159376.4    159329.6
         3732315  |    1.74134   .1687946    10.32   0.000     1.410508    2.072171
         3750063  |   2.123825   .2185196     9.72   0.000     1.695534    2.552115
         3750070  |   1.733922   .2198847     7.89   0.000     1.302956    2.164888
         3896014  |  -23.10432   58603.98    -0.00   1.000    -114884.8    114838.6
         3976115  |   3.271951   .0924815    35.38   0.000     3.090691    3.453212
         4011810  |   3.917981   .1683565    23.27   0.000     3.588008    4.247954
         4153291  |   -17.2214   5008.243    -0.00   0.997    -9833.198    9798.755
         4190582  |   1.649226   .2934424     5.62   0.000     1.074089    2.224362
         4233565  |  -1.588052   .1715151    -9.26   0.000    -1.924215   -1.251888
         4233570  |  -.0748305   .1556504    -0.48   0.631    -.3798996    .2302387
         4275095  |   4.737942   .2104478    22.51   0.000     4.325472    5.150412
         4290428  |  -23.40046   46777.94    -0.00   1.000    -91706.48    91659.68
         4390108  |  -2.421189   .1827238   -13.25   0.000    -2.779321   -2.063057
         4390285  |  -2.935998   .1855729   -15.82   0.000    -3.299714   -2.572282
         4391390  |  -2.325777   .1842946   -12.62   0.000    -2.686988   -1.964566
         4391437  |   3.165241   .0941587    33.62   0.000     2.980693    3.349789
         4391440  |  -1.503398   .1815823    -8.28   0.000    -1.859293   -1.147504
         4391483  |  -1.594306    .181582    -8.78   0.000      -1.9502   -1.238411
         4391739  |  -2.123154   .1823023   -11.65   0.000     -2.48046   -1.765848
         4395139  |  -2.469621   .1828132   -13.51   0.000    -2.827929   -2.111314
         4395142  |   3.987025   .0884625    45.07   0.000     3.813641    4.160408
         4396125  |  -2.391983    .185942   -12.86   0.000    -2.756423   -2.027544
         4410020  |   .9957898    .217881     4.57   0.000     .5687509    1.422829
         4410034  |   1.223884   .2471836     4.95   0.000      .739413    1.708355
         4450450  |  -20.67053   30199.57    -0.00   0.999    -59210.73    59169.39
         4492573  |  -27.85427   14111.92    -0.00   0.998    -27686.71       27631
         4513000  |   2.718273   .2490685    10.91   0.000     2.230107    3.206438
         4516013  |   3.182211   .2458673    12.94   0.000      2.70032    3.664102
         4530170  |  -1.311481   .2010126    -6.52   0.000    -1.705458   -.9175031
         4530190  |  -.1103853   .1962274    -0.56   0.574    -.4949839    .2742134
         4530200  |  -.2385263   .1964748    -1.21   0.225    -.6236099    .1465573
         4536048  |  -.2447586   .0847274    -2.89   0.004    -.4108212    -.078696
         4536253  |  -.7758346   .1977941    -3.92   0.000    -1.163504   -.3881653
         4536337  |    5.72346   .1127489    50.76   0.000     5.502476    5.944444
         4536338  |  -.6963029   .1041245    -6.69   0.000    -.9003831   -.4922226
         4633580  |  -26.50148   25134.25    -0.00   0.999    -49288.72    49235.71
         4651139  |  -.4842289   .2879346    -1.68   0.093     -1.04857    .0801126
         4693625  |  -28.30367   7769.415    -0.00   0.997    -15256.08    15199.47
         4693630  |  -4.664747   .2166287   -21.53   0.000    -5.089332   -4.240163
         4716028  |   2.556235    .115091    22.21   0.000     2.330661    2.781809
         4752564  |  -19.40175   23457.86    -0.00   0.999    -45995.97    45957.16
         4770430  |  -21.95721   17999.52    -0.00   0.999    -35300.37    35256.46
         4792220  |   .4682486   .0568632     8.23   0.000     .3567987    .5796985
         4792230  |          0  (omitted)
         4813735  |    2.87792   .1322586    21.76   0.000     2.618698    3.137142
         4833220  |  -22.30731   25562.33    -0.00   0.999    -50123.55    50078.94
         4853790  |   1.530082   .2574991     5.94   0.000     1.025393    2.034771
         4916029  |   5.227597   .1230836    42.47   0.000     4.986357    5.468836
         4916068  |          0  (omitted)
         4975091  |  -20.07818   15633.98    -0.00   0.999    -30662.12    30621.96
         4992851  |   1.606674    .252953     6.35   0.000     1.110895    2.102453
         5011163  |  -22.67387   62231.19    -0.00   1.000    -121993.6    121948.2
         5032670  |  -23.32591   125045.2    -0.00   1.000    -245107.3    245060.7
         5035018  |  -23.67801   75011.58    -0.00   1.000    -147043.7    146996.3
-----------------------------------------------------------------------------------




clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate closest dist_bed i.fidcn if medicaid == 1, group(patid)

Conditional (fixed-effects) logistic regression

                                                Number of obs     =  1,180,094
                                                LR chi2(252)      =  145823.13
                                                Prob > chi2       =     0.0000
Log likelihood = -57861.363                     Pseudo R2         =     0.5575

-----------------------------------------------------------------------------------
           chosen |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
 zipfacdistancecn |  -.1626615   .0014348  -113.37   0.000    -.1654736   -.1598495
zipfacdistancecn2 |   .0004458   6.95e-06    64.15   0.000     .0004322    .0004595
     NeoIntensive |   6.207176   .1918416    32.36   0.000     5.831173    6.583179
 SoloIntermediate |   4.578513   .1863833    24.57   0.000     4.213208    4.943818
          closest |   .4414162   .0176844    24.96   0.000     .4067555    .4760769
         dist_bed |    .001814   .0002268     8.00   0.000     .0013695    .0022586
                  |
            fidcn |
           16122  |   5.199635   .1661336    31.30   0.000     4.874019    5.525251
           30105  |  -20.84759   10125.99    -0.00   0.998    -19867.42    19825.73
           52390  |   3.683951    .189712    19.42   0.000     3.312122     4.05578
           52395  |  -.7918403   .2565693    -3.09   0.002    -1.294707   -.2889736
          132096  |   2.605602   .2708032     9.62   0.000     2.074837    3.136367
          172577  |   -19.3352   9639.418    -0.00   0.998    -18912.25    18873.58
          213280  |   3.367162   .2739591    12.29   0.000     2.830212    3.904112
          233210  |  -21.51784   28328.83    -0.00   0.999    -55545.01    55501.98
          250295  |   3.416708   .2373546    14.39   0.000     2.951502    3.881915
          273410  |   4.479239   .1770301    25.30   0.000     4.132266    4.826211
          273420  |  -.5578338   .2343031    -2.38   0.017    -1.017059    -.098608
          276050  |   3.923728   .1664123    23.58   0.000     3.597566     4.24989
          293005  |   -1.56697   .2372979    -6.60   0.000    -2.032065   -1.101874
          293010  |  -2.423482   .2453696    -9.88   0.000    -2.904398   -1.942567
          293015  |   3.081344    .184702    16.68   0.000     2.719335    3.443354
          293070  |   .0934875   .5198367     0.18   0.857    -.9253738    1.112349
          293105  |  -1.217473    .236435    -5.15   0.000    -1.680877    -.754069
          293120  |   4.717353   .1504387    31.36   0.000     4.422499    5.012207
          293122  |  -1.063613   .2384263    -4.46   0.000     -1.53092   -.5963057
          296002  |  -1.549321   .2385758    -6.49   0.000    -2.016921   -1.081721
          296025  |  -1.356816   .2356912    -5.76   0.000    -1.818762   -.8948694
          296191  |   3.995833   .1745697    22.89   0.000     3.653683    4.337984
          350650  |  -19.02488   11106.45    -0.00   0.999    -21787.27    21749.22
          373510  |  -30.94519   53747.33    -0.00   1.000    -105373.8    105311.9
          376245  |   -27.0182   157701.6    -0.00   1.000    -309116.4    309062.4
          390111  |   .3528805   .2390084     1.48   0.140    -.1155674    .8213283
          391525  |   1.940683   .1428404    13.59   0.000     1.660721    2.220645
          410490  |  -2.321566   .2424586    -9.58   0.000    -2.796776   -1.846356
          410500  |   4.442563    .148563    29.90   0.000     4.151385    4.733742
          430050  |   9.408057   .3914186    24.04   0.000     8.640891    10.17522
          490465  |   6.325715   .2220815    28.48   0.000     5.890444    6.760987
          572853  |  -23.19583   20196.68    -0.00   0.999    -39607.96    39561.57
          610460  |   .1079254   .2688454     0.40   0.688    -.4190019    .6348528
          611790  |   .1427153   .2602292     0.55   0.583    -.3673246    .6527551
          615100  |   .3179288   .2672217     1.19   0.234     -.205816    .8416736
          616303  |   .9659644   .7426888     1.30   0.193    -.4896788    2.421608
          616318  |   6.157677   .2264177    27.20   0.000     5.713907    6.601448
          672285  |  -21.36351    23410.9    -0.00   0.999    -45905.88    45863.15
          691167  |  -18.00552    8767.58    -0.00   0.998    -17202.15    17166.13
          732070  |   4.332655   .1891565    22.91   0.000     3.961915    4.703395
          750595  |  -20.37623   30584.47    -0.00   0.999    -59964.83    59924.08
          830660  |  -18.75819   22981.19    -0.00   0.999    -45061.06    45023.55
          852480  |    1.14887   .2025596     5.67   0.000     .7518605     1.54588
          855094  |   -5.46625    .275229   -19.86   0.000    -6.005689   -4.926811
          856181  |  -6.264637   .3633629   -17.24   0.000    -6.976815   -5.552459
          856301  |  -2.180734   1.003491    -2.17   0.030     -4.14754   -.2139274
          856354  |  -6.581039   .4562147   -14.43   0.000    -7.475204   -5.686875
          891170  |  -20.28049   11678.09    -0.00   0.999    -22908.91    22868.35
          895105  |  -20.99599   19903.41    -0.00   0.999    -39030.96    38988.96
          912625  |   -1.21816   .2506752    -4.86   0.000    -1.709475   -.7268459
          939090  |  -19.73711   12694.23    -0.00   0.999    -24899.97    24860.49
          971550  |  -19.52372    9741.43    -0.00   0.998    -19112.38    19073.33
          972574  |  -19.39972   21883.71    -0.00   0.999    -42910.69    42871.89
         1130900  |   -4.30614   .2210046   -19.48   0.000    -4.739301   -3.872979
         1130950  |   -.950824   .2043251    -4.65   0.000    -1.351294   -.5503541
         1131020  |  -2.739751   .2064783   -13.27   0.000    -3.144441   -2.335061
         1131021  |   1.819082   .1264568    14.39   0.000     1.571231    2.066933
         1131050  |  -4.805226   .2314838   -20.76   0.000    -5.258926   -4.351526
         1131616  |  -4.755355   .2319179   -20.50   0.000    -5.209906   -4.300805
         1132055  |  -3.208924   .2330267   -13.77   0.000    -3.665648     -2.7522
         1132528  |  -.0821049   .2702843    -0.30   0.761    -.6118523    .4476426
         1135009  |  -4.848077   .2328786   -20.82   0.000     -5.30451   -4.391643
         1135113  |   -1.56739   .2049734    -7.65   0.000     -1.96913   -1.165649
         1136005  |  -2.915241   .2202034   -13.24   0.000    -3.346832   -2.483651
         1136007  |   -5.58132   .2730002   -20.44   0.000     -6.11639   -5.046249
         1136020  |   1.425638   .1397663    10.20   0.000     1.151701    1.699575
         1136268  |  -5.820333   .3057628   -19.04   0.000    -6.419617   -5.221049
         1136366  |  -4.092311   .2188858   -18.70   0.000    -4.521319   -3.663303
         1152195  |  -19.34736   10497.25    -0.00   0.999    -20593.59    20554.89
         1171820  |  -16.31167   4294.059    -0.00   0.997    -8432.512    8399.889
         1215085  |   3.356063   .1235274    27.17   0.000     3.113954    3.598173
         1215126  |  -3.714263   .2227967   -16.67   0.000    -4.150936   -3.277589
         1216088  |  -3.492663   .2164094   -16.14   0.000    -3.916818   -3.068509
         1216116  |   3.598358    .127775    28.16   0.000     3.347924    3.848793
         1230865  |  -22.83674   25536.17    -0.00   0.999     -50072.8    50027.13
         1270573  |  -19.75399   19610.77    -0.00   0.999    -38456.15    38416.64
         1331183  |  -20.33928   9652.775    -0.00   0.998    -18939.43    18898.75
         1352660  |    1.54398   .3129319     4.93   0.000     .9306445    2.157315
         1355097  |   2.406478    .309348     7.78   0.000     1.800167    3.012789
         1391330  |   2.068986   .2063241    10.03   0.000     1.664598    2.473374
         1393700  |   2.293755   .1711157    13.40   0.000     1.958374    2.629136
         1411240  |   3.836544   .8030825     4.78   0.000     2.262531    5.410556
         1411290  |   1.677337   .8137997     2.06   0.039     .0823187    3.272355
         1411315  |   2.848979   .8060782     3.53   0.000     1.269095    4.428863
         1415013  |   2.959615   .8035852     3.68   0.000     1.384617    4.534613
         1415121  |   3.266706   .8043153     4.06   0.000     1.690277    4.843135
         1433330  |   2.181551   .2685314     8.12   0.000     1.655239    2.707863
         1492180  |  -19.18166   13438.74    -0.00   0.999    -26358.62    26320.26
         1532323  |  -14.82757   3372.239    -0.00   0.996    -6624.295    6594.639
         1572912  |  -2.768971   .2050341   -13.50   0.000    -3.170831   -2.367112
         1576038  |  -3.156067   .2067267   -15.27   0.000    -3.561244    -2.75089
         1576070  |  -19.89643   3075.899    -0.01   0.995    -6048.548    6008.755
         1576276  |  -6.429832   .4008255   -16.04   0.000    -7.215436   -5.644229
         1653200  |   -19.6691   15953.27    -0.00   0.999    -31287.49    31248.16
         1671615  |   -.717973   .2079407    -3.45   0.001    -1.125529   -.3104168
         1672185  |    2.36265   .1171972    20.16   0.000     2.132948    2.592352
         1711511  |  -17.85766   13046.92    -0.00   0.999    -25589.35    25553.63
         1776027  |  -19.58568    11125.5    -0.00   0.999    -21825.17       21786
         1792735  |  -19.67557   2161.895    -0.01   0.993    -4256.913    4217.562
         1811145  |    3.01735   .2172238    13.89   0.000     2.591599    3.443101
         1813240  |   3.648822   .1882152    19.39   0.000     3.279927    4.017717
         1832150  |   3.458287   .1918579    18.03   0.000     3.082252    3.834322
         1832327  |  -1.563841   .2424287    -6.45   0.000    -2.038992   -1.088689
         1836041  |   4.155417   .1690523    24.58   0.000      3.82408    4.486753
         1873189  |    4.19012   .1916693    21.86   0.000     3.814455    4.565785
         1892840  |   5.635171     .26461    21.30   0.000     5.116545    6.153797
         2010243  |   1.650571   .0978493    16.87   0.000      1.45879    1.842352
         2011890  |  -4.076541   .1975746   -20.63   0.000     -4.46378   -3.689302
         2011895  |  -19.83846   2754.774    -0.01   0.994    -5419.096    5379.419
         2011960  |  -8.347783   .7320722   -11.40   0.000    -9.782619   -6.912948
         2011970  |  -4.994124   .2042406   -24.45   0.000    -5.394428    -4.59382
         2011985  |  -3.760404    .203359   -18.49   0.000     -4.15898   -3.361828
         2012000  |  -4.076482   .1966508   -20.73   0.000    -4.461911   -3.691054
         2012005  |   .2654977   .1055155     2.52   0.012     .0586911    .4723044
         2012007  |  -23.22358   537.3222    -0.04   0.966    -1076.356    1029.909
         2012018  |  -5.939212   .2167887   -27.40   0.000     -6.36411   -5.514314
         2012025  |  -3.395589   .1975732   -17.19   0.000    -3.782825   -3.008352
         2012778  |  -4.606548   .2008138   -22.94   0.000    -5.000136    -4.21296
         2013716  |  -4.301666    .204949   -20.99   0.000    -4.703359   -3.899973
         2015022  |  -4.556952   .1990053   -22.90   0.000    -4.946995   -4.166909
         2015024  |  -4.033175   .1976221   -20.41   0.000    -4.420507   -3.645843
         2015026  |  -3.346703   .2024462   -16.53   0.000     -3.74349   -2.949916
         2015120  |  -3.964607   .2048985   -19.35   0.000    -4.366201   -3.563013
         2015130  |  -5.636739   .2105201   -26.78   0.000     -6.04935   -5.224127
         2015135  |    .718751   .1325992     5.42   0.000     .4588613    .9786406
         2015140  |  -4.480512    .198385   -22.58   0.000    -4.869339   -4.091684
         2016009  |  -4.463634   .2026512   -22.03   0.000    -4.860823   -4.066445
         2016016  |  -3.913377    .232105   -16.86   0.000    -4.368295    -3.45846
         2016065  |  -5.415127   .2141377   -25.29   0.000    -5.834829   -4.995425
         2016290  |  -.4394737   .1793899    -2.45   0.014    -.7910715   -.0878759
         2016302  |  -6.376995   .3678712   -17.33   0.000    -7.098009    -5.65598
         2019310  |  -19.79398   2144.638    -0.01   0.993    -4223.207    4183.619
         2050890  |  -21.27233   43129.02    -0.00   1.000    -84552.61    84510.06
         2093151  |   3.026917   .2772651    10.92   0.000     2.483487    3.570346
         2130125  |   4.411305   .1512273    29.17   0.000     4.114905    4.707705
         2151200  |   2.424094   .3255567     7.45   0.000     1.786014    3.062173
         2152561  |  -.5784459   .2514848    -2.30   0.021    -1.071347   -.0855446
         2153723  |   1.096282   .2791971     3.93   0.000      .549066    1.643498
         2156047  |   .4688944   .2485366     1.89   0.059    -.0182284    .9560172
         2156258  |  -20.25201    975.796    -0.02   0.983    -1932.777    1892.273
         2171840  |   3.355111   .2062061    16.27   0.000     2.950955    3.759268
         2192250  |   5.322066   .2847101    18.69   0.000     4.764044    5.880088
         2219225  |   3.486476   .2381562    14.64   0.000     3.019698    3.953253
         2233345  |  -24.56008   9423.611    -0.00   0.998     -18494.5    18445.38
         2250843  |   2.606395   .2600314    10.02   0.000     2.096743    3.116047
         2275088  |   2.653239   .3219468     8.24   0.000     2.022235    3.284244
         2311740  |  -.5218315   .2327093    -2.24   0.025    -.9779334   -.0657295
         2330400  |  -18.43975   6022.805    -0.00   0.998    -11822.92    11786.04
         2412084  |   2.581549    .202488    12.75   0.000     2.184679    2.978418
         2450244  |  -3.165618   .2246935   -14.09   0.000    -3.606009   -2.725227
         2450258  |  -3.527886   .2260601   -15.61   0.000    -3.970956   -3.084817
         2452849  |  -3.845431   .2384141   -16.13   0.000    -4.312714   -3.378148
         2452850  |   1.024728   .1980666     5.17   0.000      .636525    1.412932
         2490040  |   3.821374   .2084472    18.33   0.000     3.412825    4.229923
         2510635  |     3.2674   .2024789    16.14   0.000     2.870549    3.664252
         2576008  |    1.59266    .226027     7.05   0.000     1.149655    2.035665
         2576026  |    1.02382   .3024233     3.39   0.001     .4310816    1.616559
         2652135  |  -1.542994   .3665317    -4.21   0.000    -2.261383   -.8246053
         2732160  |   3.772062   .2320546    16.26   0.000     3.317243    4.226881
         2772760  |  -20.45731   16359.61    -0.00   0.999     -32084.7    32043.79
         2796032  |  -17.91763   9408.636    -0.00   0.998     -18458.5    18422.67
         2853800  |   .7679714   .3598141     2.13   0.033     .0627488    1.473194
         2910645  |   .5771717   .1809601     3.19   0.001     .2224965    .9318469
         2992318  |  -18.40193    19870.3    -0.00   0.999    -38963.48    38926.67
         3032360  |   6.351207   .2301259    27.60   0.000     5.900168    6.802245
         3032377  |   5.243384   .2485335    21.10   0.000     4.756267      5.7305
         3036011  |   .7216641   .2897218     2.49   0.013     .1538197    1.289508
         3053364  |  -17.34691   9374.096    -0.00   0.999    -18390.24    18355.54
         3093650  |  -1.175702   .2383136    -4.93   0.000    -1.642788   -.7086165
         3093660  |    3.76259   .1752274    21.47   0.000      3.41915    4.106029
         3179520  |  -17.09444   11691.78    -0.00   0.999    -22932.56    22898.37
         3210235  |   1.612631   .1888892     8.54   0.000     1.242414    1.982847
         3231175  |  -.7796774   .3337943    -2.34   0.020    -1.433902   -.1254526
         3251853  |  -18.00459   6343.153    -0.00   0.998    -12450.36    12414.35
         3292535  |   1.151468   .3130162     3.68   0.000     .5379676    1.764968
         3350680  |  -15.87929   5159.444    -0.00   0.998     -10128.2    10096.44
         3372635  |  -21.19246   38257.77    -0.00   1.000    -75005.04    74962.66
         3390720  |  -4.857896   .2162234   -22.47   0.000    -5.281686   -4.434106
         3396057  |  -2.396517   .1996386   -12.00   0.000    -2.787801   -2.005233
         3396189  |  -5.750507   .2252922   -25.52   0.000    -6.192072   -5.308943
         3396327  |  -5.084839   .2237666   -22.72   0.000    -5.523414   -4.646265
         3411169  |  -19.41301   8972.779    -0.00   0.998    -17605.74    17566.91
         3472582  |   4.780643   .1811698    26.39   0.000     4.425557    5.135729
         3475093  |    2.21472   .3448278     6.42   0.000      1.53887     2.89057
         3490795  |   2.456804   .2036509    12.06   0.000     2.057655    2.855952
         3535132  |  -18.58006    12942.7    -0.00   0.999     -25385.8    25348.64
         3550740  |  -.8032015   .2552356    -3.15   0.002    -1.303454   -.3029489
         3556218  |   .2772052   .2519604     1.10   0.271    -.2166281    .7710384
         3572814  |  -20.08109   16345.17    -0.00   0.999    -32056.03    32015.87
         3612695  |   1.758542   .1855985     9.47   0.000     1.394775    2.122308
         3632567  |  -19.79817   8835.398    -0.00   0.998    -17336.86    17297.26
         3650574  |   1.375761   .2981932     4.61   0.000     .7913126    1.960209
         3673715  |   3.782918   .1865502    20.28   0.000     3.417286     4.14855
         3711385  |  -20.99077   37277.29    -0.00   1.000    -73083.13    73041.15
         3732315  |   1.747539   .1828432     9.56   0.000     1.389173    2.105905
         3750063  |    .783417   .2568338     3.05   0.002      .280032    1.286802
         3750070  |   1.170927   .2545731     4.60   0.000     .6719729    1.669881
         3896014  |   -21.1521   28588.83    -0.00   0.999    -56054.22    56011.92
         3976115  |   .8723119   .2238599     3.90   0.000     .4335545    1.311069
         4011810  |   4.102868   .1947647    21.07   0.000     3.721136    4.484599
         4153291  |  -16.21868   3752.354    -0.00   0.997    -7370.697     7338.26
         4190582  |   1.675908   .3309655     5.06   0.000     1.027228    2.324589
         4233565  |  -3.011559   .2927155   -10.29   0.000    -3.585271   -2.437847
         4233570  |  -4.543411   .4454728   -10.20   0.000    -5.416522   -3.670301
         4275095  |   4.610198   .2127415    21.67   0.000     4.193232    5.027164
         4290428  |  -20.85691   15773.73    -0.00   0.999     -30936.8    30895.08
         4390108  |   -3.51375   .2149739   -16.35   0.000    -3.935091   -3.092409
         4390285  |  -5.932554   .3433831   -17.28   0.000    -6.605573   -5.259536
         4391390  |  -4.352493   .2583471   -16.85   0.000    -4.858843   -3.846142
         4391437  |   1.987702   .1501821    13.24   0.000      1.69335    2.282053
         4391440  |  -3.709229   .2297009   -16.15   0.000    -4.159435   -3.259024
         4391483  |  -1.194102   .2061545    -5.79   0.000    -1.598158   -.7900469
         4391739  |  -5.918593   .3630862   -16.30   0.000    -6.630229   -5.206957
         4395139  |  -2.610048   .2082982   -12.53   0.000    -3.018306   -2.201791
         4395142  |   1.612583   .2300466     7.01   0.000       1.1617    2.063467
         4396125  |  -5.542675   .4089338   -13.55   0.000    -6.344171    -4.74118
         4410020  |   1.659681   .2885529     5.75   0.000     1.094128    2.225235
         4410034  |   1.058104   .2901531     3.65   0.000     .4894148    1.626794
         4450450  |  -18.19744   10167.94    -0.00   0.999    -19946.99     19910.6
         4492573  |  -24.78463   6079.906    -0.00   0.997    -11941.18    11891.61
         4513000  |   2.155428    .303293     7.11   0.000     1.560984    2.749871
         4516013  |   3.164002   .2927021    10.81   0.000     2.590316    3.737687
         4530170  |    -2.1014   .2636673    -7.97   0.000    -2.618178   -1.584622
         4530190  |   .2618829   .2383135     1.10   0.272    -.2052029    .7289688
         4530200  |   -3.13601   .3141826    -9.98   0.000    -3.751796   -2.520223
         4536048  |   .2470443   .1461636     1.69   0.091    -.0394312    .5335197
         4536253  |  -1.137793   .2473229    -4.60   0.000    -1.622537   -.6530491
         4536337  |    2.70751   .3076007     8.80   0.000     2.104623    3.310396
         4536338  |  -20.32788   3154.274    -0.01   0.995     -6202.59    6161.935
         4633580  |  -23.70509   10942.81    -0.00   0.998    -21471.23    21423.82
         4651139  |  -.1660947   .3506312    -0.47   0.636    -.8533192    .5211298
         4693625  |  -26.66069   4206.988    -0.01   0.995    -8272.206    8218.884
         4693630  |  -4.500664    .241999   -18.60   0.000    -4.974973   -4.026355
         4716028  |   2.453255   .1332697    18.41   0.000     2.192051    2.714459
         4752564  |  -17.33456   9056.723    -0.00   0.998    -17768.18    17733.52
         4770430  |  -19.73447   7411.564    -0.00   0.998    -14546.13    14506.66
         4792220  |   .4848327   .0664019     7.30   0.000     .3546873    .6149781
         4792230  |          0  (omitted)
         4813735  |   2.354191   .1663553    14.15   0.000      2.02814    2.680241
         4833220  |  -20.23205   10265.73    -0.00   0.998    -20140.68    20100.22
         4853790  |   1.362987   .3574094     3.81   0.000     .6624775    2.063497
         4916029  |   4.421669   .2063526    21.43   0.000     4.017225    4.826113
         4916068  |          0  (omitted)
         4975091  |  -18.61038   9169.332    -0.00   0.998    -17990.17    17952.95
         4992851  |   1.660706   .2970617     5.59   0.000     1.078476    2.242936
         5011163  |  -20.41911   20683.83    -0.00   0.999    -40559.99    40519.15
         5032670  |  -21.37792   40837.88    -0.00   1.000    -80062.15    80019.39
         5035018  |  -21.38885   34154.85    -0.00   1.000    -66963.67     66920.9
-----------------------------------------------------------------------------------




clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate closest dist_bed i.fidcn if private == 1, group(patid)


Conditional (fixed-effects) logistic regression

                                                Number of obs     =  1,105,666
                                                LR chi2(252)      =  113678.44
                                                Prob > chi2       =     0.0000
Log likelihood = -63421.911                     Pseudo R2         =     0.4726

-----------------------------------------------------------------------------------
           chosen |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
 zipfacdistancecn |  -.1996478   .0016646  -119.94   0.000    -.2029103   -.1963853
zipfacdistancecn2 |   .0005694   7.46e-06    76.28   0.000     .0005547     .000584
     NeoIntensive |        7.9   .4214204    18.75   0.000     7.074031    8.725969
 SoloIntermediate |   6.980586   .1853806    37.66   0.000     6.617246    7.343925
          closest |   .2092608    .018553    11.28   0.000     .1728976    .2456241
         dist_bed |   .0021405    .000231     9.26   0.000     .0016877    .0025934
                  |
            fidcn |
           16122  |   5.358308   .2652498    20.20   0.000     4.838428    5.878189
           30105  |  -22.68083   10623.78    -0.00   0.998    -20844.91    20799.55
           52390  |   4.553328   .3072736    14.82   0.000     3.951083    5.155574
           52395  |  -2.078925   .3440831    -6.04   0.000    -2.753315   -1.404534
          132096  |   1.435722   1.040777     1.38   0.168    -.6041642    3.475608
          172577  |  -20.53533   51031.66    -0.00   1.000    -100040.8    99999.69
          213280  |   2.396096   .5168957     4.64   0.000     1.382999    3.409193
          233210  |  -22.69369   104068.3    -0.00   1.000    -203992.9    203947.5
          250295  |    4.19088    .530382     7.90   0.000      3.15135     5.23041
          273410  |   7.014009   .2241886    31.29   0.000     6.574608    7.453411
          273420  |    .376059   .4575384     0.82   0.411    -.5206998    1.272818
          276050  |   4.701496   .2551677    18.43   0.000     4.201377    5.201616
          293005  |  -2.135854   .4808078    -4.44   0.000     -3.07822   -1.193488
          293010  |  -.4466427   .4601564    -0.97   0.332    -1.348533    .4552473
          293015  |   4.926128   .3038219    16.21   0.000     4.330649    5.521608
          293070  |   6.522575   .2246921    29.03   0.000     6.082186    6.962963
          293105  |  -1.026256   .4646735    -2.21   0.027       -1.937   -.1155131
          293120  |   6.213613   .2325222    26.72   0.000     5.757878    6.669348
          293122  |   .6361351   .4626433     1.38   0.169    -.2706292    1.542899
          296002  |  -.3252122   .4609881    -0.71   0.481    -1.228732    .5783079
          296025  |  -2.322206    .488185    -4.76   0.000    -3.279031   -1.365381
          296191  |   7.715561   .2065704    37.35   0.000      7.31069    8.120431
          350650  |  -17.81819   14551.17    -0.00   0.999     -28537.6    28501.96
          373510  |  -27.34898   4543.339    -0.01   0.995     -8932.13    8877.432
          376245  |  -23.05711   23428.68    -0.00   0.999    -45942.43    45896.32
          390111  |   3.353639   .2055118    16.32   0.000     2.950843    3.756435
          391525  |   2.795973    .214903    13.01   0.000     2.374771    3.217175
          410490  |  -2.210394   .4731118    -4.67   0.000    -3.137676   -1.283112
          410500  |   6.925235   .2116402    32.72   0.000     6.510428    7.340042
          430050  |   6.941623   .8748792     7.93   0.000     5.226891    8.656355
          490465  |   4.840747   .4885896     9.91   0.000     3.883129    5.798365
          572853  |  -22.85452   34366.81    -0.00   0.999    -67380.57    67334.86
          610460  |     2.2048   .6609369     3.34   0.001     .9093877    3.500213
          611790  |   2.118899   .6343023     3.34   0.001     .8756896    3.362109
          615100  |   1.908498   .6615926     2.88   0.004     .6118005    3.205196
          616303  |   8.423564   .6554454    12.85   0.000     7.138915    9.708213
          616318  |   9.799417   .5974253    16.40   0.000     8.628484    10.97035
          672285  |  -20.83739   23763.79    -0.00   0.999    -46597.01    46555.34
          691167  |  -17.11837   22933.83    -0.00   0.999    -44966.61    44932.37
          732070  |   2.661507    .316889     8.40   0.000     2.040416    3.282598
          750595  |  -21.06892    53615.1    -0.00   1.000    -105104.7    105062.6
          830660  |  -18.30888   48261.27    -0.00   1.000    -94608.66    94572.04
          852480  |   4.673635   .1467589    31.85   0.000     4.385992    4.961277
          855094  |  -1.324721   .4334961    -3.06   0.002    -2.174358   -.4750848
          856181  |  -1.257916   .4333875    -2.90   0.004     -2.10734   -.4084922
          856301  |   5.259464   .1346033    39.07   0.000     4.995646    5.523281
          856354  |  -4.072662   .4520024    -9.01   0.000    -4.958571   -3.186754
          891170  |  -18.93544   16955.65    -0.00   0.999    -33251.41    33213.53
          895105  |  -20.58563   15760.03    -0.00   0.999    -30909.68    30868.51
          912625  |  -.8637869   .1921222    -4.50   0.000    -1.240339   -.4872343
          939090  |  -20.46788   23945.08    -0.00   0.999    -46951.97    46911.03
          971550  |  -18.96745   8603.122    -0.00   0.998    -16880.78    16842.84
          972574  |   -20.2719    22453.7    -0.00   0.999    -44028.71    43988.17
         1130900  |  -1.219914   .4345721    -2.81   0.005     -2.07166   -.3681687
         1130950  |  -3.322035   .4452747    -7.46   0.000    -4.194758   -2.449313
         1131020  |  -2.472447   .4380476    -5.64   0.000    -3.331004   -1.613889
         1131021  |   3.883604    .196979    19.72   0.000     3.497532    4.269675
         1131050  |  -.7633638   .4334023    -1.76   0.078    -1.612817    .0860892
         1131616  |  -2.352132   .4360732    -5.39   0.000     -3.20682   -1.497444
         1132055  |  -.9383751   .2114478    -4.44   0.000    -1.352805   -.5239451
         1132528  |     2.5183    .312613     8.06   0.000      1.90559     3.13101
         1135009  |  -1.516859   .4340817    -3.49   0.000    -2.367643   -.6660744
         1135113  |  -1.577804   .2175442    -7.25   0.000    -2.004183   -1.151426
         1136005  |  -2.992778    .248606   -12.04   0.000    -3.480037   -2.505519
         1136007  |  -3.050652   .4402942    -6.93   0.000    -3.913612   -2.187691
         1136020  |   3.185291   .2402225    13.26   0.000     2.714463    3.656118
         1136268  |  -2.079843   .4354914    -4.78   0.000    -2.933391   -1.226296
         1136366  |  -2.353584   .4372951    -5.38   0.000    -3.210667   -1.496502
         1152195  |  -19.93383   23395.52    -0.00   0.999    -45874.32    45834.45
         1171820  |  -14.35829   11474.18    -0.00   0.999    -22503.35    22474.63
         1215085  |   5.171031   .1476684    35.02   0.000     4.881606    5.460456
         1215126  |  -2.202374   .4359489    -5.05   0.000    -3.056818    -1.34793
         1216088  |   -2.28183   .4361505    -5.23   0.000    -3.136669    -1.42699
         1216116  |   5.124767   .1555171    32.95   0.000     4.819959    5.429575
         1230865  |  -22.32103   32284.09    -0.00   0.999    -63297.98    63253.34
         1270573  |  -20.40347   37865.49    -0.00   1.000    -74235.39    74194.59
         1331183  |  -20.57057   24113.81    -0.00   0.999    -47282.76    47241.62
         1352660  |   .9523947   .5481193     1.74   0.082    -.1218993    2.026689
         1355097  |   1.417408   .5471177     2.59   0.010     .3450768    2.489739
         1391330  |   3.490433   .2427144    14.38   0.000     3.014722    3.966145
         1393700  |   5.054312    .160897    31.41   0.000      4.73896    5.369664
         1411240  |   3.729899   .6965952     5.35   0.000     2.364598    5.095201
         1411290  |   5.545354   .6929615     8.00   0.000     4.187175    6.903534
         1411315  |   3.826382   .6976829     5.48   0.000     2.458949    5.193815
         1415013  |   3.009725    .697636     4.31   0.000     1.642384    4.377067
         1415121  |   3.654052   .6977084     5.24   0.000     2.286569    5.021535
         1433330  |   4.286181   .3860975    11.10   0.000     3.529443    5.042918
         1492180  |  -19.53353   13441.88    -0.00   0.999    -26365.13    26326.07
         1532323  |  -14.71641   4800.898    -0.00   0.998    -9424.304    9394.872
         1572912  |  -2.577697   .2427972   -10.62   0.000     -3.05357   -2.101823
         1576038  |   -2.36983    .228013   -10.39   0.000    -2.816728   -1.922933
         1576070  |  -17.06984   4814.302    -0.00   0.997    -9452.928    9418.788
         1576276  |  -1.647014   .2192603    -7.51   0.000    -2.076757   -1.217272
         1653200  |  -20.02663   33946.77    -0.00   1.000    -66554.47    66514.41
         1671615  |  -2.335845     .46579    -5.01   0.000    -3.248777   -1.422914
         1672185  |   3.062722   .2629252    11.65   0.000     2.547398    3.578046
         1711511  |  -17.26833   18492.64    -0.00   0.999    -36262.17    36227.64
         1776027  |  -19.33455   13212.89    -0.00   0.999    -25916.13    25877.46
         1792735  |  -17.04415   4896.726    -0.00   0.997    -9614.451    9580.363
         1811145  |   4.115604   .2555174    16.11   0.000     3.614799    4.616409
         1813240  |   4.967652   .2047802    24.26   0.000     4.566291    5.369014
         1832150  |   3.809143   .3198472    11.91   0.000     3.182254    4.436032
         1832327  |  -1.552784   .4682037    -3.32   0.001    -2.470446   -.6351214
         1836041  |   5.899114   .2289983    25.76   0.000     5.450285    6.347942
         1873189  |   4.347531   .2774121    15.67   0.000     3.803813    4.891249
         1892840  |   2.399249   .4404181     5.45   0.000     1.536045    3.262452
         2010243  |   5.233457   .1464411    35.74   0.000     4.946438    5.520476
         2011890  |  -2.086201   .4363572    -4.78   0.000    -2.941445   -1.230957
         2011895  |   4.924465   .1371597    35.90   0.000     4.655636    5.193293
         2011960  |  -1.919962   .2215074    -8.67   0.000    -2.354108   -1.485815
         2011970  |  -2.188799   .4354458    -5.03   0.000    -3.042257   -1.335341
         2011985  |  -2.886082   .2442208   -11.82   0.000    -3.364746   -2.407418
         2012000  |  -3.051998   .4412721    -6.92   0.000    -3.916876   -2.187121
         2012005  |   5.649134   .1344247    42.02   0.000     5.385667    5.912602
         2012007  |  -20.70126   540.4799    -0.04   0.969    -1080.022     1038.62
         2012018  |  -3.185252   .4422935    -7.20   0.000    -4.052132   -2.318373
         2012025  |  -2.529813   .2262109   -11.18   0.000    -2.973178   -2.086448
         2012778  |  -3.109046   .4421617    -7.03   0.000    -3.975667   -2.242425
         2013716  |  -1.757795   .4370453    -4.02   0.000    -2.614388   -.9012022
         2015022  |     -2.919   .4391633    -6.65   0.000    -3.779744   -2.058256
         2015024  |  -6.019902   .5595669   -10.76   0.000    -7.116633   -4.923171
         2015026  |  -2.410085   .2319849   -10.39   0.000    -2.864768   -1.955403
         2015120  |  -2.328987   .2293876   -10.15   0.000    -2.778578   -1.879396
         2015130  |  -.4770807   .4334816    -1.10   0.271    -1.326689    .3725277
         2015135  |   3.767265   .1669882    22.56   0.000     3.439975    4.094556
         2015140  |  -2.145644   .4357937    -4.92   0.000    -2.999784   -1.291504
         2016009  |  -3.140231   .4399472    -7.14   0.000    -4.002512   -2.277951
         2016016  |  -2.939541   .2492018   -11.80   0.000    -3.427968   -2.451115
         2016065  |   -3.31706   .4392199    -7.55   0.000    -4.177915   -2.456205
         2016290  |   4.341907    .151052    28.74   0.000     4.045851    4.637964
         2016302  |  -1.371585   .2149633    -6.38   0.000    -1.792905   -.9502644
         2019310  |  -16.96195   4344.699    -0.00   0.997    -8532.415    8498.491
         2050890  |  -23.22722   137644.9    -0.00   1.000    -269802.3    269755.8
         2093151  |   6.704072   .1940612    34.55   0.000     6.323719    7.084425
         2130125  |   3.942438   .2536167    15.54   0.000     3.445358    4.439517
         2151200  |   5.317899   .8050181     6.61   0.000     3.740092    6.895705
         2152561  |  -.6409178   .6483378    -0.99   0.323    -1.911637     .629801
         2153723  |   .7813945   .6179979     1.26   0.206    -.4298592    1.992648
         2156047  |   2.505399   .6048419     4.14   0.000     1.319931    3.690868
         2156258  |  -18.88214   2238.766    -0.01   0.993    -4406.782    4369.018
         2171840  |   3.457285   .4097655     8.44   0.000      2.65416    4.260411
         2192250  |   2.614631   .5396859     4.84   0.000     1.556866    3.672396
         2219225  |   2.029082   .3406374     5.96   0.000     1.361445    2.696719
         2233345  |  -25.56808   6175.274    -0.00   0.997    -12128.88    12077.75
         2250843  |   2.148098   .5901528     3.64   0.000     .9914194    3.304776
         2275088  |    2.29365   .4500808     5.10   0.000     1.411508    3.175792
         2311740  |  -3.616647   .2831001   -12.78   0.000    -4.171513   -3.061781
         2330400  |  -19.70311   42181.05    -0.00   1.000    -82693.05    82653.64
         2412084  |   .6321411   .5423005     1.17   0.244    -.4307483     1.69503
         2450244  |  -2.959334   .5007262    -5.91   0.000    -3.940739   -1.977928
         2450258  |  -1.900893   .4867445    -3.91   0.000    -2.854895   -.9468915
         2452849  |  -3.630677   .5358504    -6.78   0.000    -4.680924   -2.580429
         2452850  |   4.499952   .3342214    13.46   0.000      3.84489    5.155014
         2490040  |   2.379918    .461597     5.16   0.000     1.475205    3.284631
         2510635  |   3.917774   .1878076    20.86   0.000     3.549677     4.28587
         2576008  |   1.671359   .4293938     3.89   0.000     .8297624    2.512955
         2576026  |   3.514264   .2064476    17.02   0.000     3.109634    3.918893
         2652135  |  -3.491624   .6618973    -5.28   0.000    -4.788919   -2.194329
         2732160  |   3.045849   .4985259     6.11   0.000     2.068756    4.022942
         2772760  |  -19.08539   15113.55    -0.00   0.999    -29641.09    29602.92
         2796032  |  -20.52269   33930.27    -0.00   1.000    -66522.64    66481.59
         2853800  |    1.53178   .3988575     3.84   0.000      .750034    2.313527
         2910645  |   2.170995   .3199488     6.79   0.000     1.543907    2.798083
         2992318  |  -17.99072    13565.1    -0.00   0.999    -26605.09    26569.11
         3032360  |   6.518591   .3329211    19.58   0.000     5.866077    7.171104
         3032377  |   2.726083   .5023356     5.43   0.000     1.741524    3.710643
         3036011  |  -2.275428   .5397598    -4.22   0.000    -3.333337   -1.217518
         3053364  |   -19.5337   26987.74    -0.00   0.999    -52914.53    52875.46
         3093650  |  -.2355392   .4655655    -0.51   0.613    -1.148031    .6769523
         3093660  |   7.571302   .2180257    34.73   0.000      7.14398    7.998625
         3179520  |   -16.9021   18446.33    -0.00   0.999    -36171.04    36137.24
         3210235  |   1.566764   .4085121     3.84   0.000     .7660955    2.367434
         3231175  |  -4.399588   .3858293   -11.40   0.000      -5.1558   -3.643377
         3251853  |    -17.016   10455.83    -0.00   0.999    -20510.06    20476.03
         3292535  |   .7931094   .5447413     1.46   0.145    -.2745639    1.860783
         3350680  |  -12.65616   2930.896    -0.00   0.997    -5757.107    5731.794
         3372635  |   -21.9648    52157.7    -0.00   1.000    -102249.2    102205.2
         3390720  |  -4.038593   .4565621    -8.85   0.000    -4.933438   -3.143748
         3396057  |  -.9870005   .2150869    -4.59   0.000    -1.408563    -.565438
         3396189  |  -4.067685   .4499487    -9.04   0.000    -4.949568   -3.185802
         3396327  |  -2.525198   .4384265    -5.76   0.000    -3.384498   -1.665897
         3411169  |   7.289303   .3342666    21.81   0.000     6.634153    7.944454
         3472582  |   4.994556   .3284398    15.21   0.000     4.350826    5.638286
         3475093  |   6.023653   .2757539    21.84   0.000     5.483186    6.564121
         3490795  |   2.714289    .305793     8.88   0.000     2.114946    3.313632
         3535132  |  -18.60755   21689.11    -0.00   0.999    -42528.49    42491.28
         3550740  |   -2.52044   .6256073    -4.03   0.000    -3.746608   -1.294272
         3556218  |   .7858896   .5387953     1.46   0.145    -.2701298    1.841909
         3572814  |  -21.85782   64954.48    -0.00   1.000    -127330.3    127286.6
         3612695  |   3.377138   .4146812     8.14   0.000     2.564378    4.189898
         3632567  |  -19.51341   8580.655    -0.00   0.998    -16837.29    16798.26
         3650574  |   .6251669   .7877847     0.79   0.427    -.9188627    2.169196
         3673715  |   3.428174   .2161969    15.86   0.000     3.004436    3.851913
         3711385  |  -20.61422   32102.92    -0.00   0.999    -62941.18    62899.96
         3732315  |   .6112687   .5679904     1.08   0.282    -.5019721    1.724509
         3750063  |   3.972585   .4816388     8.25   0.000      3.02859    4.916579
         3750070  |   2.193263   .4921847     4.46   0.000     1.228599    3.157928
         3896014  |  -20.07332   22304.88    -0.00   0.999    -43736.84     43696.7
         3976115  |   5.268528   .1383669    38.08   0.000     4.997334    5.539722
         4011810  |   3.013865   .3910078     7.71   0.000     2.247504    3.780226
         4153291  |  -14.25898    2408.34    -0.01   0.995    -4734.519    4706.001
         4190582  |   1.495961   .7039465     2.13   0.034     .1162513    2.875671
         4233565  |  -1.365118   .2631353    -5.19   0.000    -1.880854   -.8493825
         4233570  |  -.5139447   .2531305    -2.03   0.042    -1.010071   -.0178179
         4275095  |   3.496891   .7709337     4.54   0.000     1.985888    5.007893
         4290428  |  -21.51895   34151.62    -0.00   0.999    -66957.46    66914.42
         4390108  |  -1.729275   .4343299    -3.98   0.000    -2.580546   -.8780041
         4390285  |  -2.029995   .4349624    -4.67   0.000    -2.882505   -1.177484
         4391390  |  -1.642059   .4347134    -3.78   0.000    -2.494082   -.7900364
         4391437  |   4.687872   .1458947    32.13   0.000     4.401924     4.97382
         4391440  |  -.7767159   .4335416    -1.79   0.073    -1.626442    .0730101
         4391483  |  -4.837185   .4800971   -10.08   0.000    -5.778158   -3.896212
         4391739  |  -1.178785   .4333677    -2.72   0.007     -2.02817      -.3294
         4395139  |  -2.547537   .4364722    -5.84   0.000    -3.403007   -1.692067
         4395142  |   5.583533   .1355572    41.19   0.000     5.317845     5.84922
         4396125  |  -1.761312   .4353358    -4.05   0.000    -2.614554   -.9080693
         4410020  |   .0823376   .4200076     0.20   0.845    -.7408621    .9055373
         4410034  |   .9274874   .5604663     1.65   0.098    -.1710064    2.025981
         4450450  |  -18.07342   50417.62    -0.00   1.000     -98834.8    98798.65
         4492573  |  -25.86467   4521.197    -0.01   0.995    -8887.248    8835.519
         4513000  |   3.199982   .5499669     5.82   0.000     2.122066    4.277897
         4516013  |   3.008172   .5533129     5.44   0.000     1.923699    4.092646
         4530170  |  -3.496338   .5213285    -6.71   0.000    -4.518123   -2.474553
         4530190  |  -.0271717    .450084    -0.06   0.952    -.9093201    .8549767
         4530200  |   .6116883   .4489401     1.36   0.173    -.2682181    1.491595
         4536048  |   -.676682   .1200954    -5.63   0.000    -.9120646   -.4412993
         4536253  |  -.0752994   .4498285    -0.17   0.867    -.9569471    .8063484
         4536337  |   7.546774   .1820676    41.45   0.000     7.189928     7.90362
         4536338  |  -.5093207   .1160073    -4.39   0.000    -.7366908   -.2819506
         4633580  |  -25.17346    11491.5    -0.00   0.998     -22548.1    22497.76
         4651139  |  -1.819028   .5998357    -3.03   0.002    -2.994685   -.6433721
         4693625  |  -25.32707   4031.702    -0.01   0.995    -7927.318    7876.663
         4693630  |  -4.458972   .5031389    -8.86   0.000    -5.445106   -3.472838
         4716028  |   2.781629   .2582185    10.77   0.000      2.27553    3.287728
         4752564  |  -16.96156   15427.07    -0.00   0.999    -30253.46    30219.53
         4770430  |  -18.96236   10180.96    -0.00   0.999    -19973.28    19935.36
         4792220  |   .7666163   .1339383     5.72   0.000     .5041021     1.02913
         4792230  |          0  (omitted)
         4813735  |    4.63992   .2450007    18.94   0.000     4.159728    5.120113
         4833220  |  -21.08047   29646.65    -0.00   0.999    -58127.45    58085.29
         4853790  |   1.230913   .3973368     3.10   0.002     .4521468    2.009678
         4916029  |   6.853028   .1925382    35.59   0.000      6.47566    7.230396
         4916068  |          0  (omitted)
         4975091  |  -17.07225   7823.565    -0.00   0.998    -15350.98    15316.83
         4992851  |   1.601045   .5574665     2.87   0.004     .5084309     2.69366
         5011163  |   -19.1412   99971.74    -0.00   1.000    -195960.2    195921.9
         5032670  |  -20.35079   126223.5    -0.00   1.000    -247413.9    247373.2
         5035018  |  -22.43399   60930.44    -0.00   1.000    -119443.9      119399
-----------------------------------------------------------------------------------




*/
