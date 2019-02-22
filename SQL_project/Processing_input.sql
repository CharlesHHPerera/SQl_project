------------------------------------- info-----------------------------------------
---- Name ---------- Processing_inputs - SQL project ------------------------------
---- Funcation ----- Process and exploring for SQL project  ----------------------
---- Create by ----- Charles Perera -----------------------------------------------
---- Company ------- Kubrick group ------------------------------------------------
---- Date Created -- 18/02/2019 ---------------------------------------------------
--------------------------------------info-----------------------------------------

/***************** land section **************************/ 

-- this check the data is there

select top 20 * 
from [Land].[Traff_2017_2018]


select top 20 * 
from [Land].[Traff_2018_2019]

-- this look at the length and type of HRG codes
select 
	[HRG name]
	,left([HRG name],CHARINDEX('with',[HRG name]))
	,CHARINDEX('with',[HRG name])
from [Land].[Traff_2017_2018]
where CHARINDEX('with',[HRG name]) = 0 


select distinct
	[HRG code]
	,[HRG name]
	,left([HRG code],2) BAse 
	,right(left([HRG code],4),2) BAse_num
from Land.Traff_2017_2018
order by BAse

select distinct
	len([ BPT applies to HRG or sub-HRG level]) 
From Land.Traff_2017_2018
union all 
select distinct
	len([ BPT applies to HRG or sub-HRG level]) 
From [HRG].[Traff_2018_2019]


-- check the convertion is possible without error
select distinct
	isnull(try_cast([Ordinary elective spell tariff (£)] as money),0)
from Land.Traff_2017_2018
union all 
select distinct
	isnull(try_cast([Ordinary elective spell tariff (£)] as money),0)
From [Land].[Traff_2018_2019]


-- this look at joining the data set if possible
select 
	*
from Land.Traff_2017_2018
union all 
select 
	* 
from Land.Traff_2017_2018

/***************************** clenzing section and intersceting ***********************/ 

if objecT_ID('[HRG].[Traff_2018_2019]')is not null 
	begin 
		drop table [HRG].[Traff_2018_2019]
	end 


create table [HRG].[Traff_2018_2019] -- this is inout them into a table and make data type our correct 
(
	[HRG code] [char](5) NULL,
	[HRG name] [nvarchar](255) NULL,
	[Outpatient procedure tariff (£)] money NULL,
	[Combined day case / ordinary elective spell tariff (£)] [float] NULL,
	[Day case spell tariff (£)] money NULL,
	[Ordinary elective spell tariff (£)] money NULL,
	[Ordinary elective long stay trim point (days)] [float] NULL,
	[Non-elective spell tariff (£)] money NULL,
	[Non-elective long stay trim point (days)] [float] NULL,
	[Per day long stay payment (for days exceeding trim point) (£)] money NULL,
	[Reduced short stay emergency tariff _applicable?] [varchar](3) NULL,
	[% applied in calculation of reduced short stay emergency tariff ] [float] NULL,
	[Reduced short stay emergency tariff (£)] money NULL,
	[ BPT applies to HRG or sub-HRG level] [varchar](10) NULL,
	[Area BPT Name applies (see also tab "07#BPTs")] [nvarchar](255) NULL,
	[Where BPT applies:_NE = Non-elective spell tariff_DC/EL = Day ca] [nvarchar](255) NULL,
	[SUS will automate which BPT price (BPT or non-BPT price)] [nvarchar](255) NULL,
	[The price automated by SUS] [nvarchar](255) NULL,
	[BPT Flag] [nvarchar](255) NULL
) ON [PRIMARY]


USE [Heatlth]
GO

INSERT INTO [HRG].[Traff_2018_2019]
           ([HRG code]
           ,[HRG name]
           ,[Outpatient procedure tariff (£)]
           ,[Combined day case / ordinary elective spell tariff (£)]
           ,[Day case spell tariff (£)]
           ,[Ordinary elective spell tariff (£)]
           ,[Ordinary elective long stay trim point (days)]
           ,[Non-elective spell tariff (£)]
           ,[Non-elective long stay trim point (days)]
           ,[Per day long stay payment (for days exceeding trim point) (£)]
           ,[Reduced short stay emergency tariff _applicable?]
           ,[% applied in calculation of reduced short stay emergency tariff ]
           ,[Reduced short stay emergency tariff (£)]
           ,[ BPT applies to HRG or sub-HRG level]
           ,[Area BPT Name applies (see also tab "07#BPTs")]
           ,[Where BPT applies:_NE = Non-elective spell tariff_DC/EL = Day ca]
           ,[SUS will automate which BPT price (BPT or non-BPT price)]
           ,[The price automated by SUS]
           ,[BPT Flag])
(
select * 
from [Land].[Traff_2018_2019]
)

select * 
from [HRG].[Traff_2018_2019]


if objecT_ID('[HRG].[Traff_2017_2018]')is not null 
	begin 
		drop table [HRG].[Traff_2017_2018]
	end 
