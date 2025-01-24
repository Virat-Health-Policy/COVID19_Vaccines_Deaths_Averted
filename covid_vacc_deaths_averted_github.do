


********************************************************************************
//--------------------------------------------------------------------------- //
* The Impact of the Global COVID-19 Vaccination Campaign on All-Cause Mortality *
//--------------------------------------------------------------------------- //
********************************************************************************

* This do file was originally created in STATA17-MP

clear all
cd "/Users/xxxxxxxxx/Deaths_Averted"
set scheme burd4


capture mkdir output
global output "/Users/xxxxxxxxx/Deaths_Averted/output"



********************************************************************************
//--------------------------------------------------------------------------- //
***** --------------------  Descriptive Analysis ----------------------- *******
//--------------------------------------------------------------------------- //
********************************************************************************



********************************************************************************
//------------------ 1. Twoway Plots Mar 2020 - Aug 2021 ------------------- //
//----------------- Descriptive Trends of Deaths and Vacc  ----------------- //
********************************************************************************


use economist_owidvacc_weekly_data_mar2020_aug2021.dta, clear

drop if country == "Luxembourg" // because we don't have it in regerssion data

distinct country // 43

collapse (sum) covid_deaths excess_deaths non_covid_deaths noncovid_exdeaths ///
people_fully_vacc_ipo population, by(time)


label define time_axis 1 "Mar Week 1, 2020" 2 "Mar Week 2, 2020" 3 "Mar Week 3, 2020" 4 "Mar Week 4, 2020" ///
5 "Apr Week 1, 2020" 6 "Apr Week 2, 2020" 7 "Apr Week 3, 2020" 8 "Apr Week 4, 2020" 9 "Apr Week 5, 2020" ///
10 "May Week 1, 2020" 11 "May Week 2, 2020" 12 "May Week 3, 2020" 13 "May Week 4, 2020" ///
14 "Jun Week 1, 2020" 15 "Jun Week 2, 2020" 16 "Jun Week 3, 2020" 17 "Jun Week 4, 2020" ///
18 "Jul Week 1, 2020" 19 "Jul Week 2, 2020" 20 "Jul Week 3, 2020" 21 "Jul Week 4, 2020" 22 "Jul Week 5, 2020" ///
23 "Aug Week 1, 2020" 24 "Aug Week 2, 2020" 25 "Aug Week 3, 2020" 26 "Aug Week 4, 2020" ///
27 "Sep Week 1, 2020" 28 "Sep Week 2, 2020" 29 "Sep Week 3, 2020" 30 "Sep Week 4, 2020" 31 "Sep Week 5, 2020" ///
32 "Oct Week 1, 2020" 33 "Oct Week 2, 2020" 34 "Oct Week 3, 2020" 35 "Oct Week 4, 2020" ///
36 "Nov Week 1, 2020" 37 "Nov Week 2, 2020" 38 "Nov Week 3, 2020" 39 "Nov Week 4, 2020" ///
40 "Dec Week 1, 2020" 41 "Dec Week 2, 2020" 42 "Dec Week 3, 2020" 43 "Dec Week 4, 2020" 44 "Dec Week 5, 2020" ///
45 "Jan Week 1, 2021" 46 "Jan Week 2, 2021" 47 "Jan Week 3, 2021" 48 "Jan Week 4, 2021" ///
49 "Feb Week 1, 2021" 50 "Feb Week 2, 2021" 51 "Feb Week 3, 2021" 52 "Feb Week 4, 2021" ///
53 "Mar Week 1, 2021" 54 "Mar Week 2, 2021" 55 "Mar Week 3, 2021" 56 "Mar Week 4, 2021" 57 "Mar Week 5, 2021" ///
58 "Apr Week 1, 2021" 59 "Apr Week 2, 2021" 60 "Apr Week 3, 2021" 61 "Apr Week 4, 2021" ///
62 "May Week 1, 2021" 63 "May Week 2, 2021" 64 "May Week 3, 2021" 65 "May Week 4, 2021" ///
66 "Jun Week 1, 2021" 67 "Jun Week 2, 2021" 68 "Jun Week 3, 2021" 69 "Jun Week 4, 2021" 70 "Jun Week 5, 2021" ///
71 "Jul Week 1, 2021" 72 "Jul Week 2, 2021" 73 "Jul Week 3, 2021" 74 "Jul Week 4, 2021" ///
75 "Aug Week 1, 2021" 76 "Aug Week 2, 2021" 77 "Aug Week 3, 2021" 78 "Aug Week 4, 2021" ///

label values time time_axis


*** ------------------ Generate Cumulative ---------------------- *** 

** Covid deaths
gen cum_covid_deaths = covid_deaths
replace cum_covid_deaths = cum_covid_deaths[_n] + cum_covid_deaths[_n-1] if time > 1
replace cum_covid_deaths  = round(cum_covid_deaths)

** Excess deaths
gen cum_excess_deaths = excess_deaths
replace cum_excess_deaths = cum_excess_deaths[_n] + cum_excess_deaths[_n-1] if time > 1
replace cum_excess_deaths  = round(cum_excess_deaths)

** Cum Deaths per 100k
gen cum_covid_deaths_per100k = (cum_covid_deaths/population)*100000
gen cum_excess_deaths_per100k = (cum_excess_deaths/population)*100000


** People Fully Vacc per 100
gen cum_ppl_fully_vacc_per100 = (people_fully_vacc_ipo/population)*100
replace cum_ppl_fully_vacc_per100  = round(cum_ppl_fully_vacc_per100)



*** ---------  Two Way Plots: Cum. excess deaths vs % Fully Vacc -------- ***

graph twoway (line cum_excess_deaths_per100k time, lwidth(medthick) lpattern(dash_dot)) ///
(lfit cum_excess_deaths_per100k time if time >= 32 & time <= 52, lwidth(medium) lcolor(brown)) ///
(lfit cum_excess_deaths_per100k time if time >= 58 & time <= 78, lwidth(medium) lcolor(orange_red)) ///
(line cum_ppl_fully_vacc_per100 time, lwidth(medthick) yaxis(2)), ///
xlabel(0(4)78,valuelabel angle(45) labsize(vsmall)) ///
ylabel(0(20)240,labsize(vsmall)) ///
ylabel(0(5)50, axis(2) labsize(vsmall)) ///
xtitle("Time Period", size(medsmall)) ///
ytitle("Cum. Excess Deaths / 100,000", size(medsmall)) ///
ytitle("Full Vaccination Rate", axis(2) size(medsmall)) ///
legend(order(1 "Excess Deaths" 4 "Percentage People Fully Vaccianted") size(2.5) col(3)) ///
text(120 35 "Slope = 5.2", size(vsmall)) ///
text(210 63 "Slope = 2.1", size(vsmall))

graph export "$output/trend_cum_exdeaths_vacc.png", replace





******************************************************************************** 
// ----------- 2. Scatter Plots: Relationship Deaths and Countries  ----------- //
********************************************************************************


*** ------------  Merge 2021 and 2020 files ------------ ***

* 2021 File
use owid_vacc2021_economist2021_cum_aug2021, clear 


* 2020 File
merge 1:1 country_a3_code using owid_vacc_jan-aug2021_economist_deaths_mar-dec2020_cum, ///
keepusing(total_deaths_2020 covid_deaths_2020 excess_deaths_2020 ///
non_covid_deaths_2020 country) // 45 merge
drop _merge

