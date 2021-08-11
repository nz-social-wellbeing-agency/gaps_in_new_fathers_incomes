
-- SET UP FIXED VARIABLES FOR ALL PARTS 
USE [IDI_Clean_20201020];


/***********************************************************************************************************************************************************************
******************************************** PART 1: RELATIONSHIPS - PARENT, CHILD, SIBLINGS AND CAREGIVERS   **********************************************************
************************************************************************************************************************************************************************

PART 2: RELATIONSHIPS - PARENT, CHILD, SIBLINGS AND CAREGIVERS 
CODER: Raj.Kulkarni@swa.govt.nz
QA PERSON: Simon
QA DATE: 2021-08-02

Details: Aim of this part is to record all relationships around a child - birth parents, step-parents, siblings (from same parents and different parents), caregivers 
		 on record. All 'events' of relationships will have start and end dates so this can be filterd for our time of interest. 

Filters and Logic: 
**********************************************************************************************************************************************************************/

/***************************************************** PART 1A: RELATIONSHIPS - DIA BIRTH RECORDS *******************************************************************/

IF OBJECT_ID('tempdb..#part_1') IS NOT NULL DROP TABLE #part_1;

WITH births AS(
SELECT DISTINCT a.[snz_uid] 
            ,DATEFROMPARTS(b.[snz_birth_year_nbr], b.[snz_birth_month_nbr], 15) AS 'child_dob_snz'  
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'child_dob_dia' 
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'start_date'
			,DATEFROMPARTS(2099, 12, 31) as 'end_date' 
			,[parent1_snz_uid] AS 'dia_mother'
			,[parent2_snz_uid] AS 'dia_father'
			,'DIA' as source
FROM [dia_clean].[births] a
INNER JOIN [data].[personal_detail] b
ON a.[snz_uid] = b.[snz_uid]
INNER JOIN [data].[personal_detail] c
ON a.[parent1_snz_uid] = c.[snz_uid]
INNER JOIN [data].[personal_detail] d
ON a.[parent2_snz_uid] = d.[snz_uid]
WHERE ([parent1_snz_uid] IS NOT NULL OR [parent2_snz_uid] IS NOT NULL) 
AND a.[dia_bir_parent1_sex_snz_code] = 2 -- when parent 1 is mother
AND a.[dia_bir_parent2_sex_snz_code] = 1 -- when parent 2 is father
AND a.dia_bir_still_birth_code IS NULL -- Remove still births 
AND b.snz_spine_ind = 1  /* child on spine  */
AND c.snz_spine_ind = 1  /* mother on spine  */
AND d.snz_spine_ind = 1  /* father on spine  */

UNION

SELECT DISTINCT a.[snz_uid] 
            ,DATEFROMPARTS(b.[snz_birth_year_nbr], b.[snz_birth_month_nbr], 15) AS 'child_dob_snz'  
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'child_dob_dia' 
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'start_date'
			,DATEFROMPARTS(2099, 12, 31) as 'end_date' 
			,[parent2_snz_uid] AS 'dia_mother'
			,[parent1_snz_uid] AS 'dia_father'
			,'DIA' as source
FROM [dia_clean].[births] a
INNER JOIN [data].[personal_detail] b
ON a.snz_uid = b.snz_uid
INNER JOIN [data].[personal_detail] c
ON a.[parent1_snz_uid] = c.[snz_uid]
INNER JOIN [data].[personal_detail] d
ON a.[parent2_snz_uid] = d.[snz_uid]
WHERE ([parent1_snz_uid] IS NOT NULL OR [parent2_snz_uid] IS NOT NULL) 
AND a.[dia_bir_parent2_sex_snz_code] = 2 -- when parent 2 is mother 
AND a.[dia_bir_parent1_sex_snz_code] = 1 -- and parent 1 is father 
AND a.dia_bir_still_birth_code IS NULL -- Remove still births 
AND b.snz_spine_ind = 1  /* child on spine  */
AND c.snz_spine_ind = 1  /* mother on spine  */
AND d.snz_spine_ind = 1  /* father on spine  */

UNION 
-- Same sex parents 
SELECT DISTINCT a.[snz_uid] 
            ,DATEFROMPARTS(b.[snz_birth_year_nbr], b.[snz_birth_month_nbr], 15) AS 'child_dob_snz'  
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'child_dob_dia' 
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'start_date'
			,DATEFROMPARTS(2099, 12, 31)	AS 'end_date' 
			,NULL							AS 'dia_mother'
			,[parent1_snz_uid]				AS 'dia_father'
			,'DIA'							AS [source]
FROM [dia_clean].[births] a
INNER JOIN [data].[personal_detail] b
ON a.snz_uid = b.snz_uid
INNER JOIN [data].[personal_detail] c
ON a.[parent1_snz_uid] = c.[snz_uid]
INNER JOIN [data].[personal_detail] d
ON a.[parent2_snz_uid] = d.[snz_uid]
WHERE ([parent1_snz_uid] IS NOT NULL OR [parent2_snz_uid] IS NOT NULL) 
AND a.[dia_bir_parent2_sex_snz_code] = 1 -- when parent 2 is male 
AND a.[dia_bir_parent1_sex_snz_code] = 1 -- and parent 1 is male 
AND a.dia_bir_still_birth_code IS NULL -- Remove still births 
AND b.snz_spine_ind = 1  /* child on spine  */
AND c.snz_spine_ind = 1  /* mother on spine  */


UNION 
-- Same sex parents 
SELECT DISTINCT a.[snz_uid] 
            ,DATEFROMPARTS(b.[snz_birth_year_nbr], b.[snz_birth_month_nbr], 15) AS 'child_dob_snz'  
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'child_dob_dia' 
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'start_date'
			,DATEFROMPARTS(2099, 12, 31) as 'end_date' 
			,NULL AS 'dia_mother'
			,[parent2_snz_uid] AS 'dia_father'
			,'DIA' as source
FROM [dia_clean].[births] a
INNER JOIN [data].[personal_detail] b
ON a.snz_uid = b.snz_uid
INNER JOIN [data].[personal_detail] c
ON a.[parent2_snz_uid] = c.[snz_uid]
WHERE ([parent1_snz_uid] IS NOT NULL OR [parent2_snz_uid] IS NOT NULL) 
AND a.[dia_bir_parent2_sex_snz_code] = 1 -- when parent 2 is male 
AND a.[dia_bir_parent1_sex_snz_code] = 1 -- and parent 1 is male 
AND a.dia_bir_still_birth_code IS NULL -- Remove still births 
AND b.snz_spine_ind = 1  /* child on spine  */
AND c.snz_spine_ind = 1  /* father on spine  */

UNION 
-- Same sex parents 
SELECT DISTINCT a.[snz_uid] 
            ,DATEFROMPARTS(b.[snz_birth_year_nbr], b.[snz_birth_month_nbr], 15) AS 'child_dob_snz'  
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'child_dob_dia' 
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'start_date'
			,DATEFROMPARTS(2099, 12, 31) as 'end_date' 
			,[parent2_snz_uid] AS 'dia_mother'
			,NULL AS 'dia_father'
			,'DIA' as source
FROM [dia_clean].[births] a
INNER JOIN [data].[personal_detail] b
ON a.snz_uid = b.snz_uid
INNER JOIN [data].[personal_detail] c
ON a.[parent1_snz_uid] = c.[snz_uid]
INNER JOIN [data].[personal_detail] d
ON a.[parent2_snz_uid] = d.[snz_uid]
WHERE ([parent1_snz_uid] IS NOT NULL OR [parent2_snz_uid] IS NOT NULL) 
AND a.[dia_bir_parent2_sex_snz_code] = 2 -- when parent 2 is mother 
AND a.[dia_bir_parent1_sex_snz_code] = 2 -- and parent 1 is mother 
AND a.dia_bir_still_birth_code IS NULL -- Remove still births 
AND b.snz_spine_ind = 1  /* child on spine  */
AND c.snz_spine_ind = 1  /* mother on spine  */
AND d.snz_spine_ind = 1  /* father on spine  */

UNION 
-- Same sex parents 
SELECT DISTINCT a.[snz_uid] 
            ,DATEFROMPARTS(b.[snz_birth_year_nbr], b.[snz_birth_month_nbr], 15) AS 'child_dob_snz'  
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'child_dob_dia' 
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'start_date'
			,DATEFROMPARTS(2099, 12, 31) as 'end_date' 
			,[parent1_snz_uid] AS 'dia_mother'
			,NULL AS 'dia_father'
			,'DIA' AS source
FROM [dia_clean].[births] a
INNER JOIN [data].[personal_detail] b
ON a.snz_uid = b.snz_uid
INNER JOIN [data].[personal_detail] c
ON a.[parent1_snz_uid] = c.[snz_uid]
INNER JOIN [data].[personal_detail] d
ON a.[parent2_snz_uid] = d.[snz_uid]
WHERE ([parent1_snz_uid] IS NOT NULL OR [parent2_snz_uid] IS NOT NULL) 
AND a.[dia_bir_parent2_sex_snz_code] = 2 -- when parent 2 is mother 
AND a.[dia_bir_parent1_sex_snz_code] = 2 -- and parent 1 is mother 
AND a.dia_bir_still_birth_code IS NULL -- Remove still births 
AND b.snz_spine_ind = 1  /* child on spine  */
AND c.snz_spine_ind = 1  /* mother on spine  */
AND d.snz_spine_ind = 1  /* father on spine  */

UNION 
-- Single Mother 
SELECT DISTINCT a.[snz_uid] 
            ,DATEFROMPARTS(b.[snz_birth_year_nbr], b.[snz_birth_month_nbr], 15) AS 'child_dob_snz'  
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'child_dob_dia' 
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'start_date'
			,DATEFROMPARTS(2099, 12, 31) as 'end_date' 
			,[parent1_snz_uid] AS 'dia_mother'
			,NULL AS 'dia_father'
			,'DIA' AS source
FROM [dia_clean].[births] a
INNER JOIN [data].[personal_detail] b
ON a.[snz_uid] = b.[snz_uid]
INNER JOIN [data].[personal_detail] c
ON a.[parent1_snz_uid] = c.[snz_uid]
WHERE [parent1_snz_uid] IS NOT NULL 
AND [parent2_snz_uid] IS NULL 
AND a.[dia_bir_parent1_sex_snz_code] = 2 -- and parent 1 is mother 
AND a.dia_bir_still_birth_code IS NULL -- Remove still births 
AND b.snz_spine_ind = 1  /* child on spine  */
AND c.snz_spine_ind = 1  /* parent on spine  */

UNION 
-- Single Father 
SELECT DISTINCT a.[snz_uid] 
            ,DATEFROMPARTS(b.[snz_birth_year_nbr], b.[snz_birth_month_nbr], 15) AS 'child_dob_snz'  
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'child_dob_dia' 
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'start_date'
			,DATEFROMPARTS(2099, 12, 31) as 'end_date' 
			,[parent1_snz_uid] AS 'dia_father'
			,NULL AS 'dia_mother'
			,'DIA' AS [source]
FROM [dia_clean].[births] a
INNER JOIN [data].[personal_detail] b
ON a.[snz_uid] = b.[snz_uid]
INNER JOIN [data].[personal_detail] c
ON a.[parent1_snz_uid] = c.[snz_uid]
WHERE [parent1_snz_uid] IS NOT NULL 
AND [parent2_snz_uid] IS NULL 
AND a.[dia_bir_parent1_sex_snz_code] = 1 -- and parent 1 is mother 
AND a.dia_bir_still_birth_code IS NULL -- Remove still births 
AND b.snz_spine_ind = 1  /* child on spine  */
AND c.snz_spine_ind = 1  /* parent on spine  */


)
-- Converting to long form 
SELECT [snz_uid] 
        ,[child_dob_snz]  
		,[start_date]
		,[end_date] 
		,[dia_mother] AS 'parent_snz_uid'
		,'DIA_mother' AS 'relationship'
		,'DIA' as source
		,1 AS source_rank
