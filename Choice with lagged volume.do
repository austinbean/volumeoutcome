* Estimating versions of the model with lagged volume in them.
/*
For questions related to 10/24 presentation: 
	- choice model with lagged volume - see VolumeInstrument.do
	- instrumenting given choice w/ lagged volume - see this file.
	- total population choice w/ lagged volume - see VolumeInstrument.do
*/


/* 
use "${birthdata}Birth2007.dta", clear
gen 
*/

do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"

/*
* This needs to be run only when CombinedFacCount.dta is changed, just to drop some missing values.
use "${birthdata}CombinedFacCount.dta", clear
drop if fid == .
duplicates drop fid ncdobyear ncdobmonth, force
save "${birthdata}FacCountMissingFidDropped.dta",replace
*/
foreach yr of numlist 2005(1)2012{


	use "${birthdata}Birth`yr'.dta", clear
	
	keep if b_bplace ==1 
	
* Add Zip Code Choice Sets - closest 50 hospitals.

	drop if b_mrzip < 70000 | b_mrzip > 79999
	* TODO - this may not be necessary
	drop if fid == .
	rename b_mrzip PAT_ZIP

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

	keep patid ncdobmonth ncdobyear fid fidcn PAT_ZIP chosen zipfacdistancecn zipfacdistancecn2 hs

	
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
	replace ObstetricCare = 0 if fidcn == 0
	
* Fix dumb errors in Obstetrics Level
	replace ObstetricsLevel = . if ObstetricsLevel == -9


* Estimating two choice models - first w/out facility FE's, second with.
	label variable zipfacdistancecn "Distance to Chosen"
	label variable zipfacdistancecn2 "Squared Distance to Chosen"
	label variable NeoIntensive "Level 3"
	label variable SoloIntermediate "Level 2"
	label variable ObstetricsLevel "Obstetrics Level"
	label variable chosen "Hosp. Chosen"
	
	*eststo cnicu_`yr': clogit chosen zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.ObstetricsLevel, group(patid)
	unique patid
	estadd local pN "`r(N)'"

* Merge predicted shares
	drop _merge
	merge m:1 ncdobyear fid using "${birthdata}allyearnicufidshares.dta"
	drop if _merge != 3
	drop _merge

* Merge facility level counts 
	rename fid fid_cc
	rename fidcn fid
	merge m:1 fid ncdobyear ncdobmonth using "${birthdata}FacCountMissingFidDropped.dta"
	
	drop if _merge != 3
	drop _merge
	*mat a1 = e(b)
	*estimates save "${birthdata}`yr' nicuchoices", replace

	
	
	clogit chosen prev_q zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.ObstetricsLevel, group(patid)
	mat a1 = e(b)
	
	clogit chosen prev_q zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.fid i.ObstetricsLevel, group(patid) difficult from(a1)
	
	clogit chosen prev_*_month zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.ObstetricsLevel, group(patid)
	predict pr1
	
	
* Compute Shares and save
	bysort fidcn: gen shr = sum(pr1)
	bysort fidcn: egen exp_share = max(shr)
	keep fidcn exp_share
	duplicates drop fidcn, force
	rename fidcn fid
	* this next step does not matter.
	gen mnthly_share = exp_share/12
	gen yr = `yr'
	save "${birthdata}`yr'_nicuvolfidshares.dta", replace
	
}