drop if country == "Luxembourg" | country == "Montenegro" // Not in Regression

distinct country // 43


*** ------------------ Generate per 100K  -------------------- ***
* 2021
gen covid_deaths_per_100k_2021 = (covid_deaths_2021/population)*100000
gen excess_deaths_per_100k_2021 = (excess_deaths_2021/population)*100000\
replace covid_deaths_per_100k_2021 = round(covid_deaths_per_100k_2021)
replace excess_deaths_per_100k_2021 = round(excess_deaths_per_100k_2021)

gen fully_vacc_per100 = (people_fully_vacc_ipo/population)*100
replace fully_vacc_per100 = round(fully_vacc_per100)


* 2020
gen covid_deaths_per_100k_2020 = (covid_deaths_2020/population)*100000
gen excess_deaths_per_100k_2020 = (excess_deaths_2020/population)*100000
replace covid_deaths_per_100k_2020 = round(covid_deaths_per_100k_2020)
replace excess_deaths_per_100k_2020 = round(excess_deaths_per_100k_2020)


* Diff 2020 - 2021
gen diff_excess_deaths_per_100k = excess_deaths_per_100k_2021 - excess_deaths_per_100k_2020
gen diff_covid_deaths_per_100k = covid_deaths_per_100k_2021 - covid_deaths_per_100k_2020




*** ------------ Scatter plots Excess deaths vs Vaccines ------------ ***


** 2020 and 2021 vs Vaccination
local vars excess_deaths_per_100k_2021 excess_deaths_per_100k_2020

foreach var of local vars {
	if "`var'" == "excess_deaths_per_100k_2021" {
		local ytitle "Cum. Excess Deaths / 100K"
		local title "Deaths (Jan - Aug 2021), Vaccines(Jan - Aug 2021)"
		local text "Slope = -2.18"
	}
	if "`var'" == "excess_deaths_per_100k_2020" {
		local ytitle "Cum. Excess Deaths / 100K"
		local title "Deaths (Mar - Dec 2020), Vaccines(Jan - Aug 2021)"
		local text "Slope = -0.62"
	}
	

graph twoway (lfitci `var' fully_vacc_per100) ///
(scatter `var' fully_vacc_per100, ///
msymbol(circle) msize(tiny) mcolor(navyblue) ///
mlabel(country_a3_code) mlabsize(tiny) mlabcolor(navyblue) mlabposition(3)), ///
xlabel(0(10)80,angle(45) labsize(small)) ///
ylabel(-50(50)350,labsize(vsmall)) legend(off) ///
text(300 70 "`text'", size(small)) yline(0, lc(red) lp(dash)) ///
xtitle("Percentage People Fully Vaccinated", size(medsmall)) ///
ytitle("`ytitle'", size(medsmall)) ///
title("`title'", size (medium))

graph export "$output/`var'.png", replace

}


** Change from 2020 to 2021 vs Vaccination
local vars diff_excess_deaths_per_100k

foreach var of local vars {
	
	if "`var'" == "diff_excess_deaths_per_100k" {
		local ytitle "Change in Cum. Excess Deaths / 100K"
		local text "Slope = -1.56"
	}
	

graph twoway (lfitci `var' fully_vacc_per100) ///
(scatter `var' fully_vacc_per100, ///
msymbol(circle) msize(tiny) mcolor(navyblue) ///
mlabel(country_a3_code) mlabsize(tiny) mlabcolor(navyblue) mlabposition(3)), ///
xlabel(0(10)80,angle(45) labsize(small)) ///
ylabel(-200(50)200,labsize(vsmall)) legend(off) ///
text(150 70 "`text'", size(small)) yline(0, lc(red) lp(dash)) ///
xtitle("Percentage People Fully Vaccinated", size(medsmall)) ///
ytitle("`ytitle'", size(medsmall))

graph export "$output/`var'.png", replace

}






********************************************************************************
********************************************************************************
//--------------------------------------------------------------------------- //
********* --------------------  Main Analysis ---------------------- **********
//--------------------------------------------------------------------------- //
********************************************************************************
********************************************************************************


program define regression_full_data

use economist_owidvacc_weekly_data_mar2020_aug2021.dta, clear

drop if country == "Luxembourg" // Data not fit

label define time_axis 1 "Mar Week 1, 2020" 2 "Mar Week 2, 2020" 3 "Mar Week 3, 2020" 4 "Mar Week 4, 2020" ///
5 "Apr Week 1, 2020" 6 "Apr Week 2, 2020" 7 "Apr Week 3, 2020" 8 "Apr Week 4, 2020" 9 "Apr Week 5, 2020" ///
10 "May Week 1, 2020" 11 "May Week 2, 2020" 12 "May Week 3, 2020" 13 "May Week 4, 2020" ///
14 "Jun Week 1, 2020" 15 "Jun Week 2, 2020" 16 "Jun Week 3, 2020" 17 "Jun Week 4, 2020" ///
18 "Jul Week 1, 2020" 19 "Jul Week 2, 2020" 20 "Jul Week 3, 2020" 21 "Jul Week 4, 2020" 22 "Jul Week 5, 2020" ///
23 "Aug Week 1, 2020" 24 "Aug Week 2, 2020" 25 "Aug Week 3, 2020" 26 "Aug Week 4, 2020" ///
27 "Sep Week 1, 2020" 28 "Sep Week 2, 2020" 29 "Sep Week 3, 2020" 30 "Sep Week 4, 2020" 31 "Sep Week 5, 2020" ///
32 "Oct Week 1, 2020" 33 "Oct Week 2, 2020" 34 "Oct Week 3, 2020" 35 "Oct Week 4, 2020" ///
36 "Nov Week 1, 2020" 37 "Nov Week 2, 2020" 38 "Nov Week 3, 2020" 39 "Nov Week 4, 2020" ///
40 "Dec Week 1, 2020" 41 "Dec Week 2, 2020" 42 "Dec Week 3, 2020" 43 "Dec Week 4, 2020" 44 "Dec Week 5, 2020" ///
45 "Jan Week 1, 2021" 46 "Jan Week 2, 2021" 47 "Jan Week 3, 2021" 48 "Jan Week 4, 2021" ///
49 "Feb Week 1, 2021" 50 "Feb Week 2, 2021" 51 "Feb Week 3, 2021" 52 "Feb Week 4, 2021" ///
53 "Mar Week 1, 2021" 54 "Mar Week 2, 2021" 55 "Mar Week 3, 2021" 56 "Mar Week 4, 2021" 57 "Mar Week 5, 2021" ///
58 "Apr Week 1, 2021" 59 "Apr Week 2, 2021" 60 "Apr Week 3, 2021" 61 "Apr Week 4, 2021" ///
62 "May Week 1, 2021" 63 "May Week 2, 2021" 64 "May Week 3, 2021" 65 "May Week 4, 2021" ///
66 "Jun Week 1, 2021" 67 "Jun Week 2, 2021" 68 "Jun Week 3, 2021" 69 "Jun Week 4, 2021" 70 "Jun Week 5, 2021" ///
71 "Jul Week 1, 2021" 72 "Jul Week 2, 2021" 73 "Jul Week 3, 2021" 74 "Jul Week 4, 2021" ///
75 "Aug Week 1, 2021" 76 "Aug Week 2, 2021" 77 "Aug Week 3, 2021" 78 "Aug Week 4, 2021" ///