INTO #part_1
FROM births
UNION
SELECT [snz_uid] 
        ,[child_dob_snz]  
		,[start_date]
		,[end_date] 
		,[dia_father] AS 'parent_snz_uid'
		,'DIA_father' AS 'relationship'
		,'DIA' as source
		,1 AS source_rank
FROM births;


/***************************************************** PART 1B: RELATIONSHIPS - MSD CHILD PARENT / CAREGIVER RECORDS **********************************************************/


IF OBJECT_ID('tempdb..#part_2') IS NOT NULL DROP TABLE #part_2;

WITH msd_child AS (
SELECT a.[child_snz_uid] AS 'snz_uid'
		,DATEFROMPARTS(c.[snz_birth_year_nbr], c.[snz_birth_month_nbr], 15) AS 'child_dob_snz'
		,a.[msd_chld_child_from_date] AS 'start_date'
		,ISNULL(MIN(a.[msd_chld_child_to_date]), DATEFROMPARTS(2099, 12, 31)) AS 'end_date' -- if end date is missing: assuming that the relationship is still going on.
		,a.[snz_uid] AS 'parent1_snz_uid'
FROM [msd_clean].[msd_child] a
INNER JOIN [data].[personal_detail] b
ON a.[snz_uid] = b.[snz_uid] -- Parent is on spine
INNER JOIN [data].[personal_detail] c
ON a.[child_snz_uid] = c.[snz_uid] -- Child is on spine
WHERE b.[snz_spine_ind] = 1
AND c.[snz_spine_ind] = 1
GROUP BY a.[child_snz_uid], a.[msd_chld_child_from_date], a.[snz_uid], DATEFROMPARTS(c.[snz_birth_year_nbr], c.[snz_birth_month_nbr], 15)
),