* Get quarterly values:
* Merge this with the patient choice data to see if they care about vlbw, lbw, etc.  

	use "${birthdata}CombinedFacCount.dta", clear
	
	drop prev_1_month-prev_12_month total_1_months-total_6_months total_1_lbw-total_6_lbw total_1_vlbw-total_6_vlbw lag_1_months-lag_6_months lag_1_lbw-lag_6_lbw lag_1_vlbw-lag_6_vlbw

	sort facname ncdobyear ncdobmonth
	* Generate quarterly counts of NICU admits, corresponding to calendar quarters
	bysort facname ncdobyear (ncdobmonth): gen qr1_i = month_count + month_count[_n-1] + month_count[_n-2] if ncdobmonth == 3
	bysort facname ncdobyear (ncdobmonth): gen qr2_i = month_count + month_count[_n-1] + month_count[_n-2] if ncdobmonth == 6
	bysort facname ncdobyear (ncdobmonth): gen qr3_i = month_count + month_count[_n-1] + month_count[_n-2] if ncdobmonth == 9
	bysort facname ncdobyear (ncdobmonth): gen qr4_i = month_count + month_count[_n-1] + month_count[_n-2] if ncdobmonth == 12
	
	bysort facname ncdobyear (ncdobmonth): egen qr1 = max(qr1_i) if ncdobmonth == 1 | ncdobmonth == 2 | ncdobmonth == 3
	bysort facname ncdobyear (ncdobmonth): egen qr2 = max(qr2_i) if ncdobmonth == 4 | ncdobmonth == 5 | ncdobmonth == 6
	bysort facname ncdobyear (ncdobmonth): egen qr3 = max(qr3_i) if ncdobmonth == 7 | ncdobmonth == 8 | ncdobmonth == 9
	bysort facname ncdobyear (ncdobmonth): egen qr4 = max(qr4_i) if ncdobmonth == 10 | ncdobmonth == 11 | ncdobmonth == 12
	
	egen qr_tot = rowtotal(qr1 qr2 qr3 qr4)
	gen quarter = .
	replace quarter = 1 if ncdobmonth == 1 | ncdobmonth == 2 | ncdobmonth == 3
	replace quarter = 2 if ncdobmonth == 4 | ncdobmonth == 5 | ncdobmonth == 6
	replace quarter = 3 if ncdobmonth == 7 | ncdobmonth == 8 | ncdobmonth == 9
	replace quarter = 4 if ncdobmonth == 10 | ncdobmonth == 11 | ncdobmonth == 12
	
	label variable qr_tot "calendar quarter nicu admits"
	label variable quarter "Quarter"
	
	drop qr*_i qr1 qr2 qr3 qr4 

	* Generate quarterly counts of LBW, corresponding to calendar quarter:
	bysort facname ncdobyear (ncdobmonth): gen qr1_i = lbw_month + lbw_month[_n-1] + lbw_month[_n-2] if ncdobmonth == 3
	bysort facname ncdobyear (ncdobmonth): gen qr2_i = lbw_month + lbw_month[_n-1] + lbw_month[_n-2] if ncdobmonth == 6
	bysort facname ncdobyear (ncdobmonth): gen qr3_i = lbw_month + lbw_month[_n-1] + lbw_month[_n-2] if ncdobmonth == 9
	bysort facname ncdobyear (ncdobmonth): gen qr4_i = lbw_month + lbw_month[_n-1] + lbw_month[_n-2] if ncdobmonth == 12
	
	bysort facname ncdobyear (ncdobmonth): egen lbwqr1 = max(qr1_i) if ncdobmonth == 1 | ncdobmonth == 2 | ncdobmonth == 3
	bysort facname ncdobyear (ncdobmonth): egen lbwqr2 = max(qr2_i) if ncdobmonth == 4 | ncdobmonth == 5 | ncdobmonth == 6
	bysort facname ncdobyear (ncdobmonth): egen lbwqr3 = max(qr3_i) if ncdobmonth == 7 | ncdobmonth == 8 | ncdobmonth == 9
	bysort facname ncdobyear (ncdobmonth): egen lbwqr4 = max(qr4_i) if ncdobmonth == 10 | ncdobmonth == 11 | ncdobmonth == 12
	
	egen qr_tot_lbw = rowtotal(lbwqr1 lbwqr2 lbwqr3 lbwqr4)
	label variable qr_tot_lbw "calendar quarter lbw admits"
	drop qr*_i lbwqr1-lbwqr4
	
	
	* Generate Quarterly counts of VLBW, corresponding to calender quarter:
	
	bysort facname ncdobyear (ncdobmonth): gen qr1_i = vlbw_month + vlbw_month[_n-1] + vlbw_month[_n-2] if ncdobmonth == 3
	bysort facname ncdobyear (ncdobmonth): gen qr2_i = vlbw_month + vlbw_month[_n-1] + vlbw_month[_n-2] if ncdobmonth == 6
	bysort facname ncdobyear (ncdobmonth): gen qr3_i = vlbw_month + vlbw_month[_n-1] + vlbw_month[_n-2] if ncdobmonth == 9
	bysort facname ncdobyear (ncdobmonth): gen qr4_i = vlbw_month + vlbw_month[_n-1] + vlbw_month[_n-2] if ncdobmonth == 12
	
	bysort facname ncdobyear (ncdobmonth): egen vlqr1 = max(qr1_i) if ncdobmonth == 1 | ncdobmonth == 2 | ncdobmonth == 3
	bysort facname ncdobyear (ncdobmonth): egen vlqr2 = max(qr2_i) if ncdobmonth == 4 | ncdobmonth == 5 | ncdobmonth == 6
	bysort facname ncdobyear (ncdobmonth): egen vlqr3 = max(qr3_i) if ncdobmonth == 7 | ncdobmonth == 8 | ncdobmonth == 9
	bysort facname ncdobyear (ncdobmonth): egen vlqr4 = max(qr4_i) if ncdobmonth == 10 | ncdobmonth == 11 | ncdobmonth == 12
	
	egen qr_tot_vlbw = rowtotal(vlqr1 vlqr2 vlqr3 vlqr4)
	label variable qr_tot_vlbw "calendar quarter vlbw admits"
	
	drop qr*_i vlqr1-vlqr4
	
	duplicates drop facname ncdobyear quarter, force
	drop ncdobmonth
	drop b_bcntyc
