cd "D:\desktop\research\electric vehicle\Code and Data"

**Descriptive statistics Table S1
use EV_Carbon, clear
estpost summarize co2 sales gdp popu temp stp wdsp prcp flowin flowout stnum r2001 fossilele
esttab using sum.xls, cells(" count(fmt(%12.0f)) mean(fmt(%12.2f)) sd(fmt(%12.2f)) min(fmt(%12.2f)) max(fmt(%12.2f))") title("Descriptive Statistics") replace

**benchmark Table1 
clear all
use EV_Carbon,clear
xtset id ym
xtreg lnco2 ln_ev i.ym, fe vce(cluster id) 
est store result01
xtreg lnco2 ln_ev lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout i.ym, fe vce(cluster id)
est store result02
xtreg ln_ev lnstn lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout i.ym, fe vce(cluster id)
est store result03
ivreghdfe lnco2 lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout (ln_ev =lnstn), absorb (id ym) cluster (id)
est store result04
outreg2 [result01 result02 result03 result04] using benchmark.doc, replace

**Robustness Check substitution Table S3
use EV_Carbon, clear

ivreghdfe lnn2o lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout (ln_ev =lnstn), absorb (id ym) cluster (id)
est store n2o
ivreghdfe lnch4 lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout (ln_ev =lnstn), absorb (id ym) cluster (id)
est store ch4
ivreghdfe lnghg lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout (ln_ev =lnstn), absorb (id ym) cluster (id)
est store ghg
ivreghdfe lnco2m lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout (ln_ev =lnstn), absorb (id ym) cluster (id)
est store co2m
outreg2 [n2o ch4 ghg co2m] using sub.doc, replace 


**mechanism Table 2
use EV_Carbon, clear
xtset id ym

ivreghdfe lnco2 lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout (ln_ev =lnstn), absorb (id ym) cluster (id)
est store ivreg
xtreg lnfossilele ln_ev lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout i.ym, fe vce(cluster id)
est store pathway
ivreghdfe lnfossilele lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout (ln_ev =lnstn), absorb (id ym) cluster (id)
est store pathway_iv
outreg2 [ivreg pathway pathway_iv] using mechanism.doc, replace

**Heterogeneity region Table S2
use EV_Carbon,clear
xtset id ym

ivreghdfe lnco2 lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout (ln_ev =lnstn)  if  cleanratio<=0.2, absorb (id ym) cluster (id)
est store c1
ivreghdfe lnco2 lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout (ln_ev =lnstn)  if  cleanratio>0.2 & cleanratio<0.5, absorb (id ym) cluster (id)
est store c2
ivreghdfe lnco2 lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout (ln_ev =lnstn)  if  cleanratio>=0.5, absorb (id ym) cluster (id)
est store c3
outreg2 [c1 c2 c3] using clean.doc, replace

**Saptial regression Table3 Columns (1) and (2)
clear all
use EV_Carbon, clear
xtset id ym
xtbalance, range(684,755)
duplicates drop id, force
spwmatrix gecon latitude longitude, wn(wbin) wtype(inv) alpha(1) db(0 500) rowstand
svmat wbin
save web1, replace 
use EV_Carbon, clear
xtset id ym
xtbalance, range(684 755)

