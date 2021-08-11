/*******************************************************************************************
"What about the Menz" - Low Employer Attachment and Ineligibility for Partner Parental Leave.
********************************************************************************************
Authors:	Rajas Kulkarni, Social Wellbeing Agency
			(Raj.Kulkarni@swa.govt.nz)
			Tze Ming Mok, The Southern Initiative 
			(tzeming.mok@aucklandcouncil.govt.nz)

Suggested Citation:
"Kulkarni, R & Mok, T. 2021. 'What about the menz?' Low Employer attachment and ineligibility for partner 
parental leave. The Southern Initiative."

Important things to note:
1. Check the refresh!
2. Check the meshblock concordance and use the version applicable (Table - #geo_concord)
3. Check that you are using correct version of Fabling-Mare Labour tables. 
	This script uses: [IDI_Adhoc].[clean_read_IR].[pent_emp_mth_FTE_IDI_20201020_RFabling] 
4. Check that user inputs are appropriate for your purpose. 
5. Ensure to run Highest Quaification and Relationships script before you run this file
	and save the end tables in your sandpit. 

Run Time: Anywhere between 1 hour and 4 hours depending on SQL capacity.
*******************************************************************************************/

/******************************************************************************************
DATA DICTIONARY
*******************************************************************************************

[snz_uid] -- snz_uid of the child 
[child_dob_snz] -- YYYY-MM-15 DOB of child 
[month_after_birth] -- Month relative to birth : This is the main time variable used for analysis - goes from -12 to +12 (0 being birth month)
[child_gender_sex_code] -- Sex of child 
[parent_snz_uid] -- snz_uid of parent 
[parent_dob_snz] -- date of birth of parent
[parent_age_at_birth] -- age of parent at birth of child 
[parent_gender_sex_code] -- sex of parent 
[parent_relationship] -- relationship of parent (e.g. mother, father, step-father, etc.)

-- Ethnicity of Parent 
[parent_eu]
[parent_maori]
[parent_pasific]
[parent_asian]
[parent_melaa]
[parent_other_eth]
		
[resident_class] -- if the parent received resident class visa in last 5 years (as of birth)
[temp_class] -- if the parent received temp class visa in last 5 years (as of birth)
[recent_arrival] -- if the parents first arrival to NZ was in last 5 years                                                                                                                                                   

[parent_highqual_at_birth] -- Parents' highest qualification at birth 
	
-- Address related variables 
[addr_uid] -- Parents address_uid (as of ANT notification table) at birth of child 
[mb] -- Meshblock
[sa1] -- Statistical Area 1
[sa2] -- Statistical Area 2
[ta] - Terratorial Authority
[cb] -- City Block
[ur] -- Urban Rural 
[rc] -- Regional Council

[south_auckland] -- South Auckland Flag (0/1 showing if the mother/child were born living in south auckland at time of birth)
[west_auckland] -- West Auckland Flag (0/1 showing if the mother/child were born living in south auckland at time of birth)

[inc_benefit] -- Income from BENEFITS earned by parent_snz_uid at month_after_birth 
[inc_acc_claims] -- Income from ACC CLAIMS earned by parent_snz_uid at month_after_birth 
[inc_pension] -- Income from PENSION earned by parent_snz_uid at month_after_birth 
[inc_parental_leave] -- Income from PAID PARENTAL LEAVE earned by parent_snz_uid at month_after_birth 
[inc_from_rental] -- Income from RENTAL (SELF EMPLOYED) earned by parent_snz_uid at month_after_birth 
[inc_self_employed] -- Income from SELF EMPLOYMENT (DIRECTOR, SHAREHOLDER, ETC) earned by parent_snz_uid at month_after_birth 
[inc_sole_trader] -- Income from SOLE TRADER earned by parent_snz_uid at month_after_birth 
[inc_student_loan] -- Income from STUDENT ALLOWANCE** earned by parent_snz_uid at month_after_birth   
[inc_wages] -- Income from WAGES AND SALARIES earned by parent_snz_uid at month_after_birth  

-- WAGES AND SALARIES derived variables 
[cu_inc_wages] -- cumulative income from wages
[avg_cu_inc_wages] -- average cumulative income from wages 
[min_monthly_wages_flag] -- at least earning min monthly wage from wages and salaries
[inc_wages_fall_flag] -- income drop from last month
[inc_wages_change] -- amount of income change 
[inc_wages_change_perc] -- percent of income change
[inc_wages_change_from_cu_avg] -- income change from cumulative avergage income of last month 
[inc_wages_cu_avg_change_perc] -- percent cumulative avergae income from wage change 

-- WAGES AND SALARIES + SELF EMPLOYED derived variables (Total Earned Income)   
[total_inc_wages_sei] -- Total earned income (Income from Wages and Salaries + Self-Employed + Rent + Sole Trader)
[cu_total_inc_wages_sei] -- cumulative total income from wages and sei
[min_monthly_wages_sei_flag] -- at least earning min monthly wage from wages salaries and sei combined
[avg_cu_total_inc_wages_sei] -- average cumulative total income from wages salaries and sei combined
[total_inc_wages_sei_fall_flag] -- if total income from wages + sei was lower than last month
[total_inc_wages_sei_change] -- amount of income change from last month (from sei and wages)
[total_inc_wages_sei_change_perc] -- percent of sei change from last month
[total_inc_wages_sei_change_from_cu_avg] -- Income change from cumulative average
[inc_wages_sei_cu_avg_change_perc] -- Percent of income change from average cumullative income 
		
-- Same information as above but using total income from all sources 
[total_inc]
[cu_total_inc]
[avg_cu_total_inc]
[min_monthly_wage_total_inc_flag] 
[total_inc_fall_flag]
[total_inc_change]
[total_inc_change_perc]
[total_inc_change_from_cu_avg]
[total_inc_cu_avg_change_perc]

-- control variables based on min income for the month 
[cu_min_monthly_inc] -- cumulative minimum wage monthly income (can be used for flags)
[avg_min_monthly_inc] -- average minimum wage monthly income (can be used for flags)

-- child centric income 
[ch_inc_wages_mf] -- Total income from wages for the child - based on DIA Mother and DIA Father only
[ch_cu_inc_wages_mf] -- Cumulative income from wages for the child - based on DIA Mother and DIA Father only
[ch_cu_avg_inc_wages_mf] -- Cumulative average income from wages for the child - based on DIA Mother and DIA Father only
		
[ch_total_inc_wages_sei_mf] -- Total income from wages and sei for the child - based on DIA Mother and DIA Father only
[ch_cu_total_inc_wages_sei_mf] -- Cumulative income from wages and sei for the child - based on DIA Mother and DIA Father only
[ch_cu_avg_total_inc_wages_sei_mf] -- Cumulative average income from wages and sei for the child - based on DIA Mother and DIA Father only etc.)

[ch_total_inc_mf] -- Total income from all sources for the child - based on DIA Mother and DIA Father only
[ch_cu_total_inc_mf] -- Cumulative income from all sources for the child  - based on DIA Mother and DIA Father only
[ch_cu_avg_total_inc_mf] -- Cumulative average income from all sources for the child - based on DIA Mother and DIA Father only

		
[ch_inc_wages_all]  -- Total income from wages for the child- based on all parents involved in childs life (mother, father, step parents etc.) 
[ch_cu_inc_wages_all] -- Cumulative income from wages for the child - based on all parents involved in childs life (mother, father, step parents etc.) 
[ch_cu_avg_inc_wages_all] -- Cumulative average income from wages for the child - based on all parents involved in childs life (mother, father, step parents etc.) 

[ch_total_inc_wages_sei_all] -- Total income from wages and sei for the child - based on all parents involved in childs life (mother, father, step parents etc.) 
[ch_cu_total_inc_wages_sei_all] -- Cumulative income from wages and sei for the child - based on all parents involved in childs life (mother, father, step parents etc.)
[ch_cu_avg_total_inc_wages_sei_all]-- Cumulative average income from wages and sei for the child - based on all parents involved in childs life (mother, father, step parents etc.)
		
[ch_total_inc_all] -- Total income from all sources for the child - based on all parents involved in childs life (mother, father, step parents etc.)
[ch_cu_total_inc_all] -- Cumulative income from all sources for the child  - based on all parents involved in childs life (mother, father, step parents etc.)
[ch_cu_avg_total_inc_all] -- Cumulative average income from all sources for the child - based on all parents involved in childs life (mother, father, step parents etc.)


[no_income] -- No income flag
[no_wages] -- No income from wages flag (can have income from other sources)
[no_wages_sei] -- No income from wages and sei flag (can have income from other sources)

[inc_wages_grp] -- Income from Wages categorized for parent
[inc_wages_sei_grp] -- Income from Wages and SEI categorized for parent
[inc_total_grp] -- Income from all sources categorized for parent
[ch_inc_wages_grp] -- Income from Wages categorized for child (based on mother and fathers income only)
[ch_inc_wages_sei_grp] -- Income from Wages and SEI categorized for child (based on mother and fathers income only)
[ch_inc_total_grp] -- Income from all sources categorized for child (based on mother and fathers income only)

-- BENEFITS (For parent of interest)
[n_days_T1_ben] -- number of days in the month spent on any of T1 benefits
[t1_yp] -- flag for T1 YP Benefit
[t1_job_skr] -- flag for Job seeker benefit 
[t1_sole_par] -- flag for sole parent benefit
[t1_liv_sup] -- flag for Living support 
[t1_stu_allowance] -- flag for student allowance 
[t1_other] -- flag for other types of T1 benefit 

[n_days_T2_ben] -- Number of days in the month spent on T2 benefit 
[t2_ben_inc] -- Total income earned from T2 benefit
[t2_accom_supp] -- Flag for T2 accomodotation suppliment benefit 
[t2_fam_tax_cred] -- flag for family tax credits benefit 
[t2_unsupp_child] -- flag for unsupported child benefit
[t2_other] -- flag for other T2 benefit 
		
[t3_ben_inc] -- Total income earned from Tier 3 benefit
[t3_domestic_prps] -- Flag for Domestic purposes benefit
[t3_job_src_unemp] -- Flag for job search / unemployment benefit
[t3_other] -- Flag for other T3 benefit 

[benefit_flag]-- High level benefit flag (if they received any benefit that month)
		
[ben_tiers] -- Tiers of benefit received that month (all, t1 only, t2 only, t1 and t2, t1 and t3, etc.)

[ben_type] -- Types of benefit received that month on high level (work related, sole_parent related, family, accomodation)
		
[inc_wff_mthly] -- Income from Working for Famailies 

-- FTE Based workplace 
[pent_fte] -- Total FTE worked at the workplace (where the parent worked max fte that month)
[pent_fte_anz06] -- ANZSIC06 high level code for enterprise where parent worked max fte
[pent_fte_industry_l1] -- Level 1 Industry for enterprise where parent worked max fte
[pent_fte_industry_l2] -- Level 2 Industry for enterprise where parent worked max fte

[avg_fte] -- Average FTE worked that month (if one had muliple jobs)
[max_fte] -- Max FTE worked at that month
[total_fte_worked] -- Total FTE worked based on all jobs
[n_jobs] -- Total number of jobs where parent worked that month

-- Employer attachment based workplace 
[pent_max_months] -- Enterprise where parent worked the max amount of time (in last 12 months in relation to month of interest)
[pent_time_anz06] -- ANZSIC06 high level code for enterprise where parent worked the max amount of time 
[pent_time_industry_l1] -- Level 1 Industry 
[pent_time_industry_l2] -- Level 2 Industry 
[time_with_employer] -- Length of employment with the employer 
[parental_leave_status] -- Derived parental leave status (1-5 months: no leave, 6-11 months: one week, 12+ : two weeks, 0: not working)
[new_emp_change_flag] -- Employer change flag (if the last months main employer was different from current employer)
[income_status] -- Very broad incoem status (wages and ben, wages only, sei only, etc)

[gap_inc_wages] -- If income from wages dropped by more than 50% of there was 0 income then gap = 1 else 0
[gap_inc_wages_sei] -- if income from wages and sei dropped by more than 50% of there was 0 income then gap = 1 else 0
[gap_total_inc] -- if income from all sources dropped by more than 50% of there was 0 income then gap = 1 else 0
[gap_inc_wages_abs] -- if income from wages dropped more than 50% then gap = 1 else 0 (Note: this condition would require income in previous month)
[gap_inc_wages_sei_abs] -- if income from wages and sei dropped more than 50% then gap = 1 else 0 (Note: this condition would require income in previous month)
[gap_total_inc_abs] -- if income from all sources dropped more than 50% then gap = 1 else 0 (Note: this condition would require income in previous month)

[gap_wages_below_min] -- if the income from wages drops below full time minimum wage threshold 
[gap_wages_sei_below_min] -- if the income from wages and sei drops below full time minimum wage threshold 
[gap_total_inc_below_min] -- if the income from all sources drops below full time minimum wage threshold 

-- The income fluctuation creates 4 categories 
	-- (a) Stable Above -- where income is consistently above minimum wage for current month and month before  
	-- (b) Stable Below -- where income is consistently below minimum wage for current month and month before  
	-- (c) Dipper - If the income dipped below full time min wage (income has to be above threshold in previous month in order to drop)
	-- (d) Riser -- if the income rose above full time min wage (income has to be below threshold in previous month in order to rise)
[fluc_wages] -- fluctuation based on income from wages only
[fluc_wage_sei] -- fluctuation based on income from wages and sei
[fluc_total_inc] -- fluctuation based on income from all sources

[cen_ind_occupation_code] -- Occupation code from census 18 for parent of interest 
[cen_occupation_description_l1] -- Level 1 occupation 
[cen_occupation_description_l2] -- Level 1 occupation 

[cen_ind_industry_code] -- Industry code from census 18 for parent of interest 
[cen_industry_description_l1] -- Level 1 industry
[cen_industry_description_l2] -- Level 2 industry

[cen_ind_ethgr_code_parent] -- Detailed ethnicity code for parent 


*******************************************************************************************/

/*******************************************************************************************
Title: USER INPUTS 
Details : Set Up for Fixed Variables
		1. Fixed table - which will be contain all the important dates / time / items of interest. This table acts as a control table. 
		2. Geo Concord - Geographic concordance table to map meshblocks to other non-standard geographies
		3. Months - Temporary table which will be used to inner join instead of creating a loop. 
		4. Tax Year - Calendar Year Concordance table - Convert tax month and year to calander month and year. 
*******************************************************************************************/
USE [IDI_Clean_20201020]; -- IDI Refresh we used for analysis

DECLARE @main_date DATE = '2018-03-15'; -- census month (or central date)
DECLARE @max_month INT = 12; -- max number of months the information should be collected for.
DECLARE @min_month INT = -12; -- min number of months the information should be collected for.

