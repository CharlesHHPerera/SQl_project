------------------------------------- info-----------------------------------------
---- Name ---------- Part 3 Dynamic - SQL project ---------------------------------
---- Funcation ----- Dose Pat3 but use a dyamic sql so input 3 table names --------
---- Create by ----- Charles Perera -----------------------------------------------
---- Company ------- Kubrick group ------------------------------------------------
---- Date Created -- 22/02/2019 ---------------------------------------------------
--------------------------------------info-----------------------------------------


-- Run code, neeed input HSE with HRG code, and the location of HRG two set HRG codes to compare
exec usp_Explore_HRG '[Rands].[HSe_with_HRG]','[HRG].[Traff_2017_2018]','[HRG].[Traff_2018_2019]'


go
alter proc usp_Explore_HRG
@HSE_with_HRG varchar(max), -- need set max length 
@Traff_2017 varchar(max),	-- need set the max length 
@Traff_2018 varchar(max)    -- set the lenght=
as
declare @sqlcommand varchar(max)
-- cheack that the file excitse and but dose check that the colomus are there
if OBJECT_ID(@HSE_with_HRG) is null 
	begin 
		print 'Can not find HSE data with HRG code'
		return
	end
if OBJECT_ID(@Traff_2017) is null 
	begin 
		print 'Can not find HRG Traff data for 2017 to 2018'
		return 
	end
if OBJECT_ID(@Traff_2018) is null 
	begin 
		print 'Can not find HRG Traff data for 2018 to 2019'
		return
	end
-- drop the temp table is long code at end to remove some ones table
if object_ID('dbo.temp_2017_2a5d4789') is not null 
	begin 
		drop table dbo.temp_2017_2a5d4789
	end
if object_ID('dbo.temp_2018_39a75t123') is not null 
	begin 
		drop table dbo.temp_2018_39a75t123
	end