label values time time_axis

encode country, generate(country_num)

encode continent, generate(continent_num)


***** --- Weekly Deaths per 100k ----------- *****
gen excess_deaths_per100k = (excess_deaths/population)*100000 
gen covid_deaths_per100k = (covid_deaths/population)*100000 



********************************************************************************
********************************************************************************
**** ------ Create Vaccine Stock Variable (Primary Regressor) ------------- ****
********************************************************************************
********************************************************************************

/*
Vaccines are fully effective 2 weeks after second dose, therefore not using lag 1 and 2
Vaccines are fully effective for next 2 months (lag 3 to lag 10)
Vaccines start depreciation from lag 11
*/


//----------------------------------------------------------------------------//
***** ---------- Generate new people fully vaccianted every week --------- *****
//----------------------------------------------------------------------------//

sort country time
by country: gen weekly_ppl_fully_vacc = people_fully_vacc_ipo - people_fully_vacc_ipo[_n-1]
replace weekly_ppl_fully_vacc = 0 if weekly_ppl_fully_vacc == .


*** Lag 3 to 10
forvalues i=3(1)10{
	
	by country: gen weekly_ppl_fully_vacc_lag`i' = weekly_ppl_fully_vacc[_n-`i']
	replace weekly_ppl_fully_vacc_lag`i' = 0 if weekly_ppl_fully_vacc_lag`i' == . 
}

***  Lag 11 - until start of the pandemic (with depreciation)
summ time
local t = r(max)


*** at lambda 0.97, Effectiveness reduces to 50% in ~25 weeks (6 months)
local lambda  0.97

foreach x in `lambda'{

di `x'

forvalues i=11(1)`t'{
	
	by country: gen weekly_ppl_fully_vacc_lag`i' = weekly_ppl_fully_vacc[_n-`i']
	replace weekly_ppl_fully_vacc_lag`i' = 0 if weekly_ppl_fully_vacc_lag`i' == . 
	
	local m = `i'-10
	
	// with depreciation
	replace weekly_ppl_fully_vacc_lag`i' = weekly_ppl_fully_vacc_lag`i'*(`x'^`m')
	
}

}


***** --- Generate Total Fully Vaccine Stock for each week (lag 3 to lag 38) --- ****
****  Drop 2 weeks as it takes 10-14 days to become effective

egen cum_fully_vacc_until_lag3 = rowtotal(weekly_ppl_fully_vacc_lag3-weekly_ppl_fully_vacc_lag78)
gen cum_fully_vacc_until_lag3_per100 = (cum_fully_vacc_until_lag3/population)*100
sum cum_fully_vacc_until_lag3_per100

rename cum_fully_vacc_until_lag3_per100 vaccine_stock_fully






//----------------------------------------------------------------------------//
***** ------- Generate new people vaccianted (1 Dose) every week --------- *****
//----------------------------------------------------------------------------//


sort country time
by country: gen weekly_ppl_vacc = people_vacc_ipo - people_vacc_ipo[_n-1]
replace weekly_ppl_vacc = 0 if weekly_ppl_vacc == .

*** Lag 3 to 10
forvalues i=3(1)10{
	
	by country: gen weekly_ppl_vacc_lag`i' = weekly_ppl_vacc[_n-`i']
	replace weekly_ppl_vacc_lag`i' = 0 if weekly_ppl_vacc_lag`i' == . 
}

***  Lag 11 - until start of the pandemic (with depreciation)
summ time
local t = r(max)

*** at lambda 0.97, Effectiveness reduces to 50% in ~25 weeks (6 months)
local lambda  0.97

foreach x in `lambda'{

di `x'

forvalues i=11(1)`t'{
	
	by country: gen weekly_ppl_vacc_lag`i' = weekly_ppl_vacc[_n-`i']
	replace weekly_ppl_vacc_lag`i' = 0 if weekly_ppl_vacc_lag`i' == . 
	
	local m = `i'-10
	
	// with depreciation
	replace weekly_ppl_vacc_lag`i' = weekly_ppl_vacc_lag`i'*(`x'^`m')
	
}

}


***** --- Generate Total 1 Dose Vaccine Stock for each week (lag 3 to lag 38) --- ****
**  Dropp 2 weeks
egen cum_vacc_until_lag3 = rowtotal(weekly_ppl_vacc_lag3-weekly_ppl_vacc_lag78)
gen cum_vacc_until_lag3_per100 = (cum_vacc_until_lag3/population)*100
sum cum_vacc_until_lag3_per100

rename cum_vacc_until_lag3_per100 vaccine_stock_1dose



** Create sq-vaccine stock
gen sq_vaccine_stock_fully = vaccine_stock_fully^2
gen sq_vaccine_stock_1dose = vaccine_stock_1dose^2

** Create sqrt-vaccine stock
gen sqrt_vaccine_stock_fully = sqrt(vaccine_stock_fully)
gen sqrt_vaccine_stock_1dose = sqrt(vaccine_stock_1dose)

** Time^2
gen sq_time = time^2


gen people_fully_vacc_ipo_per100 = (people_fully_vacc_ipo/population)*100
gen people_1dose_vacc_ipo_per100 = (people_vacc_ipo/population)*100


** Month to control for Continent X Month
gen month = substr(start_date, 6, 2)
destring month, replace


tab continent
list country if continent_num == . 

/*
      |   country |
      |-----------|
 235. |  Bulgaria |
 625. |    Cyprus |
1873. | Lithuania |
1874. | Lithuania |
*/

replace continent_num = 3 if continent_num == . & country_num == 4 // Bulgaria
replace continent_num = 3 if continent_num == . & country_num == 9 // Cyprus 
replace continent_num = 3 if continent_num == . & country_num == 25 // Lithuania


end







********************************************************************************
*------------------------------------------------------------------------------*
// -------------------- 1. Event Study : Sun Abraham ----------------------- //
*------------------------------------------------------------------------------*
********************************************************************************


regression_full_data program 


*** -------------------  Treatment Varible ----------------- ***

/*
** --- Threshold for treatment: Mean Vaccination March-Apr 2021

summ people_fully_vacc_ipo_per100 if year == 2021 & week == 13, detail // Mar week 4 Mean: 5.71% 
summ people_fully_vacc_ipo_per100 if year == 2021 & week == 14, detail // Apr week 1: Mean 6.46%

*/

gen treat = (vaccine_stock_fully >= 6) 


*** ------------------ Weeks Since Treat = 1 ------------------- ***

** Week when SIP turned 1
gen time_treat1 = time if treat == 1
egen first_time_treat1 = min(time_treat1), by(country_num)

** week since treat = 1 First time
gen time_since_treat1 = time - first_time_treat1 // Running Variable linear


preserve 

set scheme s2color

** Create dummies for Leads
forvalues x=1(1)20{
gen lead`x' = (time_since_treat1 == -`x')
}

** Create dummies for Lags
forvalues x=0(1)20{
gen lag`x' = (time_since_treat1 == `x')
}

** first_week_sip1 // cohort (Already Created)
gen never_treat1 = (first_time_treat1 == .) // Control_cohort