DECLARE @max_days INT = 365; -- Used to filter relationships (i.e. a individual must be involved in subjects life within max days of birth) - Check population table for more info. 
DECLARE @min_days INT = -365; -- Used to filter relationships (i.e. a individual's relationship must not end in subjects life within min days of birth) - Check population table for more info. 
DECLARE @write_db BIT = 1; -- If the table should be written to Sandpit or not 
DECLARE @table_name VARCHAR(MAX) = '[IDI_Sandpit].[DL-MAA2020-xx].[population]' -- Change this while running the script to save the table into your sandpit
/*******************************************************************************************/
-- Main control table 
IF OBJECT_ID('tempdb..#fixed') IS NOT NULL DROP TABLE #fixed
SELECT @main_date AS 'main_date'
		,YEAR(DATEADD(MONTH, @max_month, @main_date)) AS 'max_year'
		,YEAR(DATEADD(MONTH, @min_month, @main_date)) AS 'min_year'
		,@max_month AS 'max_month'
		,@min_month AS 'min_month'
		,@max_days AS 'max_days'
		,@min_days AS 'min_days'
		,DATEADD(MONTH, @max_month, @main_date) AS 'max_date'
		,DATEADD(MONTH, @min_month, @main_date) AS 'min_date'
		,DATEADD(MONTH, (@max_month/2) - 1, @main_date) AS 'max_birth' -- this can be changed when time comes 
		,DATEADD(MONTH, (@max_month/2) * (-1), @main_date) AS 'min_birth' -- this can be changed when time comes 
		,@write_db AS 'write_db'
		,@table_name AS 'table_name'
INTO #fixed

-- Geographic concordance to get "South Auckland" or any other non-standard geographic areas. 
IF OBJECT_ID('tempdb..#geo_concord') IS NOT NULL DROP TABLE #geo_concord
SELECT [MB2020_V1_00] AS 'mb'
      ,[SA12020_V1_00] AS 'sa1'
      ,[SA22020_V1_00] AS 'sa2'
      ,[IUR2020_V1_00] AS 'ur'
      ,[CB2020_V1_00] AS 'cb'
      ,[CB2020_V1_00_NAME_ASCII] AS 'cb_name'
      ,[TA2020_V1_00] AS 'ta'
	  ,[REGC2020_V1_00] AS 'rc'
      ,[REGC2020_V1_00_NAME_ASCII] AS 'rc_name'
INTO #geo_concord
FROM [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_higher_geography_2020_V1_00]; -- please confirm the refresh meshblock when running the script


-- This will be used to duplicate records / set up dataframe where information for all given months can be recorded
-- Just another way to avoid while loop. 
IF OBJECT_ID('tempdb..#months') IS NOT NULL DROP TABLE #months
CREATE TABLE #months
(
[month_after_birth] INT
)

DECLARE @current INT = @min_month
WHILE @current <= @max_month
BEGIN

INSERT INTO #months
SELECT @current AS [month_after_birth]

SET @current = @current + 1 
END 
-- To Convert tax year income into cal year income
IF OBJECT_ID('tempdb..#tax_cal_concord') IS NOT NULL DROP TABLE #tax_cal_concord
CREATE TABLE #tax_cal_concord
(
	[tax_year]	INT,
	[tax_month]	INT,
	[cal_year]	INT,
	[cal_month]	INT
)


DECLARE @current_year INT 
DECLARE @max_current_year INT

SELECT @current_year = min_year - 1 FROM #fixed 
SELECT @max_current_year = max_year + 1 FROM #fixed

WHILE @current_year <= @max_current_year 
BEGIN 
		DECLARE @tax_month INT = 1
		WHILE @tax_month <= 12 
			BEGIN
			INSERT INTO #tax_cal_concord
				SELECT @current_year AS [tax_year]
						,@tax_month AS [tax_month]
						,CASE	WHEN @tax_month < 10 
								THEN  @current_year - 1
								ELSE @current_year 
						 END AS [cal_year]
						,CASE	WHEN @tax_month < 10 
								THEN  @tax_month + 3
								ELSE  @tax_month -9 
						  END AS [cal_month]

				FROM #fixed 
		
				SET @tax_month = @tax_month + 1
			END
SET @current_year = @current_year + 1 
END

-- Adding start and end dates for each year. 
IF OBJECT_ID('tempdb..#tax_cal_concord_fin') IS NOT NULL DROP TABLE #tax_cal_concord_fin;
SELECT * 
		,DATEFROMPARTS([cal_year], [cal_month], 1)			AS [start_date]
		,EOMONTH(DATEFROMPARTS([cal_year], [cal_month], 1)) AS [end_date]
INTO #tax_cal_concord_fin
FROM #tax_cal_concord

/************************************************************ POPULATION AND DEMOGRAPHICS *************************************************************************

Title : Population Creation
Contact: Raj.Kulkarni@swa.govt.nz


Details: This script will set up the population of interest using the control and setup above. Focus of this study is on "Fathers" / Parents in general. This script will 
use births data to get the birth cohort and attach parents/other caregivers from the relationships tables. Please check the filter logic to involve other parents (e.g. 
step-father, grandparent in caregiver role, etc.). Start and end dates for parent share dates from which they have been involved in a child's life.  

Dependancies - 
			1. Geography Metadata - [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_higher_geography_2020_V1_00]
			2. Relationships - [IDI_Sandpit].[DL-MAA2020-73].[parent_child_sibling] -- Code: CLEAN_relationships.sql
			3. Highest Qualification - [IDI_Sandpit].[DL-MAA2020-73].[highest_qual] -- Code: CLEAN_highest_qualification.sql


**********************************************************************************************************************************************************************/

-- missing out on around 10k people here because their mother did not have any address notification during time of birth 
-- filtering out parents who intersect with children 1 year after birth of child
IF OBJECT_ID('tempdb..#population') IS NOT NULL DROP TABLE #population;
WITH pop_addr AS(
SELECT DISTINCT a.[snz_uid]
	  ,a.[child_dob_snz]
	  ,c.[snz_sex_gender_code]												AS [child_gender_sex_code]
	  ,c.[snz_ethnicity_grp1_nbr]											AS [child_eu]
	  ,c.[snz_ethnicity_grp2_nbr]											AS [child_maori]
	  ,c.[snz_ethnicity_grp3_nbr]											AS [child_pasific]
	  ,c.[snz_ethnicity_grp4_nbr]											AS [child_asian]
	  ,c.[snz_ethnicity_grp5_nbr]											AS [child_melaa]
	  ,c.[snz_ethnicity_grp6_nbr]											AS [child_other_eth]
	  ,a.[start_date]
	  ,a.[end_date]
	  ,a.[parent_snz_uid]
	  ,DATEFROMPARTS(d.[snz_birth_year_nbr], d.[snz_birth_month_nbr], 15)	AS [parent_dob_snz]
	  ,CONVERT(FLOAT, 
			   DATEDIFF(DAY 
						,DATEFROMPARTS(d.[snz_birth_year_nbr], d.[snz_birth_month_nbr], 15)
						,[child_dob_snz]
						) 
				/ 365.0 -- to get decimals 
				)															AS [parent_age_at_birth]
	  ,d.[snz_sex_gender_code]												AS [parent_gender_sex_code]
	  ,d.[snz_ethnicity_grp1_nbr]											AS [parent_eu]
	  ,d.[snz_ethnicity_grp2_nbr]											AS [parent_maori]
	  ,d.[snz_ethnicity_grp3_nbr]											AS [parent_pasific]
	  ,d.[snz_ethnicity_grp4_nbr]											AS [parent_asian]
	  ,d.[snz_ethnicity_grp5_nbr]											AS [parent_melaa]
	  ,d.[snz_ethnicity_grp6_nbr]											AS [parent_other_eth]
	  ,a.[relationship]
	  ,a.[source]
      ,b.[ant_notification_date]											AS [addr_start_date]
      ,b.[ant_replacement_date]												AS [addr_end_date]
      ,b.[snz_idi_address_register_uid]										AS [addr_uid]
	  ,b.[ant_meshblock_code]												AS [mb]
	  ,e.[sa1]
	  ,e.[sa2]
	  ,e.[ta]
	  ,e.[cb]
	  ,e.[ur]
	  ,e.[rc]
	  ,b.[ant_address_source_code]											AS [addr_src]
	  ,CASE WHEN e.[cb] IN (7617, 7619, 7618, 7620) THEN 1 ELSE 0 END		AS [south_auckland]
	  ,CASE WHEN [cb] IN ('07606', '07607', '07611') THEN 1 ELSE 0 END		AS [west_auckland]
	  ,IIF(f.[dia_bir_citz_status_ind] = 'Y', 1, 0)							AS [ch_nz_citizen]
FROM [IDI_Sandpit].[DL-MAA2020-73].[parent_child_sibling] a
LEFT JOIN [data].[address_notification] b
ON a.[parent_snz_uid] = b.[snz_uid]
LEFT JOIN #fixed z
ON 1 = 1
LEFT JOIN [data].[personal_detail] c
ON a.[snz_uid] = c.[snz_uid]
LEFT JOIN [data].[personal_detail] d
ON a.[parent_snz_uid] = d.[snz_uid]
LEFT JOIN #geo_concord e
ON b.[ant_meshblock_code] = e.[mb]
LEFT JOIN [dia_clean].[births] f
ON a.[snz_uid] = f.[snz_uid]
WHERE b.[ant_notification_date] <= a.[child_dob_snz]
AND b.[ant_replacement_date] >= a.[child_dob_snz]
AND b.[ant_meshblock_code] IS NOT NULL 
AND DATEDIFF(DAY, a.[child_dob_snz], a.[start_date]) + 1 <= max_days -- relationship must not start 1 year after birth (additional filter to remove some census records / msd records)
AND DATEDIFF(DAY, a.[child_dob_snz], a.[end_date]) + 1 >= min_days -- relationship must not end 1 year before birth (additional filter to remove some census records / msd records) 
AND a.[child_dob_snz] <= max_birth
AND a.[child_dob_snz] >= min_birth
),

/* 
---------- Number of Siblings ----------
	(1) Number of full siblings (before birth)
	(2) Number of total siblings from mother (before birth)
	(3) Number of total siblings (before birth)
-----------------------------------------
*/
full_siblings AS (
SELECT	[snz_uid]
		,COUNT(DISTINCT [sibling_snz_uid]) AS [n_full_sibling]
FROM [IDI_Sandpit].[DL-MAA2020-73].[parent_child_sibling]
WHERE [sibling_snz_uid] IS NOT NULL
AND [sibling_dob_snz] <= [child_dob_snz]
AND [sibling_relationship] = 'sibling'
GROUP BY [snz_uid]
),
siblings_birth_mom AS (
SELECT	[snz_uid]
		,COUNT(DISTINCT [sibling_snz_uid]) AS [n_total_sibling_mother]
FROM [IDI_Sandpit].[DL-MAA2020-73].[parent_child_sibling]
WHERE [sibling_snz_uid] IS NOT NULL 
AND [sibling_dob_snz] <= [child_dob_snz]
AND [sibling_relationship] NOT IN ('step_sibling_step_parents', 'step_sibling_father')
GROUP BY [snz_uid]
),
siblings_total AS (
SELECT	[snz_uid]
		,COUNT(DISTINCT [sibling_snz_uid]) AS [n_total_sibling_all]
FROM [IDI_Sandpit].[DL-MAA2020-73].[parent_child_sibling]
WHERE [sibling_snz_uid] IS NOT NULL 
AND [sibling_dob_snz] <= [child_dob_snz]
GROUP BY [snz_uid]
),
siblings_final AS (
SELECT a.[snz_uid]
		,a.[n_total_sibling_all]
		,b.[n_total_sibling_mother]
		,c.[n_full_sibling]
FROM siblings_total a
LEFT JOIN siblings_birth_mom b
ON a.[snz_uid] = b.[snz_uid] 
LEFT JOIN full_siblings c 
ON a.[snz_uid] = c.[snz_uid]
)
SELECT a.[snz_uid]
	  ,a.[child_dob_snz]
	  ,d.[month_after_birth]
	  ,ROW_NUMBER() 
	   OVER 
	   (
	   PARTITION BY a.[snz_uid], a.[parent_snz_uid]
	   ORDER BY d.[month_after_birth]
	   )									AS [month_number]
	  ,a.[child_gender_sex_code]
	  ,a.[child_eu]
	  ,a.[child_maori]
	  ,a.[child_pasific]
	  ,a.[child_asian]
	  ,a.[child_melaa]
	  ,a.[child_other_eth]
	  ,a.[ch_nz_citizen]
	  ,a.[start_date]						AS [par_start_date]
	  ,a.[end_date]							AS [par_end_date]
	  ,a.[parent_snz_uid]
	  ,a.[parent_dob_snz]
	  ,a.[parent_age_at_birth]
	  ,a.[parent_gender_sex_code]
	  ,a.[parent_eu]
	  ,a.[parent_maori]
	  ,a.[parent_pasific]
	  ,a.[parent_asian]
	  ,a.[parent_melaa]
	  ,a.[parent_other_eth]
	  ,a.[relationship]						AS [parent_relationship]
	  ,a.[source]							AS [parent_relationship_src]
	  ,c.[level]							AS [parent_highqual_at_birth]
	  ,c.[src]								AS [parent_highqual_at_birth_src]
      ,a.[addr_start_date]
      ,a.[addr_end_date]
      ,a.[addr_uid]
	  ,a.[mb]
	  ,a.[sa1]
	  ,a.[sa2]
	  ,a.[ta]
	  ,a.[cb]
	  ,a.[ur]
	  ,a.[rc]
	  ,a.[addr_src]
	  ,a.[south_auckland]
	  ,a.[west_auckland]
	  ,ISNULL(b.n_full_sibling, 0)			AS [n_full_sibling]
	  ,ISNULL(b.n_total_sibling_mother, 0)	AS [n_total_sibling_mother]
	  ,ISNULL(b.n_total_sibling_all, 0)		AS [n_total_sibling_all]  
INTO #population
FROM pop_addr a
LEFT JOIN siblings_final b 
ON a.[snz_uid] = b.[snz_uid]
LEFT JOIN [IDI_Sandpit].[DL-MAA2020-73].[highest_qual] c
ON a.[parent_snz_uid] = c.[snz_uid]
AND YEAR(a.[child_dob_snz]) = c.[year]
LEFT JOIN #months d 
ON 1 = 1


-- Filtering smaller subset to reduce table size. 
IF OBJECT_ID('tempdb..#population_sub') IS NOT NULL DROP TABLE #population_sub
SELECT DISTINCT [snz_uid]
	  ,[child_dob_snz]
	  ,[parent_snz_uid]
	  ,[parent_relationship]
	  ,[month_after_birth]
INTO  #population_sub
FROM #population a

/************************************************************ PARENTS BENEFIT SPELLS **************************************************************************

Title: Benefit spells and income from benefits for parents
Contact: Raj.Kulkarni@swa.govt.nz


Details: This script gathers information from Tier 1, Tier 2, Tier 3 and WFF benefit data and creates spells for each tier. Please ensure to check the benefit codes
before running this script to ensure they fit your project purpose. Note that the script does not get income from Tier 1 benefits (since it's available in SNZ Derived Income tables).

Dependancies - 
				1.[msd_clean].[msd_spell] -- Tier 1 Benefit Spells only. 
				2.[msd_clean].[msd_second_tier_expenditure] -- Tier 2 Benefit Spells and Income from Tier 2. 
				3.[msd_clean].[msd_third_tier_expenditure] -- Tier 3 Benefit Spells and Income from Tier 3 .
				4.[wff_clean].[fam_return_dtls] -- Working for Families Tax Returns - this will be added to annual incomes / total income from benefits.  


**********************************************************************************************************************************************************************/
 /*********************************************************************
Tier 1 - MSD Benefits
 *********************************************************************/

IF OBJECT_ID('tempdb..#t1_ben') IS NOT NULL DROP TABLE #t1_ben;
WITH t1 AS (
SELECT a.[snz_uid]
      ,[msd_spel_servf_code]		AS [event_type]
	  ,[msd_spel_add_servf_code]	AS [event_type_2]
      ,[msd_spel_spell_start_date]	AS [start_date]
      ,[msd_spel_spell_end_date]	AS [end_date]
FROM [msd_clean].[msd_spell] a
INNER JOIN (SELECT DISTINCT parent_snz_uid FROM #population_sub) b
ON a.[snz_uid] = b.[parent_snz_uid]
WHERE msd_spel_spell_start_date IS NOT NULL 
),

t1_missing AS (
SELECT  a.[snz_uid]
		,a.[start_date] 
		,MIN(b.[start_date]) AS [end_date]
FROM (SELECT * FROM t1 WHERE [end_date] IS NULL) a 
INNER JOIN t1 b
ON a.[snz_uid] = b.[snz_uid]
AND a.[start_date] < b.[start_date]
GROUP BY  a.[snz_uid]
		,a.[start_date] 
HAVING MIN(b.start_date) IS NOT NULL
),

t1_imputed AS (
SELECT  a.[snz_uid]
		,[event_type]
		,[event_type_2]
		,a.[start_date]
		,CASE	WHEN a.[end_date] IS NOT NULL							THEN a.[end_date]
				WHEN a.[end_date] IS NULL AND b.[end_date] IS NOT NULL	THEN b.[end_date]
				ELSE ('2021-01-01') 
		END AS [end_date] 
FROM t1 a
LEFT JOIN t1_missing b
ON a.[snz_uid] = b.[snz_uid]
AND a.[start_date] = b.[start_date]
), 

t1_with_type AS (
 SELECT [snz_uid]
		,[start_date]
		,[end_date]  
		,CASE	WHEN [event_type] ='603' AND [event_type_2]='YPP' 
				    THEN '1: YP'
			  
				WHEN [event_type] ='603'  
					THEN '1: YP'
			  
				WHEN [event_type] ='602' 
					THEN '1: YP'

				WHEN  [event_type] IN ('115', '610', '611', '030', '330')
						OR 
					([event_type] IN ('675') AND [event_type_2] IN ('FTJS1', 'FTJS2')) 
					THEN '2: job_seeker'

				WHEN ([event_type] IN ('607', '608')) 
						OR ([event_type] IN ('675') AND [event_type_2] IN ('FTJS3', 'FTJS4'))
					THEN '2: job_seeker'

				WHEN ([event_type] in ('600','601')) 
						OR ([event_type] in ('675') AND [event_type_2] IN ('MED1',  'MED2'))  
					THEN   '2: job_seeker' 

				WHEN [event_type] in ('313', '365','665', '366','666')
					THEN  '3: sole_parent' 

				WHEN ([event_type] in ('370')   AND [event_type_2] IN ('PSMED')) 
						OR ([event_type] ='320') OR ([event_type]='020')     
					THEN '4: supported_living' 

				WHEN ([event_type] IN ('370') AND [event_type_2] IN ('CARE')) 
					OR ([event_type] IN ('367','667')) 
					THEN '4: supported_living' 

				WHEN [event_type] in ('999') 
					THEN '5: student_allowance'

				WHEN ([event_type] = '050' ) 
					THEN 'Other' 

			  ELSE 'Unknown' 
			
			  END AS [benefit_type] 
FROM t1_imputed
),
t1_with_type_fin AS (
SELECT [snz_uid]
	    ,[start_date]
		,[end_date]
		,MAX([benefit_type]) AS [benefit_type]
FROM t1_with_type
GROUP BY [snz_uid]
	    ,[start_date]
		,[end_date]
),
t1_fin_spells AS (
SELECT [snz_uid]
	    ,[start_date]
		,MIN([end_date]) AS [end_date]
		,[benefit_type]
FROM t1_with_type_fin
GROUP BY [snz_uid]
	    ,[start_date]
		,[benefit_type]
),
t1_type_flag AS (
SELECT [snz_uid]
       ,[cal_year] 
	   ,[cal_month]
	   ,IIF([benefit_type] = '1: YP', 1, 0) AS [youth_payment]
	   ,IIF([benefit_type] = '2: job_seeker', 1, 0) AS [job_seeker]
	   ,IIF([benefit_type] = '3: sole_parent', 1, 0) AS [sole_parent]
	   ,IIF([benefit_type] = '4: supported_living', 1, 0) AS [living_support]
	   ,IIF([benefit_type] = '5: student_allowance', 1, 0) AS [stu_allowance]
	   ,IIF([benefit_type] IN ('Other', 'Unknown'), 1, 0) AS [other_t1]
FROM #tax_cal_concord_fin a
INNER JOIN t1_fin_spells b
ON a.[start_date] <= b.[end_date] AND a.[end_date] >= b.[start_date]
),
-- Type Final
t1_type_final AS (
SELECT [snz_uid]
       ,[cal_year] 
	   ,[cal_month]
	   ,MAX([youth_payment]) AS [youth_payment]
	   ,MAX([job_seeker]) AS [job_seeker]
	   ,MAX([sole_parent]) AS [sole_parent]
	   ,MAX([living_support]) AS [living_support]
	   ,MAX([stu_allowance]) AS [stu_allowance]
	   ,MAX([other_t1]) AS [other_t1]
FROM t1_type_flag 
GROUP BY [snz_uid]
       ,[cal_year] 
	   ,[cal_month]
),
t1_no_overlaps AS (
SELECT s1.[snz_uid]
		,s1.[start_date]
		,MIN(t1.[end_date]) as [end_date]
FROM t1_fin_spells s1
INNER JOIN t1_fin_spells t1
ON  s1.[snz_uid] = t1.[snz_uid]
AND s1.[start_date] <= t1.[end_date]
AND NOT EXISTS (
	SELECT *
	FROM t1_fin_spells t2
	WHERE
		t1.[snz_uid] = t2.[snz_uid]
		AND t1.[end_date] >= t2.[start_date]
		AND t1.[end_date] < t2.[end_date]
)
WHERE NOT EXISTS (
	SELECT *
	FROM t1_fin_spells s2
	WHERE
		s1.[snz_uid] = s2.[snz_uid]
		AND s1.[start_date] > s2.[start_date]
		AND s1.[start_date] <= s2.[end_date]
)
GROUP BY
	s1.[snz_uid],
	s1.[start_date]
),
t1_time AS (
SELECT [snz_uid]
       ,[cal_year] 
	   ,[cal_month]
	   ,CASE	WHEN b.[start_date] <= a.[start_date] AND b.[end_date] >= a.[end_date] 
					THEN DATEDIFF(DAY, a.[start_date], a.[end_date]) + 1
				
				WHEN b.[start_date] > a.[start_date] AND b.[end_date] >= a.[end_date] 
					THEN DATEDIFF(DAY,b.[start_date],a.[end_date]) + 1

				WHEN b.[start_date] > a.[start_date] AND b.[end_date] < a.[end_date] 
					THEN DATEDIFF(DAY,b.[start_date], b.[end_date]) + 1

				WHEN b.[start_date] <= a.[start_date] AND b.[end_date]< a.[end_date] 
					THEN DATEDIFF(DAY,a.[start_date], b.[end_date]) + 1
				
				ELSE NULL 

		END AS [n_days_on_ben]
FROM #tax_cal_concord_fin a
INNER JOIN t1_no_overlaps b
ON a.[start_date] <= b.[end_date] AND a.[end_date] >= b.[start_date]
),
-- Time Final 
t1_time_final AS (
SELECT [snz_uid]
       ,[cal_year] 
	   ,[cal_month]
	   ,SUM([n_days_on_ben]) AS [n_days_T1_ben]
FROM t1_time
GROUP BY [snz_uid]
       ,[cal_year] 
	   ,[cal_month]
)
SELECT a.[snz_uid]
       ,a.[cal_year] 
	   ,a.[cal_month]
	   ,[n_days_T1_ben]
	   ,[youth_payment] AS [t1_yp]
	   ,[job_seeker] AS [t1_job_skr]
	   ,[sole_parent] AS [t1_sole_par]
	   ,[living_support] AS [t1_liv_sup]
	   ,[stu_allowance] AS [t1_stu_allowance]
	   ,[other_t1] AS [t1_other]
INTO #t1_ben
FROM t1_time_final a
LEFT JOIN t1_type_final b
ON a.[snz_uid] = b.[snz_uid]
AND a.[cal_year] = b.[cal_year]
AND a.[cal_month] = b.[cal_month]


 /*********************************************************************
Tier 2 - MSD Benefits
 *********************************************************************/

IF OBJECT_ID('tempdb..#t2_ben') IS NOT NULL DROP TABLE #t2_ben;
WITH t2 AS (
 SELECT DISTINCT a.[snz_uid]
        ,[msd_ste_start_date] AS [start_date]
		,[msd_ste_end_date] AS [end_date]
		,[msd_ste_daily_gross_amt] * (DATEDIFF(DAY, [msd_ste_start_date], [msd_ste_end_date]) + 1) AS [cost]
		,[classification] AS [ben_event_type]
		,'T2_spells' AS [type_for_days]
FROM [msd_clean].[msd_second_tier_expenditure] a
INNER JOIN  (SELECT DISTINCT [parent_snz_uid] FROM #population_sub) b
ON a.[snz_uid] = b.[parent_snz_uid]
LEFT JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[msd_benefit_type_code] c
ON a.[msd_ste_supp_serv_code] = c.Code
INNER JOIN #fixed d
ON 1= 1
WHERE [msd_ste_supp_serv_code] <> '180' -- New Zealand Superannuation 
AND YEAR([msd_ste_end_date]) >= [min_year]
),
t2_monthly_costs AS (
SELECT [snz_uid]
       ,[cal_year] 
	   ,[cal_month]
	   ,b.[cost] * (CASE	WHEN b.[start_date] <= a.[start_date] AND b.[end_date] >= a.[end_date] 
										THEN DATEDIFF(DAY, a.[start_date], a.[end_date]) + 1
				
									WHEN b.[start_date] > a.[start_date] AND b.[end_date] >= a.[end_date] 
										THEN DATEDIFF(DAY,b.[start_date],a.[end_date]) + 1

									WHEN b.[start_date] > a.[start_date] AND b.[end_date]< a.[end_date] 
										THEN DATEDIFF(DAY,b.[start_date], b.[end_date]) + 1

									WHEN b.[start_date] <= a.[start_date] AND b.[end_date]< a.[end_date] 
										THEN DATEDIFF(DAY,a.[start_date], b.[end_date]) + 1
				
									ELSE NULL 

								END) / (DATEDIFF(DAY,b.[start_date], b.[end_date]) + 1) 
				AS [monthly_cost]
	   ,b.[ben_event_type]
	   ,IIF([ben_event_type] = 'Accommodation Supplement',  1, 0) AS 'accom_supp'
	   ,IIF([ben_event_type] = 'Family Tax Credit',  1, 0) AS 'fam_tax_cred'
	   ,IIF([ben_event_type] = 'Unsupported Child''s Benefit',  1, 0) AS 'unsupp_child'
	   ,IIF([ben_event_type] NOT IN ('Accommodation Supplement', 'Family Tax Credit', 'Unsupported Child''s Benefit'), 1, 0) AS 'other_t2'
FROM #tax_cal_concord_fin a
INNER JOIN t2 b
ON a.[start_date] <= b.[end_date] 
AND a.[end_date] >= b.[start_date]
), 
t2_monthly_costs_fin AS (
SELECT [snz_uid]
       ,[cal_year] 
	   ,[cal_month]
	   ,SUM([monthly_cost]) AS [t2_ben_inc]
	   ,MAX([accom_supp]) AS [t2_accom_supp]
	   ,MAX([fam_tax_cred]) AS [t2_fam_tax_cred]
	   ,MAX([unsupp_child]) AS [t2_unsupp_child]
	   ,MAX([other_t2]) AS [t2_other]
FROM t2_monthly_costs
GROUP BY [snz_uid]
       ,[cal_year] 
	   ,[cal_month]

),
t2_montly_time_setup AS (
SELECT s1.[snz_uid]
		,s1.[type_for_days]
		,s1.[start_date]
		,MIN(t1.[end_date]) as [end_date]
FROM t2 s1
INNER JOIN t2 t1
ON  s1.[snz_uid] = t1.[snz_uid]
AND s1.[type_for_days] = t1.[type_for_days]
AND s1.[start_date] <= t1.[end_date]
AND NOT EXISTS (
	SELECT *
	FROM t2 t2
	WHERE
		t1.[snz_uid] = t2.[snz_uid]
		AND t1.[type_for_days] = t2.[type_for_days]
		AND t1.[end_date] >= t2.[start_date]
		AND t1.[end_date] < t2.[end_date]
)
WHERE NOT EXISTS (
	SELECT *
	FROM t2 s2
	WHERE
		s1.[snz_uid] = s2.[snz_uid]
		AND s1.[type_for_days] = s2.[type_for_days]
		AND s1.[start_date] > s2.[start_date]
		AND s1.[start_date] <= s2.[end_date]
)
GROUP BY
	s1.[snz_uid],
	s1.[type_for_days],
	s1.[start_date]
),
t2_montly_time_comb AS (
SELECT [snz_uid]
       ,[cal_year] 
	   ,[cal_month]
	   ,CASE	WHEN b.[start_date] <= a.[start_date] AND b.[end_date] >= a.[end_date] 
					THEN DATEDIFF(DAY, a.[start_date], a.[end_date]) + 1
				
				WHEN b.[start_date] > a.[start_date] AND b.[end_date] >= a.[end_date] 
					THEN DATEDIFF(DAY,b.[start_date],a.[end_date]) + 1

				WHEN b.[start_date] > a.[start_date] AND b.[end_date] < a.[end_date] 
					THEN DATEDIFF(DAY,b.[start_date], b.[end_date]) + 1

				WHEN b.[start_date] <= a.[start_date] AND b.[end_date]< a.[end_date] 
					THEN DATEDIFF(DAY,a.[start_date], b.[end_date]) + 1
				
				ELSE NULL 

		END AS [n_days_on_ben]
FROM #tax_cal_concord_fin a
INNER JOIN t2_montly_time_setup b
ON a.[start_date] <= b.[end_date] AND a.[end_date] >= b.[start_date]
),
t2_montly_time AS (
SELECT [snz_uid]
       ,[cal_year] 
	   ,[cal_month]
	   ,SUM([n_days_on_ben]) AS [n_days_T2_ben]
FROM t2_montly_time_comb
GROUP BY [snz_uid]
       ,[cal_year] 
	   ,[cal_month]
)
SELECT a.[snz_uid]
       ,a.[cal_year] 
	   ,a.[cal_month]
	   ,[n_days_T2_ben]
	   ,[t2_ben_inc]
	   ,[t2_accom_supp]
	   ,[t2_fam_tax_cred]
	   ,[t2_unsupp_child]
	   ,[t2_other]
INTO #t2_ben
FROM t2_montly_time a
LEFT JOIN t2_monthly_costs_fin b
ON a.[snz_uid] = b.[snz_uid]
AND a.[cal_year] = b.[cal_year]
AND a.[cal_month] = b.[cal_month]


 /*********************************************************************
 third tier benefits by tax year
 *********************************************************************/
IF OBJECT_ID('tempdb..#t3_ben') IS NOT NULL DROP TABLE #t3_ben;
SELECT [snz_uid]
	  ,[cal_year]
	  ,[cal_month]
	  ,SUM([msd_tte_pmt_amt]) as [t3_ben_inc]
	  ,MAX([domestic_purposes]) AS [t3_domestic_prps]
	  ,MAX([job_search_unemp]) AS [t3_job_src_unemp]
	  ,MAX([t3_other]) AS [t3_other]
INTO #t3_ben
FROM(
	 SELECT a.[snz_uid]
           ,MONTH([msd_tte_decision_date]) AS [cal_month]
		   ,YEAR([msd_tte_decision_date]) AS [cal_year]
           ,[msd_tte_pmt_amt]
		   ,IIF([msd_tte_parent_svc_code] IN ('666', '667', '613', '367', '313', '665', '366', '365'), 1, 0) AS [domestic_purposes]
		   ,IIF([msd_tte_parent_svc_code] IN ('602', '603', '125', '604', '605', '607', '608', '115', '610'), 1, 0) AS [job_search_unemp]
		   ,IIF([msd_tte_parent_svc_code] NOT IN ('666', '667', '613', '367', '313', '665', '366', '365', '602', '603', '125', '604', '605', '607', '608', '115', '610'), 1, 0) AS [t3_other]
	  FROM (SELECT a.* 
			FROM [msd_clean].[msd_third_tier_expenditure] a
			INNER JOIN #fixed b
			ON 1 = 1
			WHERE YEAR([msd_tte_decision_date]) >= [min_year] 
			AND [msd_tte_parent_svc_code] <> '180'
			) a
	  INNER JOIN (SELECT DISTINCT parent_snz_uid  FROM #population_sub) b
	  ON a.[snz_uid] = b.[parent_snz_uid]
	  ) tier3
GROUP BY [snz_uid]
		,[cal_year]
		,[cal_month]

 /*********************************************************************
 Work for family payment
 *********************************************************************/
IF OBJECT_ID('tempdb..#wff') IS NOT NULL DROP TABLE #wff;
WITH wff_temp AS (
SELECT [snz_uid]  
      ,[tax_return_date]
	  ,SUM([wff_pmt_prt])  AS [wff_pmt_unadj] 
FROM (
	SELECT a.[snz_uid] 
		  ,[wff_frd_return_period_date] AS [tax_return_date]
		  ,(COALESCE([wff_frd_fam_paid_amt], 0) - COALESCE([wff_frd_winz_paid_amt],0) - COALESCE([wff_frd_final_dr_cr_amt], 0)) AS [wff_pmt_prt] 
    FROM [wff_clean].[fam_return_dtls]	a
	INNER JOIN (SELECT DISTINCT [parent_snz_uid] FROM #population_sub) b
	ON a.[snz_uid] = b.[parent_snz_uid]
	WHERE YEAR([wff_frd_return_period_date])>= 2014 AND YEAR([wff_frd_return_period_date]) < 2022
	) a
GROUP BY  [snz_uid], [tax_return_date]
)
-- add the negative wff payment back, and deduct it from previous wff payment
 SELECT [snz_uid]  
	   ,[cal_year]
	   ,[cal_month]
       ,[wff_pmt_unadj] + [neg_adj] + COALESCE([lead_neg_deduct], 0) AS [inc_wff_tax_yr]
	   ,([wff_pmt_unadj] + [neg_adj] + COALESCE([lead_neg_deduct], 0))/12 AS [inc_wff_mthly]
INTO #wff
FROM(
 SELECT *
        ,IIF([wff_pmt_unadj] < 0,-[wff_pmt_unadj], 0) AS [neg_adj]
		,LEAD(IIF([wff_pmt_unadj] < 0, [wff_pmt_unadj], 0)) OVER(PARTITION BY [snz_uid] ORDER BY [tax_return_date]) AS [lead_neg_deduct]
 FROM wff_temp
 ) a
 INNER JOIN #tax_cal_concord b
 ON YEAR(a.[tax_return_date]) = b.tax_year


IF OBJECT_ID('tempdb..#benefits') IS NOT NULL DROP TABLE #benefits;
SELECT a.[snz_uid]
		,[child_dob_snz]
		,[month_after_birth]
		,[parent_snz_uid]
		,ISNULL([n_days_T1_ben], 0) AS [n_days_T1_ben]
		,ISNULL([t1_yp], 0) AS [t1_yp]
		,ISNULL([t1_job_skr], 0) AS [t1_job_skr]
		,ISNULL([t1_sole_par], 0) AS [t1_sole_par]
		,ISNULL([t1_liv_sup], 0) AS [t1_liv_sup]
		,ISNULL([t1_stu_allowance], 0) AS [t1_stu_allowance]
		,ISNULL([t1_other], 0) AS [t1_other]
		,ISNULL([n_days_T2_ben], 0) AS [n_days_T2_ben]
		,ISNULL([t2_ben_inc], 0) AS [t2_ben_inc]
		,ISNULL([t2_accom_supp], 0) AS [t2_accom_supp]
		,ISNULL([t2_fam_tax_cred], 0) AS [t2_fam_tax_cred]
		,ISNULL([t2_unsupp_child], 0) AS [t2_unsupp_child]
		,ISNULL([t2_other], 0) AS [t2_other]
		,ISNULL([t3_ben_inc], 0) AS [t3_ben_inc]
		,ISNULL([t3_domestic_prps], 0) AS [t3_domestic_prps]
		,ISNULL([t3_job_src_unemp], 0) AS [t3_job_src_unemp]
		,ISNULL([t3_other], 0) AS [t3_other]
		,ISNULL([inc_wff_mthly], 0) AS [inc_wff_mthly]
INTO #benefits
FROM #population_sub a
LEFT JOIN #t1_ben b
ON a.[parent_snz_uid] = b.[snz_uid]
AND DATEADD(MONTH, a.[month_after_birth], a.[child_dob_snz]) = DATEFROMPARTS(b.[cal_year], b.[cal_month], 15)
LEFT JOIN #t2_ben c
ON a.[parent_snz_uid] = c.[snz_uid]
AND DATEADD(MONTH, a.[month_after_birth], a.[child_dob_snz]) = DATEFROMPARTS(c.[cal_year], c.[cal_month], 15)
LEFT JOIN #t3_ben d
ON a.[parent_snz_uid] = d.[snz_uid]
AND DATEADD(MONTH, a.[month_after_birth], a.[child_dob_snz]) = DATEFROMPARTS(d.[cal_year], d.[cal_month], 15)
LEFT JOIN #wff e
ON a.[parent_snz_uid] = e.[snz_uid]
AND DATEADD(MONTH, a.[month_after_birth], a.[child_dob_snz]) = DATEFROMPARTS(e.[cal_year], e.[cal_month], 15)

/************************************************************ PARENTS INCOME AND EMPLOYMENT**************************************************************************

Title: Income and Industry of Income for all Parents of interest. 
Contact: Raj.Kulkarni@swa.govt.nz

Details: This script gets the income of parents by month and the sector of employment for each month of interest. This table uses the SNZ tax year income, and the 
income benefits in the section above to create representative monthly income by each source. For purpose of our analysis, Self-Employed income was split into 
Sole Trader, Income from Rent and Director/Shareholder Income. Income from self employment activities was divided equally into the 12 months when 
it was earned for simplicity. 
Sector of employment was chosen only from the "Main" employer in the EMS records. If a individual had 2 main employers in a month and 2 sectors - 
both of them were used for analysis. 
The script ends with income from various sources and a some flags and income derived measures (e.g. rolling average, cumulative total, etc.) required for our analysis. 
Main one's include :
	- Income by Source (Self Employed, Wages and Salaries, Rental and Sole Trader) 
	- gap below full time minimum wage threshold
	- income fluctuation (Dippers, Risers, Stable Below and Stable Above)
		- Dipper - if the income dipped below full time minimum wage (requirement: individual was earning above min wage the month before)
		- Riser - if the income rose below full time minimum wage (requirement: individual was earning below min wage the month before)
		- Stable Below - if the indidual was earning below minimum wage for current month and last month (i.e. two consecutive months)
		- Stable Above - if the indidual was earning above minimum wage for current month and last month (i.e. two consecutive months)
	- Annual Income (for parents individually, for child - only DIA mother + father / all parents involved) 
	- Income Split by Sources 
	- Various flags related to income (e.g. no income flag, min_wage flag, etc.)


Dependancies - 
			1.[data].[income_tax_yr]
			2.[ir_clean].[ird_ems]
			3.[IDI_Sandpit].[DL-MAA2020-73].[METADATA_min_wages] -- Code: min_wage_table.sql
			4. #benefits table from last part. 

Final relevant Table : 

**********************************************************************************************************************************************************************/

IF OBJECT_ID('tempdb..#pop_with_inc') IS NOT NULL DROP TABLE #pop_with_inc;

WITH income_raw AS (
SELECT DISTINCT a.snz_uid
	  ,a.[child_dob_snz]
	  ,a.[parent_snz_uid]
	  ,b.[inc_tax_yr_year_nbr]
      ,CASE WHEN b.[inc_tax_yr_income_source_code] IN ('P00', 'P01', 'P02', 'C00', 'C01', 'C02') THEN 'SEI'
			WHEN b.[inc_tax_yr_income_source_code] IN ('S00', 'S01', 'S02') THEN 'ST'
			WHEN b.[inc_tax_yr_income_source_code] IN ('S03') THEN 'RENT'
			WHEN b.[inc_tax_yr_income_source_code] IN ('W&S', 'WHP') THEN 'WAS'
			ELSE b.[inc_tax_yr_income_source_code]
	   END AS [inc_source]
      ,ISNULL(b.[inc_tax_yr_mth_01_amt], 0) AS [inc_tax_m1]
      ,ISNULL(b.[inc_tax_yr_mth_02_amt], 0) AS [inc_tax_m2]
      ,ISNULL(b.[inc_tax_yr_mth_03_amt], 0) AS [inc_tax_m3]
      ,ISNULL(b.[inc_tax_yr_mth_04_amt], 0) AS [inc_tax_m4]
      ,ISNULL(b.[inc_tax_yr_mth_05_amt], 0) AS [inc_tax_m5]
      ,ISNULL(b.[inc_tax_yr_mth_06_amt], 0) AS [inc_tax_m6]
      ,ISNULL(b.[inc_tax_yr_mth_07_amt], 0) AS [inc_tax_m7]
      ,ISNULL(b.[inc_tax_yr_mth_08_amt], 0) AS [inc_tax_m8]
      ,ISNULL(b.[inc_tax_yr_mth_09_amt], 0) AS [inc_tax_m9]
      ,ISNULL(b.[inc_tax_yr_mth_10_amt], 0) AS [inc_tax_m10]
      ,ISNULL(b.[inc_tax_yr_mth_11_amt], 0) AS [inc_tax_m11]
      ,ISNULL(b.[inc_tax_yr_mth_12_amt], 0) AS [inc_tax_m12]
      ,ISNULL(b.[inc_tax_yr_tot_yr_amt], 0) AS [inc_tax_yr_tot]
FROM #population_sub a
LEFT JOIN [data].[income_tax_yr] b
ON a.[parent_snz_uid] = b.[snz_uid]
LEFT JOIN #fixed c 
ON 1 = 1 
WHERE b.[inc_tax_yr_year_nbr] >= c.[min_year] - 1
),

/* The next two query blocks pivot the shape of the data so that calendar months are in one column, and there is a column for each source of income*/

income_sum AS(
SELECT a.* 
	  ,[inc_tax_m1] + [inc_tax_m2] +
	   [inc_tax_m3] + [inc_tax_m4] + 
	   [inc_tax_m5] + [inc_tax_m6] + 
	   [inc_tax_m7] + [inc_tax_m8] + 
	   [inc_tax_m9] + [inc_tax_m10] + 
	   [inc_tax_m11] + [inc_tax_m12]
	   AS [inc_total_manual]
	   
	   ,CASE WHEN 
	   (
	   [inc_tax_m1] + [inc_tax_m2] + 
	   [inc_tax_m3] + [inc_tax_m4] + 
	   [inc_tax_m5] + [inc_tax_m6] + 
	   [inc_tax_m7] + [inc_tax_m8] + 
	   [inc_tax_m9] + [inc_tax_m10] + 
	   [inc_tax_m11] + [inc_tax_m12]
	   ) <> [inc_tax_yr_tot] 
	   THEN 1 
	   ELSE 0 
	   END AS [inc_chksum]   
FROM (SELECT [snz_uid]
			  ,[child_dob_snz]
			  ,[parent_snz_uid]
			  ,[inc_tax_yr_year_nbr]
			  ,[inc_source]
			  ,SUM([inc_tax_m1]) AS [inc_tax_m1]
			  ,SUM([inc_tax_m2]) AS [inc_tax_m2]
			  ,SUM([inc_tax_m3]) AS [inc_tax_m3]
			  ,SUM([inc_tax_m4]) AS [inc_tax_m4]
			  ,SUM([inc_tax_m5]) AS [inc_tax_m5]
			  ,SUM([inc_tax_m6]) AS [inc_tax_m6]
			  ,SUM([inc_tax_m7]) AS [inc_tax_m7]
			  ,SUM([inc_tax_m8]) AS [inc_tax_m8]
			  ,SUM([inc_tax_m9]) AS [inc_tax_m9]
			  ,SUM([inc_tax_m10]) AS [inc_tax_m10]
			  ,SUM([inc_tax_m11]) AS [inc_tax_m11]
			  ,SUM([inc_tax_m12]) AS [inc_tax_m12]
			  ,SUM([inc_tax_yr_tot]) AS [inc_tax_yr_tot]
		FROM income_raw
		GROUP BY [snz_uid]
			  ,[child_dob_snz]
			  ,[parent_snz_uid]
			  ,[inc_tax_yr_year_nbr]
			  ,[inc_source] )a
),

income_sum_fin AS (
SELECT [snz_uid]
	  ,[child_dob_snz]
	  ,[parent_snz_uid]
	  ,[inc_tax_yr_year_nbr]
      ,[inc_source]
	  ,([inc_tax_m1] + [inc_divide]) AS [inc_tax_m1]
      ,([inc_tax_m2] + [inc_divide]) AS [inc_tax_m2]
      ,([inc_tax_m3] + [inc_divide]) AS [inc_tax_m3]
      ,([inc_tax_m4] + [inc_divide]) AS [inc_tax_m4]
      ,([inc_tax_m5] + [inc_divide]) AS [inc_tax_m5]
      ,([inc_tax_m6] + [inc_divide]) AS [inc_tax_m6]
      ,([inc_tax_m7] + [inc_divide]) AS [inc_tax_m7]
      ,([inc_tax_m8] + [inc_divide]) AS [inc_tax_m8]
      ,([inc_tax_m9] + [inc_divide]) AS [inc_tax_m9]
      ,([inc_tax_m10] + [inc_divide]) AS [inc_tax_m10]
      ,([inc_tax_m11] + [inc_divide]) AS [inc_tax_m11]
      ,([inc_tax_m12] + [inc_divide]) AS [inc_tax_m12]
FROM (SELECT *, 
		CASE	WHEN [inc_chksum] = 1 THEN CAST(ROUND((([inc_tax_yr_tot] - [inc_total_manual]) / 12), 2) AS NUMERIC(18, 2))
				ELSE 0
		END AS [inc_divide]
		FROM income_sum
		)a
),

income_unpivot AS (
SELECT [snz_uid]
		,[child_dob_snz]
		,[parent_snz_uid]
		,[inc_source]
		,[inc_tax_yr_year_nbr] AS [tax_year]
		,CASE	WHEN unpiv.[month] = 'inc_tax_m1' THEN 1
				WHEN unpiv.[month] = 'inc_tax_m2' THEN 2
				WHEN unpiv.[month] = 'inc_tax_m3' THEN 3
				WHEN unpiv.[month] = 'inc_tax_m4' THEN 4
				WHEN unpiv.[month] = 'inc_tax_m5' THEN 5
				WHEN unpiv.[month] = 'inc_tax_m6' THEN 6
				WHEN unpiv.[month] = 'inc_tax_m7' THEN 7
				WHEN unpiv.[month] = 'inc_tax_m8' THEN 8
				WHEN unpiv.[month] = 'inc_tax_m9' THEN 9
				WHEN unpiv.[month] = 'inc_tax_m10' THEN 10
				WHEN unpiv.[month] = 'inc_tax_m11' THEN 11
				WHEN unpiv.[month] = 'inc_tax_m12' THEN 12
		END AS 'tax_month'
		,ISNULL(unpiv.[income], 0) AS [income]
FROM income_sum_fin 
UNPIVOT (
		[income]  FOR 
		[month] IN 
		(
			[inc_tax_m1]
			,[inc_tax_m2]
			,[inc_tax_m3]
			,[inc_tax_m4]
			,[inc_tax_m5]
			,[inc_tax_m6]
			,[inc_tax_m7]
			,[inc_tax_m8]
			,[inc_tax_m9]
			,[inc_tax_m10]
			,[inc_tax_m11]
			,[inc_tax_m12]
		) 
) AS unpiv
-- changing from tax year to calendar year 
),
income_unpivot_fin AS (
SELECT a.[snz_uid]
		,a.[child_dob_snz]
		,a.[parent_snz_uid]
		,a.[inc_source]
		,DATEFROMPARTS(b.[cal_year], b.[cal_month], 15) AS [inc_date]
		,[income]
FROM income_unpivot a
LEFT JOIN #tax_cal_concord b 
ON a.[tax_year] = b.[tax_year]
AND a.[tax_month] = b.[tax_month]
WHERE b.[tax_year] IS NOT NULL -- to remove wrong records of future earnings (e.g some records are from 2036)
),

income_pivot AS(
SELECT [snz_uid]
		,[child_dob_snz]
		,[parent_snz_uid]
		,[inc_date]
		,DATEDIFF(MONTH, [child_dob_snz], [inc_date]) AS [month_after_birth]
		,ISNULL(BEN, 0) AS 'inc_benefit'
		,ISNULL(CLM, 0) AS 'inc_acc_claims'
		,ISNULL(PEN, 0) AS 'inc_pension'
		,ISNULL(PPL, 0) AS 'inc_parental_leave'
		,ISNULL(RENT, 0) AS 'inc_from_rental'
		,ISNULL(SEI, 0) AS 'inc_self_employed'
		,ISNULL(ST, 0) AS 'inc_sole_trader'
		,ISNULL(STU, 0) AS 'inc_student_loan'
		,ISNULL(WAS, 0) AS 'inc_wages'
		,ISNULL(BEN, 0) + ISNULL(STU, 0) + ISNULL(WAS, 0) + ISNULL(CLM, 0) + ISNULL(PPL, 0) + ISNULL(PEN, 0) + ISNULL(SEI, 0) + ISNULL(ST, 0) + ISNULL(RENT, 0)  AS 'total_inc'
		,IIF(ISNULL(BEN, 0) + ISNULL(STU, 0) + ISNULL(WAS, 0) + ISNULL(CLM, 0) + ISNULL(PPL, 0) + ISNULL(PEN, 0) + ISNULL(SEI, 0) + ISNULL(ST, 0) + ISNULL(RENT, 0) = 0, 1, 0) AS 'no_income' 
		,IIF(ISNULL(WAS, 0) = 0, 1, 0) AS 'no_wages'
		,IIF(ISNULL(WAS, 0) + ISNULL(SEI, 0) + ISNULL(ST, 0) + ISNULL(RENT, 0) = 0 , 1, 0) AS 'no_wages_sei'
		,IIF(ISNULL(PPL, 0) > 0, 1, 0) AS 'parental_leave'
		,IIF(ISNULL(STU, 0) > 0, 1, 0) AS 'student_loan'
FROM income_unpivot_fin a
PIVOT (
	SUM([income]) FOR [inc_source] IN (BEN, CLM, PEN, PPL, SEI, STU, WAS, RENT, ST)
) AS piv
),
inc_piv_with_ben AS (
SELECT b.[snz_uid]
		,b.[child_dob_snz]
		,b.[parent_snz_uid]
		,[inc_date]
		,b.[month_after_birth]
		,ISNULL(inc_benefit, 0) + [t2_ben_inc] + [t3_ben_inc] AS 'inc_benefit'
		,ISNULL(inc_acc_claims, 0) AS 'inc_acc_claims'
		,ISNULL(inc_pension, 0) AS 'inc_pension'
		,ISNULL(inc_parental_leave, 0) AS 'inc_parental_leave'
		,ISNULL(inc_from_rental, 0) AS 'inc_from_rental'
		,ISNULL(inc_self_employed, 0) AS 'inc_self_employed'
		,ISNULL(inc_sole_trader, 0) AS 'inc_sole_trader'
		,ISNULL(inc_student_loan, 0) AS 'inc_student_loan'
		,ISNULL(inc_wages, 0) + [inc_wff_mthly] AS 'inc_wages'
		,ISNULL(total_inc, 0) + [t2_ben_inc] + [t3_ben_inc] + [inc_wff_mthly] AS [total_inc]
		,IIF(ISNULL(total_inc, 0) + [t2_ben_inc] + [t3_ben_inc] + [inc_wff_mthly] = 0, 1, 0) AS 'no_income' 
		,IIF(ISNULL(inc_wages, 0) = 0, 1, 0) AS 'no_wages'
		,IIF(ISNULL(inc_wages, 0) + ISNULL(inc_self_employed, 0) + ISNULL(inc_sole_trader, 0) + ISNULL(inc_from_rental, 0) = 0 , 1, 0) AS 'no_wages_sei'
		,IIF(ISNULL(inc_parental_leave, 0) > 0, 1, 0) AS 'parental_leave'
		,IIF(ISNULL(inc_student_loan, 0) > 0, 1, 0) AS 'student_loan'
FROM income_pivot a
LEFT JOIN #benefits b
ON a.[snz_uid] = b.[snz_uid]
AND a.[parent_snz_uid] = b.[parent_snz_uid]
AND a.[month_after_birth] = b.[month_after_birth]


),
income_with_industry AS(
SELECT DISTINCT a.*
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'A' THEN 1 ELSE 0 END AS 'Agriculture_Forestry_Fishing'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'B' THEN 1 ELSE 0 END AS 'Mining'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'C' THEN 1 ELSE 0 END AS 'Manufacturing'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'D' THEN 1 ELSE 0 END AS 'Electricity_Gas_Water_Waste_Services'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'E' THEN 1 ELSE 0 END AS 'Construction'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'F' THEN 1 ELSE 0 END AS 'Wholesale_trade'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'G' THEN 1 ELSE 0 END AS 'Retail_trade' 
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'H' THEN 1 ELSE 0 END AS 'Accomodation_and_food_services' 
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'I' THEN 1 ELSE 0 END AS 'Transport_postal_and_warehousing'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'J' THEN 1 ELSE 0 END AS 'Information_Media_and_Teleco'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'K' THEN 1 ELSE 0 END AS 'Finance_and_Insurance_Services'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'L' THEN 1 ELSE 0 END AS 'Rental_hiring_and_real_estate_services'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'M' THEN 1 ELSE 0 END AS 'Professional_scientific_and_technical_services'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'N' THEN 1 ELSE 0 END AS 'Administration_and_support_Services'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'O' THEN 1 ELSE 0 END AS 'Public_Admin_and_safety'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'P' THEN 1 ELSE 0 END AS 'Education_and_training'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'Q' THEN 1 ELSE 0 END AS 'Health_care_and_social_assitance'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'R' THEN 1 ELSE 0 END AS 'Arts_and_rec_services'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'S' THEN 1 ELSE 0 END AS 'Other_services'
		,CASE WHEN SUBSTRING([ir_ems_pbn_anzsic06_code], 1, 1) = 'T' THEN 1 ELSE 0 END AS 'Not_elsewhere_included' 
FROM inc_piv_with_ben a
LEFT JOIN(
			SELECT [snz_uid]
					,DATEFROMPARTS(YEAR([ir_ems_return_period_date]), MONTH([ir_ems_return_period_date]), 15) as [inc_date]
					,[ir_ems_enterprise_nbr]
					,[ir_ems_pbn_anzsic06_code]
			FROM [ir_clean].[ird_ems] a
			LEFT JOIN #fixed b
			ON 1 = 1
			WHERE [ir_ems_return_period_date] IS NOT NULL 
			AND YEAR([ir_ems_return_period_date]) > YEAR(min_birth) - 1
			AND [ir_ems_income_source_code] IN ('W&S', 'WHP')
			AND [ir_ems_tax_code] = 'M'    
		)b
ON a.[parent_snz_uid] = b.[snz_uid]
AND a.[inc_date] = b.[inc_date]
LEFT JOIN #fixed z
ON 1 = 1
WHERE a.[month_after_birth] <= max_month --@upper
AND a.[month_after_birth] >= min_month --@lower
),
-- final table
inc_comb AS (
SELECT [snz_uid]
		,[child_dob_snz]
		,[parent_snz_uid]
		,[month_after_birth]
		,[inc_benefit]
		,[inc_acc_claims]
		,[inc_pension]
		,[inc_parental_leave]
		,[inc_from_rental]
		,[inc_self_employed]
		,[inc_sole_trader]
		,[inc_student_loan]
		,[inc_wages]
		,[total_inc]
		,[no_income] 
		,[no_wages]
		,[no_wages_sei]
		,[parental_leave]
		,[student_loan]
		,MAX(Agriculture_Forestry_Fishing) AS Agriculture_Forestry_Fishing 
		,MAX(Mining) AS Mining
		,MAX(Manufacturing) AS Manufacturing
		,MAX(Electricity_Gas_Water_Waste_Services) AS Electricity_Gas_Water_Waste_Services
		,MAX(Construction) AS Construction
		,MAX(Wholesale_trade) AS Wholesale_trade
		,MAX(Retail_trade) AS Retail_trade
		,MAX(Accomodation_and_food_services) AS Accomodation_and_food_services
		,MAX(Transport_postal_and_warehousing) AS Transport_postal_and_warehousing 
		,MAX(Information_Media_and_Teleco) AS Information_Media_and_Teleco
		,MAX(Finance_and_Insurance_Services) AS Finance_and_Insurance_Services
		,MAX(Rental_hiring_and_real_estate_services) AS Rental_hiring_and_real_estate_services
		,MAX(Professional_scientific_and_technical_services) AS Professional_scientific_and_technical_services
		,MAX(Administration_and_support_Services) AS Administration_and_support_Services
		,MAX(Public_Admin_and_safety) AS Public_Admin_and_safety
		,MAX(Education_and_training)  AS Education_and_training
		,MAX(Health_care_and_social_assitance) AS Health_care_and_social_assitance
		,MAX(Arts_and_rec_services)AS Arts_and_rec_services
		,MAX(Other_services) AS Other_services
		,MAX(Not_elsewhere_included) AS Not_elsewhere_included 
FROM income_with_industry
GROUP BY [snz_uid]
		,[child_dob_snz]
		,[parent_snz_uid]
		,[month_after_birth]
		,[inc_benefit]
		,[inc_acc_claims]
		,[inc_pension]
		,[inc_parental_leave]
		,[inc_from_rental]
		,[inc_self_employed]
		,[inc_sole_trader]
		,[inc_student_loan]
		,[inc_wages]
		,[total_inc]
		,[no_income] 
		,[no_wages]
		,[no_wages_sei]
		,[parental_leave]
		,[student_loan]
)
/*
	Merging this with the main dataset 
*/
SELECT DISTINCT a.*
		,ISNULL(b.[inc_benefit], 0) AS [inc_benefit]
		,ISNULL(b.[inc_student_loan], 0) AS [inc_student_loan]
		,ISNULL(b.[inc_wages], 0) AS [inc_wages]
		,ISNULL(b.[inc_acc_claims], 0) AS [inc_acc_claims]
		,ISNULL(b.[inc_parental_leave], 0) AS [inc_parental_leave]
		,ISNULL(b.[inc_pension], 0) AS [inc_pension]
		,ISNULL(b.[inc_self_employed], 0) AS [inc_self_employed]
		,ISNULL(b.[inc_from_rental], 0) AS [inc_from_rental]
		,ISNULL(b.[inc_sole_trader], 0) AS [inc_sole_trader]
		,ISNULL(b.[inc_benefit], 0) + ISNULL(b.[inc_student_loan], 0) + ISNULL(b.[inc_wages], 0) + ISNULL(b.[inc_acc_claims], 0) + ISNULL(b.[inc_parental_leave], 0) + ISNULL(b.[inc_pension], 0) + ISNULL(b.[inc_self_employed], 0) + ISNULL([inc_from_rental], 0) + ISNULL([inc_sole_trader], 0) AS [total_inc]
		,IIF(ISNULL(b.[inc_benefit], 0) + ISNULL(b.[inc_student_loan], 0) + ISNULL(b.[inc_wages], 0) + ISNULL(b.[inc_acc_claims], 0) + ISNULL(b.[inc_parental_leave], 0) + ISNULL(b.[inc_pension], 0) + ISNULL(b.[inc_self_employed], 0) + ISNULL([inc_from_rental], 0) + ISNULL([inc_sole_trader], 0) = 0, 1, 0) AS [no_income]
		,IIF(ISNULL(b.[inc_benefit], 0) + ISNULL(b.[inc_wages], 0) + ISNULL(b.[inc_self_employed], 0) + ISNULL([inc_from_rental], 0) + ISNULL([inc_sole_trader], 0) = 0, 1, 0) AS [no_wages_sei]
		,IIF( ISNULL(b.[inc_wages], 0) = 0, 1, 0) AS [no_wages]
		,IIF(ISNULL(b.[inc_parental_leave], 0) > 0 , 1, 0) AS [parental_leave]
		,IIF(ISNULL(b.[inc_student_loan], 0) > 0 , 1, 0) AS [student_loan]
		,ISNULL(b.[Agriculture_Forestry_Fishing], 0) AS [Agriculture_Forestry_Fishing]
		,ISNULL(b.[Mining], 0) AS [Mining]
		,ISNULL(b.[Manufacturing], NULL) AS [Manufacturing]
		,ISNULL(b.[Electricity_Gas_Water_Waste_Services], 0) AS [Electricity_Gas_Water_Waste_Services]
		,ISNULL(b.[Construction], 0) AS [Construction]
		,ISNULL(b.[Wholesale_trade], 0) AS [Wholesale_trade]
		,ISNULL(b.[Retail_trade], NULL) AS [Retail_trade]
		,ISNULL(b.[Accomodation_and_food_services], 0) AS [Accomodation_and_food_services]
		,ISNULL(b.[Transport_postal_and_warehousing], 0) AS [Transport_postal_and_warehousing]
		,ISNULL(b.[Information_Media_and_Teleco], 0) AS [Information_Media_and_Teleco]
		,ISNULL(b.[Finance_and_Insurance_Services], 0) AS [Finance_and_Insurance_Services]
		,ISNULL(b.[Rental_hiring_and_real_estate_services], 0) AS [Rental_hiring_and_real_estate_services]
		,ISNULL(b.[Professional_scientific_and_technical_services], 0) AS [Professional_scientific_and_technical_services]
		,ISNULL(b.[Administration_and_support_Services], 0) AS [Administration_and_support_Services]
		,ISNULL(b.[Public_Admin_and_safety], 0) AS [Public_Admin_and_safety]
		,ISNULL(b.[Education_and_training], 0) AS [Education_and_training]
		,ISNULL(b.[Health_care_and_social_assitance], 0) AS [Health_care_and_social_assitance]
		,ISNULL(b.[Arts_and_rec_services], 0) AS [Arts_and_rec_services]
		,ISNULL(b.[Other_services], 0) AS [Other_services]
		,ISNULL(b.[Not_elsewhere_included], 0) AS [Not_elsewhere_included]
INTO #pop_with_inc
FROM #population_sub a
LEFT JOIN inc_comb b 
ON a.[snz_uid] = b.[snz_uid] 
AND a.[parent_snz_uid] = b.[parent_snz_uid]
AND a.[month_after_birth] = b.[month_after_birth];

-- creating sub population to make things easier 
IF OBJECT_ID('tempdb..#sub_pop_inc') IS NOT NULL DROP TABLE #sub_pop_inc
SELECT [snz_uid]
		,[month_after_birth]
		,[parent_snz_uid]
		,ROW_NUMBER() OVER (PARTITION BY a.snz_uid, a.parent_snz_uid ORDER BY a.month_after_birth)							AS [month_number]
		,[inc_wages]
		,([inc_wages] + [inc_from_rental] + [inc_self_employed] + [inc_sole_trader])										AS [total_inc_wages_sei]
		,[total_inc]
		,IIF(a.[inc_wages] >= b.[min_monthly_inc], 1, 0)																	AS [min_monthly_wages_flag]
		,IIF((a.[inc_wages] + [inc_from_rental] + [inc_self_employed] + [inc_sole_trader]) >= b.[min_monthly_inc], 1, 0)	AS [min_monthly_wages_sei_flag]
		,IIF(a.[total_inc] >= b.[min_monthly_inc], 1, 0)																	AS [min_monthly_wage_total_inc_flag]
		,b.[min_monthly_inc]
		,b.[min_monthly_living_wage]
INTO #sub_pop_inc
FROM #pop_with_inc a 
LEFT JOIN [IDI_Sandpit].[DL-MAA2020-73].[METADATA_min_wages] b
ON DATEADD(MONTH, a.[month_after_birth], a.[child_dob_snz])  BETWEEN b.[start_date] AND b.[end_date]

IF OBJECT_ID('tempdb..#pop_with_inc_emp') IS NOT NULL DROP TABLE #pop_with_inc_emp;
WITH inc_emp_1 AS (
SELECT a.[snz_uid]
		,a.[month_after_birth]
		,a.[parent_snz_uid]
		,a.[inc_wages]
		,a.[total_inc]
		,a.[total_inc_wages_sei]
		,a.[min_monthly_wages_flag]
		,a.[min_monthly_wages_sei_flag]
		,a.[min_monthly_wage_total_inc_flag]
		,a.[month_number]
		,SUM(b.inc_wages)								AS [cu_inc_wages]
		,SUM(b.total_inc_wages_sei)						AS [cu_total_inc_wages_sei]
		,SUM(b.total_inc)								AS [cu_total_inc]
		,SUM(b.min_monthly_inc)							AS [cu_min_monthly_inc]
		,SUM(b.inc_wages) / a.[month_number]			AS [avg_cu_inc_wages]
		,SUM(b.total_inc_wages_sei) / a.[month_number]	AS [avg_cu_total_inc_wages_sei]
		,SUM(b.total_inc) / a.[month_number]			AS [avg_cu_total_inc]
		,SUM(b.min_monthly_inc) / a.[month_number]		AS [avg_min_monthly_inc]
FROM #sub_pop_inc a
INNER JOIN #sub_pop_inc b
ON a.[snz_uid] = b.[snz_uid]
AND a.[parent_snz_uid] = b.[parent_snz_uid] 
AND a.[month_after_birth] >= b.[month_after_birth]
GROUP BY a.[snz_uid]
		,a.[month_after_birth]
		,a.[parent_snz_uid]
		,a.[inc_wages]
		,a.[total_inc]
		,a.[total_inc_wages_sei]
		,a.[min_monthly_wages_flag]
		,a.[min_monthly_wages_sei_flag]
		,a.[min_monthly_wage_total_inc_flag]
		,a.[month_number]
),
inc_emp_2 AS (
SELECT  [snz_uid]
		,[month_after_birth]
		,[parent_snz_uid]
		,[inc_wages]
		,[total_inc]
		,[total_inc_wages_sei]
		,[min_monthly_wages_flag]
		,[min_monthly_wages_sei_flag]
		,[min_monthly_wage_total_inc_flag]
		,[month_number]
		,[cu_inc_wages]
		,[cu_total_inc_wages_sei]
		,[cu_total_inc]
		,[cu_min_monthly_inc]
		,[avg_cu_inc_wages]
		,[avg_cu_total_inc_wages_sei]
		,[avg_cu_total_inc]
		,[avg_min_monthly_inc]
		-- temp varaibles 
		,LAG(inc_wages, 1, inc_wages) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth)									AS [lag_inc_wages]
		,LAG(avg_cu_inc_wages, 1, avg_cu_inc_wages) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth)						AS [lag_avg_cu_inc_wages]	
		,LAG(total_inc_wages_sei, 1, total_inc_wages_sei) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth)				AS [lag_total_inc_wages_sei]
		,LAG(avg_cu_total_inc_wages_sei, 1, avg_cu_total_inc_wages_sei) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth)	AS [lag_avg_cu_total_inc_wages_sei]
		,LAG(total_inc, 1, total_inc) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth)									AS [lag_total_inc]
		,LAG(avg_cu_total_inc, 1, avg_cu_total_inc) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth)						AS [lag_avg_cu_total_inc]
