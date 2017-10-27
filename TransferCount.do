* Count transfers by year

* use "${birthdata}Birth2005.dta", clear


keep if bo_trans == 1  

* What do I want to do... I need to REMOVE these from some facilities, especially those
* w/out level 2 or 3.
* then add them back to those which do.  
* Note two hospitals in Arkansas: Arkansas childrens and Schumpert.  

bysort facname ncdobmonth: gen ts_i = sum(bo_trans)
bysort facname ncdobmonth: egen transout = max(ts_i)

bysort 