eventstudyinteract excess_deaths_per100k lead20 lead19 lead18 lead17 lead16 ///
lead15 lead14 lead13 lead12 lead11 lead10 lead9 lead8 lead7 lead6 lead5 lead4 ///
lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8 lag9 lag10 /// ** take out lead 1
lag11 lag12 lag13 lag14 lag15 lag16 lag17 lag18 lag19 lag20, ///
cohort(first_time_treat1) control_cohort(never_treat1) ///
absorb(i.country_num i.time) vce(cluster country_num)

outreg2 using "$output/sunabraham_excess_deaths.xls", excel append ctitle(Excess Deaths per 100K) replace


event_plot e(b_iw)#e(V_iw), default_look stub_lag(lag#) stub_lead(lead#) ///
together plottype(scatter) ///
graph_opt(xtitle("Weeks since Vaccine Stock of Fully Vaccinated >= 6%") ///
ytitle("Average Effect on Excess Deaths per 100,000") ylabel(-6(3)6) ///
xlabel(-20(5)20)) ///
lag_opt(color(navy)) lead_opt(color(navy))

graph export "$output/sunabraham_excess_deaths.png", replace



** Linear Combination Leads vs Lags
matrix b = e(b_iw)
matrix V = e(V_iw)
ereturn post b V

lincom (lead2+lead3+lead4+lead5+lead6+lead7+lead8+lead9+lead10+lead11+ ///
lead12+lead13+lead14+lead15+lead16+lead17+lead18+lead19+lead20)/20 

lincom (lag1+lag2+lag3+lag4+lag5+lag6+lag7+lag8+lag9+lag10+ ///
lag11+lag12+lag13+lag14+lag15+lag16+lag17+lag18+lag19+lag20)/20

restore






********************************************************************************
*------------------------------------------------------------------------------*
// ---------------------- 2. Regression Analysis --------------------------- //
*------------------------------------------------------------------------------*
********************************************************************************


regression_full_data program 


************** -------- Fully Vaccinated (Vaccine Stock) ----- ***************

local vars excess_deaths_per100k covid_deaths_per100k

foreach var of local vars{
	
*** Model 1: Linear with TWFE
reghdfe `var' vaccine_stock_fully, abs(i.country_num i.time) vce(cluster country_num)
outreg2 using "$output/regress_results_fully.xls", excel append ///
ctitle(Model 1, Linear Fully, TWFE, `var') addtext(SE clustered at country level) 


** Model 2: Quadratic with TWFE
reghdfe `var' vaccine_stock_fully sq_vaccine_stock_fully, ///
abs(i.country_num i.time) vce(cluster country_num)
outreg2 using "$output/regress_results_fully.xls", excel append ///
ctitle(Model 2, Quadratic Fully, TWFE, `var') addtext(SE clustered at country level)


** Model 3: Quadratic with Country specific quadratic trends (Time and Time-Sq)
regress `var' vaccine_stock_fully sq_vaccine_stock_fully ///
i.country_num##c.time i.country_num##c.sq_time, vce(cluster country_num)
outreg2 using "$output/regress_results_fully.xls", excel append ///
ctitle(Model 3, Quadratic Fully, Quadratic Trends, `var') addtext(SE clustered at country level)


** Model 4: SQRT with Country specific quadratic trends (Time and Time-Sq)
regress `var' sqrt_vaccine_stock_fully ///
i.country_num##c.time i.country_num##c.sq_time, vce(cluster country_num)
outreg2 using "$output/regress_results_fully.xls", excel append ///
ctitle(Model 4, SQRT Fully, Quadratic Trends, `var') addtext(SE clustered at country level)


** Model 5 (Main): SQRT with Country specific quadratic trends (Time and Time-Sq) and Continet*Month Seasonality
regress `var' sqrt_vaccine_stock_fully ///
i.country_num##c.time i.country_num##c.sq_time i.continent_num##c.month, vce(cluster country_num)
outreg2 using "$output/regress_results_fully.xls", excel append ///
ctitle(Model 5, SQRT Fully, Quadratic Trends, Continent X Month, `var') addtext(SE clustered at country level)

}




************** ----- 1 Dose Vaccinated (Vaccine Stock 1 Dose) ----**************
** Using the Main SQRT + Quadratic Trend + Seasonality Model

local vars excess_deaths_per100k covid_deaths_per100k

foreach var of local vars{

** Model 4: SQRT with Country specific quadratic trends (Time and Time-Sq)
regress `var' sqrt_vaccine_stock_1dose ///
i.country_num##c.time i.country_num##c.sq_time, vce(cluster country_num)
outreg2 using "$output/regress_results_1Dose.xls", excel append ///
ctitle(Model 4, SQRT 1Dose, Quadratic Trends, `var') addtext(SE clustered at country level)

	
** Model 5 (Main): SQRT with Country specific quadratic trends (Time and Time-Sq) and Continet*Month Seasonality
regress `var' sqrt_vaccine_stock_1dose ///
i.country_num##c.time i.country_num##c.sq_time i.continent_num##c.month, vce(cluster country_num)
outreg2 using "$output/regress_results_1Dose.xls", excel append ///
ctitle(Model 5, SQRT 1Dose, Quadratic Trends, Continent X Month, `var') addtext(SE clustered at country level)

}





********************************************************************************
*------------------------------------------------------------------------------*
*********** ----------Test Robustness of the Main Model ----------**************
*------------------------------------------------------------------------------*
********************************************************************************



********************************************************************************
// ---------------------------  1: Drop Winter Surge ----------------------- //
********************************************************************************


*** ------------ Fully Vaccinated: Drop 2020 Winter Surge ------------------ ***
** Drop Dec 2020
preserve

drop if month == 12 

regress excess_deaths_per100k sqrt_vaccine_stock_fully ///
i.country_num##c.time i.country_num##c.sq_time i.continent_num##c.month, vce(cluster country_num)

outreg2 using "$output/regress_results_fully_robust.xls", excel append ///
ctitle(Robust Fully, Main Modle 5, Drop Dec) addtext(SE clustered at country level)

restore


** Drop Dec 2020 and Jan 2021
preserve

drop if month == 12 | month == 1

regress excess_deaths_per100k sqrt_vaccine_stock_fully ///
i.country_num##c.time i.country_num##c.sq_time i.continent_num##c.month, vce(cluster country_num)

outreg2 using "$output/regress_results_fully_robust.xls", excel append ///
ctitle(Robust Fully, Main Modle 5, Drop Dec-Jan) addtext(SE clustered at country level)


restore




*** ----------------- 1 Dose: Drop 2020 Winter Surge ------------------- ***
** Drop Dec 2020
preserve

drop if month == 12 

regress excess_deaths_per100k sqrt_vaccine_stock_1dose ///
i.country_num##c.time i.country_num##c.sq_time i.continent_num##c.month, vce(cluster country_num)

outreg2 using "$output/regress_results_1Dose_robust.xls", excel append ///
ctitle(Robust 1 Dose, Main Modle 5, Drop Dec) addtext(SE clustered at country level)

restore


** Drop Dec 2020 and Jan 2021
preserve

drop if month == 12 | month == 1

regress excess_deaths_per100k sqrt_vaccine_stock_1dose ///
i.country_num##c.time i.country_num##c.sq_time i.continent_num##c.month, vce(cluster country_num)

outreg2 using "$output/regress_results_1Dose_robust.xls", excel append ///
ctitle(Robust 1 Dose, Main Modle 5, Drop Dec-Jan) addtext(SE clustered at country level)


