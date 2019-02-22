------------------------------------- info-----------------------------------------
---- Name ---------- Pand_HRG_HSE - SQL project -----------------------------------
---- Funcation ----- join HSe and HRG with Radom data  ----------------------------
---- Create by ----- Charles Perera -----------------------------------------------
---- Company ------- Kubrick group ------------------------------------------------
---- Date Created -- 20/02/2019 ---------------------------------------------------
--------------------------------------info-----------------------------------------
use Heatlth
go 

-- rand join HRG and People

select * 
	,ROW_NUMBER() over (order by [HRG code]) Rownumber -- this rank the row number of HRG number 
--	into Rands.HRG_code -- put into table
from [HRG].[Traff_2017_2018]

Select *
	,abs(checksum(dbo.myfunction())) %2303 as Rands -- this then add Rand number on end of HSE data what the number of HRG codes
--	into Rands.HSE_data -- put into to a table
from HSe.Facts F

go
create view vw_View_export as 
-- this then just join the HRG rownumber with the HSE radoms numbers to produce an output
with cte as (
select *
from Rands.HSE_data S
	inner join Rands.HRG_code H
		on S.Rands = H.Rownumber
)
select * 
	,First_value([HRG code]) over (partition by hesid order by episode) HRG_code
from cte 

-- just check the view was create full 
select * 
from vw_View_export

USE [Heatlth]
GO

-- this create and insear the data into a table once that been created 

CREATE TABLE [Rands].[HSe_with_HRG](
	[spell] [int] NULL,
	[episode] [int] NULL,
	[epistart] [date] NULL,
	[epiend] [date] NULL,
	[epitype] [int] NULL,
	[sex] [int] NULL,
	[bedyear] [int] NULL,
	[epidur] [int] NULL,
	[epistat] [int] NULL,
	[spellbgin] [int] NULL,
	[activage] [int] NULL,
	[admiage] [int] NULL,
	[admincat] [int] NULL,
	[admincatst] [int] NULL,
	[category] [int] NULL,
	[dob] [date] NULL,
	[endage] [int] NULL,
	[ethnos] [varchar](2) NULL,
	[hesid] [bigint] NULL,
	[leglcat] [int] NULL,
	[lopatid] [bigint] NULL,
	[newnhsno] [bigint] NULL,
	[newnhsno_check] [varchar](1) NULL,
	[startage] [int] NULL,
	[admistart] [date] NULL,
	[admimeth] [varchar](2) NULL,
	[admisorc] [int] NULL,
	[elecdate] [date] NULL,
	[elecdur] [int] NULL,
	[elecdur_calc] [int] NULL,
	[classpat] [int] NULL,
	[diag_01] [varchar](6) NULL,
	[numepisodesinspell] [int] NULL,
	[HRG_code] [char](5) NULL
) 
INSERT INTO [Rands].[HSe_with_HRG]
           ([spell]
           ,[episode]
           ,[epistart]
           ,[epiend]
           ,[epitype]
           ,[sex]
           ,[bedyear]
           ,[epidur]
           ,[epistat]
           ,[spellbgin]
           ,[activage]
           ,[admiage]
           ,[admincat]
           ,[admincatst]
           ,[category]
           ,[dob]
           ,[endage]
           ,[ethnos]
           ,[hesid]
           ,[leglcat]
           ,[lopatid]
           ,[newnhsno]
           ,[newnhsno_check]
           ,[startage]
           ,[admistart]
           ,[admimeth]
           ,[admisorc]
           ,[elecdate]
           ,[elecdur]
           ,[elecdur_calc]
           ,[classpat]
           ,[diag_01]
           ,[numepisodesinspell]
           ,[HRG_code])
 (
SELECT [spell]
      ,[episode]
      ,[epistart]
      ,[epiend]
      ,[epitype]
      ,[sex]
      ,[bedyear]
      ,[epidur]
      ,[epistat]
      ,[spellbgin]
      ,[activage]
      ,[admiage]
      ,[admincat]
      ,[admincatst]
      ,[category]
      ,[dob]
      ,[endage]
      ,[ethnos]
      ,[hesid]
      ,[leglcat]
      ,[lopatid]
      ,[newnhsno]
      ,[newnhsno_check]
      ,[startage]
      ,[admistart]
      ,[admimeth]
      ,[admisorc]
      ,[elecdate]
      ,[elecdur]
      ,[elecdur_calc]
      ,[classpat]
      ,[diag_01]
      ,[numepisodesinspell]
      ,[HRG_code]
	  into Rands.HSe_with_HRG
  FROM [dbo].[vw_View_export]
)