-- MSD child with both parents 
msd_parent AS (
SELECT a.[snz_uid] AS 'partner1_snz_uid'
      ,[partner_snz_uid] AS 'partner2_snz_uid'
      ,[msd_ptnr_ptnr_from_date] AS 'start_date'
      ,ISNULL(MIN([msd_ptnr_ptnr_to_date]), DATEFROMPARTS(2099, 12, 31))  AS 'end_date' -- if end date is missing: assuming that the relationship is still going on. 
																						-- If there are multiple records on same date with same partner, select the latest end date 
FROM [msd_clean].[msd_partner] a
INNER JOIN [data].[personal_detail] b
ON a.[snz_uid] = b.[snz_uid] -- To check if main parent is on spine
INNER JOIN [data].[personal_detail] c
ON a.[partner_snz_uid] = c.[snz_uid] -- To check if parent partner is on spine
WHERE b.[snz_spine_ind] = 1
AND c.[snz_spine_ind] = 1
GROUP BY a.[snz_uid], [partner_snz_uid], [msd_ptnr_ptnr_from_date]
),

-- Only keeping records that overlap with childs benefit records (3 months before the birth and 1 year after the birth of child)
msd_reln_1 AS (
SELECT DISTINCT ch.snz_uid
				,ch.[child_dob_snz]
				,ch.start_date
				,ch.end_date
				,ch.parent1_snz_uid
				,pr.partner2_snz_uid
				,pr.start_date AS 'pr_start_date'
				,pr.end_date AS 'pr_end_date'
FROM msd_child ch
INNER JOIN msd_parent pr
ON ch.parent1_snz_uid = pr.[partner1_snz_uid] 
AND ch.snz_uid <> pr.[partner1_snz_uid]  -- parent is not child 
AND ch.snz_uid <> pr.[partner2_snz_uid]  -- parent is not child 
AND ch.start_date >= ch.[child_dob_snz]
AND ch.start_date <= DATEADD(DAY, 365, ch.[child_dob_snz])
AND ch.end_date >= ch.[child_dob_snz]
AND pr.start_date <= ch.end_date
AND pr.end_date >= ch.start_date
AND pr.start_date <= DATEADD(DAY, 365, ch.[child_dob_snz])
AND pr.end_date >= DATEADD(DAY, -365, ch.[child_dob_snz])
WHERE pr.start_date <= DATEADD(DAY, 365, ch.[child_dob_snz]) -- arbitary 1 year 
AND pr.end_date >= DATEADD(DAY, -365, ch.[child_dob_snz]) -- arbitary 1 year 
),

-- The logic below is not perfect but works for majority of records. 
--If a child has same set of caregivers multile times with a different caregiver between the same set of caregivers this logic will fail. 
msd_reln_2 AS (
SELECT DISTINCT snz_uid
				,[child_dob_snz]
				,MIN(start_date) AS 'start_date'
				,MAX(end_date) AS 'end_date'
				,parent1_snz_uid
				,partner2_snz_uid
				,MIN(pr_start_date) AS 'pr_start_date'
				,MAX(pr_end_date) AS 'pr_end_date'
FROM msd_reln_1
GROUP BY snz_uid
		,[child_dob_snz]
		,parent1_snz_uid
		,partner2_snz_uid
),

-- Replacing parent start and end dates that fit the time frame window 
msd_reln_3 AS (
SELECT DISTINCT snz_uid
		,[child_dob_snz]
		,parent1_snz_uid
		,partner2_snz_uid
		,IIF(pr_start_date < start_date, start_date, pr_start_date) AS 'start_date'
		,IIF(pr_end_date < end_date, pr_end_date, end_date) AS 'end_date'
FROM msd_reln_2
)
-- Converting to long form to match the formats
SELECT DISTINCT [snz_uid] 
        ,[child_dob_snz]  
		,[start_date]
		,[end_date] 
		,[parent1_snz_uid] AS 'parent_snz_uid'
		,'MSD_Parent_caregiver' AS 'relationship'
		,'MSD' as source
		,4 AS source_rank
INTO #part_2
FROM msd_reln_3
WHERE DATEDIFF(DAY, [child_dob_snz], start_date) + 1 < 366
AND DATEDIFF(DAY, [child_dob_snz], ISNULL(end_date, DATEFROMPARTS(2099, 12, 31))) + 1 > -91
UNION 
SELECT [snz_uid] 
        ,[child_dob_snz]   
		,[start_date]
		,[end_date] 
		,[partner2_snz_uid] AS 'parent_snz_uid'
		,'MSD_Parent_caregiver' AS 'relationship'
		,'MSD' as source
		,4 AS source_rank
FROM msd_reln_3
WHERE DATEDIFF(DAY, [child_dob_snz], start_date) + 1 < 366
AND DATEDIFF(DAY, [child_dob_snz], ISNULL(end_date, DATEFROMPARTS(2099, 12, 31))) + 1 > -91;


/******************************************************* PART 1C: RELATIONSHIPS - MBIE VISA RECORDS *******************************************************/

