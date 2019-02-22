------------------------------------- info-----------------------------------------
---- Name ---------- Part 2 - SQL project -----------------------------------------
---- Funcation ----- To create a view for Tableau for both Radar and Tables -------
---- Create by ----- Charles Perera -----------------------------------------------
---- Company ------- Kubrick group ------------------------------------------------
---- Date Created -- 19/02/2019 ---------------------------------------------------
--------------------------------------info-----------------------------------------

/********************** question 2 *******************/ 
 --this create a union file with extrantion in tableau for viewning 

/************************* create view for tabuol ***************************/

go 
-- check if the view excetis or not
if OBJECT_ID('Vw_HRG_Tablo') is not null 
	begin 
	drop view Vw_HRG_Tablo 
	end 

create view Vw_HRG_Tablo
as 

with cte as ( -- createa cte to look at the change and ratio then to feed into a selct to vewi it
select 
	TE.[HRG code]
	,case 
		when TL.[Non-elective spell tariff (£)] = 0 then TL.[Non-elective spell tariff (£)] 
		else TL.[Non-elective spell tariff (£)]/TE.[Non-elective spell tariff (£)]
	end Ratio_NON -- Ration of the cobimed days

	,case 
		when isnull(TL.[Combined day case / ordinary elective spell tariff (£)],'0') = 0 then ((Tl.[Day case spell tariff (£)]+TL.[Ordinary elective long stay trim point (days)])/2)/((TE.[Day case spell tariff (£)]+TE.[Ordinary elective long stay trim point (days)])/2)
		else TL.[Combined day case / ordinary elective spell tariff (£)]/TE.[Combined day case / ordinary elective spell tariff (£)]
	end Ratio_Planed -- ratio of the combin days

from HRG.Traff_2017_2018 TE -- join of the two data set 
	inner join HRG.Traff_2018_2019	TL 
		on TE.[HRG code] = TL.[HRG code]
)
select 
	CTE.[HRG code]
	,TE.[HRG name] HRG_name
	,case 
		when TE.[Combined day case / ordinary elective spell tariff (£)]  is null then ((TE.[Day case spell tariff (£)]+TE.[Ordinary elective long stay trim point (days)])/2)
		else TE.[Combined day case / ordinary elective spell tariff (£)] 
	end Combined_2017
	,Case 
		when TL.[Combined day case / ordinary elective spell tariff (£)] is null then ((Tl.[Day case spell tariff (£)]+TL.[Ordinary elective long stay trim point (days)])/2)
		else TL.[Combined day case / ordinary elective spell tariff (£)]
	end Combined_2018
	,CTe.Ratio_Planed
	,Tl.[Ordinary elective long stay trim point (days)]
	,TE.[Non-elective spell tariff (£)] NON_2017 
	,Tl.[Non-elective spell tariff (£)] non_2018
	,cte.Ratio_NON 
	,TE.[Non-elective long stay trim point (days)]
	,TE.[Per day long stay payment (for days exceeding trim point) (£)]
	,HN.[HRG Chapter Description]
	,HN.[HRG Subchapter Description]
	,HN.[HRG Root Decriptions]
	,HN.[HRG Root END Decriptions]
from cte -- rejoin them know could use the CTe but this make clear what is being produced
	inner join HRG.Traff_2017_2018 TE
		on Cte.[HRG code] = TE.[HRG code]
	inner join HRG.Traff_2018_2019 TL
		on Cte.[HRG code] = TL.[HRG code]
	inner join HRG.HRG_name_drop HN
		on cte.[HRG code] = HN.HRG_ID

select * 
from Vw_HRG_Tablo

/****************** Create a rader map ***************************/ 
if OBJECT_ID('HRG.Radar') is not null 
	begin 
	drop view HRG.Radar
	end 