FROM inc_emp_1
), 
inc_emp_3 AS (
SELECT [snz_uid]
		,[month_after_birth]
		,[parent_snz_uid]
		,[inc_wages]
		,[total_inc]
		,[total_inc_wages_sei]
		,[min_monthly_wages_flag]
		,[min_monthly_wages_sei_flag]
		,[min_monthly_wage_total_inc_flag]
		,[month_number]
		,[cu_inc_wages]
		,[cu_total_inc_wages_sei]
		,[cu_total_inc]
		,[cu_min_monthly_inc]
		,[avg_cu_inc_wages]
		,[avg_cu_total_inc_wages_sei]
		,[avg_cu_total_inc]
		,[avg_min_monthly_inc]
		,IIF(lag_inc_wages > inc_wages, 1, 0)											AS [inc_wages_fall_flag]
		,(inc_wages - lag_inc_wages)													AS [inc_wages_change]
		,(inc_wages - lag_avg_cu_inc_wages)												AS [inc_wages_change_from_cu_avg]
		,((inc_wages - lag_inc_wages) / NULLIF(lag_inc_wages, 0)) * 100					AS [inc_wages_change_perc]
		,(avg_cu_inc_wages - lag_avg_cu_inc_wages) / NULLIF(lag_avg_cu_inc_wages, 0)	AS [inc_wages_cu_avg_change_perc]
		
		,IIF(lag_total_inc_wages_sei > total_inc_wages_sei, 1, 0)						AS [total_inc_wages_sei_fall_flag]
		,(total_inc_wages_sei - lag_total_inc_wages_sei)								AS [total_inc_wages_sei_change]
		,(total_inc_wages_sei - lag_avg_cu_total_inc_wages_sei)							AS [total_inc_wages_sei_change_from_cu_avg]
		,(total_inc_wages_sei - lag_total_inc_wages_sei) 
		  / 
		  NULLIF(lag_total_inc_wages_sei, 0) * 100										AS [total_inc_wages_sei_change_perc]
		,(avg_cu_total_inc_wages_sei - lag_avg_cu_total_inc_wages_sei)
		  / 
		  NULLIF(lag_avg_cu_total_inc_wages_sei, 0) * 100								AS [inc_wages_sei_cu_avg_change_perc]

		,IIF(lag_total_inc > total_inc, 1, 0)											AS [total_inc_fall_flag]
		,(total_inc - lag_total_inc)													AS [total_inc_change]
		,(total_inc - lag_avg_cu_total_inc)												AS [total_inc_change_from_cu_avg]
		,(total_inc - lag_total_inc / NULLIF(lag_total_inc, 0)) * 100					AS [total_inc_change_perc]
		,((avg_cu_total_inc - lag_avg_cu_total_inc) 
		  / 
		  NULLIF(lag_avg_cu_total_inc, 0)) * 100										AS [total_inc_cu_avg_change_perc]
FROM inc_emp_2
),
-- Storing results into final table 
pop_with_inc_emp AS (
SELECT	DISTINCT a.*
		,b.[cu_inc_wages] -- cumulative income from wages
		,b.[avg_cu_inc_wages]
		,b.[min_monthly_wages_flag] -- at least earning min monthly wage from wages and salaries
		,b.[inc_wages_fall_flag] -- income drop from last month
		,b.[inc_wages_change] -- amount of income change 
		,b.[inc_wages_change_perc] -- percent of income change
		,b.[inc_wages_change_from_cu_avg] -- income change from cumulative avergage income of last month 
		,b.[inc_wages_cu_avg_change_perc] -- percent cumulative avergae income from wage change 

		-- Total income from wages + sei   
		,b.[total_inc_wages_sei]
		,b.[cu_total_inc_wages_sei] -- cumulative total income from wages and sei
		,b.[min_monthly_wages_sei_flag] -- at least earning min monthly wage from wages, salaries and sei combined
		,b.[avg_cu_total_inc_wages_sei]
		,b.[total_inc_wages_sei_fall_flag] -- if total income from wages + sei was lower than last month
		,b.[total_inc_wages_sei_change] -- amount of income change from last month (from sei and wages)
		,b.[total_inc_wages_sei_change_perc] -- percent of sei change from last month
		,b.[total_inc_wages_sei_change_from_cu_avg] 
		,b.[inc_wages_sei_cu_avg_change_perc]
		
		-- Total Income all sources 
		,b.[cu_total_inc]
		,b.[avg_cu_total_inc]
		,b.[min_monthly_wage_total_inc_flag] 
		,b.[total_inc_fall_flag]
		,b.[total_inc_change]
		,b.[total_inc_change_perc]
		,b.[total_inc_change_from_cu_avg]
		,b.[total_inc_cu_avg_change_perc]

		-- based on min income for the month 
		,b.[cu_min_monthly_inc]
		,b.[avg_min_monthly_inc]
FROM #pop_with_inc a
LEFT JOIN inc_emp_3 b 
ON a.[snz_uid] = b.[snz_uid] 
AND a.[parent_snz_uid] = b.[parent_snz_uid]
AND a.[month_after_birth] = b.[month_after_birth]
) 
-- Defining gaps 
SELECT *
		,IIF([inc_wages_change_perc] < -50 OR [inc_wages] = 0, 1, 0) AS [gap_inc_wages]
		,IIF([total_inc_wages_sei_change_perc] < -50 OR [total_inc_wages_sei] = 0, 1, 0) AS [gap_inc_wages_sei]
		,IIF([total_inc_change_perc] < -50 OR [total_inc] = 0, 1, 0) AS [gap_total_inc]
		,IIF([inc_wages_change_perc] < -50, 1, 0) AS [gap_inc_wages_abs]
		,IIF([total_inc_wages_sei_change_perc] < -50, 1, 0) AS [gap_inc_wages_sei_abs]
		,IIF([total_inc_change_perc] < -50, 1, 0) AS [gap_total_inc_abs]
		,IIF([min_monthly_wages_flag] = 0, 1, 0) AS [gap_wages_below_min]
		,IIF([min_monthly_wages_sei_flag] = 0, 1, 0) AS [gap_wages_sei_below_min] 
		,IIF([min_monthly_wage_total_inc_flag] = 0, 1, 0) AS [gap_total_inc_below_min]
		,CASE	WHEN LAG([min_monthly_wages_flag], 1, [min_monthly_wages_flag]) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth) = 1 
					 AND 
					 [min_monthly_wages_flag] = 1 
				THEN 'stable_above'

				WHEN LAG([min_monthly_wages_flag], 1, [min_monthly_wages_flag]) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth) = 0 
					 AND 
					 [min_monthly_wages_flag] = 0 
				THEN 'stable_below'

				WHEN LAG([min_monthly_wages_flag], 1, [min_monthly_wages_flag]) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth) = 1 
					 AND 
					 [min_monthly_wages_flag] = 0 
				THEN 'dipper'

				WHEN LAG([min_monthly_wages_flag], 1, [min_monthly_wages_flag]) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth) = 0 
					 AND 
					 [min_monthly_wages_flag] = 1 
				THEN 'riser'
		END AS [fluc_wages]

		,CASE	WHEN LAG([min_monthly_wages_sei_flag], 1, [min_monthly_wages_sei_flag]) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth) = 1 
					 AND 
					 [min_monthly_wages_sei_flag] = 1 
				THEN 'stable_above'

				WHEN LAG([min_monthly_wages_sei_flag], 1, [min_monthly_wages_sei_flag]) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth) = 0 
					 AND 
					 [min_monthly_wages_sei_flag] = 0 
				THEN 'stable_below'

				WHEN LAG([min_monthly_wages_sei_flag], 1, [min_monthly_wages_sei_flag]) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth) = 1 
					 AND 
					 [min_monthly_wages_sei_flag] = 0 
				THEN 'dipper'

				WHEN LAG([min_monthly_wages_sei_flag], 1, [min_monthly_wages_sei_flag]) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth) = 0 
					 AND 
					 [min_monthly_wages_sei_flag] = 1 
				THEN 'riser'
		END AS [fluc_wage_sei]

		,CASE	WHEN LAG([min_monthly_wage_total_inc_flag], 1, [min_monthly_wage_total_inc_flag]) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth) = 1 
					 AND 
					 [min_monthly_wage_total_inc_flag] = 1 
				THEN 'stable_above'

				WHEN LAG([min_monthly_wage_total_inc_flag], 1, [min_monthly_wage_total_inc_flag]) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth) = 0 
					 AND 
					 [min_monthly_wage_total_inc_flag] = 0 
				THEN 'stable_below'

				WHEN LAG([min_monthly_wage_total_inc_flag], 1, [min_monthly_wage_total_inc_flag]) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth) = 1 
					 AND 
					 [min_monthly_wage_total_inc_flag] = 0 
				THEN 'dipper'

				WHEN LAG([min_monthly_wage_total_inc_flag], 1, [min_monthly_wage_total_inc_flag]) OVER (PARTITION BY snz_uid, parent_snz_uid ORDER BY month_after_birth) = 0 
					 AND 
					 [min_monthly_wage_total_inc_flag] = 1 
				THEN 'riser'
		END AS [fluc_total_inc]
