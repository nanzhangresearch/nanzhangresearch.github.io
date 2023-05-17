* creating the data
* ----------------

clear all
set obs 6

gen m1 = .
replace m1 = 1 in 1 / 2
replace m1 = 3 in 3 / 4
replace m1 = 2 in 5 / 6

gen m0 = .
replace m0 = 1 in 1 / 2
replace m0 = 0 in 3 / 4
replace m0 = 2 in 5 / 6

gen y1 = .
replace y1 = 1 in 1 / 2
replace y1 = 3 in 3 / 4
replace y1 = 5 in 5 / 6

gen y0 = .
replace y0 = 0 in 1 / 2
replace y0 = 2 in 3 / 4
replace y0 = 4 in 5 / 6

gen z = .
replace z = 0 in 1
replace z = 0 in 3
replace z = 0 in 5
replace z = 1 in 2
replace z = 1 in 4
replace z = 1 in 6

gen y = y0 if z == 0
replace y = y1 if z == 1

gen m = m0 if z == 0
replace m = m1 if z == 1

expand 200


* regression
* ------------

reg y z

reg y z m


* errors
* -------
cap drop temp*

reg m z
predict temp1
gen e1 = y - temp1

reg y z m
predict temp2
gen e2 = y - temp2


pwcorr e1 e2


