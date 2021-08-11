USE [IDI_Clean_20201020];

/**********************************************************************************************************************************************************************
-- PART 1: MoE Qualifications 
**********************************************************************************************************************************************************************/
-- (a) Student Qualification table (MOE - NZQA)
IF OBJECT_ID('tempdb..#sch_stu_qual') IS NOT NULL DROP TABLE #sch_stu_qual;
WITH sch_qual AS (
SELECT   a.snz_uid
       	,'SCH quals'					AS [qual_type]
		,a.moe_sql_attained_year_nbr	AS [year]
		,CASE	WHEN NQFlevel >= 4																								THEN 4 -- school qualifications coded upto 4 to keep it clean(ish)
				WHEN QualificationCode = '1039' AND moe_sql_exam_result_code IN ('E', 'M', 'ZZ')								THEN 3
				WHEN NQFlevel=3																									THEN 3
				WHEN (QualificationCode = '0973' OR QualificationCode = '973') AND moe_sql_exam_result_code IN ('E', 'M', 'ZZ')	THEN 2
				WHEN NQFlevel=2																									THEN 2
				WHEN (QualificationCode = '0928' OR QualificationCode = '928') AND moe_sql_exam_result_code IN ('E', 'M', 'ZZ')	THEN 1
				WHEN NQFlevel=1																									THEN 1
				ELSE 0 
		END								AS [level]
FROM [moe_clean].[student_qualification] a
LEFT JOIN [IDI_metadata].[clean_read_CLASSIFICATIONS].[moe_ncea_qualification_20190830] b
ON a.[moe_sql_qual_code] = b.[qualificationTableId]
WHERE YEAR(moe_sql_nzqa_load_date) = moe_sql_attained_year_nbr
OR (YEAR(moe_sql_nzqa_load_date) - moe_sql_attained_year_nbr) <= 2 -- Qualification was loaded at max 2 years after achieving: This rule was added to remove potential false records that got recorded later. 
OR moe_sql_nzqa_load_date IS NULL
AND moe_sql_attained_year_nbr >= 2003 -- Good Quality data after 2003 according to MoE
)
-- Seleting the max qualification from that year 
SELECT  snz_uid
	   ,qual_type
	   ,year
	   ,MAX(level) AS 'nqflevel'
INTO #sch_stu_qual
FROM sch_qual
GROUP BY snz_uid,qual_type, year

-- (b) Secondary qualifications - School leavers dataset - includes non-NQF 
IF OBJECT_ID('tempdb..#sch_leav_qual') IS NOT NULL DROP TABLE #sch_leav_qual;
WITH school_leave AS (
SELECT snz_uid
	   ,moe_sl_leaver_year as 'year'
       ,CASE	WHEN moe_sl_highest_attain_code IN (43, 40)									THEN  4
				WHEN moe_sl_highest_attain_code IN (37, 36, 35, 34, 33, 62, 72, 82,92)		THEN  3
				WHEN moe_sl_highest_attain_code IN (56, 27, 26, 25, 24, 4, 61, 71, 81, 91)	THEN  2
				WHEN moe_sl_highest_attain_code IN (55, 17, 16, 15, 14, 13, 60, 70, 80, 90)	THEN  1
				ELSE 0 
		END AS 'level'
from [moe_clean].[student_leavers]
)
SELECT DISTINCT snz_uid
       ,'SCH LEAVE' AS [qual_type]
       ,MAX(year) AS [year] -- if the student have multiple leaving records, only select the latest one
	   ,MAX(level) AS [nqflevel]
INTO #sch_leav_qual
FROM school_leave 
GROUP BY snz_uid
	