IF OBJECT_ID('tempdb..#part_3') IS NOT NULL DROP TABLE #part_3;
WITH dol_1 AS (
SELECT a.[snz_uid]
      ,[snz_application_uid]
	  ,DATEFROMPARTS([snz_birth_year_nbr], [snz_birth_month_nbr], 15) AS 'child_dob_snz'
      ,[dol_dec_decision_date] AS 'start_date'
	  ,[dol_dec_decision_date] AS 'end_date'
	  ,DATEDIFF(DAY, 
				DATEFROMPARTS([dol_dec_birth_year_nbr], [dol_dec_birth_month_nbr], 15),
				[dol_dec_decision_date]
				) / 365.25 AS 'age_at_approval'
      ,CASE WHEN 
			   (DATEDIFF(DAY, 
						DATEFROMPARTS([dol_dec_birth_year_nbr], [dol_dec_birth_month_nbr], 15),
						[dol_dec_decision_date]
						) / 365.5 -- to get the age at approval (to check who were adults and who were children)
				) >= 18 
				THEN 1
				ELSE 0 
		END AS 'Adult'
	   ,CASE WHEN 
				 (DATEDIFF(DAY, 
						DATEFROMPARTS([dol_dec_birth_year_nbr], [dol_dec_birth_month_nbr], 15),
						[dol_dec_decision_date]
						) / 365.5 -- to get the age at approval (to check who were adults and who were children)
				) < 18 
				THEN 1
				ELSE 0 
		END AS 'Child'
FROM [dol_clean].[decisions] a
LEFT JOIN [data].[personal_detail] b
ON a.[snz_uid] = b.[snz_uid]
WHERE [dol_dec_nbr_applicants_nbr] > 1 -- to find dependancies 
AND [dol_dec_decision_type_code] = 'A' -- their appilcation was approved (Following Michelle's logic)
AND [dol_dec_reporting_cat_code] = 'R' -- Only considering residency applications
AND [snz_spine_ind] = 1 -- person is on spine
),

-- Since the relationship in DOL is not direct, we will assume that if there are multiple applicants on application, with at least one child and the age difference between child and adult is atleast 14 years then its likely
-- the parent / caregiver. We only consider the visa applications for residency for this -> for assurance on the relationship. 
dol_2 AS (
SELECT a.[snz_uid]
		,a.[snz_application_uid]
		,a.[child_dob_snz]
		,a.[start_date]
		,a.[end_date]
		,a.[age_at_approval]
		,a.[Adult] 
		,a.[Child]
FROM dol_1 a 
INNER JOIN (SELECT snz_application_uid 
			FROM dol_1
			GROUP BY snz_application_uid
			HAVING SUM(Adult) >= 1 -- at least one adult
			AND SUM(Adult) <= 2 -- at max two adults
			AND SUM(Child) > 0 -- at least one dependant child
			AND (MAX(age_at_approval * Adult) - MAX(age_at_approval * Child)) >= 14 -- there was at least 14 years of gap between oldest parent and child (no other way to get information on parents)
			) b
ON a.snz_application_uid = b.snz_application_uid
),


dol_3 AS (
SELECT DISTINCT a.snz_uid
		,a.[child_dob_snz]
		,a.[start_date]
		,a.[end_date] 
		,b.[snz_uid] AS 'parent_snz_uid'
		,'DOL_Parent_caregiver' AS 'relationship'
		,'DOL' as source
		,3 AS source_rank
FROM (SELECT * 
		FROM dol_2
		WHERE Child = 1 -- i.e. only selecting children
		AND DATEDIFF(DAY, [child_dob_snz], start_date) + 1 < 366 -- only selecting new borns / children who were at max 1 year old (as per the project timeframe)
		AND DATEDIFF(DAY, [child_dob_snz], ISNULL(end_date, DATEFROMPARTS(2099, 12, 31))) + 1 > -91 -- only selecting new borns when the application was made at max 3 months before birth of child (as per project time frame)
	  ) a
INNER JOIN (SELECT *
			FROM dol_2
			WHERE Adult = 1
			) b
ON a.snz_application_uid = b.snz_application_uid
)
-- Not perfect results but provides good information on immigrant population 
SELECT DISTINCT snz_uid
		,[child_dob_snz]
		,MIN(start_date) AS 'start_date'
		,MAX(end_date) AS 'end_date'
		,parent_snz_uid 
		,relationship
		,source
		,source_rank
INTO #part_3
FROM dol_3
GROUP BY snz_uid
		,[child_dob_snz]
		,parent_snz_uid 
		,relationship
		,source
		,source_rank;


/******************************************************* PART 1D: RELATIONSHIPS - CENSUS 2013 *******************************************************/

-- Parent-child relationship information from Census 2013 
IF OBJECT_ID('tempdb..#part_4') IS NOT NULL DROP TABLE #part_4;
WITH cen AS (
SELECT a.[snz_uid]
		,DATEFROMPARTS(b.[snz_birth_year_nbr], b.[snz_birth_month_nbr], 15) AS 'child_dob_snz'
		,a.[snz_cen_fam_uid] 
		,a.[cen_ind_recode_fam_role_code]
		,a.[cen_ind_fam_role_code]
		,c.[descriptor_text] AS 'relationship' -- simpler relationships than recode 
FROM [cen_clean].[census_individual_2013] a
INNER JOIN [data].[personal_detail] b
ON a.snz_uid = b.snz_uid 
LEFT JOIN [IDI_metadata].[clean_read_CLASSIFICATIONS].[cen_famc02] c 
ON a.[cen_ind_fam_role_code] = c.[cat_code] 
WHERE b.[snz_spine_ind] = 1
AND a.[cen_ind_fam_grp_code] NOT IN ('00','50') -- guest or visitor or unable to code 
AND a.[cen_ind_fam_role_code] NOT IN ('00','50') -- not in family nucleus or not able to code  
AND a.[snz_cen_fam_uid] IS NOT NULL 
AND a.[cen_ind_recode_fam_role_code] NOT IN ('31') -- not in a couple only family structure
),
-- Filtering parents 
cen_par AS (
SELECT [snz_uid] AS 'parent_snz_uid'
		,[snz_cen_fam_uid]
		,[relationship] 
FROM cen
WHERE [cen_ind_recode_fam_role_code] IN ('11', '12', '21', '22') -- code for parents / caregivers
),
-- Filtering children
cen_child AS (
SELECT [snz_uid]
		,[snz_cen_fam_uid]
		,[child_dob_snz]
		,'Child' AS 'relationship' 
FROM cen
WHERE [cen_ind_recode_fam_role_code] IN ('41', '42')
)
SELECT a.[snz_uid]
		,a.[child_dob_snz]
		,DATEFROMPARTS(2013, 03, 05) AS 'start_date' -- census night
		,DATEFROMPARTS(2013, 03, 05) AS 'end_date' -- census night
		,b.[parent_snz_uid]
		,b.[relationship] 
		,'CEN' AS [source]
		,2 AS source_rank
INTO #part_4
FROM cen_child a 
INNER JOIN cen_par b
ON a.snz_cen_fam_uid = b.snz_cen_fam_uid


/******************************************************* PART 1E: RELATIONSHIPS - CENSUS 2018 *******************************************************/
------------------------------------------------------------------- PLACEHOLDER -------------------------------------------------------------------


/***************************************************** PART 1F: RELATIONSHIPS - MARRIAGE RECORDS *****************************************************
******************************************************** PART 2F.1: CIVIL UNIONS AND MARRIAGES  *****************************************************

CODER: Raj.Kulkarni@swa.govt.nz
QA PERSON: Simon
QA DATE: 2021-08-02

DETAILS: Aim of this part is to clean marriage records and civil unions. For the project, we will consider civil unions and marriages as equivalent 
		 and both will be refered as "marriage(s)" in the code and sections below. But if there's a need to identify marriages from civil unions, 
		 the civil union regestration IDs have been modified (all IDs will start with 9121 and will be 8 digits long, unlike other marriage 
		 regestration IDs which are only 7 digit long. 
		 The script will clean the marriage records so that each person only has one marriage record at a time. 

HIGH LEVEL LOGIC: 

a. Check if the people with NULL marriage dates have a next marriage, if they do then we will check if their next marriage 
has a previous resolve date - and if there is a previous resolve date then replace the key records marriage resolve date with next marriage records 
previous resolve date. 

b. If the next marriage records previous resolve date is also NULL, then check the partners next marriage record for previous resolve date and impute that 
if available. 

c. If partners next marriage record is also NULL, replace the marriage end date with => (Next marriage date - 1)

d. If there are multiple marriages on same day, only keep the record that is most complete. 

e. If the next marriage record is before end date for previous marriage record, then change / set the end date of current marriage record to => (Next marriage date - 1) 

***********************************************************************************************************************************************************************/
-- Final table will be saved in temp db -> marriages 
IF OBJECT_ID('tempdb..#marriages') IS NOT NULL DROP TABLE #marriages;

-- Reordering civil union and adding reg identifier for civil unions 
WITH cu AS (
SELECT [partnr1_snz_uid] AS 'snz_uid'
      ,91210000 + [snz_dia_civil_union_reg_uid] AS 'snz_dia_marriage_reg_uid'  
	  ,ISNULL([dia_civ_civil_union_date], [dia_civ_civil_union_reg_date]) AS 'dia_mar_marriage_date'
	  ,[dia_civ_partnr1_prev_disolv_date] AS 'prev_disolv_date'
      ,[dia_civ_disolv_order_date] AS 'dia_mar_disolv_order_date'
FROM [dia_clean].[civil_unions]
UNION 
SELECT [partnr2_snz_uid] AS 'snz_uid'
      ,91210000 + [snz_dia_civil_union_reg_uid] AS 'snz_dia_marriage_reg_uid'  
	  ,ISNULL([dia_civ_civil_union_date], [dia_civ_civil_union_reg_date]) AS 'dia_mar_marriage_date'
	  ,[dia_civ_partnr2_prev_disolv_date] AS 'prev_disolv_date'
      ,[dia_civ_disolv_order_date] AS 'dia_mar_disolv_order_date'
FROM [dia_clean].[civil_unions]
), 

-- Reordering marriages and adding civil unions to marriage records
mar1 AS (
SELECT DISTINCT partnr1_snz_uid AS 'snz_uid'
	   ,[snz_dia_marriage_reg_uid]
	   ,[dia_mar_marriage_date]
	   ,[dia_mar_partnr1_prev_disolv_date] AS 'prev_disolv_date'
	   ,[dia_mar_disolv_order_date]
FROM [dia_clean].[marriages]
UNION
SELECT partnr2_snz_uid AS 'snz_uid'
	   ,[snz_dia_marriage_reg_uid]
	   ,[dia_mar_marriage_date]
	   ,[dia_mar_partnr2_prev_disolv_date] AS 'prev_disolv_date'
	   ,[dia_mar_disolv_order_date]
FROM [dia_clean].[marriages]
UNION -- civil unions from previous part
SELECT [snz_uid]
	   ,[snz_dia_marriage_reg_uid]
	   ,[dia_mar_marriage_date]
	   ,[prev_disolv_date]
	   ,[dia_mar_disolv_order_date]
FROM cu
),

-- adding row number over marriages to check next marriage record 
mar_rn AS (
SELECT [snz_uid]
	   ,[snz_dia_marriage_reg_uid]
	   ,[dia_mar_marriage_date]
	   ,[prev_disolv_date]
	   ,[dia_mar_disolv_order_date]
	   ,ROW_NUMBER() OVER (PARTITION BY [snz_uid] ORDER BY [dia_mar_marriage_date]) AS rn
FROM mar1
),

-- saving partners' current marriage records previous marriage disolve date. 
ptnr_prv_disolv AS (
SELECT k.partnr1_snz_uid AS 'snz_uid'
		,k.[snz_dia_marriage_reg_uid]
		,k.dia_mar_marriage_date
		,k.dia_mar_disolv_order_date
		,l.prev_disolv_date AS 'ptr_prev_disolv_date' 
FROM  mar_rn l 
LEFT JOIN [dia_clean].[marriages] k
ON l.snz_uid  = k.partnr2_snz_uid 
AND l.[snz_dia_marriage_reg_uid] = k.[snz_dia_marriage_reg_uid]
UNION 
SELECT k.partnr2_snz_uid AS 'snz_uid'
		,k.[snz_dia_marriage_reg_uid]
		,k.dia_mar_marriage_date
		,k.dia_mar_disolv_order_date
		,l.prev_disolv_date AS 'ptr_prev_disolv_date'
FROM  mar_rn l 
LEFT JOIN [dia_clean].[marriages] k
ON l.snz_uid  = k.partnr1_snz_uid 
AND l.[snz_dia_marriage_reg_uid] = k.[snz_dia_marriage_reg_uid]
),

-- merging partners' current marriage with the next marriage and only keeping next records previous marriage date
--- Step 1: Adding row number
ptnr_prv_disolv_rn AS(
SELECT DISTINCT snz_uid
		,[snz_dia_marriage_reg_uid]
		,dia_mar_marriage_date
		,dia_mar_disolv_order_date
		,ptr_prev_disolv_date
		,ROW_NUMBER() OVER (PARTITION BY [snz_uid] ORDER BY [dia_mar_marriage_date]) AS rn
FROM ptnr_prv_disolv  
),

--- Step 2: merging next record with current record 
prnt_prv_disolv_next_mar AS (
SELECT DISTINCT a.snz_uid
		,a.[snz_dia_marriage_reg_uid]
		,a.dia_mar_marriage_date
		,a.dia_mar_disolv_order_date
		,b.ptr_prev_disolv_date -- partners next marriages previous dissolve date record
FROM ptnr_prv_disolv_rn a
LEFT JOIN ptnr_prv_disolv_rn b
ON a.snz_uid = b.snz_uid 
AND a.rn + 1 = b.rn -- since the first marriage record will have null as previous - this will keep the first record of previous disolve date as null and gather relevant previous record date
),

-- Imputing all the inputs from the tables above into temp table
marr_impute AS (
SELECT DISTINCT a.snz_uid
		,a.snz_dia_marriage_reg_uid
		,a.dia_mar_marriage_date
		,IIF(a.[dia_mar_disolv_order_date] IS NULL OR DATEDIFF(DAY, a.[dia_mar_disolv_order_date], b.dia_mar_marriage_date) < 0, 
			ISNULL(b.prev_disolv_date, c.ptr_prev_disolv_date), 
			a.[dia_mar_disolv_order_date]) AS dia_mar_disolv_order_date
FROM mar_rn a
LEFT JOIN mar_rn b 
ON a.snz_uid = b.snz_uid 
AND a.rn + 1 = b.rn -- joining the next marriage to get previous marriage records 
LEFT JOIN prnt_prv_disolv_next_mar c -- joining partners previous marriage end date in case the partners marriage resolve date is missing
ON a.snz_uid = c.snz_uid 
AND a.snz_dia_marriage_reg_uid = c.snz_dia_marriage_reg_uid
),

-- adding row numbers to check if someone has multiple marriages on same day
marr_impute_1a AS(
SELECT snz_uid
		,snz_dia_marriage_reg_uid
		,dia_mar_marriage_date
		,dia_mar_disolv_order_date
		,ROW_NUMBER() OVER (PARTITION BY [snz_uid], [dia_mar_marriage_date] ORDER BY dia_mar_disolv_order_date DESC) AS rn
FROM marr_impute a
),

/*
checking if there are multiple active marriages (when someone is marriaged to same person but have multiple records)
if there are 2 marriage records on same day, only keep the most complete record / record which has a end date
NOTE: If someone has 3 marriages on same day with no end date - this logic might have to be changed. But as of Sept refresh, 2020 - that is not the case so keeping things as they are.
*/

marr_impute_1b AS(
SELECT a.snz_uid
		,a.snz_dia_marriage_reg_uid
		,a.dia_mar_marriage_date
		,ISNULL(a.dia_mar_disolv_order_date, b.dia_mar_disolv_order_date) AS 'dia_mar_disolv_order_date'
		,a.rn -- using the row number of first record so that the imputated values will appear on the first record. 
FROM marr_impute_1a a
LEFT JOIN marr_impute_1a b
ON a.snz_uid = b.snz_uid AND
a.rn = b.rn + 1
),

-- selecing the first rows as per logic mentioned above
marr_impute_1c AS (
SELECT snz_uid
		,snz_dia_marriage_reg_uid
		,dia_mar_marriage_date
		,dia_mar_disolv_order_date
FROM marr_impute_1b a 
WHERE rn = 1 
),

/*
If even after all the cleaning, there are some records with multiple active marriages, imputing the end date of first record as one day before start of next one.
Or if due to multiple marriages on same day, if the marriage end date is before start of marriage (rare case but some records have that) -> imputing the marriage 
end date to one day before start of next one.
*/
--- Step 1: Adding row number 
mar_rn_2 AS (
SELECT snz_uid
		,snz_dia_marriage_reg_uid
		,dia_mar_marriage_date
		,dia_mar_disolv_order_date
		,ROW_NUMBER() OVER (PARTITION BY [snz_uid] ORDER BY [dia_mar_marriage_date]) AS rn
FROM marr_impute_1c 
),

--- Step 2: Joining subsequent records to get the next marriage date. 
marr_impute_2 AS (
SELECT DISTINCT a.snz_uid
		,a.snz_dia_marriage_reg_uid
		,a.dia_mar_marriage_date
		,IIF(DATEDIFF(DAY, a.dia_mar_disolv_order_date, b.dia_mar_marriage_date)<0 
						OR a.dia_mar_disolv_order_date IS NULL,
			DATEADD(DAY, -1, b.dia_mar_marriage_date),  
			a.dia_mar_disolv_order_date) AS 'dia_mar_disolv_order_date'
FROM mar_rn_2 a
LEFT JOIN mar_rn_2 b 
ON a.snz_uid = b.snz_uid 
AND a.rn+1 = b.rn 
), 

/*
Removing duplicate records for people who got married on same day to same partners but have different different regestration ID and
mutating the end date from null if it exists
*/
--- Step 1: Adding row numbers over arbitary mar_reg_uid 
marr_dedup AS (
SELECT snz_uid
		,snz_dia_marriage_reg_uid
		,dia_mar_marriage_date
		,dia_mar_disolv_order_date
		,ROW_NUMBER() OVER (PARTITION BY snz_uid,dia_mar_marriage_date ORDER BY snz_dia_marriage_reg_uid) AS rn
FROM marr_impute_2
),

--- Step 2: merging the two rows and imputing non-null end dates (if they exist)
marr_impute_3 AS (
SELECT DISTINCT a.snz_uid
		,a.snz_dia_marriage_reg_uid
		,a.dia_mar_marriage_date
		,IIF(a.dia_mar_disolv_order_date IS NULL, b.dia_mar_disolv_order_date, a.dia_mar_disolv_order_date) AS 'dia_mar_disolv_order_date'
		,a.rn
FROM marr_dedup a
LEFT JOIN marr_dedup b
ON a.snz_uid = b.snz_uid 
AND a.rn = b.rn + 1 
)

/*
FINAL TABLE: all the script below will produce final table with one marriage at a time, no duplicate records, no overlaps between marriages, and 
filled out start and end date for each marriage record. 
Marriage regestration ID can be used to get other information about the marriage (e.g. address, parent information, etc.) if required. 
*/
SELECT snz_uid
		,snz_dia_marriage_reg_uid
		,dia_mar_marriage_date
		,dia_mar_disolv_order_date
INTO #marriages
FROM marr_impute_3 a
WHERE rn = 1;

/************************************************************************** END OF PART 1F.1 ******************************************************************************/
IF OBJECT_ID('tempdb..#part_5') IS NOT NULL DROP TABLE #part_5;

-- Birth records so we can only keep couples who had kids. 
WITH births AS(
SELECT DISTINCT a.[snz_uid] 
            ,DATEFROMPARTS(b.[snz_birth_year_nbr], b.[snz_birth_month_nbr], 15) AS 'child_dob_snz'  
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'child_dob_dia' 
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'start_date'
			,DATEFROMPARTS(2099, 12, 31) as 'end_date' 
			,[parent1_snz_uid] AS 'dia_mother'
			,[parent2_snz_uid] AS 'dia_father'
			,'DIA' as source
FROM [dia_clean].[births] a
INNER JOIN [data].[personal_detail] b
ON a.[snz_uid] = b.[snz_uid]
INNER JOIN [data].[personal_detail] c
ON a.[parent1_snz_uid] = c.[snz_uid]
INNER JOIN [data].[personal_detail] d
ON a.[parent2_snz_uid] = d.[snz_uid]
WHERE ([parent1_snz_uid] IS NOT NULL OR [parent2_snz_uid] IS NOT NULL) 
AND a.[dia_bir_parent1_sex_snz_code] = 2 -- when parent 1 is mother
AND a.[dia_bir_parent2_sex_snz_code] = 1 -- when parent 2 is father
AND a.dia_bir_still_birth_code IS NULL -- Remove still births 
AND b.snz_spine_ind = 1  /* child on spine  */
AND c.snz_spine_ind = 1  /* mother on spine  */
AND d.snz_spine_ind = 1  /* father on spine  */

UNION 

SELECT DISTINCT a.[snz_uid] 
            ,DATEFROMPARTS(b.[snz_birth_year_nbr], b.[snz_birth_month_nbr], 15) AS 'child_dob_snz'  
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'child_dob_dia' 
			,DATEFROMPARTS(a.[dia_bir_birth_year_nbr], a.[dia_bir_birth_month_nbr], 15) AS 'start_date'
			,DATEFROMPARTS(2099, 12, 31) as 'end_date' 
			,[parent2_snz_uid] AS 'dia_mother'
			,[parent1_snz_uid] AS 'dia_father'
			,'DIA' as source
FROM [dia_clean].[births] a
INNER JOIN [data].[personal_detail] b
ON a.snz_uid = b.snz_uid
INNER JOIN [data].[personal_detail] c
ON a.[parent1_snz_uid] = c.[snz_uid]
INNER JOIN [data].[personal_detail] d
ON a.[parent2_snz_uid] = d.[snz_uid]
WHERE ([parent1_snz_uid] IS NOT NULL OR [parent2_snz_uid] IS NOT NULL) 
AND a.[dia_bir_parent2_sex_snz_code] = 2 -- when parent 2 is mother 
AND a.[dia_bir_parent1_sex_snz_code] = 1 -- and parent 1 is father 
AND a.dia_bir_still_birth_code IS NULL -- Remove still births 
AND b.snz_spine_ind = 1  /* child on spine  */
AND c.snz_spine_ind = 1  /* mother on spine  */
AND d.snz_spine_ind = 1  /* father on spine  */
),

-- Checking DIA Parents other marriages after or on the time of birth
marriage_mod_1 AS (
SELECT DISTINCT a.snz_uid AS 'p1'
		,b.snz_uid AS 'p2'
		,a.snz_dia_marriage_reg_uid AS 'reg_uid'
		,a.dia_mar_marriage_date AS 'start_date'
		,a.dia_mar_disolv_order_date AS 'end_date'
FROM #marriages a
INNER JOIN #marriages b 
ON a.snz_dia_marriage_reg_uid = b.snz_dia_marriage_reg_uid
AND a.snz_uid <> b.snz_uid 
LEFT JOIN [data].[personal_detail] c
ON a.snz_uid = c.snz_uid
WHERE c.snz_sex_gender_code = 1
),

-- Adding row numbers to make panel like structure
marriage_mod_2 AS (
SELECT p1
		,p2
		,reg_uid 
		,start_date
		,end_date
		,ROW_NUMBER() OVER (PARTITION BY [reg_uid] ORDER BY [p1]) AS rn
FROM marriage_mod_1
),

-- partner 1 and 2 in a panel like structure
marriage_fin AS (
SELECT p1
		,p2
		,reg_uid 
		,start_date
		,end_date
FROM marriage_mod_2
WHERE rn = 1
), 

-- Getting other relationship of parents (apart from each other)
parent_oth_mar AS (
SELECT a.snz_uid 
		,a.child_dob_snz
		,a.dia_father
		,a.dia_mother
		,b.start_date
		,b.end_date
		,b.p2 AS 'parent_snz_uid'
		,'DIA_step_mother' AS 'relationship'
FROM births a 
INNER JOIN marriage_fin b 
ON a.dia_father = b.p1
AND a.dia_mother <> b.p2
WHERE DATEDIFF(DAY, a.child_dob_snz, b.start_date) + 1 < 366 -- start date is not 1 year after child was born (arbitary date, can be changed)
AND DATEDIFF(DAY, a.child_dob_snz, ISNULL(b.end_date, DATEFROMPARTS(2099, 12, 31))) + 1 > -91 -- end date is not 3 months before child was born (arbitary date, can be changed)

UNION 

SELECT a.snz_uid 
		,a.child_dob_snz
		,a.dia_father
		,a.dia_mother
		,b.start_date
		,b.end_date
		,b.p1 AS 'parent_snz_uid'
		,'DIA_step_mother' AS 'relationship'
FROM births a 
INNER JOIN marriage_fin b 
ON a.dia_father = b.p2
AND a.dia_mother <> b.p1
WHERE DATEDIFF(DAY, a.child_dob_snz, b.start_date) + 1 < 366 -- start date is not 1 year after child was born (arbitary date, can be changed)
AND DATEDIFF(DAY, a.child_dob_snz, ISNULL(b.end_date, DATEFROMPARTS(2099, 12, 31))) + 1 > -91 -- end date is not 3 months before child was born (arbitary date, can be changed)

UNION 

SELECT a.snz_uid 
		,a.child_dob_snz
		,a.dia_father
		,a.dia_mother
		,b.start_date
		,b.end_date
		,b.p1 AS 'parent_snz_uid'
		,'DIA_step_father' AS 'relationship'
FROM births a 
INNER JOIN marriage_fin b 
ON a.dia_mother = b.p2
AND a.dia_father <> b.p1
WHERE DATEDIFF(DAY, a.child_dob_snz, b.start_date) + 1 < 366 -- start date is not 1 year after child was born (arbitary date, can be changed)
AND DATEDIFF(DAY, a.child_dob_snz, ISNULL(b.end_date, DATEFROMPARTS(2099, 12, 31))) + 1 > -91 -- end date is not 3 months before child was born (arbitary date, can be changed)

UNION 

SELECT a.snz_uid 
		,a.child_dob_snz
		,a.dia_father
		,a.dia_mother
		,b.start_date
		,b.end_date
		,b.p2 AS 'parent_snz_uid'
		,'DIA_step_father' AS 'relationship'
FROM births a 
INNER JOIN marriage_fin b 
ON a.dia_mother = b.p1
AND a.dia_father <> b.p2
WHERE DATEDIFF(DAY, a.child_dob_snz, b.start_date) + 1 < 366 -- start date is not 1 year after child was born (arbitary date, can be changed)
AND DATEDIFF(DAY, a.child_dob_snz, ISNULL(b.end_date, DATEFROMPARTS(2099, 12, 31))) + 1 > -91 -- end date is not 3 months before child was born (arbitary date, can be changed)
)
SELECT snz_uid
		,child_dob_snz
		,start_date
		,end_date
		,parent_snz_uid
		,relationship
		,'DIA' AS source
		,1 AS source_rank
INTO #part_5
FROM parent_oth_mar;

/******************************************************* PART 1G: RELATIONSHIPS - PARENT CHILD SIBLINGS *******************************************************/

-- Step 1: Parent - child relationships
IF OBJECT_ID('tempdb..#reln_parent_child') IS NOT NULL DROP TABLE #reln_parent_child;
-- Combined relationships
WITH relationship_comb AS (
SELECT *
FROM #part_1 
UNION
SELECT *
FROM #part_2
UNION
SELECT *
FROM #part_3 
UNION
SELECT *
FROM #part_4 
UNION
SELECT *
FROM #part_5  
),

-- to remove duplicates 
relationships_mid AS (
SELECT a.snz_uid
		,a.child_dob_snz
		,a.start_date
		,a.end_date
		,a.parent_snz_uid
		,a.relationship
		,a.source
		,a.source_rank
		,ROW_NUMBER() OVER (PARTITION BY a.snz_uid, a.parent_snz_uid  ORDER BY relationship) AS rn -- might interchange few fathers and mothers 
FROM relationship_comb a
INNER JOIN (SELECT snz_uid, parent_snz_uid, MIN(source_rank) AS 'min_rank'
			FROM relationship_comb
			GROUP BY snz_uid, parent_snz_uid
			) b 
ON a.snz_uid = b.snz_uid 
AND a.parent_snz_uid = b.parent_snz_uid
AND a.source_rank = b.min_rank
)
SELECT snz_uid
		,child_dob_snz
		,MAX(start_date) AS 'start_date'
		,ISNULL(MIN(end_date), DATEFROMPARTS(2099, 12, 31)) AS 'end_date'
		,parent_snz_uid
		,relationship
		,source
		,source_rank
INTO #reln_parent_child
FROM relationships_mid
WHERE rn = 1
GROUP BY snz_uid
		,child_dob_snz
		,parent_snz_uid
		,relationship
		,source
		,source_rank;


/******************************************************* PART 1 FINAL: RELATIONSHIPS - PARENT CHILD SIBLINGS *******************************************************/
-- Sibling relationships based on parent child relationships created above
IF OBJECT_ID('tempdb..#parent_child_sibling') IS NOT NULL DROP TABLE #parent_child_sibling;
WITH siblings AS (
SELECT DISTINCT a.snz_uid
		,a.child_dob_snz
		,a.start_date
		,a.end_date
		,a.parent_snz_uid 
		,a.relationship 
		,a.source
		,a.source_rank
		,b.snz_uid AS 'sibling_snz_uid'
		,b.child_dob_snz AS 'sibling_dob_snz'
FROM #reln_parent_child a 
LEFT JOIN #reln_parent_child b 
ON a.parent_snz_uid = b.parent_snz_uid
AND a.snz_uid <> b.snz_uid
AND a.relationship IN ('DIA_father', 'DIA_mother', 'DIA_step_mother', 'DIA_step_father')
AND b.relationship IN ('DIA_father', 'DIA_mother')
)
SELECT DISTINCT a.snz_uid
		,child_dob_snz
		,start_date
		,end_date
		,parent_snz_uid 
		,relationship 
		,source
		,source_rank
		,a.sibling_snz_uid
		,a.sibling_dob_snz
		,CASE	WHEN b.sibling_relationship IN ('DIA_mother_DIA_father', 'DIA_father_DIA_mother') THEN 'sibling'
				WHEN b.sibling_relationship IN ('DIA_step_mother_DIA_father', 'DIA_father_DIA_step_mother', 'DIA_father')  THEN 'step_sibling_father'
				WHEN b.sibling_relationship IN ('DIA_mother', 'DIA_mother_DIA_step_father', 'DIA_step_father_DIA_mother') THEN 'step_sibling_mother'
				WHEN b.sibling_relationship IN ('DIA_step_father', 'DIA_step_father_DIA_step_mother', 'DIA_step_mother', 'DIA_step_mother_DIA_step_father') THEN 'step_sibling_step_parent'
				WHEN b.sibling_relationship IS NULL THEN NULL 
				ELSE b.sibling_relationship -- fail safe 
		 END AS 'sibling_relationship'
INTO #parent_child_sibling
FROM siblings a
LEFT JOIN (
			SELECT DISTINCT snz_uid
					,sibling_snz_uid
					,STRING_AGG(relationship, '_') AS 'sibling_relationship'
			FROM siblings
			WHERE sibling_snz_uid IS NOT NULL 
			GROUP BY snz_uid 
					,sibling_snz_uid 
			
		)b
ON a.snz_uid = b.snz_uid 
AND a.sibling_snz_uid = b.sibling_snz_uid

/********************************************************************* END OF PART 1  *********************************************************************/

/* Save table into Sandpit 

SELECT * 
INTO [IDI_Sandpit].[DL-MAA2020-73].[parent_child_sibling] 
FROM #parent_child_sibling


ALTER TABLE [IDI_Sandpit].[DL-MAA2020-73].[parent_child_sibling] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)
CREATE CLUSTERED INDEX GNIFE_child_parent ON [IDI_Sandpit].[DL-MAA2020-73].[parent_child_sibling] ([snz_uid], [parent_snz_uid], [sibling_snz_uid])

*/