restore





********************************************************************************
// --------------------------- 2. Different Lags --------------------------- //
********************************************************************************

**  Dropping 3 weeks (Using from Lag 4)
**  Dropping 4 weeks (Using from Lag 5)
**  Dropping 5 weeks (Using from Lag 6)


forvalues i=4(1)6{
	
***** --- Generate Total Vaccine Stock for each week (lag 4 to lag 38) --- ****
egen cum_fully_vacc_until_lag`i' = rowtotal(weekly_ppl_fully_vacc_lag`i'-weekly_ppl_fully_vacc_lag78)
gen cum_fully_vacc_until_lag`i'_per100 = (cum_fully_vacc_until_lag`i'/population)*100
sum cum_fully_vacc_until_lag`i'_per100

rename cum_fully_vacc_until_lag`i'_per100 vaccine_stock_fully_lag`i'


***** --- Generate Total Vaccine Stock for each week (lag 4 to lag 38) --- ****
egen cum_vacc_until_lag`i' = rowtotal(weekly_ppl_vacc_lag`i'-weekly_ppl_vacc_lag78)
gen cum_vacc_until_lag`i'_per100 = (cum_vacc_until_lag`i'/population)*100
sum cum_vacc_until_lag`i'_per100

rename cum_vacc_until_lag`i'_per100 vaccine_stock_1dose_lag`i'

}

** Create sqrt-vaccine stock
gen sqrt_vacc_stock_fully_lag4 = sqrt(vaccine_stock_fully_lag4)
gen sqrt_vacc_stock_fully_lag5 = sqrt(vaccine_stock_fully_lag5)
gen sqrt_vacc_stock_fully_lag6 = sqrt(vaccine_stock_fully_lag6)

gen sqrt_vacc_stock_1dose_lag4 = sqrt(vaccine_stock_1dose_lag4)
gen sqrt_vacc_stock_1dose_lag5 = sqrt(vaccine_stock_1dose_lag5)
gen sqrt_vacc_stock_1dose_lag6 = sqrt(vaccine_stock_1dose_lag6)



** Fully: Lags
local vars sqrt_vacc_stock_fully_lag4 sqrt_vacc_stock_fully_lag5 sqrt_vacc_stock_fully_lag6

foreach var of local vars{
	
regress excess_deaths_per100k `var' ///
i.country_num##c.time i.country_num##c.sq_time i.continent_num##c.month, vce(cluster country_num)

outreg2 using "$output/regress_results_fully_robust.xls", excel append ///
ctitle(Robust Fully, Main Modle 5, `var') addtext(SE clustered at country level)


}


** 1 Dose: Lags
local vars sqrt_vacc_stock_1dose_lag4 sqrt_vacc_stock_1dose_lag5 sqrt_vacc_stock_1dose_lag6

foreach var of local vars{
	
regress excess_deaths_per100k `var' ///
i.country_num##c.time i.country_num##c.sq_time i.continent_num##c.month, vce(cluster country_num)

outreg2 using "$output/regress_results_1Dose_robust.xls", excel append ///
ctitle(Robust 1 Dose, Main Modle 5, `var') addtext(SE clustered at country level)


}








********************************************************************************
********************************************************************************
// ------ Forecast: Using Sqrt (Model 5) Full Vaccination (Main) --------//
********************************************************************************
********************************************************************************


regression_full_data program


gen d_vaccine_stock_fully = vaccine_stock_fully
gen d_sqrt_vaccine_stock_fully = sqrt_vaccine_stock_fully

local vars excess_deaths_per100k 

