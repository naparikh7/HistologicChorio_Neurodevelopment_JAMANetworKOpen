/* TItle: Histologic chorioamnionitis and neurodevelopment in infants born preterm; JAMA Network Open 2025

Laura S. Peterson, MD1,2 , Shalini Roy, BS1,2, Viral G. Jain, MD3, Stephanie L. Merhar, MD, MS1,2,4, Karen Harpster, PhD, OTR/L1,2,4, Nehal A. Parikh, DO, MS*1,2,4; Cincinnati Infant Neurodevelopment Early Prediction Study (CINEPS) Investigators */

//Stata version 18.0

// Dataset: ChorioBayleyMediationAnalysis_LP.DTA 

/*Primary exposure:
MSchorio - mod-severe histologic chorioamnionitis (as defined in Jain V, AJOG 2022 paper
*MSChorio n=55 out of 350 with complete data without imputation

Primary outcome measure (at 2 years CA):
motor_comp_score - Bayley Scales of Infant & Toddler Development, Third Ed. (Bayley-3) Motor composite score (composite of fine and gross motor subtest scores)
summarize motor_comp_score, detail
n=338 

Secondary outcome measures:
cog_comp_score - Bayley-3 Cognitive composite score
summarize cog_comp_score, detail
n=341
lang_comp_score - Bayley-3 Language composite score
summarize lang_comp_score, detail
n=341
motor_cp2 - cerebral palsy at 2 years CA

A priori selected confounders:
hdp2 - hypertensive disorders of pregnancy (i.e., chronic hypertension and/or gestational hypertension, inclusive of pre-eclampsia)
sex2 - infant sex (1=male)
mag_sulf2 - maternal receipt of magnesium sulfate 
ans2 - maternal receipt of antenatal steroids (any)
smokepreg - antenatal maternal cigarette smoking
outborn - born at level I/II center and transferred to level III/IV NICU (one of five PI NICUs that we recruited from)
mult_birth - multiple births
hriskses2 - high social risk score (see details below)
zscore_bw - birth weight z-score (based on Fenton growth curve)

Mediators:
ga - gestational age at birth (using best OB estimate)
KIDOKORO - global brain abnormality score based on Kikokoro H, AJNR 2013 (also see Jain VG, AJOG 2022)
*/

*Univariate anlaysis
regress motor_comp_score MSchorio
regress cog_comp_score MSchorio
regress lang_comp_score MSchorio

*Assess group difference in GA using non-parametric stats since GA is skewed
qreg ga MSchorio_imp if fu==1
bootstrap, reps(1000): qreg ga MSchorio_imp if fu==1


*Multivariable model for MSchorio
regress motor_comp_score MSchorio hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw

regress cog_comp_score MSchorio hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw 

regress lang_comp_score MSchorio hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw
*All three models are significant for MSChorio total effect on the three BSID-3 outcomes>>proceed to causal mediation analysis

// =============================================================================
//                            CAUSAL INFERENCE
// =============================================================================

*First evaluate if there is an interaction between the exposure and mediator
net install med4way, from("https://raw.githubusercontent.com/anddis/med4way/master/") replace

*Stata med4way command is a macro developed for VanderWeele's counterfactual approach to causal mediation analysis and tests for an interaction term between exposure and mediator (MSchoro*ga)
*I set GA at 1 SD below mean value (26.8); all other values (for covariates) set at mean
med4way motor_comp_score MSchorio ga sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw, a0(0) a1(1) m(26.8) yreg(linear) mreg(linear) bootstrap reps(1000) seed(1234) 
fulloutput
estat bootstrap, all

med4way cog_comp_score MSchorio ga sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw, a0(0) a1(1) m(26.8) yreg(linear) mreg(linear) bootstrap reps(1000) seed(1234) 
fulloutput
estat bootstrap, all

med4way lang_comp_score MSchorio ga sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw, a0(0) a1(1) m(26.8) yreg(linear) mreg(linear) bootstrap reps(1000) seed(1234) 
fulloutput
estat bootstrap, all

*Since there is no significant interaction for any of the three outcomes, we can run the mediation models without specifying an interaction term

// =============================================================================
//                            MEDIATION WITH mediate
// =============================================================================