-- (c) Tertiary QUalifications 
IF OBJECT_ID('tempdb..#ter_qual') IS NOT NULL DROP TABLE #ter_qual;
WITH tertiary_qual AS (
SELECT  DISTINCT snz_uid
		,moe_com_year_nbr AS year
		,CASE WHEN moe_com_qual_level_code = '10'	THEN 10
			  WHEN moe_com_qual_level_code = '09'	THEN 9
			  WHEN moe_com_qual_level_code = '08'	THEN 8
			  WHEN moe_com_qual_level_code = '07'	THEN 7
			  WHEN moe_com_qual_level_code = '06'	THEN 6
			  WHEN moe_com_qual_level_code = '05'	THEN 5
			  WHEN moe_com_qual_level_code = '04'	THEN 4
			  WHEN moe_com_qual_level_code = '03'	THEN 3
			  WHEN moe_com_qual_level_code = '02'	THEN 2
			  WHEN moe_com_qual_level_code = '01'	THEN 1	  
		      ELSE NULL 
		END AS nqflevel  
FROM [moe_clean].[completion] 
WHERE moe_com_year_nbr >= 2000
)
-- Get highest qualification by year 
SELECT snz_uid
      ,year
	  ,'TER' AS 'qual_type'
	  ,max(nqflevel) as nqflevel
INTO #ter_qual
FROM tertiary_qual
GROUP BY snz_uid, year


-- (d) Industry training qualifications 
IF OBJECT_ID('tempdb..#it_qual') IS NOT NULL DROP TABLE #it_qual;
WITH industry_training AS (
SELECT  snz_uid
		,moe_itl_year_nbr as year
		,moe_itl_nqf_level_code
       /* counts of number of qualifications awarded, by NZQF level*/
	  	,CASE WHEN moe_itl_level1_qual_awarded_nbr >= 1 THEN 1
		WHEN moe_itl_level2_qual_awarded_nbr >= 1 THEN 2
		WHEN moe_itl_level3_qual_awarded_nbr >= 1 THEN 3
		WHEN moe_itl_level4_qual_awarded_nbr >= 1 THEN 4
		WHEN moe_itl_level5_qual_awarded_nbr >= 1 THEN 5
		WHEN moe_itl_level6_qual_awarded_nbr >= 1 THEN 6
		WHEN moe_itl_level7_qual_awarded_nbr >= 1 THEN 7
		ELSE 0 
		END AS nqflevel   
FROM [moe_clean].[tec_it_learner]
WHERE moe_itl_programme_type_code NOT IN ('LCP') /* LCP are non standard programmes */
)
-- Final table
SELECT [snz_uid]
		,[year]
		,'IT' AS 'qual_type'
		,MAX(nqflevel) AS [nqflevel]
INTO #it_qual
FROM industry_training
GROUP BY [snz_uid]
		,[year];
 

-- (e) Targeted training qualifications 
IF OBJECT_ID('tempdb..#tt_qual') IS NOT NULL DROP TABLE #tt_qual
SELECT [snz_uid]
      ,[moe_ttr_year_nbr] AS 'year'
	  ,'TT' AS 'qual_type'
      ,MAX([moe_ttr_course_level_nbr]) AS 'nqflevel'
INTO #tt_qual
FROM [moe_clean].[targeted_training]
WHERE [moe_ttr_course_level_nbr] != '99'
GROUP BY [snz_uid]
		,[moe_ttr_year_nbr]