foreach var of local vars{
	
** Actual Predicted
regress `var' sqrt_vaccine_stock_fully ///
i.country_num##c.time i.country_num##c.sq_time i.continent_num##c.month, vce(cluster country_num)

predict `var'_hat 


** Counterfactual Predicted
replace sqrt_vaccine_stock_fully = 0
predict `var'_counter

replace sqrt_vaccine_stock_fully = d_sqrt_vaccine_stock_fully
	
}


*** --------------------- Cum Y, Y-Hat, Y-Counterfactual ----------------- ***

local vars excess //covid

foreach var of local vars{
	
** Absolute values of Y-hats
gen `var'_deaths_hat = (`var'_deaths_per100k_hat/100000)*population
gen `var'_deaths_counter = (`var'_deaths_per100k_counter/100000)*population

	
** Actual
gen cum_`var'_deaths = `var'_deaths
sort country time
by country: replace cum_`var'_deaths = cum_`var'_deaths[_n] + ///
cum_`var'_deaths[_n-1] if time > 1

** Y-Hat
gen cum_`var'_deaths_hat = `var'_deaths_hat
sort country time
by country: replace cum_`var'_deaths_hat = cum_`var'_deaths_hat[_n] + ///
cum_`var'_deaths_hat[_n-1] if time > 1


** Y-Counterfactual
gen cum_`var'_deaths_counter = `var'_deaths_counter
sort country time
by country: replace cum_`var'_deaths_counter = cum_`var'_deaths_counter[_n] + ///
cum_`var'_deaths_counter[_n-1] if time > 1


}



********************************************************************************
// ------- 43 Counties Plot: Cum Excess Deaths-hat vs Counterfactual ---------- //
********************************************************************************

preserve 

collapse (sum) cum_excess_deaths cum_excess_deaths_hat cum_excess_deaths_counter ///
(mean) d_vaccine_stock_fully, by(time)

/*
summ cum_excess_deaths_hat cum_excess_deaths_counter if time == 78

//yline at 3246778 and 5250913 sqrt
restore
*/


/*
summ cum_excess_deaths cum_excess_deaths_hat cum_excess_deaths_counter d_vaccine_stock_fully

summ cum_excess_deaths_hat
local pred_max = r(max)

summ cum_excess_deaths_counter
local counter_max = r(max)

local diff = `counter_max' - `pred_max'
disp `diff' 

//2,004,134 sqrt

restore
*/


graph twoway (line cum_excess_deaths time, lwidth(medthick)) ///
(line cum_excess_deaths_hat time, lpattern(dash) lwidth(medthick)) ///
(line cum_excess_deaths_counter time, lpattern(longdash) lwidth(medthick)) ///
(line d_vaccine_stock_fully time, lpattern(dash_dot) lwidth(medthick) yaxis(2)), ///
xlabel(0(4)78,valuelabel angle(45) labsize(vsmall)) ///
ylabel(0(1000000)5000000,labsize(vsmall)) ///
ylabel(0(5)50, axis(2) labsize(vsmall)) ///
xtitle("Time Period", size(medsmall)) ///
ytitle("Cum. Excess Deaths", size(medsmall)) ///
ytitle("Vaccine Stock (%)", axis(2) size(medsmall)) ///
legend(order(1 "Actual Excess Deaths" 2 "Predicted Excess Deaths with Vaccines" ///
3 "Predicted Excess Deaths with No Vaccines" 4 "Vaccine Stock (Fully Vaccinated)") size(2) col(2)) ///
text(4250000 55 "Estimated Deaths Averted", size(vsmall)) ///
text(4000000 55 "2.0 million", size(vsmall)) ///
text(5000000 20 "Projected Deaths without Vaccines: 5.25 million", size(vsmall)) ///
text(3400000 20 "Deaths with Vaccines: 3.25 million", size(vsmall)) ///
yline(5190556, lpattern(shortdash) lcolor(grey)) ///
yline(3196700, lpattern(shortdash) lcolor(grey)) 

graph export "$output/Predicted_vs_Counterfactual_excess_sqrt.png", replace

restore




********************************************************************************
//---------------------- Plot For top 10 countries -------------------- //
********************************************************************************


** First: Group countries based on Cum deaths by Aug 2021 for Y scaling
by country: egen max_cum_excess_deaths_counter = max(cum_excess_deaths_counter)


preserve

replace cum_excess_deaths = round(cum_excess_deaths)
replace cum_excess_deaths_hat = round(cum_excess_deaths_hat)
replace cum_excess_deaths_counter = round(cum_excess_deaths_counter)
replace max_cum_excess_deaths_counter = round(max_cum_excess_deaths_counter)

replace country = "New_Zealand" if country == "New Zealand"
replace country = "Czech_Republic" if country == "Czech Republic"
replace country = "South_Africa" if country == "South Africa"
replace country = "South_Korea" if country == "South Korea"
replace country = "United_Kingdom" if country == "United Kingdom"
replace country = "United_States" if country == "United States"


*** ----------------- Run a Loop --------------------- ***

local vars United_States Germany United_Kingdom Mexico France Italy Spain Poland Canada Colombia
 
foreach var of local vars {
	
summ max_cum_excess_deaths_counter if country == "`var'"
local scale_max = r(max)
local scale_step =  `scale_max'/5
	
graph twoway (line cum_excess_deaths time if country == "`var'", lwidth(medthick)) ///
(line cum_excess_deaths_hat time if country == "`var'", lpattern(dash) lwidth(medthick)) ///
(line cum_excess_deaths_counter time if country == "`var'", lpattern(dash) lwidth(medthick)) ///
(line d_vaccine_stock_fully time if country == "`var'", lpattern(dash_dot) lwidth(medthick) yaxis(2)), ///
xlabel(0(4)78,valuelabel angle(45) labsize(vsmall)) ///
ylabel(0(`scale_step')`scale_max',labsize(vsmall)) ///
ylabel(0(10)80, axis(2) labsize(vsmall)) ///
xtitle("Time Period", size(medsmall)) ///
ytitle("Cum. Excess Deaths", size(small)) ///
ytitle("Vaccine Stock (%)", axis(2) size(small)) ///
title("Trends: Excess Deaths and Vaccination (Mar 2020 - Aug 2021)", size (medium)) ///
subtitle("`var'", size(medium)) ///
legend(order(1 "Actual Excess Deaths" 2 "Predicted Excess Deaths with Vaccines" ///
3 "Predicted Excess Deaths with No Vaccines" 4 "Vacccine Stock (Fully Vaccinated)") size(2) col(2))

graph export "$output/each_country_predict_counter_sqrt/Predicted_vs_Counterfactual_`var'.png", replace


}

restore







********************************************************************************
//=========================================================================== //

*** -------------------------- Global Analysis --------------------------- ***

//=========================================================================== //
********************************************************************************



********************************************************************************
********************************************************************************
//------------------- 1. 141 Countries Weekly Analysis ---------------------- //
********************************************************************************
********************************************************************************


program define weekly_countries_analysis

clear all

use countrywise_weekly_vacc_rate, clear 
merge m:1 country using country_code_region_worldbank, keepusing(region)
drop if _merge == 2

drop if country == "England" | country == "Northern Ireland" | country == "Scotland" | country == "Wales"

// drop British Overseas Territory
drop if country == "Montserrat"
drop if country == "Anguilla"

replace region = "East Asia & Pacific" if country == "Taiwan"

distinct country // 141
drop _merge


*** --------- Merge VSL data with vaccination and region data ------------ ***

merge m:1 country using VSL_data_sweis2022, keepusing(vsl1 vsl2 vsl3)
drop if _merge == 2
drop _merge

// Replace Missing VSL with Region Average
tab region

summ vsl3 if region == "East Asia & Pacific" & vsl3 != . 
local region1 = r(mean)
replace vsl3 = `region1' if region == "East Asia & Pacific" & vsl3 == .

summ vsl3 if region == "Europe & Central Asia" & vsl3 != .
local region2 = r(mean)
replace vsl3 = `region2' if region == "Europe & Central Asia" & vsl3 == .

summ vsl3 if region == "Latin America & Caribbean" & vsl3 != .
local region3 = r(mean)
replace vsl3 = `region3' if region == "Latin America & Caribbean" & vsl3 == .

summ vsl3 if region == "Middle East & North Africa" & vsl3 != .
local region4 = r(mean)
replace vsl3 = `region4' if region == "Middle East & North Africa" & vsl3 == .

summ vsl3 if region == "North America" & vsl3 != . 
local region5 = r(mean)
replace vsl3 = `region5' if region == "North America" & vsl3 == .

summ vsl3 if region == "South Asia" & vsl3 != . 
local region6 = r(mean)
replace vsl3 = `region6' if region == "South Asia" & vsl3 == .

summ vsl3 if region == "Sub-Saharan Africa" & vsl3 != .
local region7 = r(mean)
replace vsl3 = `region7' if region == "Sub-Saharan Africa" & vsl3 == .

replace vsl3 = round(vsl3, .01)



*** ----------------- Merge GDP per capita ------------------ ***

merge m:1 country using countries_gdp_per_capita, keepusing(gdp_per_capita_2021) // all matched
keep if _merge == 3
drop _merge

gen gdp_2021_million = (population*gdp_per_capita_2021)/1000000

//GDP of Gibraltar = 2.4 billion = 2,400,000,000
replace gdp_2021_million = 2400 if country == "Gibraltar"

end




********************************************************************************
**** ------ Create Vaccine Stock Variable (Primary Regressor) ------------- ****
********************************************************************************

/*
Vaccines are fully effective 2 weeks after second dose, therefore not using lag 1 and 2
Vaccines are fully effective for next 2 months (lag 3 to lag 10)
Vaccines start depreciation from lag 11
*/


*** ------------ Generate new people fully vaccianted every week ----------- ***
sort country time
by country: gen weekly_ppl_fully_vacc = people_fully_vacc_epo - people_fully_vacc_epo[_n-1]
replace weekly_ppl_fully_vacc = 0 if weekly_ppl_fully_vacc == .


*** Lag 3 to 10
forvalues i=3(1)10{
	
	by country: gen weekly_ppl_fully_vacc_lag`i' = weekly_ppl_fully_vacc[_n-`i']
	replace weekly_ppl_fully_vacc_lag`i' = 0 if weekly_ppl_fully_vacc_lag`i' == . 
}


***  Lag 11 - until start of the pandemic or Vaccine (with depreciation)
summ time
local t = r(max)


*** at lambda 0.97, Effectiveness reduces to 50% in ~25 weeks (6 months)
local lambda  0.97

foreach x in `lambda'{

di `x'

forvalues i=11(1)`t'{
	
	by country: gen weekly_ppl_fully_vacc_lag`i' = weekly_ppl_fully_vacc[_n-`i']
	replace weekly_ppl_fully_vacc_lag`i' = 0 if weekly_ppl_fully_vacc_lag`i' == . 
	
	local m = `i'-10
	
	// with depreciation
	replace weekly_ppl_fully_vacc_lag`i' = weekly_ppl_fully_vacc_lag`i'*(`x'^`m')
	
}

}