foreach var in temp lnpopu lngdp lnstp lnwdsp lnprcp lnflowin lnflowout {
	bysort ym: egen `var'_mean = mean(`var')
    replace `var' = `var'_mean if missing(`var')
    drop `var'_mean
}
save spreg, replace
//LM test
use web1, clear
spmat dta web1 wbin*, id(id) normalize(row)
spcs2xt wbin*, matrix(kuoda) time(72)
spatwmat using kuodaxt, name(W)
use spreg, clear 
xtset id ym
reg lnco2 ln_ev temp lnpopu lngdp lnstp lnwdsp lnprcp lnflowin lnflowout
spatdiag, weights(W)
//spatial regression
clear all
use web1, clear
spmat dta web1 wbin*, id(id) normalize(row)
use spreg, clear 
xtset id ym
xsmle lnco2 ln_ev temp lnpopu lngdp lnstp lnwdsp lnprcp lnflowin lnflowout, wmat(web1) fe type(both,leeyu) model(sar) cluster(id)
est store sar
xsmle lnco2 ln_ev temp lnpopu lngdp lnstp lnwdsp lnprcp lnflowin lnflowout, emat(web1) fe type(both,leeyu) model(sem) cluster(id)
est store sem
outreg2 [sar sem] using spreg.doc, replace

spxtregress lnco2 ln_ev temp lnpopu lngdp lnstp lnwdsp lnprcp lnflowin lnflowout, dvarlag(w) fe 
help spxtregress
spxtregress y x1 x2, fe dvarlag(web1)
estat lmdiag

**Saptial regression Table3 Colomns (3) and (4)
clear all
use EV_Carbon, clear
xtset id ym
xtbalance, range(684 755)
duplicates drop id, force
spwmatrix gecon latitude longitude, wn(web2) wtype(bin) db(0 500) rowstand
svmat web2
save web2, replace
use EV_Carbon, clear
xtset id ym
xtbalance, range(684 755)
foreach var in temp lnpopu lngdp lnstp lnwdsp lnprcp lnflowin lnflowout {
	bysort ym: egen `var'_mean = mean(`var')
    replace `var' = `var'_mean if missing(`var')
    drop `var'_mean
}
save spreg2, replace 
//LM test
use web2
spmat dta web2 web2*, id(id) normalize(row)
spcs2xt web2*, matrix(kuoda2) time(72)
spatwmat using kuoda2xt, name(W)
use spreg2, clear 
xtset id ym
reg lnco2 ln_ev temp lnpopu lngdp lnstp lnwdsp lnprcp lnflowin lnflowout
spatdiag, weights(W)
//spatial regression
clear all
use web2
spmat dta web2 web2*, id(id) normalize(row)
use spreg2, clear
xtset id ym
xsmle lnco2 ln_ev temp lnpopu lngdp lnstp lnwdsp lnprcp lnflowin lnflowout, wmat(web2) fe type(both,leeyu) model(sar) cluster(id)
est store sar
xsmle lnco2 ln_ev temp lnpopu lngdp lnstp lnwdsp lnprcp lnflowin lnflowout, emat(web2) fe type(both,leeyu) model(sem) cluster(id)
est store sem
outreg2 [sar sem] using web.doc, replace


**scenario analysis TableS6
use EV_Carbon, clear

collapse (sum) co2 (mean) ev_ratio cleanratio lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout lnstn, by(city year month) 
replace co2=co2/1000
reghdfe co2 c.ev_ratio##c.cleanratio lngdp lnpopu temp lnstp lnwdsp lnprcp lnflowin lnflowout, absorb (city year month) cluster(city)

clear
set obs 21
gen ev_ratio = (_n - 1)/20
tempfile evs
save `evs'

clear
set obs 21
gen cleanratio = (_n - 1)/20
tempfile cleans
save `cleans'

use `evs', clear
cross using `cleans'
gen yhat = _b[_cons] ///
          + _b[ev_ratio]*ev_ratio ///
          + _b[cleanratio]*cleanratio ///
          + _b[c.ev_ratio#c.cleanratio]*ev_ratio*cleanratio
twoway (contour yhat cleanratio ev_ratio, levels(15)), ///
    title("Predicted lnCO2 by EV ratio and Clean ratio") ///
    xtitle("Clean Ratio") ytitle("EV Ratio") ///
    scheme(s2color)

**data for figure1
use EV_Carbon, clear
collapse (sum) co2 sales, by (yearmonth)

**data for figure 2 
use EV_Carbon, clear
collapse (mean) ev_ratio cleanratio, by(yearmonth)
