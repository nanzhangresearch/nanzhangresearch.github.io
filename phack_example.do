clear all

set seed 1

set obs 1600  // number of participants

gen id = _n  // assigning each participant a numerical id

gen subgroup = ceil(id / 80)  // splitting the sample into 20 subgroups, each with 80 people

gen tx = mod(id, 2)  // assigning T and C to every other person

tab subgroup tx  // check it out

gen y = runiform() // observed outcome is a random number.  By definition, there is no treatment effect



reg y tx // ATE not statistically different from 0


// the following code estimates and plots the CATE for each subgroup
matrix define A = J(20,4,0)

forvalues i = 1 / 20 {
	
	qui reg y i.tx##ib`i'.subgroup
	qui lincom 1.tx
	
	matrix A[`i',1] = `r(estimate)'
	matrix A[`i',2] = `r(ub)'
	matrix A[`i',3] = `r(lb)'
	matrix A[`i',4] = `r(p)'
	
}
svmat A
gen N = _n if A1 != .

twoway ///
	(scatter N A1 if A4 > 0.05, msym(O)) ///
	(scatter N A1 if A4 <= 0.05, msym(O) mcolor(blue)) ///
	(rcap A2 A3 N if A4 > 0.05, horizontal msize(tiny)) ///
	(rcap A2 A3 N if A4 <= 0.05, horizontal msize(tiny) lcolor(blue)) ///
	, scheme(lean2) legend(off) ///
	xline(0, lcolor(red)) ///
	ytitle("Subgroup") ///
	ylab(1(1)20) ///
	xtitle("CATE with 95% CIs") ///
	xsize(1) ysize(2)