-- Final table with all MOE qualifications
IF OBJECT_ID('tempdb..#moe_qual') IS NOT NULL DROP TABLE #moe_qual;
WITH moe_qual_init AS (
SELECT  snz_uid
       ,year
	   ,nqflevel
	   ,qual_type
	   ,'1_Sch' AS 'source'
FROM  #sch_stu_qual
WHERE nqflevel >=0 
UNION
SELECT  snz_uid
       ,year
	   ,nqflevel
	   ,qual_type
	   ,'1_Sch' AS 'source'
FROM  #sch_leav_qual
where nqflevel >=0 
UNION 
SELECT snz_uid
       ,year
	   ,nqflevel
	   ,qual_type
	   ,'3_Ter' AS 'source'
FROM #ter_qual 
WHERE nqflevel >=0 
UNION 
SELECT snz_uid
       ,year
	 	,nqflevel
	   ,qual_type
	   ,'2_IT' AS 'source'
FROM  #it_qual
WHERE nqflevel >=0
--UNION 
--SELECT snz_uid
--       ,year
--	 	,nqflevel
--	   ,qual_type
--	   ,'2_TT' AS 'source'
--FROM  #tt_qual
--WHERE nqflevel >=0
)
-- Aggregate to get one highest qualification level achieved to date by year (cumulative max)
SELECT a.snz_uid
		,a.year
		,MAX(CASE WHEN b.source = '1_Sec' THEN 1 ELSE 0 END) AS sch_qual
		,MAX(CASE WHEN b.source = '2_IT' OR b.source='2_TT' THEN 1 ELSE 0 END) AS it_tt_qual
		,MAX(CASE WHEN b.source = '3_Ter' THEN 1 ELSE 0 END) AS ter_qual
		,MAX(b.nqflevel) AS 'level'
INTO #moe_qual
FROM moe_qual_init a
LEFT JOIN moe_qual_init b
ON a.snz_uid = b.snz_uid 
AND a.year >= b.year -- to get cumulative max 
GROUP BY a.snz_uid
		,a.year

/*********************************************************************************************************************************************************************
PART 2: Census 2013 and 2018 Highest Qualification
*********************************************************************************************************************************************************************/
IF OBJECT_ID('tempdb..#cen_qual') IS NOT NULL DROP TABLE #cen_qual
SELECT snz_uid
		,YEAR(cen_ind_process_date) AS year	
		,CASE	WHEN cen_ind_std_highest_qual_code ='00' THEN 0
				WHEN cen_ind_std_highest_qual_code ='01' THEN 1
				WHEN cen_ind_std_highest_qual_code ='02' THEN 2
				WHEN cen_ind_std_highest_qual_code ='03' THEN 3
				WHEN cen_ind_std_highest_qual_code ='04' THEN 4
				WHEN cen_ind_std_highest_qual_code ='05' THEN 5
				WHEN cen_ind_std_highest_qual_code ='06' THEN 6
				WHEN cen_ind_std_highest_qual_code ='07' THEN 7
				WHEN cen_ind_std_highest_qual_code ='08' THEN 8
				WHEN cen_ind_std_highest_qual_code ='09' THEN 9
				WHEN cen_ind_std_highest_qual_code ='10' THEN 10
				WHEN cen_ind_std_highest_qual_code ='11' THEN 1 
				WHEN cen_ind_std_highest_qual_code IN ('97','99') THEN NULL
                ELSE NULL END AS nqflevel
			,'CEN' AS source
INTO #cen_qual
FROM [cen_clean].[census_individual_2013] 
UNION
SELECT snz_uid
		,2018 AS year	
		,CASE	WHEN [cen_ind_standard_hst_qual_code] ='00' THEN 0
				WHEN [cen_ind_standard_hst_qual_code] ='01' THEN 1
				WHEN [cen_ind_standard_hst_qual_code] ='02' THEN 2
				WHEN [cen_ind_standard_hst_qual_code] ='03' THEN 3
				WHEN [cen_ind_standard_hst_qual_code] ='04' THEN 4
				WHEN [cen_ind_standard_hst_qual_code] ='05' THEN 5
				WHEN [cen_ind_standard_hst_qual_code] ='06' THEN 6
				WHEN [cen_ind_standard_hst_qual_code] ='07' THEN 7
				WHEN [cen_ind_standard_hst_qual_code] ='08' THEN 8
				WHEN [cen_ind_standard_hst_qual_code] ='09' THEN 9
				WHEN [cen_ind_standard_hst_qual_code] ='10' THEN 10
				WHEN [cen_ind_standard_hst_qual_code] ='11' THEN 1 
				WHEN [cen_ind_standard_hst_qual_code] IN ('97','99') THEN NULL
                ELSE NULL END AS nqflevel
			,'CEN' AS source