***** --- Generate Total Vaccine Stock (Fully) for each week (lag 3 to lag 38) --- ****
egen cum_fully_vacc_until_lag3 = rowtotal(weekly_ppl_fully_vacc_lag3-weekly_ppl_fully_vacc_lag37)
gen cum_fully_vacc_until_lag3_per100 = (cum_fully_vacc_until_lag3/population)*100
sum cum_fully_vacc_until_lag3_per100

drop weekly_ppl_fully_vacc_lag3-weekly_ppl_fully_vacc_lag37

rename cum_fully_vacc_until_lag3_per100 vaccine_stock_fully

** Create sq-vaccine stock
gen sq_vaccine_stock_fully = vaccine_stock_fully^2

** Create sqrt-vaccine stock
gen sqrt_vaccine_stock_fully = sqrt(vaccine_stock_fully)





********************************************************************************
*** ---------------------------- Lives Saved ------------------------------ ***
********************************************************************************

** Model 5 Sqrt Coeff Excess: -1.585 (p=0.001) Covid: -1.446 (p=0.000)


*** ------------------------ Weekly Lives Saved ------------------------- ***
** Excess
gen weekly_exdeaths_saved = (population/100000)*(1.585*sqrt_vaccine_stock_fully)

** Covid
gen weekly_covdeaths_saved = (population/100000)*(1.446*sqrt_vaccine_stock_fully)


*** ------------------------ Cum Lives Saved ---------------------------- ***
** Excess
bysort country (time): gen cum_lives_saved_excess = sum(weekly_exdeaths_saved) 

** Covid
bysort country (time): gen cum_lives_saved_covid = sum(weekly_covdeaths_saved) 


*** ---------------------- Weekly VSL saved --------------------------- ***
** EXcess Deaths
gen weekly_vsl_saved_excess = vsl3*weekly_exdeaths_saved
replace weekly_vsl_saved_excess = round(weekly_vsl_saved_excess)

** COVID
gen weekly_vsl_saved_covid = vsl3*weekly_covdeaths_saved
replace weekly_vsl_saved_covid = round(weekly_vsl_saved_covid)



*** --------------------  Cum VSL saved Until Aug 2021 ------------------ ***
** Excess Deaths
bysort country (time): gen cum_vsl_saved_excess = sum(weekly_vsl_saved_excess) 

** COVID
bysort country (time): gen cum_vsl_saved_covid = sum(weekly_vsl_saved_covid) 



*** ----------- Save Weekly Data -------------- ***
export excel using "$output/lives_and_vsl_saved_weekly.xlsx", ///
firstrow(variables) replace


*** ---------  Save Cumulative Data ---------- ****
preserve

distinct country

collapse (mean) population vsl3 (last) people_full_vacc_per100 vaccine_stock cum_lives_saved_excess ///
cum_lives_saved_covid cum_vsl_saved_excess cum_vsl_saved_covid, by(country)

export excel using "$output/lives_and_vsl_saved_cum.xlsx", ///
firstrow(variables) replace

restore



*** --------- dta file for the MAP ---------- ****
preserve

collapse (mean) population vsl3 (last) people_full_vacc_per100 vaccine_stock cum_lives_saved_excess ///
cum_lives_saved_covid cum_vsl_saved_excess cum_vsl_saved_covid, by(country)

replace cum_lives_saved_excess = round(cum_lives_saved_excess)
replace cum_lives_saved_covid = round(cum_lives_saved_covid)

replace cum_vsl_saved_excess = round(cum_vsl_saved_excess)
replace cum_vsl_saved_covid = round(cum_vsl_saved_covid)

encode country, gen(counrty_num)

save "$output/lives_and_vsl_saved_cum_dta.dta", replace

restore








*******************************************************************************
*******************************************************************************
//--------------- 2. Equitable distribution 141 Countries --------------------//
*******************************************************************************
*******************************************************************************


weekly_countries_analysis program

merge m:1 time using weekly_ppl_fully_vacc_141countries // all matched
drop _merge
sort country time


** people vaccinated in each country if weekly total people vacc is distributed based on population
gen weekly_ppl_fully_vacc = (ppl_vacc_weekly/5253202000)*population

** Cum ppl vaccinated in each country based on proportional distribution
gen cum_ppl_fully_vacc = weekly_ppl_fully_vacc
replace cum_ppl_fully_vacc = cum_ppl_fully_vacc[_n] + cum_ppl_fully_vacc[_n-1] if time > 1

** Alternative per people vacc
gen alt_per_ppl_vacc = (cum_ppl_fully_vacc/population)*100




*******************************************************************************
**** ------------ Create Vaccine Stock Variable (Equitable) -------------- ****
*******************************************************************************

/*
Vaccines are fully effective 2 weeks after second dose, therefore not using lag 1 and 2
Vaccines are fully effective for next 2 months (lag 3 to lag 10)
Vaccines start depreciation from lag 11
*/

*** Lag 3 to 10
forvalues i=3(1)10{
	
	by country: gen weekly_ppl_fully_vacc_lag`i' = weekly_ppl_fully_vacc[_n-`i']
	replace weekly_ppl_fully_vacc_lag`i' = 0 if weekly_ppl_fully_vacc_lag`i' == . 
}

***  Lag 11 - until start of the pandemic or Vaccine (with depreciation)
summ time
local t = r(max)


*** at lambda 0.97, Effectiveness reduces to 50% in ~25 weeks (6 months)
local lambda  0.97

foreach x in `lambda'{

di `x'

forvalues i=11(1)`t'{
	
	by country: gen weekly_ppl_fully_vacc_lag`i' = weekly_ppl_fully_vacc[_n-`i']
	replace weekly_ppl_fully_vacc_lag`i' = 0 if weekly_ppl_fully_vacc_lag`i' == . 
	
	local m = `i'-10
	
	// with depreciation
	replace weekly_ppl_fully_vacc_lag`i' = weekly_ppl_fully_vacc_lag`i'*(`x'^`m')
	
}

}



***** --- Generate Total Vaccine Stock for each week (lag 3 to lag 38) --- ****
egen cum_fully_vacc_until_lag3 = rowtotal(weekly_ppl_fully_vacc_lag3-weekly_ppl_fully_vacc_lag37)
gen cum_fully_vacc_until_lag3_per100 = (cum_fully_vacc_until_lag3/population)*100
sum cum_fully_vacc_until_lag3_per100

drop weekly_ppl_fully_vacc_lag3-weekly_ppl_fully_vacc_lag37

rename cum_fully_vacc_until_lag3_per100 vaccine_stock_fully

** Create sq-vaccine stock
gen sq_vaccine_stock_fully = vaccine_stock_fully^2

** Create sqrt-vaccine stock
gen sqrt_vaccine_stock_fully = sqrt(vaccine_stock_fully)



*******************************************************************************
***** ----------------------- Lives Saved (Equitable) ------------------- *****
*******************************************************************************



*** ------------------------ Weekly Lives Saved ---------------------- ***
** Excess
gen weekly_exdeaths_saved = (population/100000)*(1.585*sqrt_vaccine_stock_fully) // sqrt

** Covid
gen weekly_covdeaths_saved = (population/100000)*(1.446*sqrt_vaccine_stock_fully) // sqrt