INTO #pop_with_inc_emp 
FROM pop_with_inc_emp

-- Adding parental income (or child centric income)
IF OBJECT_ID('tempdb..#pop_with_inc_final') IS NOT NULL DROP TABLE #pop_with_inc_final;
WITH ch_inc_mf AS (
SELECT [snz_uid]
		,[month_after_birth]	
		,SUM(ISNULL([inc_wages], 0)) AS [ch_inc_wages_mf]
		,SUM(ISNULL([total_inc_wages_sei], 0)) AS [ch_total_inc_wages_sei_mf]
		,SUM(ISNULL([total_inc], 0)) AS [ch_total_inc_mf]
FROM #pop_with_inc_emp
WHERE parent_relationship IN ('DIA_Father', 'DIA_Mother')
GROUP BY [snz_uid]
		,[month_after_birth]
),
ch_inc_mf_cu AS (
SELECT a.[snz_uid]
		,a.[month_after_birth]
		,a.[ch_inc_wages_mf]
		,SUM(b.[ch_inc_wages_mf]) AS [ch_cu_inc_wages_mf]
		,(SUM(b.[ch_inc_wages_mf]) / (a.[month_after_birth] + 13)) AS [ch_cu_avg_inc_wages_mf]
		
		,a.[ch_total_inc_wages_sei_mf]
		,SUM(b.[ch_total_inc_wages_sei_mf]) AS [ch_cu_total_inc_wages_sei_mf]
		,(SUM(b.[ch_total_inc_wages_sei_mf]) / (a.[month_after_birth] + 13))  AS [ch_cu_avg_total_inc_wages_sei_mf]
		
		,a.[ch_total_inc_mf]
		,SUM(b.[ch_total_inc_mf]) AS [ch_cu_total_inc_mf]
		,(SUM(b.[ch_total_inc_mf]) / (a.[month_after_birth] + 13)) AS [ch_cu_avg_total_inc_mf]
FROM ch_inc_mf a
INNER JOIN ch_inc_mf b
ON a.[snz_uid] = b.[snz_uid]
AND a.[month_after_birth] >= b.[month_after_birth]
GROUP BY a.[snz_uid]
		,a.[month_after_birth]
		,a.[ch_inc_wages_mf]
		,a.[ch_total_inc_wages_sei_mf]
		,a.[ch_total_inc_mf]

),
ch_inc_all AS (
SELECT [snz_uid]
		,[month_after_birth]
		,SUM(ISNULL([inc_wages], 0))			AS [ch_inc_wages_all]
		,SUM(ISNULL([total_inc_wages_sei], 0))	AS [ch_total_inc_wages_sei_all]
		,SUM(ISNULL([total_inc], 0))			AS [ch_total_inc_all]
FROM #pop_with_inc_emp
GROUP BY [snz_uid]
		,[month_after_birth]
),
ch_inc_all_cu AS (
SELECT a.[snz_uid]
		,a.[month_after_birth]
		,a.[ch_inc_wages_all]
		,SUM(b.[ch_inc_wages_all])												AS [ch_cu_inc_wages_all]
		,(SUM(b.[ch_inc_wages_all]) / (a.[month_after_birth] + 13))				AS [ch_cu_avg_inc_wages_all]

		,a.[ch_total_inc_wages_sei_all]
		,SUM(b.[ch_total_inc_wages_sei_all])									AS [ch_cu_total_inc_wages_sei_all]
		,(SUM(b.[ch_total_inc_wages_sei_all]) / (a.[month_after_birth] + 13))	AS [ch_cu_avg_total_inc_wages_sei_all]
				
		,a.[ch_total_inc_all]
		,SUM(b.[ch_total_inc_all])												AS [ch_cu_total_inc_all]
		,(SUM(b.[ch_total_inc_all]) / (a.[month_after_birth] + 13))				AS [ch_cu_avg_total_inc_all]
FROM ch_inc_all a
INNER JOIN ch_inc_all b
ON a.[snz_uid] = b.[snz_uid]
AND a.[month_after_birth] >= b.[month_after_birth]
GROUP BY a.[snz_uid]
		,a.[month_after_birth]
		,a.[ch_inc_wages_all]
		,a.[ch_total_inc_wages_sei_all]
		,a.[ch_total_inc_all]
)
SELECT a.*
		,b.[ch_inc_wages_mf]
		,b.[ch_cu_inc_wages_mf]
		,b.[ch_cu_avg_inc_wages_mf]
		
		,b.[ch_total_inc_wages_sei_mf]
		,b.[ch_cu_total_inc_wages_sei_mf]
		,b.[ch_cu_avg_total_inc_wages_sei_mf]

		,b.[ch_total_inc_mf]
		,b.[ch_cu_total_inc_mf]
		,b.[ch_cu_avg_total_inc_mf]
	
		
		,c.[ch_inc_wages_all]
		,c.[ch_cu_inc_wages_all]
		,c.[ch_cu_avg_inc_wages_all]

		,c.[ch_total_inc_wages_sei_all]
		,c.[ch_cu_total_inc_wages_sei_all]
		,c.[ch_cu_avg_total_inc_wages_sei_all]
		
		,c.[ch_total_inc_all]
		,c.[ch_cu_total_inc_all]
		,c.[ch_cu_avg_total_inc_all]

		,CASE	WHEN [cu_inc_wages] IS NULL OR	[cu_inc_wages] <= 5000 THEN '0-5000'
			WHEN [cu_inc_wages] > 5000	AND [cu_inc_wages] <= 10000	THEN '5001-10000'
			WHEN [cu_inc_wages] > 10000 AND [cu_inc_wages] <= 20000 THEN '10001-20000'
			WHEN [cu_inc_wages] > 20000 AND [cu_inc_wages] <= 30000 THEN '20001-30000'
			WHEN [cu_inc_wages] > 30000 AND [cu_inc_wages] <= 40000 THEN '30001-40000'
			WHEN [cu_inc_wages] > 40000 AND [cu_inc_wages] <= 50000 THEN '40001-50000'
			WHEN [cu_inc_wages] > 50000 AND [cu_inc_wages] <= 70000 THEN '50001-70000'
			WHEN [cu_inc_wages] > 70000								THEN '70001+'
	END AS [inc_wages_grp]
	
	,CASE	WHEN [cu_total_inc_wages_sei] IS NULL	OR	[cu_total_inc_wages_sei] <= 5000	THEN '0-5000'
			WHEN [cu_total_inc_wages_sei] > 5000	AND [cu_total_inc_wages_sei] <= 10000	THEN '5001-10000'
			WHEN [cu_total_inc_wages_sei] > 10000	AND [cu_total_inc_wages_sei] <= 20000	THEN '10001-20000'
			WHEN [cu_total_inc_wages_sei] > 20000	AND [cu_total_inc_wages_sei] <= 30000	THEN '20001-30000'
			WHEN [cu_total_inc_wages_sei] > 30000	AND [cu_total_inc_wages_sei] <= 40000	THEN '30001-40000'
			WHEN [cu_total_inc_wages_sei] > 40000	AND [cu_total_inc_wages_sei] <= 50000	THEN '40001-50000'
			WHEN [cu_total_inc_wages_sei] > 50000	AND [cu_total_inc_wages_sei] <= 70000	THEN '50001-70000'
			WHEN [cu_total_inc_wages_sei] > 70000											THEN '70001+'
	END AS [inc_wages_sei_grp]
	
	,CASE	WHEN [cu_total_inc] IS NULL OR	[cu_total_inc] <= 5000 THEN '0-5000'
			WHEN [cu_total_inc] > 5000	AND [cu_total_inc] <= 10000	THEN '5001-10000'
			WHEN [cu_total_inc] > 10000 AND [cu_total_inc] <= 20000 THEN '10001-20000'
			WHEN [cu_total_inc] > 20000 AND [cu_total_inc] <= 30000 THEN '20001-30000'
			WHEN [cu_total_inc] > 30000 AND [cu_total_inc] <= 40000 THEN '30001-40000'
			WHEN [cu_total_inc] > 40000 AND [cu_total_inc] <= 50000 THEN '40001-50000'
			WHEN [cu_total_inc] > 50000 AND [cu_total_inc] <= 70000 THEN '50001-70000'
			WHEN [cu_total_inc] > 70000								THEN '70001+'
	END AS [inc_total_grp]

	,CASE	WHEN [ch_cu_inc_wages_mf] IS NULL OR  [ch_cu_inc_wages_mf] <= 20000		THEN '0-10000'
			WHEN [ch_cu_inc_wages_mf] > 20000 AND [ch_cu_inc_wages_mf] <= 30000		THEN '20001-30000'
			WHEN [ch_cu_inc_wages_mf] > 30000 AND [ch_cu_inc_wages_mf] <= 40000		THEN '30001-40000'
			WHEN [ch_cu_inc_wages_mf] > 40000 AND [ch_cu_inc_wages_mf] <= 50000		THEN '40001-50000'
			WHEN [ch_cu_inc_wages_mf] > 50000 AND [ch_cu_inc_wages_mf] <= 70000		THEN '50001-70000'
			WHEN [ch_cu_inc_wages_mf] > 70000 AND [ch_cu_inc_wages_mf] <= 100000	THEN '70001-100000'
			WHEN [ch_cu_inc_wages_mf] > 100000 AND [ch_cu_inc_wages_mf] <= 150000	THEN '100001-150000'
			WHEN [ch_cu_inc_wages_mf] > 150000										THEN '150001+'
	END AS [ch_inc_wages_grp]

	,CASE	WHEN [ch_cu_total_inc_wages_sei_mf] IS NULL OR  [ch_cu_total_inc_wages_sei_mf] <= 20000		THEN '0-10000'
			WHEN [ch_cu_total_inc_wages_sei_mf] > 20000 AND [ch_cu_total_inc_wages_sei_mf] <= 30000		THEN '20001-30000'
			WHEN [ch_cu_total_inc_wages_sei_mf] > 30000 AND [ch_cu_total_inc_wages_sei_mf] <= 40000		THEN '30001-40000'
			WHEN [ch_cu_total_inc_wages_sei_mf] > 40000 AND [ch_cu_total_inc_wages_sei_mf] <= 50000		THEN '40001-50000'
			WHEN [ch_cu_total_inc_wages_sei_mf] > 50000 AND [ch_cu_total_inc_wages_sei_mf] <= 70000		THEN '50001-70000'
			WHEN [ch_cu_total_inc_wages_sei_mf] > 70000 AND [ch_cu_total_inc_wages_sei_mf] <= 100000	THEN '70001-100000'
			WHEN [ch_cu_total_inc_wages_sei_mf] > 100000 AND [ch_cu_total_inc_wages_sei_mf] <= 150000	THEN '100001-150000'
			WHEN [ch_cu_total_inc_wages_sei_mf] > 150000										THEN '150001+'
	END AS [ch_inc_wages_sei_grp]

	,CASE	WHEN [ch_cu_total_inc_mf] IS NULL OR  [ch_cu_total_inc_mf] <= 20000		THEN '0-10000'
			WHEN [ch_cu_total_inc_mf] > 20000 AND [ch_cu_total_inc_mf] <= 30000		THEN '20001-30000'
			WHEN [ch_cu_total_inc_mf] > 30000 AND [ch_cu_total_inc_mf] <= 40000		THEN '30001-40000'
			WHEN [ch_cu_total_inc_mf] > 40000 AND [ch_cu_total_inc_mf] <= 50000		THEN '40001-50000'
			WHEN [ch_cu_total_inc_mf] > 50000 AND [ch_cu_total_inc_mf] <= 70000		THEN '50001-70000'
			WHEN [ch_cu_total_inc_mf] > 70000 AND [ch_cu_total_inc_mf] <= 100000	THEN '70001-100000'
			WHEN [ch_cu_total_inc_mf] > 100000 AND [ch_cu_total_inc_mf] <= 150000	THEN '100001-150000'
			WHEN [ch_cu_total_inc_mf] > 150000										THEN '150001+'
	END AS [ch_inc_total_grp]