*Mediation with gestational age (GA) as mediator
mediate (motor_comp_score hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw) (ga hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw) (MSchorio), nointeraction nie nde te
estat proportion
model

mediate (cog_comp_score hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw) (ga hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw) (MSchorio), nointeraction nie nde te
estat proportion

mediate (lang_comp_score hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw) (ga hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw) (MSchorio), nointeraction nie nde te
estat proportion

*Mediation with Kidokoro/global brain abnormality score as mediator
mediate (motor_comp_score_no46 hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw) (KIDOKORO hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw) (MSchorio), nointeraction nie nde te
estat proportion

mediate (cog_comp_score hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw) (KIDOKORO hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw) (MSchorio), nointeraction nie nde te
estat proportion

mediate (lang_comp_score hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw) (KIDOKORO hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw) (MSchorio), nointeraction nie nde te
estat proportion

// =============================================================================
//                            Sensitivity Analyses
// =============================================================================


*Sensitivity analysis that excludes the 5 infants with severe NDI that were unable to complete BSID-3 and  had scores of 54 or 46 assigned: 
*Multivariable model for MSchorio_imp
regress motor_comp_score_no46 MSchorio hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw

regress cog_comp_score_no54 MSchorio hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw

regress lang_comp_score_no46 MSchorio hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw
*All results remain significant - added a new table - eTable 2 in Supplement 1.


*Sensitivity analysis that includes 5 postnatal variables (likely mediators)
regress motor_comp_score MSchorio hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw abnl36hus NEC SEPSIS SEVEREBPD SEVEREROP

regress cog_comp_score MSchorio hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw abnl36hus NEC SEPSIS SEVEREBPD SEVEREROP

regress lang_comp_score MSchorio hdp2 sex2 mag_sulf2 ans2 smokepreg outborn mult_birth hriskses2 zscore_bw abnl36hus NEC SEPSIS SEVEREBPD SEVEREROP
*all three models remain significant; results presented in Table 4



*JAMA Network Open reviewer 2 asked we conduct analyses after dichtomizing BSID-3 outcomes
*Generate dichotomous variables
gen cognitive85=0 if cog_comp_score!=.
replace cognitive85=1 if cog_comp_score<85 & cog_comp_score!=.
list cognitive85 cog_comp_score in 1/50

gen language85=0 if lang_comp_score!=.
replace language85=1 if lang_comp_score<85 & lang_comp_score!=.

gen motor85=0 if motor_comp_score!=.
replace motor85=1 if motor_comp_score<85 & motor_comp_score!=.

*Now use Bayley <70 as cut-off
gen cognitive70=0 if cog_comp_score!=.
replace cognitive70=1 if cog_comp_score<70 & cog_comp_score!=.
list cognitive70 cog_comp_score in 1/50

gen language70=0 if lang_comp_score!=.
replace language70=1 if lang_comp_score<70 & lang_comp_score!=.

gen motor70=0 if motor_comp_score!=.
replace motor70=1 if motor_comp_score<70 & motor_comp_score!=.

*We will use a smaller subset of confounders due to our limited statistical power now that we are using categorical outcomes

// Stata is unable to run logit but it can run probit with linear regression
// Also need to convert probabilities to relative risks (rr) 

mediate (motor_cp2 hdp2 sex2 ans2 mag_sulf2 hriskses2 mult_birth, probit) ///
        (ga hdp2 sex2 ans2 mag_sulf2 hriskses2 mult_birth) ///
        (MSchorio), nointeraction
estat rr

mediate (motor85 hdp2 sex2 ans2 mag_sulf2 hriskses2 mult_birth, probit) ///
        (ga hdp2 sex2 ans2 mag_sulf2 hriskses2 mult_birth) ///
        (MSchorio), nointeraction
estat rr
		
mediate (cognitive85 hdp2 sex2 ans2 mag_sulf2 hriskses2 mult_birth, probit) ///
        (ga hdp2 sex2 ans2 mag_sulf2 hriskses2 mult_birth) ///
        (MSchorio), nointeraction
estat rr

