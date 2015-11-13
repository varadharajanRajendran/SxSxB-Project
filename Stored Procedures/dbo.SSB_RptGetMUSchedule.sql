SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SSB_RptGetMUSchedule]		
 AS

SELECT 
	   [JobID]						as 'OrderNo'	,
	   [SKUNo]						as 'SKU'		,
	   [Product]					as 'SKUDesc'	,
       [UnitSize]					as 'UnitSize'	,
	   ISNULL([L1PDesc],'')		as 'L1Desc'		,
	   ISNULL([L2PDesc],'')        as 'L2Desc'		,
	   ISNULL([L3PDesc],'')		as 'L3Desc'		,
	   ISNULL([L4PDesc],'')		as 'L4Desc'		
  FROM [SSB].[dbo].[MES2LC]
  ORDER BY [EstSeq] , [JobID] ASC
GO
