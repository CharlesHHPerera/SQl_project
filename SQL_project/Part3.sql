------------------------------------- info-----------------------------------------
---- Name ---------- Part 3 - SQL project -----------------------------------------
---- Funcation ----- To caculation of the Traiff of a HSE data set with HRG codes--
---- Create by ----- Charles Perera -----------------------------------------------
---- Company ------- Kubrick group ------------------------------------------------
---- Date Created -- 21/02/2019 ---------------------------------------------------
--------------------------------------info-----------------------------------------

/******************************************** 2017 calculator ************************/ 

go -- this is the Tariff_cost for 2017  
alter Function HRG.Tariff_cacluator_2017 () -- this is same as question 1 fucation but change to look at full table
returns table 
as
return(
with cte as (
select -- this look in doing this for a table
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
from [Rands].[HSe_with_HRG] D -- this join to the seach table. 
	inner join HRG.Traff_2017_2018 HE
		on D.HRG_code = HE.[HRG code]
)
select 
	cte.hesid
	,cte.[HRG code]
	,cte.episode 
	,cte.epistart
	,cte.epidur
	,cte.Non_or_Elective*10 + cte.Duration type_cost_applied 
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


from cte
	inner join HRG.Traff_2017_2018 HE
		on cte.[HRG code] = HE.[HRG code]
)

	
/******************************** 2018 hisid caclualtor *******************/ 
go


create Function HRG.Tariff_cacluator_2018 () -- this same fucation as above but there change of look at table
returns table 
as
return(
with cte as (
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
from [Rands].[HSe_with_HRG] D
	inner join HRG.Traff_2018_2019 HE -- this change of a table to look at 
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
from cte
	inner join HRG.Traff_2018_2019 HE -- do the caclautions 
		on cte.[HRG code] = HE.[HRG code]
)


/*************************** Join of 2 yeaer and anyalsis *****************************************/


go
create proc usp_Hesid_cost_on_HSE_data -- this is just to run it all for the systeam and do some basic anylsis on a data set
as
select *
	,TU.Tariff_cost_2018 - TL.Tariff_cost_2017 Tariff_differnce -- this is look at the diffence 
	,round(TU.Tariff_cost_2018/(TL.Tariff_cost_2017 + 0.000001),4) Tariff_ratio -- this is basic anylsis to lkook at the % incrase
 from HRG.Tariff_cacluator_2017 () TL
	left join HRG.Tariff_cacluator_2018 () TU
		on TL.hesid = TU.Hesid_2018 and Tl.epistart = TU.epistart_2018


/**************** test of question 3 **********************/ 

exec usp_Hesid_cost_on_HSE_data

















