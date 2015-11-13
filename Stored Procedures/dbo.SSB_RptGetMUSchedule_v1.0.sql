SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SSB_RptGetMUSchedule_v1.0]		
 AS

SELECT ''				as 'Group'			,
	   ''				as 'Sequence'		,
	   [Job_ID]			as 'OrderID'		,
	   [SKU_No]			as 'SKU'			,
	   [Product]		as 'Description'	,
       [Unit_Size]		as 'UnitSize'		,
	   [L1_PDesc]		as 'Layer1Desc'		,
	   [L1_Loc]			as 'L1PLoc'			,
	   [L2_PDesc]       as 'Layer2Desc'		,
	   [L2_Loc]			as 'L2PLoc'			,
	   [L3_PDesc]		as 'Layer3Desc'		,
	   [L3_Loc]			as 'L3PLoc'			,
	   [L4_PDesc]		as 'Layer4Desc'		,
	   [L4_Loc]			as 'L4PLoc'			
  FROM [SSB].[dbo].[MES2LC]
  ORDER BY [EstTime] ASC
GO