FROM [cen_clean].[census_individual_2018]


/*********************************************************************************************************************************************************************
PART 3: MSD Qualification Records

OTHER:
Education Code Classification for MSD
A	No Formal School Quals or <3 yrs
B	Less than 3 SC Passes or Equiv.
C	3 or More SC Passes or Equiv.
D	Sixth Form Cert  UE or Equiv.
E	Scholarship  Bursary  HSC
F	Other School Quals
G	Post Secondary Quals
H	Degree or Professional Quals
I	(NCEA) : 1-79 credits
J	(NCEA) Level 1: > = 80 credits
K	(NCEA) Level 2: > = 80 credits
L	(NCEA) Level 3: > = 80 credits
M	(NCEA) Level 4: > = 72 credits
P	Unknown - auto-enrolled
*********************************************************************************************************************************************************************/
IF OBJECT_ID('tempdb..#msd_qual') IS NOT NULL DROP TABLE #msd_qual;
WITH msd_qual_init AS (
SELECT snz_uid 
		,YEAR(ISNULL(msd_edh_educ_lvl_end_date,msd_edh_educ_lvl_start_date)) AS 'year'
		,CASE	WHEN msd_edh_education_code IN ('A' ,'B' ,'I')	THEN 0
				WHEN msd_edh_education_code IN ('C', 'J')		THEN 1
				WHEN msd_edh_education_code IN ('D', 'F', 'K')	THEN 2
				WHEN msd_edh_education_code IN ('E', 'L','G')	THEN 3 
				WHEN msd_edh_education_code IN ('H','M')		THEN 4 
				ELSE NULL 
		END AS 'nqflevel'
FROM [msd_clean].[msd_education_history] 
)
SELECT snz_uid
		,year
		,'MSD' AS 'source'
		,MAX(nqflevel) AS 'nqflevel'
INTO #msd_qual
FROM msd_qual_init
GROUP BY snz_uid
		,year

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Combining all sources 
IF OBJECT_ID('tempdb..#qual_all') IS NOT NULL DROP TABLE #qual_all
SELECT snz_uid
		,year
		,sch_qual
		,it_tt_qual
		,ter_qual
		,level AS nqflevel
		,'MOE' AS 'source'
		,1 AS src_priority
INTO #qual_all
FROM #moe_qual
WHERE level IS NOT NULL
UNION
SELECT snz_uid
		,year
		,CASE WHEN nqflevel IS NOT NULL AND nqflevel BETWEEN 1 AND 4 THEN 1 ELSE 0 END AS sch_qual
		,NULL AS it_tt_qual
		,CASE WHEN nqflevel IS NOT NULL AND nqflevel BETWEEN 5 AND 10 THEN 1 ELSE 0 END AS ter_qual
		,nqflevel
		,source
		,2 AS src_priority
FROM #cen_qual
WHERE nqflevel IS NOT NULL
UNION 
SELECT snz_uid
		,year
		,CASE WHEN nqflevel IS NOT NULL AND nqflevel BETWEEN 1 AND 4 THEN 1 ELSE 0 END AS sch_qual
		,NULL AS it_tt_qual
		,CASE WHEN nqflevel IS NOT NULL AND nqflevel BETWEEN 5 AND 10 THEN 1 ELSE 0 END AS ter_qual
		,nqflevel
		,source
		,3 AS src_priority
FROM #msd_qual
WHERE nqflevel IS NOT NULL 

-- Gathering highest qualification per year exisitng for each person

IF OBJECT_ID('tempdb..#qualifications') IS NOT NULL DROP TABLE #qualifications
SELECT a.snz_uid
		,a.year
		,MAX(b.sch_qual) AS sch_qual
		,MAX(b.it_tt_qual) AS it_tt_qual
		,MAX(b.ter_qual) AS ter_qual
		,a.[nqflevel]
		,b.[source]
		,a.[src_priority]