;with cte as ( 

Select distinct -- this avg all of the 5 area used for the radar map. 
	[HRG Chapter Description]
	,AVG([Combined_2018] - Combined_2017) over (partition by [HRG Chapter Description]) Ratio
	,COUNT([Combined_2018]) over (partition by [HRG Chapter Description]) Number
	,AVG([Combined_2018]) over (partition by [HRG Chapter Description]) COm
	,AVG([non_2018]) over (partition by [HRG Chapter Description]) NON 
	,AVG([Ordinary elective long stay trim point (days)]) over (partition by [HRG Chapter Description]) DayL
	,AVG([Per day long stay payment (for days exceeding trim point) (£)]) over (partition by [HRG Chapter Description]) CostO
from Vw_HRG_Tablo
) 
select -- this is ranking of all the chapter compare to avg 
	[HRG Chapter Description]
	,RANK() over (order by [Ratio] asc ) Ratio
	,Ratio/Number Ratio_number
	,RANK() over (order by COm asc ) Combined_day_case
	,COm Elective_case
	,RANK() over (order by NON  asc ) Non_Elective
	,NON Non_elective_value
	,RANK() over (order by DayL asc ) Day_length_elective
	,DayL Trim_day 
	,RANK() over (order by CostO asc ) Extened_Cost_per_day
	,CostO Length_cost
	into HRG.Radar --put into a table for use later in a view
from cte 

go 

-- this is secound view that is need for the radar grpah. need have creat if frist time run
alter view Vw_HRG_Radar 
as 
with Cte as (
select 
	[HRG Chapter Description]
	,'Diffince 2017 to 2018 case (£)' Name
	,Ratio_number*100 value 
	,cast(0 as float) X
	,cast(Ratio *10 as Float) Y
	,RANK() over (order by Ratio) Rustles
	, 1 point
from HRG.Radar
union all
select 
	[HRG Chapter Description]
	,'Elective case (£)' Name -- this break name for filtering later
	,Elective_case value
	,cast(Combined_day_case*10*sin(1.23) as float) X -- this work out the angle and check the format
	,cast(Combined_day_case*10*cos(1.23) as float) Y -- this make the y location
	,RANK() over (order by Combined_day_case) Rustles
	,2 point -- this for the type of point that be used=
from HRG.Radar
union all
select 
	[HRG Chapter Description]
	,'Non Elective case (£)' Name
	,Non_elective_value value 
	,cast(Non_Elective*10*cos(0.975) as float) X
	,cast(-Non_Elective*10*sin(0.975) as float) Y
	,RANK() over (order by Non_Elective) Rustles
	,3 point
from HRG.Radar
union all
select 
	[HRG Chapter Description]
	,'Trim Length of Case (Days)' Name
	,Trim_day Value
	,cast(-Day_length_elective*10*cos(0.975) as float) X
	,cast(-Day_length_elective*10*sin(0.975) as float) Y
	,RANK() over (order by Day_length_elective) Rustles
	,4 point
from HRG.Radar
union all 
select 
	[HRG Chapter Description]
	,'Extened Cost per day (£)' Name
	,Length_cost value
	,cast(-Day_length_elective*10*sin(1.23) as float) X
	,cast(Day_length_elective*10*cos(1.23) as float) Y
	,RANK() over (order by Day_length_elective) Rustles
	,5 point
from HRG.Radar
union all 
select 
	[HRG Chapter Description]
	,'Diffince 2017 to 2018 case (£)' Name
	,Ratio_number*100 value 
	,cast(0 as float) X
	,cast(Ratio *10 as Float) Y
	,RANK() over (order by Ratio) Rustles
	, 7 point
from HRG.Radar
)
select -- this is to trim the data and pick what be send to tabbleau 
	[HRG Chapter Description]
	,Name
	,value
	,(ROUND(x,2)/10) -0.15 X
	,(ROUND(y,2)/10)-1.6 Y
	,Rustles
	,point
from cte


select * from Vw_HRG_Radar 
