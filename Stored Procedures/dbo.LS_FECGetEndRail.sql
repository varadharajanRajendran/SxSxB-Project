SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[LS_FECGetEndRail]
AS

SELECT [ItemClass],
		[PartNo] ,
		[Description],
		[UoM],
		[StorageLocation],
		UnitSize,
		CONVERT(int,ISNULL([1],0)) as '1', 
		CONVERT(int,ISNULL([2],0)) as '2', 
		CONVERT(int,ISNULL([3],0)) as '3', 
		CONVERT(int,ISNULL([4],0)) as '4', 
		CONVERT(int,ISNULL([5],0)) as '5', 
		CONVERT(int,ISNULL([6],0)) as '6',  
		CONVERT(int,ISNULL([7],0)) as '7', 
		CONVERT(int,ISNULL([8],0)) as '8',
		CONVERT(int,ISNULL([9],0)) as '9', 
		CONVERT(int,ISNULL([10],0)) as '10', 
		CONVERT(int,ISNULL([11],0)) as '11', 
		CONVERT(int,ISNULL([12],0)) as '12', 
		CONVERT(int,ISNULL([13],0)) as '13', 
		CONVERT(int,ISNULL([14],0)) as '14',  
		CONVERT(int,ISNULL([15],0)) as '15', 
		CONVERT(int,ISNULL([16],0)) as '16'
FROM 
(SELECT [GroupID]
      ,[ItemClass]
      ,[PartNo]
      ,[Description]
      ,Qty
      ,[UoM]
      ,[StorageLocation]
      ,RIGHT([PartNo],2) as UnitSize
  FROM [SSB].[dbo].[LSMaterialRequest]
  Where ProdCell='FEC'
	AND ( [Description] LIKE '%END%'
	OR [Description] LIKE '%WIDTH%')) p
PIVOT
(
SUM([Qty]) 
FOR GroupID IN
( [1], [2], [3], [4], [5],[6], [7], [8],[9], [10], [11], [12], [13],[14], [15], [16] )
) AS pvt
 GROUP BY pvt.ItemClass,pvt.PartNo,pvt.[Description],pvt.UoM,pvt.StorageLocation,pvt.UnitSize,pvt.[1],pvt.[2],pvt.[3],pvt.[4],pvt.[5],pvt.[6],pvt.[7],pvt.[8],pvt.[9],pvt.[10],pvt.[11],pvt.[12],pvt.[13],pvt.[14],pvt.[15],pvt.[16]
GO