create table [HRG].[Traff_2017_2018]
(
	[HRG code] [char](5) NULL,
	[HRG name] [nvarchar](255) NULL,
	[Outpatient procedure tariff (£)] money NULL,
	[Combined day case / ordinary elective spell tariff (£)] [float] NULL,
	[Day case spell tariff (£)] money NULL,
	[Ordinary elective spell tariff (£)] money NULL,
	[Ordinary elective long stay trim point (days)] [float] NULL,
	[Non-elective spell tariff (£)] money NULL,
	[Non-elective long stay trim point (days)] [float] NULL,
	[Per day long stay payment (for days exceeding trim point) (£)] money NULL,
	[Reduced short stay emergency tariff _applicable?] [varchar](3) NULL,
	[% applied in calculation of reduced short stay emergency tariff ] [float] NULL,
	[Reduced short stay emergency tariff (£)] money NULL,
	[ BPT applies to HRG or sub-HRG level] [varchar](10) NULL,
	[Area BPT Name applies (see also tab "07#BPTs")] [nvarchar](255) NULL,
	[Where BPT applies:_NE = Non-elective spell tariff_DC/EL = Day ca] [nvarchar](255) NULL,
	[SUS will automate which BPT price (BPT or non-BPT price)] [nvarchar](255) NULL,
	[The price automated by SUS] [nvarchar](255) NULL,
	[BPT Flag] [nvarchar](255) NULL
) ON [PRIMARY]

INSERT INTO [HRG].[Traff_2017_2018]
           ([HRG code]
           ,[HRG name]
           ,[Outpatient procedure tariff (£)]
           ,[Combined day case / ordinary elective spell tariff (£)]
           ,[Day case spell tariff (£)]
           ,[Ordinary elective spell tariff (£)]
           ,[Ordinary elective long stay trim point (days)]
           ,[Non-elective spell tariff (£)]
           ,[Non-elective long stay trim point (days)]
           ,[Per day long stay payment (for days exceeding trim point) (£)]
           ,[Reduced short stay emergency tariff _applicable?]
           ,[% applied in calculation of reduced short stay emergency tariff ]
           ,[Reduced short stay emergency tariff (£)]
           ,[ BPT applies to HRG or sub-HRG level]
           ,[Area BPT Name applies (see also tab "07#BPTs")]
           ,[Where BPT applies:_NE = Non-elective spell tariff_DC/EL = Day ca]
           ,[SUS will automate which BPT price (BPT or non-BPT price)]
           ,[The price automated by SUS]
           ,[BPT Flag])
(
select * 
from [Land].[Traff_2017_2018]
)


/*************************************** addational exploring after process data ********************/ 
-- this is basic anylisis if the exporing to see if possible and
 --this just a qucik check of the size avg price differecnet
;with cte 
as 
(
select
	HA.[HRG code]
	,HA.[Non-elective spell tariff (£)]/(HB.[Non-elective spell tariff (£)]+0.00000000000001) pecent_change -- this small addation is remove the zero error
from [HRG].[Traff_2017_2018] HB
inner join [HRG].[Traff_2018_2019] HA
	on HB.[HRG code] = HA.[HRG code]
)
select
	(pecent_change - 1)*100 abc
from cte 
order by abc



if OBJECT_ID('HRG.HRG_name_drop') is not null 
	begin 
	drop table HRG.HRG_name_drop
	end 

create table HRG.HRG_name_drop
(
[HRG_ID] varchar(5) primary key,
[HRG name] varchar(200),
[HRG Chapter Description] varchar(200),
[HRG Subchapter Description] varchar(200),
[HRG Root Decriptions] varchar(200),
[HRG Root END Decriptions] varchar(200)
) 

USE [Heatlth]
GO

INSERT INTO [HRG].[HRG_name_drop]
           ([HRG_ID]
           ,[HRG name]
           ,[HRG Chapter Description]
           ,[HRG Subchapter Description]
           ,[HRG Root Decriptions]
           ,[HRG Root END Decriptions])
(
select
	cast(HB.[HRG code] as varchar(5)) [HRG_ID]
	,HB.[HRG name] 
	,HC.[HRG Chapter Description]
	,HS.[HRG Subchapter Description]
	,ltrim(rtrim(HD.[HRG Root Description])) Descriptions
	,REPLACE(HB.[HRG name],ltrim(rtrim(HD.[HRG Root Description])),' ') RootEND
from [HRG].[Traff_2017_2018] HB
	inner join [HRG].[Chapter] HC
		on left(HB.[HRG code],1) = HC.[HRG Chapter]
	inner join HRG.Subchapter HS
		on left(HB.[HRG code],2) = HS.[HRG Subchapter] 
	inner join HRG.Descriptions HD
		on left(HB.[HRG code],4) = HD.[HRG Root]
)

select * 
from [HRG].[HRG_name_drop]



/************************* HRG code Break ******************************/ 

-- important from a group of description for starting HSE code
Select*
from [HRG].[HRG_groups]

Select *
From [HRG].[Traff_2017_2018]