INTO #pop_with_inc_final
FROM #pop_with_inc_emp a
LEFT JOIN ch_inc_mf_cu b
ON a.[snz_uid] = b.[snz_uid]
AND a.[month_after_birth] = b.[month_after_birth]
LEFT JOIN ch_inc_all_cu c
ON a.[snz_uid] = c.[snz_uid]
AND a.[month_after_birth] = c.[month_after_birth]

/************************************************************ PARENTS AND CHILD CENSUS VARIABLES *******************************************************************

Title: Parents and Child Census Information
Contact: Raj.Kulkarni@swa.govt.nz

Details: This script adds relevant census variables to the dataframe - Main variable - Occpupation Level 1 and 2 and detailed Ethnicity. 

Dependancies - 
				1. [cen_clean].[census_individual_2018] 
				2. [IDI_Metadata].[clean_read_CLASSIFICATIONS].[CEN_ANZSCO] 
				3. [IDI_Metadata].[clean_read_CLASSIFICATIONS].[CEN_ANZSIC06] 
				4. [cen_clean].[census_dwelling_2018]


**********************************************************************************************************************************************************************/

IF OBJECT_ID('tempdb..#pop_with_cen') IS NOT NULL DROP TABLE #pop_with_cen

SELECT	a.[snz_uid]
		,a.[child_dob_snz]
		,a.[month_after_birth]
		,a.[parent_snz_uid]
		,a.[parent_relationship]
		,[cen_ind_job_ind_code] AS [cen_ind_par_job_ind_code]
		,[cen_ind_occupation_code]
		,c.[descriptor_text] AS [cen_occupation_description_l1]
		,e.[descriptor_text] AS [cen_occupation_description_l2]
		,[cen_ind_industry_code] 
		,d.[descriptor_text] AS [cen_industry_description_l1]
		,f.[descriptor_text] AS [cen_industry_description_l2]
		,[cen_ind_ethgr_code] AS [cen_ind_ethgr_code_parent]
