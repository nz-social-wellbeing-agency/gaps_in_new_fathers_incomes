/* drop table if it exists */
IF OBJECT_ID('[IDI_Sandpit].[DL-MAA2020-73].[METADATA_min_wages]', 'U') IS NOT NULL
DROP TABLE [IDI_Sandpit].[DL-MAA2020-73].[METADATA_min_wages];
GO

/* create empty table */
CREATE TABLE [IDI_Sandpit].[DL-MAA2020-73].[METADATA_min_wages] (
	[start_date] [DATE],
	[end_date] [DATE],
	[min_wage] [FLOAT](53),
	[min_monthly_inc] [FLOAT](53),
	[living_wage] [FLOAT](53),
	[min_monthly_living_wage] [FLOAT](53)
) ON [PRIMARY];
GO

INSERT INTO [IDI_Sandpit].[DL-MAA2020-73].[METADATA_min_wages]
([start_date], [end_date], [min_wage], [min_monthly_inc], [living_wage], [min_monthly_living_wage])
VALUES
('2007-04-01', '2008-03-31', 11.25, 1800, 11.25, 1800),
('2008-04-01', '2009-03-31', 12, 1920, 12, 1920),
('2009-04-01', '2010-03-31', 12.5, 2000, 12.5, 2000),
('2010-04-01', '2011-03-31', 12.75, 2040, 12.75, 2040),
('2011-04-01', '2012-03-31', 13, 2080, 13, 2080),
('2012-04-01', '2013-03-31', 13.5, 2160, 13.5, 2160),
('2013-04-01', '2014-03-31', 13.75, 2200, 18.4, 2944),
('2014-04-01', '2015-03-31', 14.25, 2280, 18.8, 3008),
('2015-04-01', '2016-03-31', 14.75, 2360, 19.25, 3080),
('2016-04-01', '2017-03-31', 15.25, 2440, 19.8, 3168),
('2017-04-01', '2018-03-31', 15.75, 2520, 20.2, 3232),
('2018-04-01', '2019-03-31', 16.5, 2640, 20.55, 3288),
('2019-04-01', '2020-03-31', 17.5, 2800, 21.15, 3384),
('2020-04-01', '2021-03-31', 18.9, 3024, 22.1, 3536);
GO