declare @file varchar(max) 
set @file = @HSE_with_HRG
set @sqlcommand =' 
;with cte as (
select 
	 D.spell
	,D.hesid
	,He.[HRG code]
	,D.episode
	,D.epistart
	,D.epiend
	,D.epidur
	,D.admimeth
	,D.classpat
	,case 
		when left(admimeth,1) = 1 then 1 
		else 2
	 end Non_or_Elective
	 ,case 
		when D.epidur = 0 and D.classpat = 2 then 5
		when D.epidur = 0 and D.classpat <> 2 then 6
		when D.epidur < 2 then 4
		when D.epidur <= HE.[Ordinary elective long stay trim point (days)] then 1 
		when D.epidur >= HE.[Ordinary elective long stay trim point (days)] and D.epidur <= HE.[Non-elective long stay trim point (days)] then 3 
		else 2
	 end Duration
from '+ @file +' D
	inner join' + @Traff_2017 +'HE
		on D.HRG_code = HE.[HRG code]
)
select 
	cte.hesid
	,cte.[HRG code]
	,cte.epistart
	,cte.epidur
	,cte.Non_or_Elective*10 + cte.Duration type_cost_applied_2017
	,case 
		-- this group if for tehe elective spells 
		when cte.Non_or_Elective*10 + cte.Duration = 11 then isnull((HE.[Combined day case / ordinary elective spell tariff (£)]), 0) -- Normal cost
		when cte.Non_or_Elective*10 + cte.Duration = 12 then  -- Add if stay a longer duration 
			case 
				when  HE.[Combined day case / ordinary elective spell tariff (£)] + (cte.epidur - He.[Ordinary elective long stay trim point (days)]*1)*He.[Per day long stay payment (for days exceeding trim point) (£)] <0 then (HE.[Combined day case / ordinary elective spell tariff (£)] + (-cte.epidur + He.[Ordinary elective long stay trim point (days)]*1)*He.[Per day long stay payment (for days exceeding trim point) (£)])
				else isnull(HE.[Combined day case / ordinary elective spell tariff (£)] + (cte.epidur - He.[Ordinary elective long stay trim point (days)]*1)*He.[Per day long stay payment (for days exceeding trim point) (£)],0)
			end
		when cte.Non_or_Elective*10 + cte.Duration = 13 then isnull(HE.[Combined day case / ordinary elective spell tariff (£)] + ((cte.epidur - He.[Ordinary elective long stay trim point (days)]))*He.[Per day long stay payment (for days exceeding trim point) (£)],0) -- if the say between the two
		when cte.Non_or_Elective*10 + cte.Duration = 14 then isnull(HE.[Reduced short stay emergency tariff (£)],HE.[Combined day case / ordinary elective spell tariff (£)]) -- for short stay emergency caculator
		when cte.Non_or_Elective*10 + cte.Duration = 15 then -- this caculation if it is a day case 
			case 
				when isnull(He.[Day case spell tariff (£)],isnull((HE.[Combined day case / ordinary elective spell tariff (£)]), 0)) = 0 then isnull((HE.[Combined day case / ordinary elective spell tariff (£)]), 0)
				else isnull(He.[Day case spell tariff (£)],isnull((HE.[Combined day case / ordinary elective spell tariff (£)]), 0))
			end
		when cte.Non_or_Elective*10 + cte.Duration = 16 then isnull(HE.[Combined day case / ordinary elective spell tariff (£)],0) -- this get the non day cases 

		-- this group for the non elective spells, same set as above
		when cte.Non_or_Elective*10 + cte.Duration = 21 then He.[Non-elective spell tariff (£)] 
		when cte.Non_or_Elective*10 + cte.Duration = 22 then 
			case 
				when  He.[Non-elective spell tariff (£)]  + (cte.epidur - He.[Non-elective long stay trim point (days)])*He.[Per day long stay payment (for days exceeding trim point) (£)] <0 then (HE.[Non-elective spell tariff (£)] + (-cte.epidur + He.[Non-elective long stay trim point (days)])*He.[Per day long stay payment (for days exceeding trim point) (£)])
				else isnull(HE.[Non-elective spell tariff (£)]  + (cte.epidur - He.[Non-elective long stay trim point (days)])*He.[Per day long stay payment (for days exceeding trim point) (£)],0)
			end
		when cte.Non_or_Elective*10 + cte.Duration = 23 then isnull(He.[Non-elective spell tariff (£)],0)
		when cte.Non_or_Elective*10 + cte.Duration = 24 then isnull(HE.[Reduced short stay emergency tariff (£)],[Non-elective spell tariff (£)])  
		when cte.Non_or_Elective*10 + cte.Duration = 25 then 
			case 
				when isnull(HE.[Outpatient procedure tariff (£)],0) = 0 then isnull(He.[Non-elective spell tariff (£)],0)
				else isnull(HE.[Outpatient procedure tariff (£)],0) 
			end
		when cte.Non_or_Elective*10 + cte.Duration = 26 then isnull(He.[Non-elective spell tariff (£)],0)
	end Tariff_cost_2017

	into dbo.temp_2017_2a5d4789
from cte
	inner join '+ @Traff_2017 +' HE
		on cte.[HRG code] = HE.[HRG code]