INTO #pop_with_cen
FROM #population_sub a 
LEFT JOIN [cen_clean].[census_individual_2018] b
ON a.[parent_snz_uid] = b.[snz_uid] 

LEFT JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[CEN_ANZSCO] c 
ON SUBSTRING(b.[cen_ind_occupation_code], 1, 1) = CONVERT(VARCHAR, c.[cat_code])

LEFT JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[CEN_ANZSIC06] d
ON SUBSTRING(b.[cen_ind_industry_code], 1, 1) = d.[cat_code]

LEFT JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[CEN_ANZSCO] e 
ON SUBSTRING(b.[cen_ind_occupation_code], 1, 2) = CONVERT(VARCHAR, e.[cat_code])

LEFT JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[CEN_ANZSIC06] f
ON SUBSTRING(b.[cen_ind_industry_code], 1, 3) = f.[cat_code]

LEFT JOIN [cen_clean].[census_dwelling_2018] j
ON b.[ur_snz_cen_dwell_uid] = j.[snz_cen_dwell_uid]

/************************************************************ PARENTS MIGRATION STATUS *******************************************************************

Title: Migration Status for Parents (Recent Migrants, Long term Migrants)
Contact: Raj.Kulkarni@swa.govt.nz

Details: This script uses SNZ Derived Migration spells and MBIE Visa Approvals to determine recent migrants (defined as migrants who received temp class visa 
or residence class visa in last 5 years (compared to year of birth of their child) or were on any temporary or residence class visa in last 5 years. 


Dependancies - 
				1.[dol_clean].[decisions]
				2.[data].[person_overseas_spell]

***********************************************************************************************************************************************************/