*** ------------------------- Cum Lives Saved ------------------------ ***
** Excess
bysort country (time): gen cum_lives_saved_excess = sum(weekly_exdeaths_saved) 

** Covid
bysort country (time): gen cum_lives_saved_covid = sum(weekly_covdeaths_saved) 


*** ------------------------- Weekly VSL saved ------------------------ ***
** EXcess Deaths
gen weekly_vsl_saved_excess = vsl3*weekly_exdeaths_saved
replace weekly_vsl_saved_excess = round(weekly_vsl_saved_excess)

** COVID
gen weekly_vsl_saved_covid = vsl3*weekly_covdeaths_saved
replace weekly_vsl_saved_covid = round(weekly_vsl_saved_covid)


*** --------------------  Cum VSL saved Until Aug 2021 ---------------- ***
** Excess Deaths
bysort country (time): gen cum_vsl_saved_excess = sum(weekly_vsl_saved_excess) 

** COVID
bysort country (time): gen cum_vsl_saved_covid = sum(weekly_vsl_saved_covid) 


*** --------- Weekly Data ------------- ***
export excel using "$output/lives_and_vsl_saved_weekly_equitable.xlsx", ///
firstrow(variables) replace


*** --------- Cumulative Data ----------- ***
preserve

distinct country

collapse (mean) population (last) vaccine_stock cum_lives_saved_excess ///
cum_lives_saved_covid cum_vsl_saved_excess cum_vsl_saved_covid, by(country)
 

export excel using "$output/lives_and_vsl_saved_cum_equitable.xlsx", ///
firstrow(variables) replace

restore



*** --------- dta file for the MAP --------- ***
preserve

collapse (mean) population vsl3 (last) people_full_vacc_per100 vaccine_stock ///
cum_lives_saved_excess cum_lives_saved_covid cum_vsl_saved_excess cum_vsl_saved_covid, by(country)

replace cum_lives_saved_excess = round(cum_lives_saved_excess)
replace cum_lives_saved_covid = round(cum_lives_saved_covid)

replace cum_vsl_saved_excess = round(cum_vsl_saved_excess)
replace cum_vsl_saved_covid = round(cum_vsl_saved_covid)

rename cum_lives_saved_excess cum_lives_saved_excess_equi
rename cum_lives_saved_covid cum_lives_saved_covid_equi
rename cum_vsl_saved_excess cum_vsl_saved_excess_equi
rename cum_vsl_saved_covid cum_vsl_saved_covid_equi

save "$output/lives_and_vsl_saved_cum_equitable_dta.dta", replace

restore








*******************************************************************************
*** -------------- Bin Scatter 141 Countries Vacc vs VSL ------------------ ***
*******************************************************************************

weekly_countries_analysis program

** Merge Country GDP per capita
merge m:1 country using countries_gdp_per_capita.dta, keepusing(gdp_per_capita_2021) // Gibralta - missing data
drop if _merge == 2
drop _merge


**** -------- Vacc by Aug 2021 and GDP per Capita ------------ ****
preserve

keep if time == 37

summ gdp_per_capita_2021

set scheme burd4

binscatter people_full_vacc_per100 gdp_per_capita_2021, msymbols(smcircle) /// 
xlabel(0(10000)120000, valuelabel angle(45) labsize(small)) ///
ylabel(0(20)100, labsize(small)) ///
ytitle("% People Fully Vaccinated", size(medsmall)) ///
xtitle("GDP per Capita 2021 ($)", size(medsmall)) legend(off)

graph export "$output/binscatter_vacc_aug2021_GDPpercapita.png", replace

restore



**** --------------- Time Took to 5% Vacc ----------------- ****

sort country time
by country: gen time_10perc = time if people_full_vacc_per100 >= 10

egen first_time_10perc = min(time_10perc), by(country)

summ first_time_10perc // 7 - 37

replace first_time_10perc = 38 if first_time_10perc == . // These countries reached 10% after time 37

** Binscatter
gen weeks_took_10perc = first_time_10perc - 0
summ weeks_took_10perc // 7 - 38

binscatter weeks_took_10perc gdp_per_capita_2021, msymbols(smcircle) /// 
xlabel(0(10000)120000, valuelabel angle(45) labsize(small)) ///
ylabel(0(5)40, labsize(small)) ///
ytitle("Number of Weeks", size(medsmall)) ///
xtitle("GDP per Capita 2021 ($)", size(medsmall)) legend(off)

graph export "$output/binscatter_weeks_took_to_10perc_GDPpercapita.png", replace






*******************************************************************************
//--------------------------- Global Map -----------------------------------//
*******************************************************************************


*** Use updated Lives Saved file
use lives_vsl_saved_shape_ids, clear 
rename id _ID


******** --------------- Map: Actual Vaccination by Aug 2021 ----------- *****

summ people_full_vacc_per100, detail //0.29 to 115.32

spmap people_full_vacc_per100 using world_shp, id(_ID) fcolor(Spectral) ///
clmethod(custom) clbreaks(0 1 10 20 30 40 50 60 70 80 115.32) ///
legend(symy(*1.5) symx(*1.5) size(*1.5) position (9)) legtitle("-- % Vaccination --") ///
legorder(hilo) legend(label(2 "0 to 1%") label(3 "1% to 10%" ) label(4 "10% to 20%") ///
label(5 "20% to 30%" ) label(6 "30% to 40%") label(7 "40% to 50%") ///
label(8 "50% to 60%" ) label(9 "60% to 70%" ) label(10 "70% to 80%" ) ///
label(11 "More than 80%" ) size(vsmall)) ///
legstyle(2) legend(region(lcolor(black)))   

graph export "$output/141country_analysis_sqrt_final/spmap_vacc_rate_actual.png", replace




***** --------------- Change in Excess Deaths Averted -------------------- *****

summ d_lives_saved_excess, detail //  -236383 to  342231

* generate the colors
//colorpalette HCL heat2, n(13) nograph
colorpalette HCL bluered2, n(15) nograph reverse
local colors `r(p)'

spmap d_lives_saved_excess using world_shp, id(_ID) fcolor(`r(p)') ///
clmethod(custom) clbreaks(-236383 -100000 -50000 -10000 -5000 -1000 -500 0 ///
500 1000 5000 10000 50000 100000 342231) ///
legend(symy(*1.5) symx(*1.5) size(*1.3) position (9)) legtitle("-- Absolute Change --") ///
legorder(hilo) legend(label(2 "Less than -100,001") label(3 " -100,000 to -50,001") label(4 "-50,000 to -10,001") ///
label(5 "-10,000 to -5001") label(6 "-5000 to -1001") label(7 "-1000 to -501") ///
label(8 "-500 to -1") label(9 "0 to 500") label(10 "501 to 1000" ) label(11 "1001 to 5000" ) ///
label(12 "5001 to 10,000") label(13 "10,001 to 50,000") label(14 "50,001 to 100,000" ) ///
label(15 "More than 100,000" ) size(vsmall)) ///
legstyle(2) legend(region(lcolor(black)))         

graph export "$output/141country_analysis_sqrt_final/spmap_excess_deaths_averted_change.png", replace





////////////////////////////////////////////////////////////////////////////////
*********************** ------- End -------- **********************************
////////////////////////////////////////////////////////////////////////////////