mediate (language85 hdp2 sex2 ans2 mag_sulf2 hriskses2 mult_birth, probit) ///
        (ga hdp2 sex2 ans2 hriskses2  mag_sulf2 mult_birth) ///
        (MSchorio), nointeraction
estat rr	
	
mediate (motor70 hdp2 sex2 ans2 mag_sulf2 hriskses2 mult_birth, probit) ///
        (ga hdp2 sex2 ans2 mag_sulf2 hriskses2 mult_birth) ///
        (MSchorio), nointeraction
estat rr
		
mediate (cognitive70 hdp2 sex2 ans2 mag_sulf2 hriskses2 mult_birth, probit) ///
        (ga hdp2 sex2 ans2 mag_sulf2 hriskses2 mult_birth) ///
        (MSchorio), nointeraction
estat rr
		
mediate (language70 hdp2 sex2 ans2 mag_sulf2 hriskses2 mult_birth, probit) ///
        (ga hdp2 sex2 ans2 hriskses2  mag_sulf2 mult_birth) ///
        (MSchorio), nointeraction
estat rr

*For eTable 2, also need to evaluate prevalence
tab motor_cp2 if MSchorio!=.
tab motor85 if MSchorio!=.
tab cognitive85 if MSchorio!=.
tab language85 if MSchorio!=.
tab motor70 if MSchorio!=.
tab cognitive70 if MSchorio!=.
tab language70 if MSchorio!=. 

// Run data for Tables 1 AND 2

*Table 1
cs hdp2 MSchorio if cog_comp_score!=., exact
cs smokepreg MSchorio if cog_comp_score!=., exact
cs mag_sulf2 MSchorio if cog_comp_score!=., exact
cs ans2 MSchorio if cog_comp_score!=., exact
cs mult_birth MSchorio if cog_comp_score!=., exact
cs hriskses2 MSchorio if cog_comp_score!=., exact
cs maternalrace MSchorio if cog_comp_score!=., exact
tab maternalrace if MSchorio==1
tab maternalrace if MSchorio==0
cs mhispanic MSchorio if cog_comp_score!=., exact

cs sex2 MSchorio if cog_comp_score!=., exact
cs outborn MSchorio if cog_comp_score!=., exact
cs abnl36hus MSchorio if cog_comp_score!=., exact
cs SEPSIS MSchorio if cog_comp_score!=., exact
cs NEC MSchorio if cog_comp_score!=., exact
cs SEVEREBPD MSchorio if cog_comp_score!=., exact
cs SEVEREROP MSchorio if cog_comp_score!=., exact
cs abnl36hus MSchorio if cog_comp_score!=., exact 

ttest mat_age if cog_comp_score!=., by(MSchorio) unequal
ranksum ga if cog_comp_score!=., by(MSchorio)
summarize ga if MSchorio==1 & cog_comp_score!=., detail
summarize ga if MSchorio==0 & cog_comp_score!=., detail
ttest zscore_bw if cog_comp_score!=., by(MSchorio) unequal
ranksum KIDOKORO if cog_comp_score!=., by(MSchorio)
summarize KIDOKORO if MSchorio==1 & cog_comp_score!=., detail
summarize KIDOKORO if MSchorio==0 & cog_comp_score!=., detail
*/

*Table 2: assess mean standardized differences (SMDs) between FU and no FU at 2 yrs groups
*SMD for continuous variables
stddiff mat_age ga zscore_bw KIDOKORO if MSchorio!=., by(fu)
**SMD for cat variables
stddiff MSchorio hdp2 smokepreg mag_sulf2 ans2 mult_birth hriskses2 sex2 outborn abnl36hus SEPSIS NEC SEVEREBPD SEVEREROP if MSchorio!=., by(fu)


*Table 3
ranksum motor_comp_score, by(MSchorio)
summarize motor_comp_score if MSchorio==1, detail
summarize motor_comp_score if MSchorio==0, detail

ranksum cog_comp_score, by(MSchorio)
summarize cog_comp_score if MSchorio==1, detail
summarize cog_comp_score if MSchorio==0, detail

ranksum lang_comp_score, by(MSchorio)
summarize lang_comp_score if MSchorio==1, detail
summarize lang_comp_score if MSchorio==0, detail






