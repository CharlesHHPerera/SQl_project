------------------------------------- info-----------------------------------------
---- Name ---------- Part 1 - SQL project -----------------------------------------
---- Funcation ----- Create a SP to work out Traiff cost form input  --------------
---- Create by ----- Charles Perera -----------------------------------------------
---- Company ------- Kubrick group ------------------------------------------------
---- Date Created -- 21/02/2019 ---------------------------------------------------
--------------------------------------info-----------------------------------------
use Heatlth
go

/******************************* 2017 stored proce ************/
go -- this is the Tariff_cost for 2017  
-- funcation for the 2017 tariff caculaator, 
create Function HRG.usp_Tariff_cost_cacluator_2017 (@HRG char(5),@Epidur_number int,@classpat_number int,@adimeth_code varchar(2))
returns table 
as
return(
with cte as (
select -- these our the factor that been inputed 
	@HRG [HRG code]
	,@Epidur_number epidur
	,@classpat_number classpat
	,@adimeth_code admimeth
	,case -- this work out the entery method
		when left(@adimeth_code,1) = 1 then 1 
		else 2
	 end Non_or_Elective
	 ,case -- this case to work out out the length stayed and give a number to it
		when @Epidur_number = 0 and @classpat_number = 2 then 5 -- this for a non day case 
		when @Epidur_number = 0 and @classpat_number <> 2 then 6 -- this work if is a day case 
		when @Epidur_number < 2 then 4 -- this is emergy short stay applies 
		when @Epidur_number <= HE.[Ordinary elective long stay trim point (days)] then 1 -- this is for normal applies  
		when @Epidur_number >= HE.[Ordinary elective long stay trim point (days)] and @Epidur_number <= HE.[Non-elective long stay trim point (days)] then 3 -- this is difference between non and normal
		else 2 -- this if not match that it work they stayed longer
	 end Duration
from  HRG.Traff_2017_2018 HE
where [HRG code] = @HRG
)
select -- form the select above they give code and then when case for of the code, to work what need to be produced 
	cte.[HRG code] 
	,cte.epidur
	,classpat
	,admimeth
	,cte.Non_or_Elective*10 + cte.Duration type_cost_applied -- this show the type of cost applied
	,case 
		-- this group if for the elective speel
		when cte.Non_or_Elective*10 + cte.Duration = 11 then isnull((HE.[Combined day case / ordinary elective spell tariff (£)]), 0) -- Normal cost
		when cte.Non_or_Elective*10 + cte.Duration = 12 then  -- Add if stay a longer duration 
			case -- secound case to compare if longer or shorter for elective and non eleective
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
	end Tariff_cost
	,2017 Year_applied -- this add a year_applied filed

from cte
	inner join HRG.Traff_2017_2018 HE
		on cte.[HRG code] = HE.[HRG code]
)



-- run stored procedure


/*************** this for 2018 *************************************************************/

go -- this is the Tariff_cost for 2018 
alter Function HRG.usp_Tariff_cost_cacluator_2018 (@HRG char(5),@Epidur_number int,@classpat_number int,@adimeth_code varchar(2))
returns table 
as
return(
	with cte as (
select -- this use the same logical as for the 2017 and have not commited it but would if had more time. 
	@HRG [HRG code]
	,@Epidur_number epidur
	,@classpat_number classpat
	,@adimeth_code admimeth
	,case 
		when left(@adimeth_code,1) = 1 then 1 
		else 2
	 end Non_or_Elective
	 ,case 
		when @Epidur_number = 0 and @classpat_number = 2 then 5
		when @Epidur_number = 0 and @classpat_number <> 2 then 6
		when @Epidur_number < 2 then 4
		when @Epidur_number <= HE.[Ordinary elective long stay trim point (days)]  then 1 
		when @Epidur_number >= HE.[Ordinary elective long stay trim point (days)] and @Epidur_number <= HE.[Non-elective long stay trim point (days)] then 3 
		else 2
	 end Duration
from  HRG.Traff_2018_2019 HE
where [HRG code] = @HRG
)
select 
	cte.[HRG code] 
	,cte.epidur
	,classpat
	,admimeth
	,cte.Non_or_Elective*10 + cte.Duration type_cost_applied 
	,case 
		-- this group if for tehe elective spells 
		when cte.Non_or_Elective*10 + cte.Duration = 11 then isnull((HE.[Combined day case / ordinary elective spell tariff (£)]), 0) -- Normal cost
		when cte.Non_or_Elective*10 + cte.Duration = 12 then  -- Add if stay a longer duration 
			case 
				when  HE.[Combined day case / ordinary elective spell tariff (£)] + (cte.epidur - He.[Ordinary elective long stay trim point (days)])*He.[Per day long stay payment (for days exceeding trim point) (£)] <0 then (HE.[Combined day case / ordinary elective spell tariff (£)] + (-cte.epidur - He.[Ordinary elective long stay trim point (days)]*1)*He.[Per day long stay payment (for days exceeding trim point) (£)])
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
	end Tariff_cost
	,2018 Year_applied 
	--into dbo.temp
from cte
	inner join HRG.Traff_2018_2019 HE
		on cte.[HRG code] = HE.[HRG code]
)


