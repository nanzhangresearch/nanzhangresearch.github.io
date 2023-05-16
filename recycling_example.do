clear all

* creating the data

set obs 3279

gen temp = _n

gen tx = temp > 1430

gen canvassed = tx == 1 & (temp > 1430 & temp <= 2445)

gen y = 0
replace y = 1 if temp <= 377 & tx == 0
replace y = 1 if tx == 1 & canvassed == 1  & (temp > 1430 & temp <= 1859)
replace y = 1 if tx == 1 & canvassed == 0  & temp > 3117

* checking that everything is correctly created
tab tx y
tab canvassed y if tx == 1



* first stage
reg canvassed tx

predict dhat // predicted treatment status based on treatment assignment


* second stage
reg y dhat

* ITT
reg y tx


* dividing the ITT by the compliance rate...confirming this is the same as the second stage regression
di .0559959  /  .5489454 


* 2sls
ivregress 2sls y (canvassed=tx)



* ----------------------------------------------------
* Weak Instrument Example
* -----------------------------------------------------

clear all

* creating the data
set obs 1000
set seed 1

gen y0 = rnormal()  // potential outcome if d = 0
gen y1 = y0 + 1    // potential outcome if d = 1


* 100 randomizations with strong instrument
matrix define A = J(100,2,0) // matrix to store the results

forvalues row = 1 / 100 {
	
	preserve
	
	set seed `row'
	
	gen temp = runiform()
	sort temp
	
	gen tx = 0 in 1 / 500
	replace tx = 1 if tx == .
	
	qui su temp if tx == 1, detail
	gen d = tx == 1 & temp > `r(p50)'  // 50% compliance
	
	gen y = y0
	replace y = y1 if d == 1
	
	qui ivregress 2sls y (d=tx)
	qui lincom d
	
	matrix A[`row',1] = `r(estimate)'
	matrix A[`row',2] = `r(p)'
	
	restore	
}



* 100 randomizations with weak instrument
matrix define B = J(100,2,0) // matrix to store the results

forvalues row = 1 / 100 {
	
	preserve
	
	set seed `row'
	
	gen temp = runiform()
	sort temp
	
	gen tx = 0 in 1 / 500
	replace tx = 1 if tx == .
	
	qui su temp if tx == 1, detail
	gen d = tx == 1 & temp > `r(p90)'  // 10% compliance
	
	gen y = y0
	replace y = y1 if d == 1
	
	qui ivregress 2sls y (d=tx)
	qui lincom d
	
	matrix B[`row',1] = `r(estimate)'
	matrix B[`row',2] = `r(p)'
	
	restore	
}




* graphing

svmat A 
svmat B

kdensity A1, addplot(kdensity B1) ///
	legend(order(1 "Strong Instrument" 2 "Weak Instrument")) ///
	xtitle("2SLS estimate of CACE")

	
	
sort A1
cap drop tempa
gen tempa = _n if A1 != .
twoway (scatter tempa A1 if A2 < 0.05, msym(O)) ///
	(scatter tempa A1 if A2 >= 0.05, msym(Oh)) ///
	, nodraw name(strong, replace) ///
	xline(1) ///
	xtitle("2SLS estimate of CACE") ///
	title("Strong Instrument") ///
	legend(off)


sort B1
cap drop tempb
gen tempb = _n if B1 != .
twoway (scatter tempb B1 if B2 < 0.05, msym(O)) ///
	(scatter tempb B1 if B2 >= 0.05, msym(Oh)) ///
	, nodraw name(weak, replace) ///
	xline(1) ///
	xtitle("2SLS estimate of CACE") ///
	title("Weak Instrument") ///
	legend(off)

	
graph combine strong weak, xcommon

