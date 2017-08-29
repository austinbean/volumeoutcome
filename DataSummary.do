* Making a table

do "/Users/austinbean/Desktop/Birth2005-2012/FilePathGlobal.do"
capture quietly do "/Users/austinbean/Google Drive/Annual Surveys of Hospitals/TX Global Filepath Names.do"


use "${birthdata}Births2005-2012wCounts.dta"


* Fraction born in hospitals:

forvalues n = 2005/2012{

quietly count if ncdobyear == `n' & b_bplace != 1
local cn = `r(N)'

quietly count if ncdobyear == `n'
local dn = `r(N)'

local rat = (`dn'-`cn')/`dn'

di " `n', `rat'"

}



* Mortality rates by year:

forvalues n = 2005/2012{


quietly count if ncdobyear == `n'
local cn = `r(N)'

quietly count if neonataldeath == 1 & ncdobyear == `n'
local dn = `r(N)'

local dr = (`dn'/`cn')*1000

di "`n', `dr'"

}


* Fraction Male

forvalues n = 2005/2012{

quietly count if ncdobyear == `n'
local cn = `r(N)'

quietly count if bs_sex == 1 & ncdobyear == `n'
local mn = `r(N)'

local ml = `mn'/`cn'

di " Fraction Male `n', `ml'"

}

* Gestational Age mean/sd

forvalues n = 2005/2012{

quietly summarize b_es_ges if ncdobyear == `n'
local mn = `r(mean)'
local sd = `r(sd)'

di "`n', mean `mn', sd `sd' "
}

* Birth weight

forvalues n = 2005/2012{

quietly summarize b_wt_cgr if ncdobyear == `n'
local mn = `r(mean)'
local sd = `r(sd)'

di "Weight `n', mean `mn', sd `sd' "
}


* Fraction Transferred

forvalues n = 2005/2012{

quietly count if ncdobyear == `n'
local cn = `r(N)'

quietly count if bo_trans == 1 & ncdobyear == `n'
local mn = `r(N)'

local ml = `mn'/`cn'

di " Fraction transferred `n', `ml'"

}

* Unique facilities:

preserve

keep if b_bplace == 1

forvalues n = 2005/2012{
di "`n'"
unique facname if ncdobyear == `n'


}

restore


* Distance Traveled by year
forvalues n = 2005/2012{

quietly summarize chdist if ncdobyear == `n', d
local cn = `r(mean)'
local sn = `r(sd)'
local p5 = `r(p5)'
local p95 = `r(p95)'

di " distance `n', `cn', `sn'"
di " `n', `p5', `p95' "

}

* closest hospital by year:

forvalues n = 2005/2012{

quietly summarize zipfacdistancecn1 if ncdobyear == `n'


}


* Insurance status:

bysort ncdobyear: tab pay


* Race

gen race = 0

replace race = 1 if m_rblack == 1
replace race = 2 if m_rwhite == 1
replace race = 3 if m_asian == 1
label define rl 1 "Af/Am"
label define rl 2 "White", add
label define rl 3 "Asian", add
label define rl 0 "Other", add
label values race rl

bysort ncdobyear: tab race