IF OBJECT_ID('tempdb..#migration_status') IS NOT NULL DROP TABLE #migration_status;
SELECT DISTINCT a.[parent_snz_uid]
		,ISNULL(b.[resident_class], 0) AS [resident_class]
		,ISNULL(b.[temp_class], 0) AS [temp_class]
		,ISNULL(c.[recent_arrival], 0) AS [recent_arrival]
INTO #migration_status
FROM #population_sub a
LEFT JOIN (
			SELECT a.[parent_snz_uid]
					,MAX(IIF([dol_dec_reporting_cat_code] = 'R', 1, 0)) AS [resident_class]
					,MAX(IIF([dol_dec_reporting_cat_code] = 'T', 1, 0)) AS [temp_class]
			FROM #population_sub a
			INNER JOIN [dol_clean].[decisions] b
			ON a.[parent_snz_uid] = b.[snz_uid]
			WHERE DATEDIFF(YEAR, [dol_dec_decision_date], [child_dob_snz]) <=5
			AND DATEDIFF(YEAR, [dol_dec_decision_date], [child_dob_snz]) >= -1
			AND dol_dec_decision_type_code = 'A'
			GROUP BY a.[parent_snz_uid]
)b
ON a.[parent_snz_uid] = b.[parent_snz_uid] 
LEFT JOIN (
			SELECT DISTINCT a.parent_snz_uid
					,1 AS [recent_arrival]
			FROM #population_sub a
			INNER JOIN [data].[person_overseas_spell] b
			ON a.parent_snz_uid = b.snz_uid
			WHERE [pos_first_arrival_ind] = 'y'
			AND DATEDIFF(YEAR, CAST([pos_ceased_date] AS DATE), [child_dob_snz]) <=5
) c
ON a.[parent_snz_uid] = c.[parent_snz_uid]


/****************************************************************************************************************************************
Title: Employment spells and Employer Attachment Variables using Labour Tables
Contact: Raj.Kulkarni@swa.govt.nz

Details: This script uses Fabling-Mare Labour tables to get employment spells (and employment status) for population of interest at a 
monthly frequency. We also gather the FTE information from the tables to idenfity population potentially working part time (<0.5 FTE or <0.8 FTE) 
and population working full time. The employment spells are used to determine length of employment with employer. 
For each month, we then select the main employer - based on who the individual has worked the most in last 12 months. 
case 1: if snz_uid_1 was only working with employer (x) at month (t), employer (x) is selected as main employer. 
case 2: if snz_uid_2 was working with employers (x, y) at month (t) - we check the employment spells for last 12 months (t-12) and select the employer 
who has been there for longest as the main employer. 
	Note - if there is a conflict in this condition (i.e. if there are two or more consistent employers at month (t), we randomly select one of them to 
	represent as main employer. Such events are very rare but do happen. We suspect this having minimal to no impact on broader population. 

Dependancies - 
			1.[IDI_Adhoc].[clean_read_IR].[pent_emp_mth_FTE_IDI_20201020_RFabling] (NOTE: This is using specific refresh of IDI - Please 
			check the refresh before using this table)
			2.[IDI_Metadata].[clean_read_CLASSIFICATIONS].[CEN_ANZSIC06] (to get industry classification for main employer)
****************************************************************************************************************************************/

IF OBJECT_ID('tempdb..#income_spells') IS NOT NULL DROP TABLE #income_spells;
SELECT DISTINCT b.[snz_uid]
	  ,[parent_snz_uid]
	  ,[parent_relationship]
	  ,[child_dob_snz]
	  ,[pent]
      ,DATEFROMPARTS(LEFT([dim_month_key], 4), RIGHT([dim_month_key], 2), 15) AS [income_month]
      ,[spell_start]
      ,[spell_end]
      ,[short_spell]
INTO #income_spells
FROM [IDI_Adhoc].[clean_read_IR].[pent_emp_mth_FTE_IDI_20201020_RFabling] a
INNER JOIN (SELECT DISTINCT [snz_uid]
				,[parent_snz_uid]
				,[parent_relationship]
				,[child_dob_snz] 
			FROM #population_sub 
			)b 
ON a.[snz_uid] = b.[parent_snz_uid]
WHERE spell_start = 1 OR spell_end = 1


IF OBJECT_ID('tempdb..#emp_fte') IS NOT NULL DROP TABLE #emp_fte;
SELECT b.[snz_uid]
	  ,[parent_snz_uid]
	  ,[child_dob_snz]
	  ,[pent]
      ,DATEFROMPARTS(LEFT([dim_month_key], 4), RIGHT([dim_month_key], 2), 15) AS [income_month]
      ,SUM([fte]) AS [fte]
	  ,MAX([n_jobs]) AS [n_jobs]
INTO #emp_fte
FROM [IDI_Adhoc].[clean_read_IR].[pent_emp_mth_FTE_IDI_20201020_RFabling] a
INNER JOIN (SELECT DISTINCT [snz_uid]
				,[parent_snz_uid]
				,[child_dob_snz] 
			FROM #population_sub 
			)b 
ON a.[snz_uid] = b.[parent_snz_uid]
GROUP BY b.[snz_uid]
	  ,[parent_snz_uid]
	  ,[child_dob_snz]
	  ,[pent]
      ,DATEFROMPARTS(LEFT([dim_month_key], 4), RIGHT([dim_month_key], 2), 15)

IF OBJECT_ID('tempdb..#emp_clean_spells') IS NOT NULL DROP TABLE #emp_clean_spells;