-- test


/****************** joing of the years ********************************/ 

go 
-- this is to create the top level Stored proce 
alter proc usp_Tariff_cost_cacluator
@HRG char(5)
,@Epidur_number int
,@classpat_number int
,@adimeth_code varchar(2)
,@year_applied int
as
if @HRG not like '[A-Z]%'+ '[A-Z]%' + '[0-9]%' + '[0-9]%' + '[A-Z]%' -- this check type HRG code is correct
	begin 
	print 'Input a correct HRG code must be format AA22C'
	return 
	end 

if @year_applied <>2017 and @year_applied <> 2018 -- 
	begin 
	set @year_applied = 2017
	print 'calculated for 2017, year not recognice'
	end

declare @flags int 
select 
	 @flags = count([HRG code]) 
from HRG.Traff_2017_2018
where [HRG code] = @HRG 
if @flags <> 1 
	begin
		print 'HRG Code not found Example AA22C' 
		return 
	end 

if OBJECT_ID('dbo.temp') is not null 
	begin 
		drop table dbo.temp
	end 
if @year_applied = '2017'
	begin 
	select * from HRG.usp_Tariff_cost_cacluator_2017(@HRG ,@Epidur_number ,@classpat_number,@adimeth_code)
	end
if @year_applied = '2018'
	begin 
	select * from HRG.usp_Tariff_cost_cacluator_2018(@HRG ,@Epidur_number ,@classpat_number,@adimeth_code)
	end
--select * from dbo.temp


-- testing the SP
go
exec usp_Tariff_cost_cacluator 'AA22C',10,1,'2A',2017


/********************************* testng section ****************************/

go 
select * from HRG.usp_Tariff_cost_cacluator_2017('AA22C',5,1,'2A') -- this was a test 2017 
go 
select * from HRG.usp_Tariff_cost_cacluator_2018('AA22C',5,1,'2A') -- test for the 2018 



/****************** create type_cost_applie table ******/ 
-- this is to create a table that show the type_cost_applied_ID means
--if OBJECT_ID('Type_cost_applied') is not null 
--	begin 
--		drop table Type_cost_applied 
--	end 

--create table Type_cost_applied 
--(
--Type_IDs int
--,Elective varchar(100) 
--,Case_applied varchar(1000)
--)
--insert Type_cost_applied 
--(Type_IDs,Elective,Case_applied)
--values 
--(11,'Elective Spell','Ordinary Spell Tariff(£) Applied'),
--(12,'Elective Spell','Ordinary Spell Tariff(£) with Long stay Tariff Applied '),
--(13,'Elective Spell','Ordinary Spell Tariff(£) with Long stay Tariff Applied Shorter than Non elective stay'),
--(14,'Elective Spell','Tariff(£) Applied with Reduce short stay'),
--(15,'Elective Spell','Day Care Tariff(£) Applied'),
--(16,'Elective Spell','Ordinary Spell Tariff(£) Applied without staying'),
--(21,'NON-Elective Spell','Non-elective Spell Tariff(£) Applied'),
--(22,'NON-Elective Spell','Non-elective Spell Tariff(£) Applied with Long stay Tariff Applied'),
--(23,'NON-Elective Spell','Non-elective Spell Tariff(£) Applied with Long stay Tariff Applied Shorter than Ordinary spell'),
--(24,'NON-Elective Spell','Reduce short stay with Non-elective Spell Tariff(£) Applied'),
--(25,'NON-Elective Spell','Day Care Tariff(£) for Non-elective Spell Tariff(£) Applied'),
--(26,'NON-Elective Spell','Non-elective Day Care Tariff(£) Applied without staying')

--select *
--from Type_cost_applied 

