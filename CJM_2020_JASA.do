********************************************************************************
* Empirical Illustration
* M.D. Cattaneo, M. Jansson, X. Ma
* 21-AUG-2020
********************************************************************************

* net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace
* net install lpdensity, from(https://raw.githubusercontent.com/nppackages/lpdensity/master/stata) replace

********************************************************************************
********************************************************************************
* NOTE: If you are using RDDENSITY version 2020 or newer, the option "nomasspoints" may be needed to 
* replicate the results in the paper. For example:
*
*     rddensity X
*
* should be replaced by:
*
*     rddensity X, nomasspoints
********************************************************************************
********************************************************************************

********************************************************************************
********************************************************************************
* Headstart Data
********************************************************************************
********************************************************************************

clear all
set more off

**********************************
* import data
**********************************
use "headstart.dta"
preserve
replace povrate60 = povrate60 - 59.198

**********************************
* manipulation test with different bandwidths on each side
**********************************
rddensity povrate60, p(1) bwselect(each) 
rddensity povrate60, p(2) bwselect(each) 
rddensity povrate60, p(3) bwselect(each) 

**********************************
* manipulation test with common bandwidth for both sides
**********************************
rddensity povrate60, p(1) bwselect(diff) 
rddensity povrate60, p(2) bwselect(diff) 
rddensity povrate60, p(3) bwselect(diff)

**********************************
* density plot, different bandwidths with local quadratic fit
**********************************
rddensity povrate60, p(2) bwselect(each) ///
	plot plot_range(-40 20) plot_n(100 100) ///
	graph_options(xtitle("Running Variable") legend(off) yscale(r(0 0.035)))

**********************************
* histogram
**********************************
hist povrate60, xline(0) xtitle("Running Variable") ytitle("") legend(off) ///
	yscale(r(0 0.035))
	
restore