INTO #qualifications
FROM (
		SELECT a.[snz_uid]
				,a.[year]
				,MAX(a.[nqflevel]) AS [nqflevel]
				,b.[src_priority]
		FROM #qual_all a
		LEFT JOIN (SELECT [snz_uid]
							,[year]
							,[nqflevel]
							,MIN(src_priority) AS [src_priority] 
					FROM #qual_all  
					WHERE [nqflevel] IS NOT NULL 
					GROUP BY [snz_uid], [year], [nqflevel]
					)b
		ON a.[snz_uid] = b.[snz_uid]
		AND a.[nqflevel] = b.[nqflevel]
		WHERE a.[nqflevel] IS NOT NULL
		GROUP BY a.[snz_uid]
				,a.[year]
				,b.[src_priority]
	) a
LEFT JOIN #qual_all b
ON a.[snz_uid] = b.[snz_uid] 
AND a.[year] = b.[year] 
AND a.[nqflevel] = b.[nqflevel]
AND a.[src_priority] = b.[src_priority]
GROUP BY a.[snz_uid]
		,a.[year]
		,a.[nqflevel]
		,b.[source]
		,a.[src_priority]


-- Adding highest qual cumulative for each year 

IF OBJECT_ID('tempdb..#qualification_loop') IS NOT NULL DROP TABLE #qualification_loop
CREATE TABLE #qualification_loop
(
	snz_uid INT NULL,
	year INT NULL,
	sch_qual INT NULL,
	it_tt_qual INT NULL,
	ter_qual INT NULL,
	nqflevel INT NULL,
	src_priority INT NULL
);

DECLARE @year_max INT = 2020
DECLARE @year_current INT = 2008

WHILE @year_current <= @year_max
BEGIN
	
	INSERT INTO #qualification_loop
	SELECT snz_uid
		,@year_current AS 'year'
		,MAX(sch_qual) AS 'sch_qual'
		,MAX(it_tt_qual) AS 'it_tt_qual'
		,MAX(ter_qual) AS 'ter_qual'
		,MAX(nqflevel) AS 'nqflevel'
		,MAX(src_priority) AS 'src_priority'
	FROM (SELECT * FROM #qualifications WHERE year <= @year_current) a	
	GROUP BY snz_uid


SET @year_current = @year_current + 1 
END

-- Final qualification table

IF OBJECT_ID('tempdb..#highest_qualification') IS NOT NULL DROP TABLE #highest_qualification
SELECT DISTINCT snz_uid
		,year 
		,sch_qual AS 'school'
		,it_tt_qual AS 'industry'
		,ter_qual AS 'tertiary'
		,nqflevel AS 'level'
		,CASE	WHEN src_priority = 1 THEN 'MOE'
				WHEN src_priority = 2 THEN 'CENSUS'
				WHEN src_priority = 3 THEN 'MSD'
				ELSE NULL
		END AS 'src'
INTO #highest_qualification
FROM #qualification_loop

-- Saving highest qualification in Sandpit 
/*

ALTER TABLE [IDI_Sandpit].[DL-MAA2020-73].[pre_qa_highest_qual] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)
CREATE CLUSTERED INDEX GNIFE_child_parent ON [IDI_Sandpit].[DL-MAA2020-73].[pre_qa_highest_qual] ([snz_uid])

DROP TABLE [IDI_Sandpit].[DL-MAA2020-73].[highest_qual]
SELECT * 
INTO [IDI_Sandpit].[DL-MAA2020-73].[highest_qual]
FROM #highest_qualification

ALTER TABLE [IDI_Sandpit].[DL-MAA2020-73].[highest_qual] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)
CREATE CLUSTERED INDEX GNIFE_child_parent ON [IDI_Sandpit].[DL-MAA2020-73].[highest_qual] ([snz_uid])

*/