;with cte as (
select 
	D.hesid
	,He.[HRG code]
	,D.episode
	,D.epistart
	,D.epidur
	,D.admimeth
	,D.classpat
	,case 
		when left(admimeth,1) = 1 then 1 
		else 2
	 end Non_or_Elective
	 ,case 
		when D.epidur = 0 and D.classpat = 2 then 5
		when D.epidur = 0 and D.classpat <> 2 then 6
		when D.epidur < 2 then 4
		when D.epidur <= HE.[Ordinary elective long stay trim point (days)] then 1 
		when D.epidur >= HE.[Ordinary elective long stay trim point (days)] and D.epidur <= HE.[Non-elective long stay trim point (days)] then 3 
		else 2
	 end Duration
from '+ @file +' D
	inner join ' + @Traff_2018 +' HE
		on D.HRG_code = HE.[HRG code]
)
select 
	cte.hesid Hesid_2018
	,cte.epistart epistart_2018
	,cte.Non_or_Elective*10 + cte.Duration type_cost_applied_2018 
	,case 
		-- this group if for tehe elective spells 
		when cte.Non_or_Elective*10 + cte.Duration = 11 then isnull((HE.[Combined day case / ordinary elective spell tariff (£)]), 0) -- Normal cost
		when cte.Non_or_Elective*10 + cte.Duration = 12 then  -- Add if stay a longer duration 
			case 
				when  HE.[Combined day case / ordinary elective spell tariff (£)] + (cte.epidur - He.[Ordinary elective long stay trim point (days)]*1)*He.[Per day long stay payment (for days exceeding trim point) (£)] <0 then (HE.[Combined day case / ordinary elective spell tariff (£)] + (-cte.epidur + He.[Ordinary elective long stay trim point (days)]*1)*He.[Per day long stay payment (for days exceeding trim point) (£)])
				else isnull(HE.[Combined day case / ordinary elective spell tariff (£)] + (cte.epidur - He.[Ordinary elective long stay trim point (days)]*1)*He.[Per day long stay payment (for days exceeding trim point) (£)],0)
			end
		when cte.Non_or_Elective*10 + cte.Duration = 13 then isnull(HE.[Combined day case / ordinary elective spell tariff (£)] + ((cte.epidur - He.[Ordinary elective long stay trim point (days)]))*He.[Per day long stay payment (for days exceeding trim point) (£)],0) -- if the say between the two
		when cte.Non_or_Elective*10 + cte.Duration = 14 then isnull(HE.[Reduced short stay emergency tariff (£)],HE.[Combined day case / ordinary elective spell tariff (£)]) -- for short stay emergency caculator
		when cte.Non_or_Elective*10 + cte.Duration = 15 then -- this caculation if it is a day case 
			case 
				when isnull(He.[Day case spell tariff (£)],isnull((HE.[Combined day case / ordinary elective spell tariff (£)]), 0)) = 0 then isnull((HE.[Combined day case / ordinary elective spell tariff (£)]), 0)
				else isnull(He.[Day case spell tariff (£)],isnull((HE.[Combined day case / ordinary elective spell tariff (£)]), 0))
			end
		when cte.Non_or_Elective*10 + cte.Duration = 16 then isnull(HE.[Combined day case / ordinary elective spell tariff (£)],0) -- this get the non day cases 

		-- this group for the non elective spells, same set as above
		when cte.Non_or_Elective*10 + cte.Duration = 21 then He.[Non-elective spell tariff (£)] 
		when cte.Non_or_Elective*10 + cte.Duration = 22 then 
			case 
				when  He.[Non-elective spell tariff (£)]  + (cte.epidur - He.[Non-elective long stay trim point (days)])*He.[Per day long stay payment (for days exceeding trim point) (£)] <0 then (HE.[Non-elective spell tariff (£)] + (-cte.epidur + He.[Non-elective long stay trim point (days)])*He.[Per day long stay payment (for days exceeding trim point) (£)])
				else isnull(HE.[Non-elective spell tariff (£)]  + (cte.epidur - He.[Non-elective long stay trim point (days)])*He.[Per day long stay payment (for days exceeding trim point) (£)],0)
			end
		when cte.Non_or_Elective*10 + cte.Duration = 23 then isnull(He.[Non-elective spell tariff (£)],0)
		when cte.Non_or_Elective*10 + cte.Duration = 24 then isnull(HE.[Reduced short stay emergency tariff (£)],[Non-elective spell tariff (£)])  
		when cte.Non_or_Elective*10 + cte.Duration = 25 then 
			case 
				when isnull(HE.[Outpatient procedure tariff (£)],0) = 0 then isnull(He.[Non-elective spell tariff (£)],0)
				else isnull(HE.[Outpatient procedure tariff (£)],0) 
			end
		when cte.Non_or_Elective*10 + cte.Duration = 26 then isnull(He.[Non-elective spell tariff (£)],0)
	end Tariff_cost_2018
	into dbo.temp_2018_39a75t123
from cte
	inner join ' + @Traff_2018 +' HE
		on cte.[HRG code] = HE.[HRG code]


select 
	Hesid
	,[HRG code]
	,epistart
	,epidur
	,type_cost_applied_2017
	,Tariff_cost_2017
	,type_cost_applied_2018
	,Tariff_cost_2018
	,TU.Tariff_cost_2018 - TL.Tariff_cost_2017 Tariff_differnce
	,round(TU.Tariff_cost_2018/(TL.Tariff_cost_2017 + 0.000001),4) Tariff_ratio
 from dbo.temp_2017_2a5d4789 TL
	inner join  dbo.temp_2018_39a75t123 TU
		on TL.hesid = TU.Hesid_2018 and Tl.epistart = TU.epistart_2018 '

EXEC(@sqlcommand)
-- drop the tem table that where created
if object_ID('dbo.temp_2017_2a5d4789') is not null 
	begin 
		drop table dbo.temp_2017_2a5d4789
	end
if object_ID('dbo.temp_2018_39a75t123') is not null 
	begin 
		drop table dbo.temp_2018_39a75t123
	end