* drop non-quarterly variables.	
	drop month_count* lbw_month* vlbw_month* monthly_admit_deaths month_mort_all prev_*_q
	
	duplicates drop fid ncdobyear quarter, force
	
	save "${birthdata}QuarterlyFacCount.dta", replace
	
/*
- Using 2007BirthData.  
clogit chosen prev_q zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.ObstetricsLevel, group(patid)

mat a1 = e(b)

clogit chosen prev_q zipfacdistancecn zipfacdistancecn2 NeoIntensive SoloIntermediate i.fid i.ObstetricsLevel, group(patid) difficult from(a1)


Iteration 11:  log likelihood = -66336.834  
Iteration 12:  log likelihood = -66336.834  

Conditional (fixed-effects) logistic regression

                                                Number of obs     =    962,430
                                                LR chi2(217)      =  113484.98
                                                Prob > chi2       =     0.0000
Log likelihood = -66336.834                     Pseudo R2         =     0.4610

------------------------------------------------------------------------------
      chosen |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      prev_q |   9.74e-06   .0004543     0.02   0.983    -.0008807    .0009001
zipfacdist~n |  -.2011789   .0013386  -150.29   0.000    -.2038026   -.1985553
zipfacdist~2 |   .0005629   7.97e-06    70.65   0.000     .0005473    .0005786
NeoIntensive |  -3.106564    .604953    -5.14   0.000     -4.29225   -1.920878
SoloInterm~e |    2.02073   .4126381     4.90   0.000     1.211974    2.829486
             |
         fid |
      30105  |  -3.504138   .5501703    -6.37   0.000    -4.582452   -2.425824
      52390  |  -.7032776    .416063    -1.69   0.091    -1.518746     .112191
      52395  |  -2.634844   .4254689    -6.19   0.000    -3.468748   -1.800941
     132096  |   .1675555    .522529     0.32   0.748    -.8565824    1.191693
     233210  |  -4.931408   .9017574    -5.47   0.000     -6.69882   -3.163996
     250295  |  -1.294613   .5989392    -2.16   0.031    -2.468512   -.1207133
     273410  |   .1431566   .2288747     0.63   0.532    -.3054297    .5917428
     273420  |   7.157559   .5025688    14.24   0.000     6.172542    8.142576
     293005  |   6.890078   .4515298    15.26   0.000     6.005095     7.77506
     293070  |   1.125487   .4829254     2.33   0.020      .178971    2.072004
     293105  |   7.121138   .4518232    15.76   0.000     6.235581    8.006696
     293120  |   3.826011   .4393127     8.71   0.000     2.964974    4.687048
     293122  |   7.804321   .4546338    17.17   0.000     6.913255    8.695387
     296025  |   6.675254   .4507115    14.81   0.000     5.791876    7.558633
     350650  |   .0632673   .7570275     0.08   0.933    -1.420479    1.547014
     373510  |   3.457268   .7178272     4.82   0.000     2.050353    4.864184
     390111  |  -.5472724   .4773945    -1.15   0.252    -1.482948    .3884038
     391525  |  -.7172454   .4566672    -1.57   0.116    -1.612297     .177806
     410490  |   4.799219   .5554058     8.64   0.000     3.710644    5.887795
     410500  |   2.030379   .4285052     4.74   0.000     1.190524    2.870233
     430050  |  -2.477179   .8099212    -3.06   0.002    -4.064595   -.8897626
     490465  |  -.8381657    .534173    -1.57   0.117    -1.885125     .208794
     572853  |  -1.319799   .6197369    -2.13   0.033    -2.534461   -.1051373
     610460  |   1.731264   .5080245     3.41   0.001     .7355546    2.726974
     611790  |   1.871955   .4991009     3.75   0.000      .893735    2.850174
     615100  |   1.460262   .5071585     2.88   0.004     .4662495    2.454274
     616318  |  -3.331272   .6628733    -5.03   0.000     -4.63048   -2.032064
     672285  |  -2.517113   .9311448    -2.70   0.007    -4.342123   -.6921022
     732070  |   -2.26824   .3937935    -5.76   0.000    -3.040061   -1.496419
     750595  |  -3.750522   .7661199    -4.90   0.000    -5.252089   -2.248954
     830660  |    -1.1193   1.606186    -0.70   0.486    -4.267368    2.028767
     852480  |   3.666816   .3500219    10.48   0.000     2.980786    4.352846
     855094  |   7.596703   .5511294    13.78   0.000     6.516509    8.676896
     856181  |    8.16966   .5513959    14.82   0.000     7.088944    9.250376
     856301  |   1.061055   .3221849     3.29   0.001     .4295844    1.692526
     856316  |   6.032521   .5763755    10.47   0.000     4.902845    7.162196
     856354  |   6.276248   .5582118    11.24   0.000     5.182173    7.370324
     891170  |  -.1021386   1.505852    -0.07   0.946    -3.053553    2.849276
     895105  |   .0972098   .5885292     0.17   0.869    -1.056286    1.250706
     912625  |  -1.077211   .2489949    -4.33   0.000    -1.565232   -.5891902
    1130900  |   8.308813   .5522484    15.05   0.000     7.226427      9.3912
    1130950  |   9.268357    .561764    16.50   0.000     8.167319    10.36939
    1131020  |   8.054553   .5506287    14.63   0.000     6.975341    9.133766
    1131021  |     2.1343   .3896453     5.48   0.000     1.370609    2.897991
    1131050  |    8.53057   .5534284    15.41   0.000      7.44587    9.615269
    1131616  |    6.86052   .5527646    12.41   0.000     5.777122    7.943919
    1132055  |   1.917605   .3123224     6.14   0.000     1.305464    2.529746
    1135009  |    7.55054   .5511679    13.70   0.000     6.470271     8.63081
    1135113  |    2.14079   .3093024     6.92   0.000     1.534569    2.747012
    1136005  |   .8234402   .3252121     2.53   0.011     .1860361    1.460844
    1136007  |    2.82033   .3636235     7.76   0.000     2.107641    3.533019
    1136020  |   3.859144   .3616999    10.67   0.000     3.150226    4.568063
    1136061  |   2.701872   .3644803     7.41   0.000     1.987504     3.41624
    1136268  |    7.37859   .5524533    13.36   0.000     6.295801    8.461379
    1152195  |  -5.632152   .8561171    -6.58   0.000    -7.310111   -3.954194
    1171820  |  -.5171817    .700631    -0.74   0.460    -1.890393    .8560299
    1215085  |    2.64356   .3738755     7.07   0.000     1.910777    3.376342
    1215126  |   7.581826   .5521457    13.73   0.000      6.49964    8.664012
    1216088  |   7.359579   .5525179    13.32   0.000     6.276664    8.442494
    1216116  |   7.236129   .5540383    13.06   0.000     6.150234    8.322024
    1230865  |   .8891589   .5874346     1.51   0.130    -.2621917    2.040509
    1270573  |  -4.946507   .5531576    -8.94   0.000    -6.030676   -3.862338
    1352660  |   5.351998   .6386731     8.38   0.000     4.100222    6.603774
    1355097  |   5.503002   .6378799     8.63   0.000     4.252781    6.753224
    1391330  |   1.156073   .3877408     2.98   0.003     .3961152    1.916031
    1393700  |   2.736039   .3633528     7.53   0.000      2.02388    3.448197
    1411240  |   6.252884   .7607014     8.22   0.000     4.761936    7.743831
    1411290  |    7.37093   .7612645     9.68   0.000     5.878879    8.862981
    1411315  |    6.41653   .7616742     8.42   0.000     4.923676    7.909384
    1415013  |   6.263378   .7605075     8.24   0.000      4.77281    7.753945
    1415121  |   6.276602   .7614012     8.24   0.000     4.784283    7.768921
    1433330  |  -1.751691   .4483708    -3.91   0.000    -2.630482   -.8729006
    1492180  |   .0005731    .480982     0.00   0.999    -.9421343    .9432805
    1532323  |   -.795612   .7659745    -1.04   0.299    -2.296894    .7056705
    1572912  |   .1599591   .3500539     0.46   0.648     -.526134    .8460522
    1576276  |  -.3467545   .3542396    -0.98   0.328    -1.041051    .3475424
    1632801  |  -1.663048   .5452003    -3.05   0.002    -2.731621   -.5944749
    1653200  |  -4.231079   .7013686    -6.03   0.000    -5.605736   -2.856422
    1671615  |   8.575234   .5614308    15.27   0.000      7.47485    9.675618
    1672185  |    2.10022   .4487068     4.68   0.000     1.220771    2.979669
    1711511  |  -.3940526   .5198252    -0.76   0.448    -1.412891     .624786
    1776027  |   -1.63299   .6051158    -2.70   0.007    -2.818995   -.4469847
    1792735  |  -14.60824   489.1264    -0.03   0.976    -973.2784    944.0619
    1811145  |   1.474789   .4027433     3.66   0.000     .6854269    2.264152
    1813240  |   1.847851   .3894515     4.74   0.000      1.08454    2.611162
    1832150  |  -.1985035   .4304205    -0.46   0.645    -1.042112    .6451052
    1832327  |   4.880906   .5829909     8.37   0.000     3.738264    6.023547
    1836041  |   .9104229   .3594004     2.53   0.011      .206011    1.614835
    1873189  |   .6600363    .464325     1.42   0.155     -.250024    1.570097
    1892840  |  -1.678203   .6540208    -2.57   0.010     -2.96006   -.3963453
    2010243  |   .1436115   .3517303     0.41   0.683    -.5457672    .8329902
    2011890  |   7.241623   .5577445    12.98   0.000     6.148463    8.334782
    2011895  |   5.606507   .5543415    10.11   0.000     4.520017    6.692996
    2011960  |   .2655249   .3485549     0.76   0.446    -.4176301    .9486799
    2011970  |   5.926767   .5544353    10.69   0.000     4.840094     7.01344
    2011985  |   .3038331   .3478479     0.87   0.382    -.3779363    .9856025
    2012000  |   6.684071   .5550646    12.04   0.000     5.596165    7.771978
    2012005  |   3.388922   .4220574     8.03   0.000     2.561704    4.216139
    2012025  |   .3481246   .3447788     1.01   0.313    -.3276294    1.023879
    2012778  |   6.043455   .5561685    10.87   0.000     4.953384    7.133525
    2013716  |   6.700639   .5558009    12.06   0.000     5.611289    7.789989
    2015022  |   5.944056   .5553406    10.70   0.000     4.855609    7.032504
    2015024  |   6.624304   .5545324    11.95   0.000     5.537441    7.711167
    2015026  |   2.209736   .4288289     5.15   0.000     1.369247    3.050225
    2015120  |   3.221294   .7424901     4.34   0.000      1.76604    4.676548
    2015130  |   8.102188   .6000262    13.50   0.000     6.926159    9.278218
    2015135  |   4.921294   .5578924     8.82   0.000     3.827845    6.014743
    2015140  |   6.410178   .5545291    11.56   0.000     5.323321    7.497035
    2016016  |  -1.332564   .4106145    -3.25   0.001    -2.137354   -.5277745
    2016065  |   5.264396   .5554566     9.48   0.000     4.175721    6.353071
    2016290  |   .9302164   .4381762     2.12   0.034     .0714068    1.789026
    2016302  |   .4491239   .3431995     1.31   0.191    -.2235347    1.121783
    2050890  |  -2.466602    .936869    -2.63   0.008    -4.302832   -.6303728
    2093151  |   .4756479   .4432214     1.07   0.283      -.39305    1.344346
    2130125  |  -.0392614   .3354111    -0.12   0.907    -.6966551    .6181323
    2151200  |   -2.90796   1.118896    -2.60   0.009    -5.100956   -.7149632
    2152561  |   .3477718   .4849489     0.72   0.473    -.6027105    1.298254
    2153723  |  -5.855068   .5478855   -10.69   0.000    -6.928903   -4.781232
    2156047  |   .8206381   .4842031     1.69   0.090    -.1283825    1.769659
    2156335  |   .9914605   .4913421     2.02   0.044     .0284477    1.954473
    2171840  |   .9649349   .4319859     2.23   0.026     .1182581    1.811612
    2192250  |  -.2882454   .5996078    -0.48   0.631    -1.463455    .8869643
    2219225  |    1.30379   .4085481     3.19   0.001     .5030502    2.104529
    2233345  |  -1.156843   .3829819    -3.02   0.003    -1.907474    -.406212
    2250843  |   -3.19983   .6797437    -4.71   0.000    -4.532103   -1.867557
    2275088  |  -6.153532   .6185051    -9.95   0.000     -7.36578   -4.941284
    2311740  |   .5135072   .3375252     1.52   0.128    -.1480302    1.175044
    2330400  |   -1.57666   .6904268    -2.28   0.022    -2.929872   -.2234486
    2412084  |   -3.17591   .5878083    -5.40   0.000    -4.327993   -2.023827
    2450244  |   1.123064   .5684252     1.98   0.048     .0089715    2.237157
    2452849  |   1.446387   .5709136     2.53   0.011     .3274168    2.565357
    2510635  |   2.388198   .3830465     6.23   0.000     1.637441    3.138955
    2576008  |   1.590073   .3942359     4.03   0.000     .8173844    2.362761
    2576026  |   .8396151   .4713466     1.78   0.075    -.0842073    1.763437
    2652135  |  -2.847302   .3543439    -8.04   0.000    -3.541803   -2.152801
    2732160  |  -2.158871   .5690794    -3.79   0.000    -3.274246   -1.043496
    2772760  |   -3.05739   .4373325    -6.99   0.000    -3.914546   -2.200234
    2796032  |  -1.841118   .7027384    -2.62   0.009     -3.21846   -.4637763
    2853800  |  -.9406483   .6390724    -1.47   0.141    -2.193207    .3119106
    2910645  |   .3045124   .4478481     0.68   0.497    -.5732537    1.182279
    2932533  |   -3.26939   .9538623    -3.43   0.001    -5.138926   -1.399854
    2992318  |   .0109625   .4822013     0.02   0.982    -.9341346    .9560596
    3036011  |   6.447593   .6397095    10.08   0.000     5.193785    7.701401
    3093650  |   6.439217    .524922    12.27   0.000     5.410389    7.468045
    3093660  |    .229712    .267746     0.86   0.391    -.2950606    .7544846
    3210235  |  -.9068866   .5137004    -1.77   0.077    -1.913721    .0999476
    3231175  |  -5.365022   .5611185    -9.56   0.000    -6.464794    -4.26525
    3251853  |  -.1601939   .5776635    -0.28   0.782    -1.292394    .9720058
    3292535  |   2.880055    .645656     4.46   0.000     1.614593    4.145518
    3390720  |   5.326524   .5566023     9.57   0.000     4.235603    6.417444
    3396057  |   6.291776   .5535093    11.37   0.000     5.206918    7.376634
    3396189  |   4.651304   .5596564     8.31   0.000     3.554398     5.74821
    3396327  |   5.922163   .5545884    10.68   0.000      4.83519    7.009136
    3472582  |   .3139051   .3867041     0.81   0.417    -.4440211    1.071831
    3475093  |    .091773   .3899965     0.24   0.814    -.6726061    .8561521
    3490795  |  -.9643762   .4155386    -2.32   0.020    -1.778817   -.1499354
    3535132  |  -2.533714   .5756925    -4.40   0.000     -3.66205   -1.405377
    3550740  |   4.703337   .4203039    11.19   0.000     3.879556    5.527117
    3556218  |   6.153261   .4146268    14.84   0.000     5.340607    6.965915
    3572814  |  -7.381928   .7971011    -9.26   0.000    -8.944218   -5.819638
    3612695  |  -2.740259   .4638072    -5.91   0.000    -3.649305   -1.831214
    3632567  |   .4154463   .4446591     0.93   0.350    -.4560695    1.286962
    3650574  |  -1.247193   .5769345    -2.16   0.031    -2.377964   -.1164222
    3673715  |     2.1254   .3950353     5.38   0.000     1.351145    2.899655
    3732315  |  -1.393145   .4604588    -3.03   0.002    -2.295627    -.490662
    3750063  |   6.980438   .6953274    10.04   0.000     5.617621    8.343255
    3750070  |   7.473737    .695147    10.75   0.000     6.111274    8.836201
    3896014  |  -8.507781   .7992762   -10.64   0.000    -10.07433   -6.941228
    3976115  |   6.129568   .5577407    10.99   0.000     5.036416     7.22272
    4011810  |   .2128159   .3719664     0.57   0.567    -.5162249    .9418566
    4190582  |  -2.865156   .5078006    -5.64   0.000    -3.860427   -1.869885
    4233565  |   -3.89922   .4176007    -9.34   0.000    -4.717702   -3.080737
    4275095  |  -7.386906   .6948808   -10.63   0.000    -8.748848   -6.024965
    4390108  |   7.545061   .5506198    13.70   0.000     6.465866    8.624256
    4390285  |   7.197491   .5522514    13.03   0.000     6.115098    8.279884
    4391390  |   7.753732    .551044    14.07   0.000     6.673706    8.833758
    4391437  |   2.891653    .362986     7.97   0.000     2.180214    3.603093
    4391440  |    8.92966   .5525548    16.16   0.000     7.846672    10.01265
    4391483  |   8.468256   .5505263    15.38   0.000     7.389244    9.547267
    4391739  |   8.045275   .5515482    14.59   0.000     6.964261     9.12629
    4395139  |   8.245076    .552635    14.92   0.000     7.161931    9.328221
    4395142  |   3.214933   .3621047     8.88   0.000     2.505221    3.924645
    4396125  |   7.210208   .5533626    13.03   0.000     6.125638    8.294779
    4396401  |   3.382157   .3608356     9.37   0.000     2.674933    4.089382
    4410020  |  -1.254156    .402593    -3.12   0.002    -2.043224   -.4650887
    4410034  |    5.06818   .5902235     8.59   0.000     3.911363    6.224996
    4450450  |  -2.034722   .7030534    -2.89   0.004    -3.412682   -.6567629
    4492573  |  -.0259756   .3966482    -0.07   0.948    -.8033918    .7514406
    4513000  |   4.360472   .5816588     7.50   0.000     3.220441    5.500502
    4516013  |   4.849351   .5776163     8.40   0.000     3.717244    5.981458
    4530170  |   6.566401    .482694    13.60   0.000     5.620338    7.512464
    4530190  |   7.003038   .4834589    14.49   0.000     6.055476      7.9506
    4530200  |   6.805785    .481869    14.12   0.000     5.861339     7.75023
    4536048  |   .0079968   .1417563     0.06   0.955    -.2698404     .285834
    4536253  |   6.399198   .4830977    13.25   0.000     5.452344    7.346052
    4536337  |   .4345691   .1214594     3.58   0.000     .1965131    .6726252
    4536338  |   1.415159   .4338424     3.26   0.001     .5648433    2.265474
    4633580  |  -4.971679   .3683003   -13.50   0.000    -5.693534   -4.249824
    4651139  |   -2.55717   .5131106    -4.98   0.000    -3.562849   -1.551492
    4693630  |   6.742392   .4819455    13.99   0.000     5.797796    7.686987
    4716028  |  -.6629252   .4851042    -1.37   0.172    -1.613712    .2878616
    4770430  |   .1415054   .5395819     0.26   0.793    -.9160558    1.199067
    4792220  |   .1052847    .093782     1.12   0.262    -.0785246    .2890939
    4792230  |          0  (omitted)
    4813735  |   .0209107   .4957842     0.04   0.966    -.9508085    .9926299
    4853790  |  -5.344428   .4354469   -12.27   0.000    -6.197888   -4.490967
    4916029  |   1.886957   .4155449     4.54   0.000     1.072504     2.70141
    4916068  |          0  (omitted)
    4916419  |   .5360715   .5044078     1.06   0.288    -.4525496    1.524693
    4975091  |    2.57489   .3813758     6.75   0.000     1.827407    3.322373
    4992851  |  -1.801784    .603704    -2.98   0.003    -2.985022   -.6185459
    5011163  |  -5.886059   1.312132    -4.49   0.000    -8.457791   -3.314327
    5032670  |  -1.663299   1.104223    -1.51   0.132    -3.827536    .5009372
    5035018  |   -1.48133   .5608356    -2.64   0.008    -2.580548   -.3821123
             |
Obstetrics~l |
          1  |          0  (omitted)
          2  |          0  (omitted)
          3  |          0  (omitted)
------------------------------------------------------------------------------



*/
	