WITH t1 AS (
SELECT snz_uid
		,parent_snz_uid
		,child_dob_snz
		,pent
		,income_month
		,unpiv.[spell_ind]
FROM #income_spells
UNPIVOT (
	spell_start_val FOR  
	spell_ind  IN 
	(
		spell_start,
		spell_end
	) 
)  unpiv
WHERE unpiv.spell_start_val != 0 
), 
t2 AS (
SELECT snz_uid
		,parent_snz_uid
		,child_dob_snz
		,pent
		,income_month
		,spell_ind
		,ROW_NUMBER() OVER (PARTITION BY snz_uid, parent_snz_uid, pent, spell_ind ORDER BY income_month) AS spell_start_number
FROM t1
),
spell_clean AS (
SELECT a.snz_uid 
		,a.parent_snz_uid
		,a.child_dob_snz
		,a.pent
		,a.income_month AS spell_start
		,ISNULL(b.income_month, '2020-05-15') AS spell_end
FROM (SELECT * FROM t2 WHERE spell_ind = 'spell_start') a
LEFT JOIN (SELECT * FROM t2 WHERE spell_ind = 'spell_end')b 
ON a.snz_uid = b.snz_uid 
AND a.parent_snz_uid = b.parent_snz_uid
AND a.pent = b.pent 
AND a.spell_start_number = b.spell_start_number
), 
spells_with_time AS (
SELECT DISTINCT a.snz_uid
		,a.parent_snz_uid 
		,b.month_after_birth
		,a.child_dob_snz
		,a.pent
		,a.spell_start
		,a.spell_end
		,ROW_NUMBER() OVER (PARTITION BY snz_uid, parent_snz_uid, pent, spell_start, spell_end ORDER BY b.month_after_birth) AS 'n_months_with_emp'
FROM spell_clean a
INNER JOIN #months b
ON 1 = 1 
WHERE DATEADD(MONTH, b.month_after_birth, child_dob_snz) BETWEEN spell_start AND spell_end
), 
spells_n_months AS (
SELECT a.snz_uid
		,a.parent_snz_uid 
		,a.month_after_birth
		,a.child_dob_snz
		,a.pent
		,a.n_months_with_emp
FROM spells_with_time a
INNER JOIN (SELECT snz_uid
					,parent_snz_uid 
					,month_after_birth
					,MAX(n_months_with_emp) AS max_n_months_with_emp
			FROM spells_with_time
			GROUP BY snz_uid
					,parent_snz_uid 
					,month_after_birth
			)b 
ON a.snz_uid = b.snz_uid
AND a.parent_snz_uid = b.parent_snz_uid
AND a.month_after_birth = b.month_after_birth
AND a.n_months_with_emp = b.max_n_months_with_emp
), 
spells_n_months_final AS (
SELECT snz_uid
		,parent_snz_uid 
		,month_after_birth
		,child_dob_snz
		,pent
		,n_months_with_emp
		,ROW_NUMBER() OVER (PARTITION BY snz_uid, parent_snz_uid, month_after_birth, n_months_with_emp ORDER BY pent DESC) AS rn
FROM spells_n_months
),  
main_emp_fte AS (
SELECT DISTINCT a.snz_uid
		,a.parent_snz_uid
		,a.child_dob_snz
		,a.income_month
		,a.pent
		,b.avg_fte
		,b.max_fte
		,b.total_fte_worked
		,b.n_jobs
FROM #emp_fte a
INNER JOIN (SELECT snz_uid
					,parent_snz_uid
					,income_month
					,AVG(fte) AS avg_fte
					,MAX(fte) AS max_fte
					,SUM(fte) AS total_fte_worked
					,MAX(n_jobs) AS n_jobs
			FROM #emp_fte
			GROUP BY snz_uid
					,parent_snz_uid
					,income_month
			) b
ON a.snz_uid = b.snz_uid
AND a.parent_snz_uid = b.parent_snz_uid
AND a.income_month = b.income_month
AND a.fte = b.max_fte
), 
main_emp_fte_final AS (
SELECT DISTINCT snz_uid
		,parent_snz_uid
		,DATEDIFF(MONTH, child_dob_snz, income_month) AS month_after_birth
		,child_dob_snz
		,pent
		,avg_fte
		,max_fte
		,total_fte_worked
		,n_jobs
		,ROW_NUMBER() OVER (PARTITION BY snz_uid, parent_snz_uid, income_month, max_fte ORDER BY pent) AS rn
FROM main_emp_fte 
WHERE DATEDIFF(MONTH, child_dob_snz, income_month) >= -24 AND DATEDIFF(MONTH, child_dob_snz, income_month) <= 12
), 
pent_industry AS (
SELECT a.pent, a.anz06_4d, b.descriptor_text AS 'industry_l1', c.descriptor_text AS 'industry_l2'
FROM [IDI_Adhoc].[clean_read_IR].[pent_ind_IDI_20201020_RFabling] a
LEFT JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[CEN_ANZSIC06] b
ON SUBSTRING(a.[anz06_4d], 1, 1) = b.cat_code
LEFT JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[CEN_ANZSIC06] c
ON SUBSTRING(a.[anz06_4d], 1, 3) = c.cat_code
),
final_emp_table AS (
SELECT a.snz_uid 
		,a.parent_snz_uid 
		,ISNULL(a.child_dob_snz, b.child_dob_snz) AS [child_dob_snz]
		,ISNULL(a.month_after_birth, b.month_after_birth) AS [month_after_birth]
		,b.pent AS [pent_fte]
		,d.[anz06_4d] AS [pent_fte_anz06]
		,d.industry_l1 AS [pent_fte_industry_l1]
		,d.industry_l2 AS [pent_fte_industry_l2]
		,ISNULL(b.avg_fte, 0) AS avg_fte
		,ISNULL(b.max_fte, 0) AS max_fte
		,ISNULL(b.total_fte_worked, 0) AS total_fte_worked
		,ISNULL(b.n_jobs, 1) AS n_jobs -- since this only joins on existing spells, I am making the assumption that people still have at least one job in the inner spells
		,a.pent AS pent_max_months
		,c.anz06_4d AS [pent_time_anz06]
		,c.industry_l1 AS [pent_time_industry_l1]
		,c.industry_l2 AS [pent_time_industry_l2]
		,a.[n_months_with_emp]
FROM (SELECT * FROM spells_n_months_final   WHERE rn = 1 AND [month_after_birth] >= -12 AND [month_after_birth] <= 12) a
LEFT JOIN (SELECT * FROM main_emp_fte_final WHERE rn = 1 AND [month_after_birth] >= -12 AND [month_after_birth] <= 12) b
ON a.snz_uid = b.snz_uid 
AND a.parent_snz_uid = b.parent_snz_uid
AND a.month_after_birth = b.month_after_birth
LEFT JOIN pent_industry c 
ON a.pent = c.pent
LEFT JOIN pent_industry d 
ON b.pent = d.pent
), 
emp_clean AS (
SELECT snz_uid
		,parent_snz_uid
		,child_dob_snz
		,[month_after_birth]
		,ISNULL([pent_fte], [pent_max_months]) AS [pent_fte]
		,ISNULL([pent_fte_anz06], [pent_time_anz06]) AS [pent_fte_anz06]
		,ISNULL([pent_fte_industry_l1], [pent_time_industry_l1]) AS [pent_fte_industry_l1]
		,ISNULL([pent_fte_industry_l2], [pent_time_industry_l2]) AS [pent_fte_industry_l2]
		,avg_fte
		,max_fte
		,total_fte_worked
		,n_jobs 
		,pent_max_months
		,[pent_time_anz06]
		,[pent_time_industry_l1]
		,[pent_time_industry_l2]
		,n_months_with_emp
FROM final_emp_table
),
pop_with_inc AS (
SELECT *,
		[inc_wages] + [inc_from_rental] + [inc_self_employed] + [inc_sole_trader]	AS [total_inc_wages_sei]
FROM #pop_with_inc
)
SELECT c.[snz_uid]
		,c.[parent_snz_uid]
		,c.[month_after_birth]
		,c.[parent_relationship]
		,[pent_fte]
		,[pent_fte_anz06]
		,[pent_fte_industry_l1]
		,[pent_fte_industry_l2]
		,ISNULL([avg_fte], 0) AS [avg_fte]
		,ISNULL([max_fte], 0) AS [max_fte]
		,ISNULL([total_fte_worked], 0) AS [total_fte_worked]
		,ISNULL([n_jobs], 0) AS [n_jobs]
		,[pent_max_months]
		,[pent_time_anz06]
		,[pent_time_industry_l1]
		,[pent_time_industry_l2]
		,[n_months_with_emp] AS [time_with_employer]
		,CASE	WHEN [n_months_with_emp] >= 12 AND [pent_fte] = [pent_max_months] THEN 'two_weeks_leave_main_emp'
				WHEN [n_months_with_emp] >= 12 AND [pent_fte] <> [pent_max_months] THEN 'two_weeks_leave_sec_emp'
				WHEN [n_months_with_emp] > 5 AND [n_months_with_emp] <= 11 AND [pent_fte] = [pent_max_months] THEN 'one_week_leave_main_emp'
				WHEN [n_months_with_emp] > 5 AND [n_months_with_emp] <= 11 AND [pent_fte] <> [pent_max_months] THEN 'one_week_leave_sec_emp'
				WHEN [n_months_with_emp] <= 5 THEN 'no_leave'
				WHEN [n_months_with_emp] IS NULL THEN 'not_on_wages'
		END AS [parental_leave_status]
		,IIF(LAG(b.[pent_max_months], 1, 0) OVER (PARTITION BY a.snz_uid, a.parent_snz_uid ORDER BY a.month_after_birth) <> b.[pent_max_months], 1, 0)	AS [new_emp_change_flag]
		,CASE	WHEN a.[total_inc_wages_sei] > 0 AND a.[inc_benefit] > 0 THEN 'wages_and_ben'
				WHEN a.[total_inc_wages_sei] = 0 AND a.[inc_benefit] > 0 THEN 'only_on_ben'
				WHEN a.[total_inc_wages_sei] > 0 AND a.[inc_benefit] = 0 THEN 'only_wages'
				WHEN a.[total_inc_wages_sei] = 0 AND a.[inc_benefit] = 0 AND a.[total_inc] > 0 THEN 'no_wages_no_ben_some_inc'
				WHEN a.[total_inc_wages_sei] = 0 AND a.[inc_benefit] = 0 AND a.[total_inc] = 0 THEN 'no_wages_no_ben_no_inc'
				WHEN a.[total_inc_wages_sei] IS NULL OR a.[inc_benefit] IS NULL OR a.[total_inc] IS NULL THEN 'no_wages_no_ben_no_inc'
				WHEN a.[total_inc_wages_sei] < 0 THEN 'employed_sei_neg_inc'
		END AS [income_status]
INTO #emp_clean_spells
FROM #population_sub c
LEFT JOIN pop_with_inc a
ON c.[snz_uid] = a.[snz_uid] 
AND c.parent_snz_uid = a.parent_snz_uid
AND c.month_after_birth = a.month_after_birth
LEFT JOIN emp_clean b  
ON a.snz_uid = b.snz_uid
AND a.parent_snz_uid = b.parent_snz_uid
AND a.month_after_birth = b.month_after_birth;

/****************************************************************************************************************************************
COMBINING ALL DATA INTO FINAL DATAFRAME 
****************************************************************************************************************************************/

IF OBJECT_ID('tempdb..#ginfe_pop') IS NOT NULL DROP TABLE #ginfe_pop;
SELECT	DISTINCT a.[snz_uid]
		,a.[child_dob_snz]
		,a.[month_after_birth]
		,[child_gender_sex_code]
		,a.[parent_snz_uid]
		,[parent_dob_snz]
		,[parent_age_at_birth]
		,[parent_gender_sex_code]
		,a.[parent_relationship]
		,[parent_eu]
		,[parent_maori]
		,[parent_pasific]
		,[parent_asian]
		,[parent_melaa]
		,[parent_other_eth]
		
		,[resident_class]
		,[temp_class]
		,[recent_arrival]
		,[parent_highqual_at_birth]
		
		,[addr_uid]
		,[mb]
		,[sa1]
		,[sa2]
		,[ta]
		,[cb]
		,[ur]
		,[rc]
		,[south_auckland]
		,[west_auckland]

		,[inc_benefit]
		,[inc_acc_claims]
		,[inc_pension]
		,[inc_parental_leave]
		,[inc_from_rental]
		,[inc_self_employed]
		,[inc_sole_trader]
		,[inc_student_loan]
		
		-- Wages   
		,[inc_wages]
		,[cu_inc_wages] -- cumulative income from wages
		,[avg_cu_inc_wages]
		,[min_monthly_wages_flag] -- at least earning min monthly wage from wages and salaries
		,[inc_wages_fall_flag] -- income drop from last month
		,[inc_wages_change] -- amount of income change 
		,[inc_wages_change_perc] -- percent of income change
		,[inc_wages_change_from_cu_avg] -- income change from cumulative avergage income of last month 
		,[inc_wages_cu_avg_change_perc] -- percent cumulative avergae income from wage change 

		-- Total income from wages + sei   
		,[total_inc_wages_sei]
		,[cu_total_inc_wages_sei] -- cumulative total income from wages and sei
		,[min_monthly_wages_sei_flag] -- at least earning min monthly wage from wages, salaries and sei combined
		,[avg_cu_total_inc_wages_sei]
		,[total_inc_wages_sei_fall_flag] -- if total income from wages + sei was lower than last month
		,[total_inc_wages_sei_change] -- amount of income change from last month (from sei and wages)
		,[total_inc_wages_sei_change_perc] -- percent of sei change from last month
		,[total_inc_wages_sei_change_from_cu_avg] 
		,[inc_wages_sei_cu_avg_change_perc]
		
		-- Total Income all sources 
		,[total_inc]
		,[cu_total_inc]
		,[avg_cu_total_inc]
		,[min_monthly_wage_total_inc_flag] 
		,[total_inc_fall_flag]
		,[total_inc_change]
		,[total_inc_change_perc]
		,[total_inc_change_from_cu_avg]
		,[total_inc_cu_avg_change_perc]

		-- based on min income for the month 
		,[cu_min_monthly_inc]
		,[avg_min_monthly_inc]

		-- child centric income 
		,[ch_inc_wages_mf]
		,[ch_cu_inc_wages_mf]
		,[ch_cu_avg_inc_wages_mf]
		
		,[ch_total_inc_wages_sei_mf]
		,[ch_cu_total_inc_wages_sei_mf]
		,[ch_cu_avg_total_inc_wages_sei_mf]

		,[ch_total_inc_mf]
		,[ch_cu_total_inc_mf]
		,[ch_cu_avg_total_inc_mf]
	
		
		,[ch_inc_wages_all]
		,[ch_cu_inc_wages_all]
		,[ch_cu_avg_inc_wages_all]

		,[ch_total_inc_wages_sei_all]
		,[ch_cu_total_inc_wages_sei_all]
		,[ch_cu_avg_total_inc_wages_sei_all]
		
		,[ch_total_inc_all]
		,[ch_cu_total_inc_all]
		,[ch_cu_avg_total_inc_all]
		,[no_income] 
		,[no_wages]
		,[no_wages_sei]

		,[inc_wages_grp]
		,[inc_wages_sei_grp]
		,[inc_total_grp]
		,[ch_inc_wages_grp]
		,[ch_inc_wages_sei_grp]
		,[ch_inc_total_grp]

		,[n_days_T1_ben]
		,[t1_yp]
		,[t1_job_skr]
		,[t1_sole_par]
		,[t1_liv_sup]
		,[t1_stu_allowance]
		,[t1_other]

		,[n_days_T2_ben]
		,[t2_ben_inc]
		,[t2_accom_supp]
		,[t2_fam_tax_cred]
		,[t2_unsupp_child]
		,[t2_other]
		
		,[t3_ben_inc]
		,[t3_domestic_prps]
		,[t3_job_src_unemp]
		,[t3_other]

		,CASE WHEN [n_days_T1_ben] > 0 OR [n_days_T2_ben] > 0 OR [t3_ben_inc] > 0 THEN 1 ELSE 0 END AS [benefit_flag]
		
		,CASE	WHEN [n_days_T1_ben] > 0 AND [n_days_T2_ben] > 0 AND [t3_ben_inc] > 0 THEN 'all_tiers'
				WHEN [n_days_T1_ben] > 0 AND [n_days_T2_ben] = 0 AND [t3_ben_inc] = 0 THEN 'only_t1'
				WHEN [n_days_T1_ben] = 0 AND [n_days_T2_ben] = 0 AND [t3_ben_inc] > 0 THEN 'only_t3'
				WHEN [n_days_T1_ben] = 0 AND [n_days_T2_ben] > 0 AND [t3_ben_inc] = 0 THEN 'only_t2'
				WHEN [n_days_T1_ben] > 0 AND [n_days_T2_ben] > 0 AND [t3_ben_inc] = 0 THEN 't1_t2'
				WHEN [n_days_T1_ben] > 0 AND [n_days_T2_ben] = 0 AND [t3_ben_inc] > 0 THEN 't1_t3'
				WHEN [n_days_T1_ben] = 0 AND [n_days_T2_ben] > 0 AND [t3_ben_inc] > 0 THEN 't2_t3'
				WHEN [n_days_T1_ben] = 0 AND [n_days_T2_ben] = 0 AND [t3_ben_inc] = 0 THEN 'no_ben'
				ELSE 'oops'
		 END AS [ben_tiers]

		,CASE	WHEN [t1_job_skr] = 1 OR [t3_job_src_unemp] = 1 THEN 'work'
				WHEN [t1_sole_par] = 1 OR [t2_unsupp_child] = 1 THEN 'sole_parent'
				WHEN [t2_fam_tax_cred] = 1 OR [t3_domestic_prps] = 1  THEN 'family'
				WHEN [t2_accom_supp] = 1 OR [t1_liv_sup] = 1 THEN 'accomodation'
				WHEN [n_days_T1_ben] = 0 AND [n_days_T2_ben] = 0 AND [t3_ben_inc] = 0 THEN 'no_ben'
				ELSE 'other'
		END AS [ben_type]
		
		,[inc_wff_mthly]

		,[pent_fte]
		,[pent_fte_anz06]
		,[pent_fte_industry_l1]
		,[pent_fte_industry_l2]
		,[avg_fte]
		,[max_fte]
		,[total_fte_worked]
		,[n_jobs]
		,[pent_max_months]
		,[pent_time_anz06]
		,[pent_time_industry_l1]
		,[pent_time_industry_l2]
		,[time_with_employer]
		,[parental_leave_status]
		,[new_emp_change_flag]
		,[income_status]

		,[gap_inc_wages]
		,[gap_inc_wages_sei]
		,[gap_total_inc]
		,[gap_inc_wages_abs]
		,[gap_inc_wages_sei_abs]
		,[gap_total_inc_abs]
		,[gap_wages_below_min]
		,[gap_wages_sei_below_min]
		,[gap_total_inc_below_min]

		,[fluc_wages]
		,[fluc_wage_sei]
		,[fluc_total_inc]

		,[cen_ind_occupation_code]
		,[cen_occupation_description_l1]
		,[cen_occupation_description_l2]
		,[cen_ind_industry_code] 
		,[cen_industry_description_l1]
		,[cen_industry_description_l2]
		,[cen_ind_ethgr_code_parent]
INTO #ginfe_pop
FROM #population a
LEFT JOIN #pop_with_inc_final b 
ON a.[snz_uid] = b.[snz_uid] 
AND a.[parent_snz_uid] = b.[parent_snz_uid]
AND a.[month_after_birth] = b.[month_after_birth]

LEFT JOIN #pop_with_cen h
ON a.[snz_uid] = h.[snz_uid] 
AND a.[parent_snz_uid] = h.[parent_snz_uid]
AND a.[month_after_birth] = h.[month_after_birth]

LEFT JOIN #migration_status k
ON a.[parent_snz_uid] = k.[parent_snz_uid]

LEFT JOIN #benefits m
ON a.[snz_uid] = m.[snz_uid]
AND a.[parent_snz_uid] = m.[parent_snz_uid]
AND a.[month_after_birth] = m.[month_after_birth]

LEFT JOIN #emp_clean_spells n 
ON a.[snz_uid] = n.[snz_uid]
AND a.[parent_snz_uid] = n.[parent_snz_uid]
AND a.[month_after_birth] = n.[month_after_birth];


/****************************************************************************************************************************************
WRITING FINAL DATAFRAME INTO SANDPIT 
****************************************************************************************************************************************/
IF (SELECT write_db FROM #fixed) = 1 
BEGIN
	DECLARE @temp_name VARCHAR(MAX);
	SELECT @temp_name = table_name FROM #fixed;

	EXEC('IF OBJECT_ID('''+@temp_name+''') IS NOT NULL DROP TABLE'+@temp_name+'')
	EXEC('
	SELECT * 
	INTO'+@temp_name+' 
	FROM #ginfe_pop
	')

	-- Adding compression and indexing 
	EXEC('ALTER TABLE '+@temp_name+' REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)')
	EXEC('CREATE CLUSTERED INDEX GNIFE_child_parent ON '+@temp_name+' ([snz_uid], [parent_snz_uid], [month_after_birth])')

END; 
